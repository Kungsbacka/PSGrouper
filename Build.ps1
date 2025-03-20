param (
    [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
    [Parameter(Mandatory=$true,Position=0)]
    [string]$GrouperLibPath,
    [ValidateSet('Debug','Release')]
    [Parameter(Mandatory=$true,Position=1)]
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

"Build started at $(Get-Date)" | Out-File -FilePath $LogFilePath

$csprojPath = Join-Path $GrouperLibPath 'CompileTarget\CompileTarget.csproj'
Execute-Step -StepName "Check CompileTarget project" -Action {
    if (!(Test-Path -Path $csprojPath)) {
        throw "CompileTarget project not found at $csprojPath."
    }
}

if ($BuildType -eq 'Debug') {
    $libPath = Join-Path $PSScriptRoot 'lib'
    Execute-Step -StepName "Create lib directory" -Action {
        if (!(Test-Path -Path $libPath)) {
            New-Item -ItemType Directory -Path $libPath
        }
    }

    Execute-Step -StepName "Publish Debug build" -Action {
        & dotnet publish $csprojPath --configuration Debug --self-contained --output $libPath
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

Execute-Step -StepName "Build dependencies" -Action {
    & dotnet publish $csprojPath --configuration Release --self-contained --output (Join-Path $path 'lib')
    Remove-Item -Path (Join-Path $path 'lib\CompileTarget*') -Force
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

"Build ended at $(Get-Date)" | Out-File -FilePath $LogFilePath -Append