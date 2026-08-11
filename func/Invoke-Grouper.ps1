<#
    .SYNOPSIS
        Performs group member changes based on supplied Grouper document

    .DESCRIPTION
        Processes a Grouper document and makes changes to group members based on the
        rules in the document.
        Invoke-Grouper has no WhatIf switch and will always try to make requested
        changes to a group. To test what will happen when Invoke-Grouper is called
        on a document without making any changes, use Get-GrouperMemberDiff.

    .PARAMETER InputObject
        Grouper document or database document entry

    .PARAMETER Force
        Writes the changes even when they fall below the configured change limit. Grouper normally
        refuses to write when a group would shrink too much, because that usually means a member
        source returned incomplete data. Look at the change with Get-GrouperMemberDiff first, and
        use this switch only once you are satisfied that the reduction is correct.

    .INPUTS
        (see InputObject)

    .OUTPUTS
        GrouperLib.Core.OperationalLogItem

        One item for each member added or removed. A document that results in no changes produces
        no output. Errors are not returned as objects. They are recorded in the event log, where
        Get-GrouperEventLog will find them.

    .EXAMPLE
        Get-GrouperDocument -GroupName 'MyGroup' | Invoke-Grouper

    .EXAMPLE
        Get-GrouperDocument -All | Invoke-Grouper

    .LINK
        Get-GrouperMemberDiff

    .LINK
        Get-GrouperOperationalLog

    .LINK
        Get-GrouperEventLog

    .NOTES
        A document has to be published before the scheduled service will process it. Invoke-Grouper
        does not check this, so it will happily process an unpublished document once, by hand.

    .LINK
        Publish-GrouperDocument
#>
function Invoke-Grouper
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [object]
        $InputObject,
        [Parameter(Mandatory=$false)]
        [switch]
        $Force
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
        if ($Force) {
            Write-Warning 'Change limit is ignored when updating group members'
        }
        if ($PSCmdlet.ShouldProcess($document.Id, 'Update group members')) {
            $url = GetApiUrl 'grouper' 'invoke'
            if ($Force) {
                $url = AddUrlParameter $url 'ignoreChangelimit' 'true'
            }
            $result = ApiPostDocument $url $document
            # For some reason the foreach loop iterates once even if the array is empty
            if ($result.Length -gt 0) {
                foreach ($item in $result) {
                    $argsList = @(
                        $item.logTime
                        $item.documentId
                        $item.groupId
                        $item.groupDisplayName
                        $item.groupStore
                        $item.operation
                        $item.targetId
                        $item.targetDisplayName
                    )
                    New-Object -TypeName 'GrouperLib.Core.OperationalLogItem' -ArgumentList $argsList
                }
            }
        }
    }
}
