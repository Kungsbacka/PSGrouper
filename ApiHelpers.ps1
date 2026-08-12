function CheckApi()
{
    if (-not $Script:ApiUrl) {
        throw 'Not connected. Call Connect-Grouper before calling any other cmdlets.'
    }
    $true
}

function AddUrlParameter($url, $name, $value)
{
    $param = [System.Web.HttpUtility]::UrlEncode($name) + '=' + [System.Web.HttpUtility]::UrlEncode($value.ToString())
    if ($url.IndexOf('?') -gt 0) {
        "$url&$param"
    }
    else {
        "$url`?$param"
    }
}

function AddUrlParameters($url, $params)
{
    foreach ($param in $params.GetEnumerator()) {
        if ($null -ne $param.Value) {
            $url = AddUrlParameter $url $param.Key $param.Value
        }
    }
    $url
}

function GetApiUrl($controller, $fragment)
{
    $controller = $controller.Trim('/')
    if ($fragment) {
        "$($Script:ApiUrl.TrimEnd('/'))/$controller/$($fragment.TrimStart('/'))"
    }
    else {
        "$($Script:ApiUrl.TrimEnd('/'))/$controller"
    }
}

# The API refuses a document that does not validate with 400 and puts the validation errors in the
# response body. Left alone, the caller would see nothing but "400 Bad Request" and never learn what
# was wrong, so the body is lifted into the error message.
function ThrowApiError($errorRecord)
{
    $body = $errorRecord.ErrorDetails.Message
    if (-not $body) {
        throw $errorRecord
    }
    $parsed = $null
    try {
        $parsed = ConvertFrom-Json -InputObject $body
    }
    catch {
        # Not JSON. The body is still the most useful thing available.
    }
    if ($parsed.errorMessage) {
        throw "$($errorRecord.Exception.Message) $($parsed.errorMessage -join ' ')"
    }
    throw "$($errorRecord.Exception.Message) $body"
}

function ApiInvokeWebRequest($url, $method, $body)
{
    $params = @{
        Uri = $url
        Method = $method
        UseDefaultCredentials = $true
        UseBasicParsing = $true
    }
    if ($body) {
        if ($body -is [GrouperLib.Core.GrouperDocument]) {
            $params.Body = $body.ToJson()
        }
        else {
            $params.Body = $body
        }
        $params.ContentType = 'application/json; charset=utf-8'
    }
    try {
        $null = Invoke-WebRequest @params
    }
    catch {
        ThrowApiError $_
    }
}

function ApiGetDocuments($fragment, $params, $includeMeta)
{
    $url = GetApiUrl 'document' $fragment
    if ($params) {
        $url = AddUrlParameters $url $params
    }
    $entries = Invoke-RestMethod -Uri $url -Method 'Get' -UseDefaultCredentials -UseBasicParsing
    foreach ($entry in $entries) {
        $json = ConvertTo-Json -InputObject $entry.document -Depth 5 -Compress
        # Parsed without validation, so that a revision written under an earlier version of the
        # rules can still be fetched, edited and saved back. The API has already judged the document
        # and that verdict is passed on rather than worked out again here.
        $grouperDocument = [GrouperLib.Core.GrouperDocument]::FromJsonUnvalidated($json)
        # An older API does not send the verdict at all, and silence there does not mean invalid.
        if ($null -ne $entry.isValid -and -not $entry.isValid) {
            Write-Warning -Message "Document $($entry.document.id) does not validate against the current rules. $($entry.validationErrors.errorMessage -join ' ')"
        }
        if ($includeMeta) {
            [pscustomobject]@{
                Document = $grouperDocument
                GroupId = $entry.groupId
                GroupName = $entry.groupName
                Revision = $entry.revision
                RevisionCreated = $entry.revisionCreated
                IsPublished = $entry.isPublished
                IsDeleted = $entry.isDeleted
                Tags = $entry.tags
                IsValid = $entry.isValid
                ValidationErrors = $entry.validationErrors
            }
        }
        else {
            $grouperDocument
        }
    }
}

function ApiPostDocument($url, $doc)
{
    if ($doc -is [GrouperLib.Core.GrouperDocument]) {
        $json = $doc.ToJson()
    }
    else {
        $json = $doc
    }
    $params = @{
        Uri = $url
        Method = 'Post'
        Body = $json
        ContentType = 'application/json; charset=utf-8'
        UseDefaultCredentials = $true
        UseBasicParsing = $true
    }

    try {
        Invoke-RestMethod @params
    }
    catch {
        ThrowApiError $_
    }
}

function ApiGetLogItems($url, $params)
{
    if ($params) {
        $url = AddUrlParameters $url $params
    }
    Invoke-RestMethod -Uri $url -Method 'Get' -UseDefaultCredentials -UseBasicParsing
}
