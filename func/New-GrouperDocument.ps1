<#
    .SYNOPSIS
        Creates a new Grouper document

    .DESCRIPTION
        Creates a Grouper document object that can edited or stored in the document database.

    .PARAMETER GroupId
        Group GUID

    .PARAMETER GroupName
        Group name

    .PARAMETER Store
        Group store

    .PARAMETER OwnerAction
        What should happen to the group's owners. AddAll, KeepExisting or MatchSource. Defaults to
        AddAll. This has an effect on Entra ID groups only, because Entra ID is the only store that
        can report group owners.

    .PARAMETER Members
        One or more member objects created with New-GrouperDocumentMember. When this is left out, a
        placeholder Static member object is added so that the document is valid, and it is expected
        that you replace it in the editor.

    .PARAMETER OutputErrors
        Writes each validation error as a PowerShell error instead of throwing a single exception.
        Use this when you want to see everything that is wrong at once rather than only that the
        document was rejected.

    .INPUTS
        (none)

    .OUTPUTS
        GrouperLib.Core.GrouperDocument

    .EXAMPLE
        New-GrouperDocument -GroupId '449e9f05-d939-9fbc-a110-1e8b49de9a91' -GroupName 'MyGroup' -Store AzureAd | Edit-GrouperDocument | Save-GrouperDocument

        Creates a document with a placeholder member object, opens it in the editor so the member
        object can be replaced, and saves the result.

    .EXAMPLE
        $r = New-GrouperDocumentRule -Name 'Organisation' -Value '011JABCDEF12'
        $m = New-GrouperDocumentMember -Source 'Personalsystem' -Action 'Include' -Rules $r
        $d = New-GrouperDocument -GroupId '449e9f05-d939-9fbc-a110-1e8b49de9a91' -GroupName 'MyGroup' -Store OnPremAd -Members $m

        Builds a complete document without opening the editor.

    .NOTES
        The document is validated as it is created. When validation fails the cmdlet throws, or
        writes each error separately if -OutputErrors was given, and no document is returned.

        Nothing is written to the database here. Pass the result to Save-GrouperDocument for that.

    .LINK
        New-GrouperDocumentMember

    .LINK
        New-GrouperDocumentRule

    .LINK
        Edit-GrouperDocument

    .LINK
        Save-GrouperDocument
#>
function New-GrouperDocument
{
    param (
        [Parameter(Mandatory=$true)]
        [guid]
        $GroupId,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,
        [Parameter(Mandatory=$true)]
        [GrouperLib.Core.GroupStore]
        $Store,
        [Parameter(Mandatory=$false)]
        [GrouperLib.Core.GroupOwnerAction]
        $OwnerAction,
        [Parameter(Mandatory=$false)]
        [GrouperLib.Core.GrouperDocumentMember[]]
        $Members,
        [Parameter(Mandatory=$false)]
        [switch]
        $OutputErrors
    )

    process {
        if ($null -eq $Members -or $Members.Count -eq 0) {
            $rule = New-GrouperDocumentRule -Name 'Upn' -Value 'none@kungsbacka.se'
            $Members = New-GrouperDocumentMember -Source 'Static' -Action 'Include' -Rules $rule
        }

        if (-not $OwnerAction) {
            $OwnerAction = 'AddAll'
        }

        $errorList = New-Object -TypeName 'System.Collections.Generic.List[GrouperLib.Core.ValidationError]'
        [GrouperLib.Core.GrouperDocument]::Create([Guid]::NewGuid(), 0, $GroupId, $GroupName, $Store, $OwnerAction, $Members, $errorList)
        if ($OutputErrors) {
            $errorList | Write-Error
        }
        elseif ($errorList.Count -gt 0) {
            throw 'Invalid Grouper Document'
        }
    }
}
