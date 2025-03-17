# PSGrouper

## Description

Grouper manages group membership for on-premises AD groups, Entra ID groups, Exchange Online (EXO) distribution groups and OpenE Platform.

This is the PowerShell module that is used for creating and updating Grouper documents. It can also be used to read logs.
The core functionality of Grouper is found [here](https://github.com/Kungsbacka/Grouper)

## Dependencies

The module uses parts of the GrouperLib for document handling. Since GrouperLib is currently built for .NET 9, PSGrouper needs PowerShell 7.5
or later to work.

PSGrouper uses the [Grouper API](https://github.com/Kungsbacka/Grouper/tree/master/GrouperApi) to perform most tasks and this
must be up and running before PSGrouper can be used.

## Build & deploy

Run Build.ps1 to make either a release build or a debug build. A release build builds necessary components of GrouperLib, creates a file catalog,
signs the catalog and relevant module files with a code signing certificate (must be in the current user's certificate store), and finally
creates a zip file with all files that need to be distributed to the client.

A debug build only builds GrouperLib and puts the resulting binaries in a lib folder for debugging purposes.

## Working with Grouper documents

Below are some examples of how to perform common tasks. Take a look at the help for each function for more information.

Before you can use the PowerShell module you have to connect to the API using Connect-GrouperApi.

```PowerShell
# Connect to the API
Connect-GrouperApi -Uri 'https://api-server/path/to/api'

# Process a single document
Get-GrouperDocumentEntry -GroupName 'My Group' | Invoke-Grouper

# Process all published documents in the database
Get-GrouperDocumentEntry -All | Invoke-Grouper

# Edit a document, save and publish in one go
Get-GrouperDocumentEntry -GroupName 'My Group' | Edit-GrouperDocument | Save-GrouperDocument -Publish

# Create a new document, edit and save (without publishing)
# A new document always contains one member object (static) as a placeholder just to make the document valid.
# Remove or edit the member object to match your needs.
New-GrouperDocument -GroupId '4a31e904-a33a-476e-95da-4d0ec7ab602a' -GroupName 'My Group' -Store AzureAd | Edit-GrouperDocument | Save-GrouperDocument

# It is also possible to create new documents by hand. Create a document in your favorite text editor,
# save the document as a JSON file
Get-Content document.json | ConvertTo-GrouperDocument | Save-GrouperDocument

# ...or straight from the clipboard
Get-Clipboard | ConvertTo-GrouperDocument | Save-GrouperDocument

# To check if a document is valid before converting, use Test-GrouperDocument
Get-Content document.json | Test-GrouperDocument -OutputErrors
```

## Grouper document

A Grouper document contains all information required by Grouper to process a single group.
Name, ID and Store are required properties. The document must also contain at least one
member object that describes the members that the group should contain.

Interval is used by the GrouperService as a recommended (but not contractual) processing
interval in minutes for a document. GrouperProcess will try to process the document in
the given interval. A document with an interval of zero (default) will be processed either
when GrouperService does a full pass through all published documents, or when the document
is updated in the document database.

A full pass is done three times a day (at 6 am, 12 pm and 4 pm). This is hardcoded into the
service (see method ShouldProcessAllDocuments), but may be configurable at a later time.

Below is an example where the group lives in Entra ID and the members come from a student
roster (elevregister).

```Json
{
  "id": "1c5ec8b9-05e6-467a-969c-fa9be4513126",
  "interval": 30,
  "groupId": "4a31e904-a33a-476e-95da-4d0ec7ab602a",
  "groupName": "Elever i klass 7A på Testskolan",
  "id": "4afb1b58-0e20-4cb8-832b-9bbfed0b8d02",
  "store": "AzureAd",
  "owners": "KeepAll",
  "members": [
    {
      "source": "Elevregister",
      "action": "Include",
      "rules": [
        {
          "name": "Roll",
          "value": "Elev"
        },
        {
          "name": "Klass",
          "value": "EG_41e60dc2-1300-471d-a3a9-674664320e25"
        }
      ]
    }
  ]
}
```

Grouper documents can be stored anywhere, but some of the PowerShell cmdlets, the API and
the service can only work with documents stored in the Grouper database.

## Member sources

The following member sources are recognized by Grouper

* __Personalsystem__: members from employees in selected parts of the organization. Befattning (title)
can be used to filter members.
* __Elevregister__: members from Procapita/IST Administration. A combination of role, school,
class, group or year can be used.
* __Static__: Explicitly add members to a group by listing the UPN for each member.
* __CustomView__: Get members from a custom database view.
* __AzureAdGroup__: Get members from an Entra ID group.
* __ExoGroup__: Get members from an Exchange Online distribution group.
* __OnPremAdGroup__: Get members from an on-premises Active Directory group.
* __OnPremAdQuery__: Get members from an on-premises Active Directory LDAP query (with optional search base)

The first four sources requires access to a member database (e.g. a metadirectory) that can output
relevant user identities, but the last four only requires access to their respective catalog
(Entra ID, on-premises AD or Exchange Online).

## Group stores

Grouper can work with groups in the following locations:

* on-premises Active Directory
* Entra ID
* Exchange Online (distribution groups)
* OpenE Platform
