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
ModuleVersion = '5.0.4'

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
    'lib/GrouperLib.Language.dll'
    'lib/GrouperLib.Core.dll'
    'lib/sv/GrouperLib.Language.resources.dll'
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



# SIG # Begin signature block
# MIIlPwYJKoZIhvcNAQcCoIIlMDCCJSwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDgwCy+lTHtAMZ0
# /uAm/pF9EG+0hX8q6kOWvahQNIex2KCCH14wggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggX1MIID3aADAgECAhN6AAAaSHUP2Gj50LinAAAAABpIMA0G
# CSqGSIb3DQEBCwUAMEoxCzAJBgNVBAYTAlNFMRowGAYDVQQKExFLdW5nc2JhY2th
# IGtvbW11bjEfMB0GA1UEAxMWS3VuZ3NiYWNrYSBJc3N1aW5nIENBMjAeFw0yNTAy
# MTMxMzM4MzlaFw0yNjAyMTMxMzM4MzlaMBkxFzAVBgNVBAMMDkpvbmFzIFNqw7Zt
# YXJrMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyDf6Vp2tJTEzTfP7
# kqJNR+qr8LjYLNOUel7ue3xwgH8jQmrpnl43AhK1YDbLyGm/AOZlFc+H0ME9PwoB
# kD5QTP53Pn0ItO4Dg5cGQHOlftK9MsZU6f9cDMv3Flqp4hpibH7YxqO5esLq6crk
# fecg/B2lEpXjkg/B7xXJK06Js6IbKybEfnfm4gBPQBy9Ctb0WH4nj/UzK1G5gmJl
# 7wSiPS1lHvl3yp+/veApOHRxxMn/Hck1Z42+UkFZm6guk/7D+seZqZSb8BwTIpE5
# tp4n/oJcCAD0g6SX1l2wYLuBV3ONScd62fjK12LC1IQsPJ6IudSWjYPQZVzVyzTN
# FtOOuQIDAQABo4ICAzCCAf8wPgYJKwYBBAGCNxUHBDEwLwYnKwYBBAGCNxUIhdKy
# ZISDhmGDzZcoheflLIKDsCqBC4XStEWCiLImAgFkAgECMBMGA1UdJQQMMAoGCCsG
# AQUFBwMDMA4GA1UdDwEB/wQEAwIHgDASBgNVHSAECzAJMAcGBSqFcIIaMBsGCSsG
# AQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFMw7X52oEygro1ubE4dc
# jbDM/YGkMB8GA1UdIwQYMBaAFIV3ie4z/pITGAUpJibTI0Zet/T4MEgGA1UdHwRB
# MD8wPaA7oDmGN2h0dHA6Ly9wa2kua3VuZ3NiYWNrYS5zZS9LdW5nc2JhY2thJTIw
# SXNzdWluZyUyMENBMi5jcmwwUwYIKwYBBQUHAQEERzBFMEMGCCsGAQUFBzAChjdo
# dHRwOi8vcGtpLmt1bmdzYmFja2Euc2UvS3VuZ3NiYWNrYSUyMElzc3VpbmclMjBD
# QTIuY3J0MDYGA1UdEQQvMC2gKwYKKwYBBAGCNxQCA6AdDBtqb25hcy5zam9tYXJr
# QGt1bmdzYmFja2Euc2UwUAYJKwYBBAGCNxkCBEMwQaA/BgorBgEEAYI3GQIBoDEE
# L1MtMS01LTIxLTI5ODQwMTc5NjAtNDEzMDgwMDE0Mi0xMjE1MTA4MTQxLTEzNzY4
# MA0GCSqGSIb3DQEBCwUAA4ICAQCFbvMbByz5SJEymjh3SaI4UZ6pC6aDiy9AuHy+
# qvEVJJwuwbccwgxcoh2dj7IAQljbr3Du6ECvPtBi14Mr5yPnWUuFfU0p4dExDFhQ
# ZWP0stQq3DmOW5P6bUxnQ66B/63dcJvPBoUlN9yxxVlFVGbDiqFPxp7rfjiA9i29
# dUA3NjzF15EN3kJCIhMEvfEWKoSrc3gCFrVICRjpm1Q83yHDQokm8WQwEaBLGS/b
# GbXRP2qWpnm9Vpg8xm6lcncPtKiyLuCp3Tttp4q37j6pVdCWaxSjDrRwHiu3jpWn
# eZqppRbT4EtEEg6OnoghrB/Y/zqQc49gavJ9+dmnBgftT0MzEZ2lzlptELgPgPXu
# ulXohicUL0wWNZFbFvCR6iRy/jDzDcKjN0qIGgwPb777ALEdfVEeARcwSMHX6Iya
# l43TUYXSkzISP34zYQdcnoBcOITWS2ykTBzQDvJQp+7XFaGu3ZXR6n1wGAx6m+vn
# rYXRdSTVcJXmjH3F2+WUaBnc0nqivsmseURHgJ+1vIeZNmcRftniCksMyYz/5KQX
# pGHp7i3OVtgks2zaAibC6vfRRCW6bUIB7IiwECC2QXTBe9uwy559U7Oq3zneY2Ab
# yCHohs1H+Qc4atGE6hyqWpK9pJoESAsCUzUK7SRS+u/MH2N6u9WX9aB3AqFnpVEW
# +1E3TDCCBl4wggRGoAMCAQICEzMAAAACWgdtYoO+NiEAAAAAAAIwDQYJKoZIhvcN
# AQELBQAwRzELMAkGA1UEBhMCU0UxGjAYBgNVBAoTEUt1bmdzYmFja2Ega29tbXVu
# MRwwGgYDVQQDExNLdW5nc2JhY2thIFJvb3QgQ0EyMB4XDTI0MDUwMzA5MTM1N1oX
# DTQ0MDUwMzA5MjM1N1owSjELMAkGA1UEBhMCU0UxGjAYBgNVBAoTEUt1bmdzYmFj
# a2Ega29tbXVuMR8wHQYDVQQDExZLdW5nc2JhY2thIElzc3VpbmcgQ0EyMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAzMJt8ayoeVEErQqOGxRggloXmr3M
# KGDnmHV3Kys7ldMgp5j0+uafbaucR7TXTS5SNaDhIFtDAd9NCTsg2EP9CQ5aBZHw
# t9cFMaOVs8byTvUFuhKaycpkBC1BPXY/lug0poKPtMzWXgLNb/mqx0MEOrqy1DvE
# BYWjhmWz6OFYcR7tBL7rS6gxeg0fXlKHfhKKK7fopXRuvBDi0GrA41sxhrqNeoma
# H/jfmyCzvkBowma58zBdku2hJ+uvb/BeZO8XX6He9/zX1clXE9EKQbOnssS8Wc64
# EY524k7vEPQnsM0Y/ikzkI9gagEM+Ibo6oopx0XStYKuMOTmSD+2u61iUgJWL6T5
# jAyHfPBBSzriztLHjR7m1Fy7diJwOx4jvRtEWSATEvmnxcR23nRTV61wxFkArI/0
# CgbDVnYXkrY94T4w2McY96sVmYu4fRBOo/tavfPo4Wz+rrWfp5aZcO3qje11vbhF
# 2aYxAUtHlcTzPZAYIFGcxRJNRAufXOoBIxxdYk31c7lVysmh9bHKuC3fZdGeVppk
# DM1L4WKytxbeR/vpRe8tlaR0E4AJE7NPgvvOtSUds/Da89sMkAyD/iiaHWGVUdyR
# 83CNdzVGqxc2L1+nQtIMXrJ+FNuXrrp6Wby/l5KRNRBKcvBux7wncz/YcEV1zryF
# SwAYVZEIq09OkJUCAwEAAaOCAT4wggE6MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1Ud
# DgQWBBSFd4nuM/6SExgFKSYm0yNGXrf0+DARBgNVHSAECjAIMAYGBFUdIAAwGQYJ
# KwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMBIGA1UdEwEB/wQI
# MAYBAf8CAQAwHwYDVR0jBBgwFoAUWa8lMfbdWoGncUz8b5aJb6465KEwRQYDVR0f
# BD4wPDA6oDigNoY0aHR0cDovL3BraS5rdW5nc2JhY2thLnNlL0t1bmdzYmFja2El
# MjBSb290JTIwQ0EyLmNybDBQBggrBgEFBQcBAQREMEIwQAYIKwYBBQUHMAKGNGh0
# dHA6Ly9wa2kua3VuZ3NiYWNrYS5zZS9LdW5nc2JhY2thJTIwUm9vdCUyMENBMi5j
# cnQwDQYJKoZIhvcNAQELBQADggIBAJ6JS3LCjt7q5trMmSLKIBl8Vyw837YjaZSW
# HSclCfB2po0/PyCbp7IX14yubf3ZHf3L5Rx1SnKMtLZPDX6Yq5j+5T35TsQbPMvN
# G8wbRoZzFEwDinI9YIkbZhOmtI9fE9zRmcF+zD6qqB92wx/mamoMy6U8DnAZl43J
# l/HP8EbNwBgo1tRNWNtZMdx0ghkkv9NquMZ4pfBoImJYJCC6zSDaHpCnO2oCNB5Z
# xCfLVSxTs/xCGQWzhdhj8BU61j8g1Jv8HJ6ydvkCmP/y4UAYHEdPNd5cGd9nZHJ7
# hXq2y5WNTosnJMnlfYsBoU6famYP73YEyyo+fTrItFT2JipnXWTk3rpCXqpamQiA
# /8DwycGpW9rfLiieqoMOsK9pMJD083fUOIJSxROWCh6X8/qYY7UX2Ibp3NL1O1a3
# f5jPafIid2DsVd+rGo+hosJCBtY5aR4BW5qjFJoyZ+ZH4Zsv7K3HUbrknKF9Vpnb
# ZZ21OycZQAY0sY/fxyioQVuWl6hzAsA5fDJpy9Iv21aYJ62ikbbHzJd5sqLxkZUi
# JgRsmCbvvo+xY+BMTir/m5/arHccBQRQopOH4UgETwVwkWOOzc792gRX6MwugrZH
# +bjSr2PQqeHPVFmRscIXhaiF7lp4WuHqLScZ3bqty9XnLZaQqDl2JvXLzCaaOUFx
# LT1Vj8hNMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0B
# AQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVk
# IFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lD
# ZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKR
# N6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZz
# lm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1Oco
# LevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH
# 92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRA
# p8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+g
# GkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU
# 8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/
# FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwj
# jVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQ
# EgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUae
# tdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAw
# HQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LS
# cV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYy
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5j
# cmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEB
# CwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftw
# ig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalW
# zxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQm
# h2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScb
# qyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLaf
# zYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbD
# Qc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0K
# XzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm
# 8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9
# gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8a
# pIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBrwwggSk
# oAMCAQICEAuuZrxaun+Vh8b56QTjMwQwDQYJKoZIhvcNAQELBQAwYzELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2Vy
# dCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0y
# NDA5MjYwMDAwMDBaFw0zNTExMjUyMzU5NTlaMEIxCzAJBgNVBAYTAlVTMREwDwYD
# VQQKEwhEaWdpQ2VydDEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjQw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC+anOf9pUhq5Ywultt5lmj
# tej9kR8YxIg7apnjpcH9CjAgQxK+CMR0Rne/i+utMeV5bUlYYSuuM4vQngvQepVH
# VzNLO9RDnEXvPghCaft0djvKKO+hDu6ObS7rJcXa/UKvNminKQPTv/1+kBPgHGlP
# 28mgmoCw/xi6FG9+Un1h4eN6zh926SxMe6We2r1Z6VFZj75MU/HNmtsgtFjKfITL
# utLWUdAoWle+jYZ49+wxGE1/UXjWfISDmHuI5e/6+NfQrxGFSKx+rDdNMsePW6FL
# rphfYtk/FLihp/feun0eV+pIF496OVh4R1TvjQYpAztJpVIfdNsEvxHofBf1BWka
# dc+Up0Th8EifkEEWdX4rA/FE1Q0rqViTbLVZIqi6viEk3RIySho1XyHLIAOJfXG5
# PEppc3XYeBH7xa6VTZ3rOHNeiYnY+V4j1XbJ+Z9dI8ZhqcaDHOoj5KGg4YuiYx3e
# Ym33aebsyF6eD9MF5IDbPgjvwmnAalNEeJPvIeoGJXaeBQjIK13SlnzODdLtuThA
# LhGtyconcVuPI8AaiCaiJnfdzUcb3dWnqUnjXkRFwLtsVAxFvGqsxUA2Jq/WTjbn
# NjIUzIs3ITVC6VBKAOlb2u29Vwgfta8b2ypi6n2PzP0nVepsFk8nlcuWfyZLzBaZ
# 0MucEdeBiXL+nUOGhCjl+QIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAI
# BgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WM
# aiCPnshvMB0GA1UdDgQWBBSfVywDdw4oFZBmpWNe7k+SH3agWzBaBgNVHR8EUzBR
# ME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVk
# RzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsG
# AQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEB
# CwUAA4ICAQA9rR4fdplb4ziEEkfZQ5H2EdubTggd0ShPz9Pce4FLJl6reNKLkZd5
# Y/vEIqFWKt4oKcKz7wZmXa5VgW9B76k9NJxUl4JlKwyjUkKhk3aYx7D8vi2mpU1t
# KlY71AYXB8wTLrQeh83pXnWwwsxc1Mt+FWqz57yFq6laICtKjPICYYf/qgxACHTv
# ypGHrC8k1TqCeHk6u4I/VBQC9VK7iSpU5wlWjNlHlFFv/M93748YTeoXU/fFa9hW
# JQkuzG2+B7+bMDvmgF8VlJt1qQcl7YFUMYgZU1WM6nyw23vT6QSgwX5Pq2m0xQ2V
# 6FJHu8z4LXe/371k5QrN9FQBhLLISZi2yemW0P8ZZfx4zvSWzVXpAb9k4Hpvpi6b
# Ue8iK6WonUSV6yPlMwerwJZP/Gtbu3CKldMnn+LmmRTkTXpFIEB06nXZrDwhCGED
# +8RsWQSIXZpuG4WLFQOhtloDRWGoCwwc6ZpPddOFkM2LlTbMcqFSzm4cd0boGhBq
# 7vkqI1uHRz6Fq1IX7TaRQuR+0BGOzISkcqwXu7nMpFu3mgrlgbAW+BzikRVQ3K2Y
# HcGkiKjA4gi4OA/kz1YCsdhIBHXqBzR0/Zd2QwQ/l4Gxftt/8wY3grcc/nS//TVk
# ej9nmUYu83BDtccHHXKibMs/yXHhDXNkoPIdynhVAku7aRZOwqw6pDGCBTcwggUz
# AgEBMGEwSjELMAkGA1UEBhMCU0UxGjAYBgNVBAoTEUt1bmdzYmFja2Ega29tbXVu
# MR8wHQYDVQQDExZLdW5nc2JhY2thIElzc3VpbmcgQ0EyAhN6AAAaSHUP2Gj50Lin
# AAAAABpIMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKEC
# gAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIAx/wTly2IvE6QjeEXjrdq308jhP
# bieQgM7wlLG1lJL9MA0GCSqGSIb3DQEBAQUABIIBAIa2IqvzV14roJsgyC06S9g4
# U/dubQtn8STFslAKorAZtPnP5qhyAKLf8oi+uUyvqDMdsRg6mmJXwMNR5HzFBq03
# rpdGuWXYOiWg6JNjKiJpcel9z13dVnyoT1mHnrOJgpALkantS1zugQs0R0WK/c5F
# HBPFdlt8VsgGo+UE8EGyLvF6Qj+v6yvFhfVyGCxxQPMPW79jk6tU0a0rwogtDt/B
# ezuv0IP+DJ82JMA7Qp9DrFwvuxFBkHiGY3rDCznZo8atwFR96FOPFl+OOisDD6nA
# jsJHxKORbHUQq/mKlGIMfDDO85OSekvueKhY1DUcPntPT5OCA9+QOzC+NzMi18mh
# ggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0
# ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhALrma8Wrp/lYfG
# +ekE4zMEMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEH
# ATAcBgkqhkiG9w0BCQUxDxcNMjUwMzEyMjA0ODMzWjAvBgkqhkiG9w0BCQQxIgQg
# n/1tG0g7ky0tG5TPMmlvjQZaB80bs/rxAdRTxn0p8WQwDQYJKoZIhvcNAQEBBQAE
# ggIAjHtRbNnPK88y86mrxH7vJJUUvHI6tF0jKTOu5HcU1PiDAVtUIR4PC5YCCOkV
# mF2nUXLjfOhA75mF7gAGpy+l2B/7S9HIhoH8/QreaZeQd4kGIRv57RjeBSrtast/
# /JIU2cfF9bgKk1LXdVAgp2TUBOgj71tbkPDn3oVfq81zmGAap8rsbMtnRuTLCBTQ
# 7IbvRt7IWxYb5yPe16EtkPDBTsHk41dcDBaUeDY+tPZseP23J85DblF0lwuYAaER
# Ws088E/3KtOlh6HXxN4WwJeTtCt+J9vBWwsQ3ut8WeWo6og5WXKFPiaMhxbxbXQ+
# HKOUDzbXA1+/t7I8PX+Yv4OV1XdMvLpG9iuVkW3WsE+Ck/oz4LwHpaLaUm/T2XGY
# yLs65ZjG6ORN1ag1cpwYYoVxDVxDB50Mnk4W5hneCNgymTlk2fLg93BlO3ml4e/H
# E1PXSl+HijXNqGn7uWB+DYP/UBuHNKf30/iWPlaZuElhswBkXX+Qj02JRLlpxiG9
# Xf2l5fOUBsmJYGr9syxYcNPsVC3edNUTdIvjPt5JDyJ4aJK3XNo5R8ORpCLFgiRv
# M96VMoA9lREj7US0ep0oG3bNFUijzfhOl11zo5mK+4efrMkzif3B/amMsiHTZ8b5
# hpcBrRmQH2DMhSHXOtk4G646fRUqzFCE3WOphy1OAtvpDrA=
# SIG # End signature block
