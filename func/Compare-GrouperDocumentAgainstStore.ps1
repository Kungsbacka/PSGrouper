<#
    .SYNOPSIS
        Takes a grouper document and checks if the group exists in the store
        and if the group names match.

    .DESCRIPTION
        Takes a grouper document and checks if the group exists in the store
        and if the group name in the document match the name in the store.
        The name comparison is case sensitive by default. Use CaseInsensitive
        switch to change behavoiur.

    .PARAMETER InputObject
        Grouper document, Grouper document inside metadata object, [System.Guid] or
        a GUID string.

    .PARAMETER CaseInsensitive
        Make a case insensitve group name comparison

    .PARAMETER OutputAll
        Output all entries even when the group exist and the name match

    .INPUTS
        (see InputObject)

    .OUTPUTS
        Custom object describing what the store said about the group, with NameInDocument,
        NameInStore, GroupExists and NamesMatch. A group that is no longer in the store comes back
        with GroupExists set to false and no name. Nothing at all is written when the group is there
        and the names already match, unless OutputAll is given.

    .EXAMPLE
        Get-GrouperDocument -All | Compare-GrouperDocumentAgainstStore

        Check all published documents in database

    .LINK
        Get-GrouperMemberDiff

    .LINK
        Invoke-Grouper

    .LINK
        Get-GrouperDocument
#>
function Compare-GrouperDocumentAgainstStore
{
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [object]
        $InputObject,
        [Parameter(Mandatory=$false)]
        [switch]
        $CaseInsensitive,
        [Parameter(Mandatory=$false)]
        [switch]
        $OutputAll
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
        $output = [pscustomobject]@{
            Document = $document
            NameInDocument =  $document.GroupName
            NameInStore = $null
            GroupExists = $true
            NamesMatch = $false
        }
        # AllowNotFound, because a group that is no longer in the store is the answer this cmdlet
        # exists to give. The stores raise an exception for a group they cannot find rather than
        # returning nothing, so without this the API's 404 would be thrown here and GroupExists could
        # never come back false.
        $groupInfo = ApiPostDocument (GetApiUrl 'groupinfo') $document -AllowNotFound
        if ($null -eq $groupInfo) {
            $output.GroupExists = $false
            $output
            return
        }
        $output.NameInStore = $groupInfo.DisplayName
        if ($CaseInsensitive) {
            $output.NamesMatch = $groupInfo.DisplayName -eq $document.GroupName
        }
        else {
            $output.NamesMatch = $groupInfo.DisplayName -ceq $document.GroupName
        }
        if ($OutputAll -or -not $output.GroupExists -or -not $output.NamesMatch) {
            $output
        }
    }
}
