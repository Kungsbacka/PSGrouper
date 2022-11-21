function New-GrouperDocumentMember
{
    param (
        [Parameter(Mandatory=$true)]
        [GrouperLib.Core.GroupMemberSource]
        $Source,
        [Parameter(Mandatory=$true)]
        [GrouperLib.Core.GroupMemberAction]
        $Action,
        [Parameter(Mandatory=$true)]
        [GrouperLib.Core.GrouperDocumentRule[]]
        $Rules
    )
    
    process {
        $member = New-Object -TypeName 'GrouperLib.Core.GrouperDocumentMember' -ArgumentList @($Source, $Action, $Rules)
        Write-Output -InputObject $member
    }
}
