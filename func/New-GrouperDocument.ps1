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

    .PARAMETER Members
        Group members

    .INPUTS
        (none)

    .EXAMPLE
        New-GrouperDocument -GroupId '449e9f05-d939-9fbc-a110-1e8b49de9a91' -GroupName 'MyGroup' -Store AzureAD | Edit-GrouperDocument | Save-GrouperDocument

    .EXAMPLE
        $r = New-GrouperDocumentRule -Name 'Organisation' -Value 'ABC123'
        $m = New-GrouperDocumentMember -Source 'Personalsystem' -Action 'Include' -Rules $r
        $d = New-GrouperDocument -GroupId '449e9f05-d939-9fbc-a110-1e8b49de9a91' -GroupName 'MyGroup' -Store OnPremAD -Members $m
    .NOTES
        This is a prototype version of the cmdlet. A template member object is added that has to be edited by hand.
        The final version will take an array of member objects to create a complete Grouper document.
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
