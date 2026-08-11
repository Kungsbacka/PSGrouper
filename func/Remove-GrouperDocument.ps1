<#
    .SYNOPSIS
        Removes a Grouper document

    .DESCRIPTION
        Sets a grouper document as 'deleted' in the Grouper database

    .PARAMETER InputObject
        Grouper document, Grouper document inside metadata object, [System.Guid] or
        a GUID string.
    
    .PARAMETER Force
        Force removal without asking for confirmation. 

    .INPUTS
        (see InputObject)

    .OUTPUTS
        None

    .EXAMPLE
        Get-GrouperDocument -GroupName 'MyGroup' -Store 'AzureAD' | Remove-GrouperDocument

    .LINK
        Restore-GrouperDocument

    .LINK
        Unpublish-GrouperDocument

    .LINK
        Get-GrouperDocument
#>
function Remove-GrouperDocument
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [object]
        $InputObject,
        [Parameter(Mandatory=$false)]
        [switch]
        $Force
    )

    begin {

        if ($PSBoundParameters['WhatIf'] -and $Force) {
            throw 'Cannot supply both -WhatIf and -Force at the same time.'
            return
        }

        if (-not (CheckApi)) {
            break
        }
    }

    process {
        $documentId = GetDocumentIdFromInputObject $InputObject
        if ($null -eq $documentId) {
            return
        }
        if ($Force -or $PSCmdlet.ShouldProcess($documentId, 'Remove')) {
            ApiInvokeWebRequest (GetApiUrl 'document' "id/$documentId") 'Delete'
        }
    }
}
