param (
    [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
    [Parameter(Mandatory=$true,Position=0)]
    [string]$GrouperLibPath,
    [ValidateSet('Debug','Release')]
    [Parameter(Mandatory=$true,Position=1)]
    [string]$BuildType = 'Release'
)

$ErrorActionPreference = 'Stop'

$csprojPath = Join-Path $GrouperLibPath 'CompileTarget\CompileTarget.csproj'
if (!(Test-Path -Path $csprojPath)) {
    Write-Error "CompileTarget project not found at $csprojPath."
    exit
}

if ($BuildType -eq 'Debug') {
    $libPath = Join-Path $PSScriptRoot 'lib'
    if (!(Test-Path -Path $libPath)) {
        New-Item -ItemType Directory -Path $libPath
    }

    & dotnet publish $csprojPath --configuration Debug --self-contained --output $libPath

    exit
}


# Get module version from manifest
$manifest = Import-PowerShellDataFile -Path "$PSScriptRoot\PSGrouper.psd1"
if ($null -eq $manifest.ModuleVersion) {
    Write-Error 'Failed to read module version.'
    exit
}

$release = Join-Path $PSScriptRoot 'release'

# Check if release already exists
$path = Join-Path $release $manifest.ModuleVersion
if ((Test-Path -Path $path)) {
    Write-Error "Release $manifest.ModuleVersion already exists."
    exit
}

# Check if zip file already exists
$zipPath = "$release\PSGrouper_$($manifest.ModuleVersion -replace '\.', '_').zip"
if ((Test-Path -Path $zipPath)) {
    Write-Error "Release $zipPath already exists."
    exit
}

# Create folders
if (!(Test-Path -Path $release)) {
    New-Item -ItemType Directory -Path $release
}
New-Item -ItemType Directory -Path $path
New-Item -ItemType Directory -Path "$path\lib"
New-Item -ItemType Directory -Path "$path\func"

# Build dependencies
& dotnet publish $csprojPath --configuration Release --self-contained --output (Join-Path $path 'lib')

# Copy module files
Copy-Item -Path "$PSScriptRoot\PSGrouper.psd1" -Destination $path
Copy-Item -Path "$PSScriptRoot\PSGrouper.psm1" -Destination $path
Copy-Item -Path "$PSScriptRoot\PSGrouper.Format.ps1xml" -Destination $path
Copy-Item -Path "$PSScriptRoot\ApiHelpers.ps1" -Destination $path
Copy-Item -Path "$PSScriptRoot\FunctionHelpers.ps1" -Destination $path
Copy-Item -Path "$PSScriptRoot\LICENSE" -Destination $path
Copy-Item -Path "$PSScriptRoot\README.md" -Destination $path
Copy-Item -Path "$PSScriptRoot\func\*.*" -Destination "$path\func"

# Create catalog file
New-FileCatalog -Path $path -CatalogVersion 2.0 -CatalogFilePath "$path\PSGrouper.cat"

# Sign files
$signingCert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
Set-AuthenticodeSignature -FilePath "$path\PSGrouper.psd1" -Certificate $signingCert -TimestampServer 'http://timestamp.digicert.com'
Set-AuthenticodeSignature -FilePath "$path\PSGrouper.cat" -Certificate $signingCert -TimestampServer 'http://timestamp.digicert.com'

# Create zip file
Compress-Archive -Path $path -DestinationPath "$release\PSGrouper_$($manifest.ModuleVersion -replace '\.', '_').zip"

# Clean up
Remove-Item -Path $path -Recurse -Force
