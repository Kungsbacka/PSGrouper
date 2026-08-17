param (
    [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
    [Parameter(Mandatory=$true,Position=0)]
    [string]$GrouperLibPath,
    [ValidateSet('Debug','Release')]
    [Parameter(Mandatory=$false,Position=1)]
    [string]$BuildType = 'Release',
    [Parameter(Mandatory=$false)]
    [string]$LogFilePath = "$PSScriptRoot\build.log"
)

function Execute-Step {
    param (
        [string]$StepName,
        [scriptblock]$Action
    )
    try {
        Write-Host "${StepName}..." -NoNewline
        & $Action *>&1 | Out-File -FilePath $LogFilePath -Append
        Write-Host "ok!" -ForegroundColor Green
    } catch {
        Write-Host "failed!" -ForegroundColor Red
        $_ | Out-File -FilePath $LogFilePath -Append
        exit 1
    }
}

# Publishes a project into a throwaway folder and copies out only the files it is asked for.
# Going through a staging folder rather than reading the project's own bin folder means output
# left over from an earlier build cannot reach the module, and naming the files keeps the lib
# folder down to what the manifest actually loads.
function Copy-PublishedFiles {
    param (
        [string]$Project,
        [string]$Configuration,
        [string[]]$Files,
        [string]$Destination,
        [string[]]$PublishArguments = @()
    )
    if (!(Test-Path -Path $Project)) {
        throw "Project not found at $Project."
    }
    $stagePath = Join-Path ([System.IO.Path]::GetTempPath()) "PSGrouperBuild_$([Guid]::NewGuid().ToString('n'))"
    try {
        & dotnet publish $Project --configuration $Configuration --output $stagePath @PublishArguments
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to publish $Project."
        }
        foreach ($file in $Files) {
            $source = Join-Path $stagePath $file
            if (!(Test-Path -Path $source)) {
                throw "$file was not produced by $Project."
            }
            $targetDirectory = Split-Path -Path (Join-Path $Destination $file) -Parent
            if (!(Test-Path -Path $targetDirectory)) {
                $null = New-Item -ItemType Directory -Path $targetDirectory
            }
            Copy-Item -Path $source -Destination $targetDirectory
        }
    }
    finally {
        if (Test-Path -Path $stagePath) {
            Remove-Item -Path $stagePath -Recurse -Force
        }
    }
}

# The GrouperLib entries in the manifest's RequiredAssemblies, and nothing else. The Swedish
# satellite assembly keeps its culture folder, because that is how the runtime finds it. The
# publish also produces .pdb files and a deps.json that the module never reads, and those stay
# behind in the staging folder.
function Copy-GrouperLibAssemblies {
    param (
        [string]$GrouperLibPath,
        [string]$Destination,
        [string]$Configuration = 'Release',
        [switch]$IncludeSymbols
    )
    $files = @(
        'GrouperLib.Core.dll'
        'GrouperLib.Language.dll'
        'sv\GrouperLib.Language.resources.dll'
    )
    # Symbols are the one thing a debug build wants and a release build does not, because they are
    # what turns a stack trace from GrouperLib into line numbers.
    if ($IncludeSymbols) {
        $files += 'GrouperLib.Core.pdb'
        $files += 'GrouperLib.Language.pdb'
    }
    Copy-PublishedFiles -Project (Join-Path $GrouperLibPath 'GrouperLib.Core\GrouperLib.Core.csproj') `
        -Configuration $Configuration `
        -PublishArguments @('-r', 'win-x64', '-f', 'net10.0') `
        -Files $files `
        -Destination $Destination
}

# The assemblies that come from outside both repos, resolved from NuGet through the dependency
# project rather than checked in. That project also builds an empty assembly of its own, which
# is not part of the module.
function Copy-ThirdPartyAssemblies {
    param (
        [string]$Destination
    )
    Copy-PublishedFiles -Project (Join-Path $PSScriptRoot 'deps\PSGrouperDeps.csproj') `
        -Configuration 'Release' `
        -Files @('ICSharpCode.AvalonEdit.dll') `
        -Destination $Destination
}

"Build started at $(Get-Date)" | Out-File -FilePath $LogFilePath

$coreProject = Join-Path $GrouperLibPath 'GrouperLib.Core\GrouperLib.Core.csproj'
Execute-Step -StepName "Check GrouperLib.Core project" -Action {
    if (!(Test-Path -Path $coreProject)) {
        throw "GrouperLib.Core project not found at $coreProject."
    }
}

if ($BuildType -eq 'Debug') {
    $libPath = Join-Path $PSScriptRoot 'lib'
    # This lib folder belongs to the working copy rather than to a single build, so whatever an
    # earlier build left has to go. A file that is no longer produced would otherwise stay behind
    # and still be there to be loaded.
    Execute-Step -StepName "Reset lib directory" -Action {
        if (Test-Path -Path $libPath) {
            Remove-Item -Path (Join-Path $libPath '*') -Recurse -Force
        }
        else {
            New-Item -ItemType Directory -Path $libPath
        }
    }

    Execute-Step -StepName "Build & copy GrouperLib assemblies" -Action {
        Copy-GrouperLibAssemblies -GrouperLibPath $GrouperLibPath -Destination $libPath `
            -Configuration 'Debug' -IncludeSymbols
    }

    Execute-Step -StepName "Copy third-party assemblies" -Action {
        Copy-ThirdPartyAssemblies -Destination $libPath
    }

    exit 0
}

$manifest = Import-PowerShellDataFile -Path "$PSScriptRoot\PSGrouper.psd1"
Execute-Step -StepName "Read module version" -Action {
    if ($null -eq $manifest.ModuleVersion) {
        throw 'Failed to read module version.'
    }
}

$release = Join-Path $PSScriptRoot 'release'
$path = Join-Path $release $manifest.ModuleVersion
$zipPath = "$release\PSGrouper_$($manifest.ModuleVersion -replace '\.', '_').zip"

Execute-Step -StepName "Check if release already exists" -Action {
    if ((Test-Path -Path $path)) {
        throw "Release $manifest.ModuleVersion already exists."
    }
}

Execute-Step -StepName "Check if zip file already exists" -Action {
    if ((Test-Path -Path $zipPath)) {
        throw "Release $zipPath already exists."
    }
}

Execute-Step -StepName "Create release folders" -Action {
    if (!(Test-Path -Path $release)) {
        New-Item -ItemType Directory -Path $release
    }
    New-Item -ItemType Directory -Path $path
    New-Item -ItemType Directory -Path "$path\lib"
    New-Item -ItemType Directory -Path "$path\func"
}

Execute-Step -StepName 'Build & copy GrouperLib assemblies' -Action {
    Copy-GrouperLibAssemblies -GrouperLibPath $GrouperLibPath -Destination "$path\lib"
}

Execute-Step -StepName 'Copy third-party assemblies' -Action {
    Copy-ThirdPartyAssemblies -Destination "$path\lib"
}

Execute-Step -StepName "Copy module files" -Action {
    Copy-Item -Path "$PSScriptRoot\PSGrouper.psd1" -Destination $path
    Copy-Item -Path "$PSScriptRoot\PSGrouper.psm1" -Destination $path
    Copy-Item -Path "$PSScriptRoot\PSGrouper.Format.ps1xml" -Destination $path
    Copy-Item -Path "$PSScriptRoot\ApiHelpers.ps1" -Destination $path
    Copy-Item -Path "$PSScriptRoot\FunctionHelpers.ps1" -Destination $path
    Copy-Item -Path "$PSScriptRoot\LICENSE" -Destination $path
    Copy-Item -Path "$PSScriptRoot\README.md" -Destination $path
    Copy-Item -Path "$PSScriptRoot\func\*.*" -Destination "$path\func"
}

Execute-Step -StepName "Create catalog file" -Action {
    New-FileCatalog -Path $path -CatalogVersion 2.0 -CatalogFilePath "$path\PSGrouper.cat"
}

Execute-Step -StepName "Sign files" -Action {
    $signingCert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
    Set-AuthenticodeSignature -FilePath "$path\PSGrouper.psd1" -Certificate $signingCert -TimestampServer 'http://timestamp.digicert.com'
    Set-AuthenticodeSignature -FilePath "$path\PSGrouper.Format.ps1xml" -Certificate $signingCert -TimestampServer 'http://timestamp.digicert.com'
    Set-AuthenticodeSignature -FilePath "$path\PSGrouper.cat" -Certificate $signingCert -TimestampServer 'http://timestamp.digicert.com'
}

Execute-Step -StepName "Create zip file" -Action {
    Compress-Archive -Path $path -DestinationPath "$release\PSGrouper_$($manifest.ModuleVersion -replace '\.', '_').zip"
}

Execute-Step -StepName "Clean up" -Action {
    Remove-Item -Path $path -Recurse -Force
}

"Build ended at $(Get-Date)" | Out-File -FilePath $LogFilePath
