<#
    .SYNOPSIS
        Connects to the Grouper API.

    .DESCRIPTION
        Stores the address of the Grouper API for the rest of the session. This is the first thing
        you have to do, because every other cmdlet that talks to the database or to a group store
        goes through the API and will fail until it has been called.

        The connection is verified before it is stored. The cmdlet asks the API for its version and
        fails if the API cannot be reached, or if it reports a version below 1.0.

        Authentication uses your current Windows account. There is no credential to supply, and no
        separate sign-in step.

    .PARAMETER Uri
        Base address of the Grouper API, for example https://api-server/grouper. Any trailing slash
        is removed. Controller names such as /document are appended by the cmdlets themselves and
        should not be part of this address.

    .INPUTS
        (none)

    .OUTPUTS
        None

    .EXAMPLE
        Connect-Grouper -Uri 'https://api-server/path/to/api'

    .EXAMPLE
        $PSDefaultParameterValues['Connect-Grouper:Uri'] = 'https://api-server/path/to/api'
        Connect-Grouper

        Puts the address in your PowerShell profile so that it does not have to be typed each
        session.

    .NOTES
        The connection lasts for the current session only. A new PowerShell session needs a new
        call to Connect-Grouper.

    .LINK
        Get-GrouperDocument

    .LINK
        Invoke-Grouper
#>
function Connect-Grouper
{
    param (
        [Parameter(Mandatory=$true)]
        [Uri]
        $Uri
    )
    $url = $Uri.AbsoluteUri.TrimEnd('/')
    $response = Invoke-WebRequest -Uri "$url/test/version" -UseBasicParsing -UseDefaultCredentials
    if ($response.Content -lt '1.0') {
        throw 'Unable to find API version or version less than 1.0'
        return
    }
    $Script:ApiUrl = $url
}
