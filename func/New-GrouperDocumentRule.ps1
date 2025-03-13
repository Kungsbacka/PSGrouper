function New-GrouperDocumentRule
{
   param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,
        [Parameter(Mandatory=$true)]
        [string]
        $Value
    )

    process {
        $rule = New-Object -TypeName 'GrouperLib.Core.GrouperDocumentRule' -ArgumentList @($Name, $Value)
        Write-Output -InputObject $rule
    }
}
