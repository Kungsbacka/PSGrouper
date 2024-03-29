<#
    .SYNOPSIS
        Gets membership diff for Grouper document

    .DESCRIPTION
        Gets a list of objects that will be added or removed from the group if Invoke-Grouper is executed.

    .PARAMETER InputObject
        Grouper document or database document entry

    .PARAMETER IncludeUnchanged
        Include members that will not be added or removed

    .INPUTS
        (see InputObject)

    .OUTPUTS
        PSObject {Operation, TargetId, TargetDisplayName}

    .EXAMPLE
        Get-Content .\group.json | Out-String | ConvertTo-GrouperDocument | Get-GrouperMemberDiff
#>
function Get-GrouperMemberDiff
{
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [object]
        $InputObject,
        [Parameter(Mandatory=$false)]
        [switch]
        $IncludeUnchanged
    )

    begin {
        if (-not (CheckApi)) {
            break
        }
    }

    process {
        $document = GetDocumentFromInputObject $InputObject
        if ($null -eq $document) {
            return
        }
        $url = GetApiUrl 'grouper' 'diff'
        if ($IncludeUnchanged) {
            $url = AddUrlParameter $url 'unchanged' 'true'
        }
        $diff = ApiPostDocument $url $document
        foreach ($item in $diff.Add) {
            $member = New-Object -TypeName 'GrouperLib.Core.GroupMember' -ArgumentList @($item.id, $item.displayName, $item.memberType)
            $obj = New-Object -TypeName 'GrouperLib.Core.GroupMemberTask' -ArgumentList @($document, $member, 'Add')
            Write-Output -InputObject $obj
        }
        foreach ($item in $diff.Remove) {
            $member = New-Object -TypeName 'GrouperLib.Core.GroupMember' -ArgumentList @($item.id, $item.displayName, $item.memberType)
            $obj = New-Object -TypeName 'GrouperLib.Core.GroupMemberTask' -ArgumentList @($document, $member, 'Remove')
            Write-Output -InputObject $obj
        }
        if ($IncludeUnchanged) {
            foreach ($item in $diff.Unchanged) {
                $member = New-Object -TypeName 'GrouperLib.Core.GroupMember' -ArgumentList @($item.id, $item.displayName, $item.memberType)
                $obj = New-Object -TypeName 'GrouperLib.Core.GroupMemberTask' -ArgumentList @($document, $member, 'None')
                Write-Output -InputObject $obj
            }
        }
    }
}
