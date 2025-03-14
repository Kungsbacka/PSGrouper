﻿#
# Module manifest for module 'PSGrouper'
#
# Generated by: Jonas Sjömark
#
# Generated on: 2020-10-06
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSGrouper.psm1'

# Version number of this module.
ModuleVersion = '4.0.1'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '75efac42-50ad-4f63-963b-54b71cdaa98d'

# Author of this module
Author = 'Jonas Sjömark'

# Company or vendor of this module
CompanyName = 'Kungsbacka kommun'

# Copyright statement for this module
Copyright = '(c) 2020 Jonas Sjömark All rights reserved.'

# Description of the functionality provided by this module
# Description = ''

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# NOTE: This module depends on the ActiveDirectory module for on-prem AD groups and AzureAD
# module for AzureAD groups.
RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# NOTE: This is only parts of the required assemblies. The rest are loaded from Grouper.psm1
# because they require redirection to load the correct dependencies.
RequiredAssemblies = @(
    'PresentationFramework'
    'GrouperLib.Language.dll'
    'GrouperLib.Core.dll'
    'sv/GrouperLib.Language.resources.dll'
)

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @('PSGrouper.format.ps1xml')

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
    'FunctionHelpers.ps1'
    'ApiHelpers.ps1'
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Add-GrouperDocumentTag'
    'Compare-GrouperDocumentAgainstStore'
    'Connect-Grouper'
    'ConvertFrom-GrouperDocument'
    'ConvertTo-GrouperDocument'
    'Edit-GrouperDocument'
    'Get-GrouperAuditLog'
    'Get-GrouperDocument'
    'Get-GrouperEventLog'
    'Get-GrouperMemberDiff'
    'Get-GrouperOperationalLog'
    'Invoke-Grouper'
    'New-GrouperDocument'
    'New-GrouperDocumentMember'
    'New-GrouperDocumentRule'
    'Publish-GrouperDocument'
    'Remove-GrouperDocument'
    'Remove-GrouperDocumentTag'
    'Rename-GrouperDocumentGroup'
    'Restore-GrouperDocument'
    'Save-GrouperDocument'
    'Test-GrouperDocument'
    'Unpublish-GrouperDocument'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}


