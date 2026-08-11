<#
    .SYNOPSIS
        Creates a single rule for a Grouper document member object.

    .DESCRIPTION
        Creates one name and value pair that narrows down which people a member source returns. A
        rule on its own is not useful. Pass one or more of them to New-GrouperDocumentMember, and
        pass the resulting member objects to New-GrouperDocument.

        Which rule names are valid depends on the member source they are used with, and so does the
        format of the value. Nothing is checked at this point. Both are checked when the whole
        document is validated, which happens in New-GrouperDocument, Test-GrouperDocument and
        Save-GrouperDocument.

        The README lists the rule names each member source accepts, and the value format for each
        one.

    .PARAMETER Name
        Rule name, for example Organisation, Roll or Upn. Rule names are case-sensitive and have to
        be spelled exactly as the member source declares them.

    .PARAMETER Value
        Rule value. The accepted format depends on the rule name.

    .INPUTS
        (none)

    .OUTPUTS
        GrouperLib.Core.GrouperDocumentRule

    .EXAMPLE
        New-GrouperDocumentRule -Name 'Organisation' -Value '011JABCDEF12'

    .EXAMPLE
        $rules = @(
            New-GrouperDocumentRule -Name 'Roll' -Value 'Elev'
            New-GrouperDocumentRule -Name 'Klass' -Value 'EG_41e60dc2-1300-471d-a3a9-674664320e25'
        )
        New-GrouperDocumentMember -Source 'Elevregister' -Action 'Include' -Rules $rules

        Builds the two rules that select the pupils in one class, and puts them into a member object.

    .LINK
        New-GrouperDocumentMember

    .LINK
        New-GrouperDocument
#>
function New-GrouperDocumentRule
{
   param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,
        [Parameter(Mandatory=$true)]
        [string]
        $Value
    )

    process {
        $rule = New-Object -TypeName 'GrouperLib.Core.GrouperDocumentRule' -ArgumentList @($Name, $Value)
        Write-Output -InputObject $rule
    }
}
