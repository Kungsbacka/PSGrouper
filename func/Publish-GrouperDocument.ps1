<#
    .SYNOPSIS
        Publishes a Grouper document

    .DESCRIPTION
        Sets a grouper document as 'published' in the Grouper database

    .PARAMETER InputObject
        Grouper document, Grouper document inside metadata object, [System.Guid] or
        a GUID string.

    .INPUTS
        (see InputObject)

    .OUTPUTS
        None

    .EXAMPLE
        Get-GrouperDocument -GroupName 'MyGroup' -Store 'AzureAD' -IncludeUnpublished | Publish-GrouperDocument

    .LINK
        Unpublish-GrouperDocument

    .LINK
        Save-GrouperDocument

    .LINK
        Get-GrouperDocument

    .NOTES
        Publishing is what hands a document to the scheduled service, so a document that no longer
        satisfies the current validation rules is refused and the errors are reported. The rules
        change over time, and a document that was valid when it was saved may no longer be valid
        today. Correct it with Edit-GrouperDocument and save it again before publishing.
#>
function Publish-GrouperDocument
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [object]
        $InputObject
    )

    begin {
        if (-not (CheckApi)) {
            break
        }
    }

    process {
        $documentId = GetDocumentIdFromInputObject $InputObject
        if ($null -eq $documentId) {
            return
        }
        if ($PSCmdlet.ShouldProcess($documentId, 'Publish')) {
            ApiInvokeWebRequest (GetApiUrl 'document' "publish/$documentId") 'Post'
        }
    }
}
