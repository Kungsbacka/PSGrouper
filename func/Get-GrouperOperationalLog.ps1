<#
    .SYNOPSIS
        Gets entries from the operational log

    .DESCRIPTION
        Gets entries from the operational log, which records every individual member that Grouper has
        added to or removed from a group. One entry is written per member and per change, so a single
        processing run can produce many entries.

        The member the entry is about is called the target.

    .PARAMETER InputObject
        Grouper document entry, Grouper document, [System.Guid] or a string that can
        be converted to a GUID.

    .PARAMETER GroupId
        Returns entries for one group, identified by its GUID.

    .PARAMETER TargetId
        Returns entries for one member, identified by their GUID. Use this to follow a single person
        across groups, for example to find out when and why they were removed from one.

    .PARAMETER GroupDisplayNameContains
        Part of group display name. Does a wildcard search (*text*)

    .PARAMETER TargetDisplayNameContains
        Part of target display name. Does a wildcard search (*text*)

    .PARAMETER Newest
        Number of new entries to return

    .PARAMETER Start
        Start of date interval. Returns entries on or after this date

    .PARAMETER End
        End of date interval. Returns entries before or on this date. If omitted,
        current date and time is used.

    .INPUTS
        (see DocumentId)

    .OUTPUTS
        GrouperLib.Core.OperationalLogItem

    .EXAMPLE
        Get-GrouperDocument -GroupName 'MyGroup' | Get-GrouperOperationalLog -Newest 10

    .EXAMPLE
        Get-GrouperOperationalLog -Start '2019-01-01' -End '2019-01-31'

    .EXAMPLE
        Get-GrouperOperationalLog -TargetId '9f0c1c62-4a1e-4b3e-8f4a-2d6b1e5c7a90' -Newest 20

        Shows the twenty most recent group changes affecting one person, across every group.

    .LINK
        Get-GrouperAuditLog

    .LINK
        Get-GrouperEventLog

    .LINK
        Invoke-Grouper
#>
function Get-GrouperOperationalLog
{
    [CmdletBinding(DefaultParameterSetName='Newest')]
    param (
        [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true,ParameterSetName='Newest')]
        [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true,ParameterSetName='Range')]
        [object]
        $InputObject,
        [Parameter(Mandatory=$false,ParameterSetName='Newest')]
        [Parameter(Mandatory=$false,ParameterSetName='Range')]
        [guid]
        $GroupId,
        [Parameter(Mandatory=$false,ParameterSetName='Newest')]
        [Parameter(Mandatory=$false,ParameterSetName='Range')]
        $TargetId,
        [Parameter(Mandatory=$false,ParameterSetName='Newest')]
        [Parameter(Mandatory=$false,ParameterSetName='Range')]
        [string]
        $GroupDisplayNameContains,
        [Parameter(Mandatory=$false,ParameterSetName='Newest')]
        [Parameter(Mandatory=$false,ParameterSetName='Range')]
        [string]
        $TargetDisplayNameContains,
        [Parameter(Mandatory=$false,ParameterSetName='Newest')]
        [int]
        $Newest = 10,
        [Parameter(Mandatory=$true,ParameterSetName='Range')]
        [DateTime]
        $Start,
        [Parameter(Mandatory=$false,ParameterSetName='Range')]
        [DateTime]
        $End
    )

    begin {
        if (-not (CheckApi)) {
            break
        }
    }

    process {
        $query = @{}
        if ($InputObject) {
            $documentId = GetDocumentIdFromInputObject $InputObject
            if (-not $documentId) {
                return
            }
            $query.DocumentId = $documentId
        }
        if ($GroupId) {
            $query.GroupId = $GroupId
        }
        if ($TargetId) {
            $query.TargetId = $TargetId
        }
        if ($GroupDisplayNameContains) {
            $query.GroupDisplayNameContains = $GroupDisplayNameContains
        }
        if ($TargetDisplayNameContains) {
            $query.TargetDisplayNameContains = $TargetDisplayNameContains
        }
        if ($PSCmdlet.ParameterSetName -eq 'Newest') {
            $query.Count = $Newest
        }
        else {
            $query.Count = [int]::MaxValue
            $query.StartDate = $Start
            if ($End) {
                $query.EndDate = $End
            }
        }
        $url = GetApiUrl 'operationallog'
        $items = ApiGetLogItems $url $query
        foreach ($item in  $items) {
            $argList = @(
                $item.logTime
                $item.documentId
                $item.groupId
                $item.groupDisplayName
                $item.groupStore
                $item.operation
                $item.targetId
                $item.targetDisplayName
            )
            New-Object -TypeName 'GrouperLib.Core.OperationalLogItem' -ArgumentList $argList
        }
    }
}
