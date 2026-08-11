<#
    .SYNOPSIS
        Saves a Grouper document do the database

    .DESCRIPTION
        Saves a Grouper document to the Grouper database. If a document already exists
        with the same ID, that document is updated. If not, a new document entry is
        created in the database.

    .PARAMETER InputObject
        Grouper document entry, Grouper document

    .PARAMETER Publish
        Publish document after it is saved

    .INPUTS
        (see InputObject)

    .OUTPUTS
        None

    .EXAMPLE
        Get-GrouperDocument -GroupName 'MyGroup' | Edit-GrouperDocument | Save-GrouperDocument -Publish

    .LINK
        Publish-GrouperDocument

    .LINK
        Test-GrouperDocument

    .LINK
        Edit-GrouperDocument

    .NOTES
        Saving always leaves the document unpublished unless you pass -Publish. This is deliberate,
        so that publishing is a separate decision, but it does mean a saved document is not picked
        up by the scheduled service until it has been published. The cmdlet prints a warning to
        remind you. Use Publish-GrouperDocument afterwards, or pass -Publish when saving.

        Each save creates a new revision rather than overwriting the previous one, so an earlier
        version of a document is never lost.

    .LINK
        New-GrouperDocument
#>
function Save-GrouperDocument
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [object]
        $InputObject,
        [Parameter(Mandatory=$false)]
        [switch]
        $Publish
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
        if ($Publish) {
            if ($PSCmdlet.ShouldProcess($document.Id, 'Save & Publish')) {
                ApiPostDocument (GetApiUrl 'document') $document
                ApiInvokeWebRequest (GetApiUrl 'document' "publish/$($document.Id)") 'Post'
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess($document.Id, 'Save')) {
                ApiPostDocument (GetApiUrl 'document') $document
                Write-Warning -Message 'Document is not published and may not be processed by the scheduled task. Use Publish-GrouperDocument to publish.'
            }
        }
    }
}
