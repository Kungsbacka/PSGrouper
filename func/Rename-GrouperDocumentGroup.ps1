<#
    .SYNOPSIS
        Sets a new name for the group in a Grouper document.

    .DESCRIPTION
        Takes a Grouper document as input and clones that document, but with a new
        group name. The cloned document can then be saved to the document database.
        This creates a new version of the document with a new group name.

    .PARAMETER InputObject
        Grouper document entry, Grouper document

    .PARAMETER NewName
        New group name

    .INPUTS
        (see InputObject)

    .EXAMPLE
        Get-GrouperDocumentEntry -GroupName 'MyGroup' | Rename-GrouperDocumentGroup -NewName 'New Group Name' | Save-GrouperDocument

        Renames MyGroup to New Group Name inside document and saves the updated document to the database.
#>
function Rename-GrouperDocumentGroup
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [object]
        $InputObject,
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewName
    )

    begin {
        if (-not (CheckApi)) {
            break
        }
    }

    process {
        $document = GetDocumentFromInputObject $InputObject
        if (-not $document) {
            return
        }
        $document.CloneWithNewGroupName($NewName)
    }
}
