# Hide progress bar for Invoke-WebRequest
$ProgressPreference = 'SilentlyContinue'

$functions = Get-ChildItem -Path "$PSScriptRoot\func\*.ps1" | Select-Object -ExpandProperty FullName
foreach ($func in $functions) {
    . $func
    Export-ModuleMember -Function ([System.IO.Path]::GetFileNameWithoutExtension($func))
}
