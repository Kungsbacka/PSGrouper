<#
    .SYNOPSIS
        Creates a member object for a Grouper document.

    .DESCRIPTION
        Creates one member object, which says where a set of members comes from and whether they
        should be included in the group or excluded from it. A document needs at least one member
        object, and it may contain several.

        Build the rules first with New-GrouperDocumentRule, then pass them here, then pass the
        resulting member objects to New-GrouperDocument.

        Nothing is validated at this point. Whether the source accepts the rule names you supplied,
        and whether their values have the right format, is checked when the whole document is
        validated in New-GrouperDocument, Test-GrouperDocument or Save-GrouperDocument.

        Note that a member object with Action set to Exclude does not simply remove people. Includes
        and excludes are applied in a fixed order, and Static members are applied last, so a Static
        include cannot be undone by a rule that excludes the same person. The README explains the
        order in full.

    .PARAMETER Source
        Member source, for example Elevregister, Personalsystem, Static or AzureAdGroup. Which rule
        names are valid depends on this choice, and so does which group stores the finished document
        may use.

    .PARAMETER Action
        Include or Exclude.

    .PARAMETER Rules
        One or more rules created with New-GrouperDocumentRule.

    .INPUTS
        (none)

    .OUTPUTS
        GrouperLib.Core.GrouperDocumentMember

    .EXAMPLE
        $rule = New-GrouperDocumentRule -Name 'Organisation' -Value '011JABCDEF12'
        New-GrouperDocumentMember -Source 'Personalsystem' -Action 'Include' -Rules $rule

    .EXAMPLE
        $include = New-GrouperDocumentMember -Source 'Elevregister' -Action 'Include' -Rules @(
            New-GrouperDocumentRule -Name 'Roll' -Value 'Elev'
            New-GrouperDocumentRule -Name 'Klass' -Value 'EG_41e60dc2-1300-471d-a3a9-674664320e25'
        )
        $exclude = New-GrouperDocumentMember -Source 'Static' -Action 'Exclude' -Rules (
            New-GrouperDocumentRule -Name 'Upn' -Value 'someone@example.com'
        )
        New-GrouperDocument -GroupId '4a31e904-a33a-476e-95da-4d0ec7ab602a' -GroupName 'My Group' -Store AzureAd -Members $include, $exclude

        Selects the pupils in one class and then keeps one named person out of the group.

    .LINK
        New-GrouperDocumentRule

    .LINK
        New-GrouperDocument
#>
function New-GrouperDocumentMember
{
    param (
        [Parameter(Mandatory=$true)]
        [GrouperLib.Core.GroupMemberSource]
        $Source,
        [Parameter(Mandatory=$true)]
        [GrouperLib.Core.GroupMemberAction]
        $Action,
        [Parameter(Mandatory=$true)]
        [GrouperLib.Core.GrouperDocumentRule[]]
        $Rules
    )
    
    process {
        $member = New-Object -TypeName 'GrouperLib.Core.GrouperDocumentMember' -ArgumentList @($Source, $Action, $Rules)
        Write-Output -InputObject $member
    }
}
