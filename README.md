# PSGrouper

## Description

Grouper manages group membership for on-premises AD groups, Entra ID groups, Exchange Online (EXO) distribution groups and OpenE Platform.

This is the PowerShell module that is used for creating and updating Grouper documents. It can also be used to read logs.
The core functionality of Grouper is found in the [Grouper](https://github.com/Kungsbacka/Grouper) repo.

## Dependencies

The module uses parts of the GrouperLib for document handling. GrouperLib is built for .NET 10, so PSGrouper needs PowerShell 7.6
or later.

PSGrouper uses the [Grouper API](https://github.com/Kungsbacka/Grouper/tree/master/GrouperApi) to perform most tasks and this
must be up and running before PSGrouper can be used.

## Build & deploy

Run Build.ps1 to make either a release build or a debug build. A release build builds necessary components of GrouperLib, creates a file catalog,
signs the catalog and relevant module files with a code signing certificate (must be in the current user's certificate store), and finally
creates a zip file with all files that need to be distributed to the client.

A debug build only builds GrouperLib and puts the resulting binaries in a lib folder for debugging purposes.

## Working with Grouper documents

Below are some examples of how to perform common tasks. Take a look at the help for each function for more information.

Before you can use the PowerShell module you have to connect to the API using Connect-Grouper.

```PowerShell
# Connect to the API. For convenience, you can store the URI in $PSDefaultParameterValues in you PowerShell profile.
Connect-Grouper -Uri 'https://api-server/path/to/api'

# Process a single document
Get-GrouperDocument -GroupName 'My Group' | Invoke-Grouper

# Process all published documents in the database
Get-GrouperDocument -All | Invoke-Grouper

# Edit a document, save and publish in one go
Get-GrouperDocument -GroupName 'My Group' | Edit-GrouperDocument | Save-GrouperDocument -Publish

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
interval in minutes for a document. GrouperService will try to process the document in
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
  "store": "AzureAd",
  "owner": "KeepExisting",
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

A member object says where a group's members should come from. The `source` property selects one of
eight member sources, and the `rules` list narrows down which people that source should return.

* __Personalsystem__: employees from selected parts of the organization. Befattning (job title) can
  be used to narrow the selection further.
* __Elevregister__: pupils and school staff from Procapita/IST Administration. A combination of role,
  school unit, class, group and year can be used.
* __Static__: members listed explicitly, one UPN at a time.
* __CustomView__: members from a custom database view.
* __AzureAdGroup__: members of an Entra ID group.
* __ExoGroup__: members of an Exchange Online distribution group.
* __OnPremAdGroup__: members of an on-premises Active Directory group.
* __OnPremAdQuery__: the result of an on-premises Active Directory LDAP query, with an optional
  search base.

The first four sources need access to a member database, such as a metadirectory, that can turn the
selection into user identities. The last four only need access to the directory they read from, which
is Entra ID, on-premises AD or Exchange Online.

### Which rules each source accepts

Not every rule name works with every source, and for some sources not every combination of rule names
is allowed. The rules are checked when the document is validated, so a mistake here is caught by
`Test-GrouperDocument` before the document is ever saved.

| Source | Rule names | How they may be combined |
| --- | --- | --- |
| `Personalsystem` | `Organisation`, `Befattning`, `IncludeManager` | At least one of `Organisation` and `Befattning` is required. `IncludeManager` can only be used together with `Organisation`. |
| `Elevregister` | `Roll`, `Enhet`, `Klass`, `Grupp`, `Skolform`, `Årskurs` | At least one rule is required. All rules narrow the selection further. `Klass`, `Grupp` and the pair `Skolform`/`Årskurs` are three alternative ways to name a set of people, so only one of the three may be used. See below. |
| `Static` | `Upn` | Required. May be repeated to list several members. |
| `CustomView` | `View` | Required. |
| `AzureAdGroup` | `Group` | Required. Cannot name the document's own group. |
| `OnPremAdGroup` | `Group` | Required. Cannot name the document's own group. |
| `ExoGroup` | `Group` | Required. Cannot name the document's own group. |
| `OnPremAdQuery` | `LdapFilter`, `SearchBase` | `LdapFilter` is required. `SearchBase` is optional. |

### Rule names are case-sensitive

A rule name has to be spelled exactly as it appears in the table above, including its capital
letters. `Organisation` is correct, and `organisation` is rejected as an unknown rule name.

Rule *values*, on the other hand, are not case-sensitive. `Roll` accepts `Elev` and `elev` equally.

### Value formats

| Rule name | Accepted value | May be repeated |
| --- | --- | --- |
| `Befattning` | Any text. No format is checked. | Yes |
| `Enhet` | The school unit's identifier, __not its name__. Either an external ID such as `ARA` or `ELOF`, or a GUID, optionally with the prefix `S` or `S_` | No |
| `Group` | A GUID, written with hyphens | No |
| `Grupp` | A GUID, or a GUID with the prefix `FG` or `FG_` | No |
| `IncludeManager` | `true` or `false` | No |
| `Klass` | A GUID, or a GUID with the prefix `EG` or `EG_` | No |
| `LdapFilter` | Any text. No format is checked. | No |
| `Organisation` | `011J` followed by exactly eight more characters, each a digit or a letter A–Z. Twelve characters in total, for example `011JABCDEF12`. | No |
| `Roll` | `Personal` or `Elev` | No |
| `SearchBase` | Any text. No format is checked. | No |
| `Skolform` | `FSK`, `GR`, `GRSÄR`, `GY` or `GYSÄR` | No |
| `Upn` | A user principal name, in the form `user@domain.tld` | Yes |
| `View` | Any text. No format is checked. | No |
| `Årskurs` | A single character: a digit from `0` to `9`, or the letter `F` for förskoleklass | Yes |

A few notes on this table:

* __A GUID must be written with hyphens__, in the usual `8-4-4-4-12` form. A GUID without hyphens is
  rejected.
* __No value may be empty__, even for the rules where no format is checked.
* __A rule name marked "may be repeated" can appear several times__ in the same member object, and
  the results are added together. All other names may appear only once. Repeating the same name *and*
  the same value is always rejected, because the second copy adds nothing.
* __Values are checked for format only, never for existence.__ A `Klass` value can be a
  well-formed GUID that belongs to no class at all. Such a document is valid, and it simply
  contributes no members when the group is processed.

### Elevregister in more detail

`Elevregister` has six rule names. Every one of them narrows the selection, and they combine with
"and" rather than "or". A member object with both `Roll` and `Enhet` therefore selects the people who
match *both* of them.

You can use as few or as many of the six as you like, subject to the one restriction described below.
A single rule is a perfectly normal way to start, and it gives a broad selection:

| Rules used | What is selected |
| --- | --- |
| `Roll` = `Elev` | Every pupil, at every school |
| `Enhet` = one school unit | Everybody at that school unit, pupils and staff alike |
| `Roll` = `Elev` and `Enhet` = one school unit | The pupils at that school unit |
| `Klass` = one class | Everybody connected to that class, which includes its staff |
| `Roll` = `Elev` and `Klass` = one class | The pupils in that class, and nobody else |
| `Roll` = `Personal` and `Klass` = one class | Only the staff attached to that class |

Be aware that the first two of those select very large groups. Use `Get-GrouperMemberDiff` to see how
many people a selection actually produces before publishing the document.

#### Roll decides whether you get pupils, staff, or both

This is worth its own note, because leaving `Roll` out is easy to do and the result is not obvious.

`Enhet`, `Klass`, `Grupp` and `Skolform` all select __everybody connected to__ whatever they name.
That includes the teachers, mentors and other staff attached to a class or a group, not only the
pupils. A member object with `Klass` alone therefore produces a group containing both.

`Roll` is the rule that narrows this down. It works by excluding the role you did not ask for:

| `Roll` | Who is selected |
| --- | --- |
| Not used | Both pupils and staff |
| `Elev` | Pupils only. Staff are excluded. |
| `Personal` | Staff only. Pupils are excluded. |

None of the three is wrong, and each is useful for something. A class group intended for pupils will
usually want `Roll` = `Elev`, while a group meant for everybody around a class does not need `Roll` at
all.

__You cannot use `Roll` twice to ask for both roles.__ `Roll` may appear only once in a member object,
and a second one is rejected when the document is validated. To select both, leave `Roll` out
altogether.

#### Årskurs selects pupils only

A year belongs to a pupil's enrolment, so staff have no `Årskurs` at all. Any member object that uses
`Årskurs` therefore selects pupils, whatever `Roll` says.

This has one consequence worth remembering: __`Roll` = `Personal` together with `Årskurs` selects
nobody.__ The document is valid and saves without any complaint, and the group simply comes out empty.

`Skolform` does not behave this way. Staff belong to a school form, so `Skolform` selects staff as well
as pupils. If you want the staff at a particular school form, use `Skolform` and leave `Årskurs` out.

#### The one restriction

Four of the rule names — `Klass`, `Grupp`, `Skolform` and `Årskurs` — describe *which set of people
within a school* you want. There are three alternative ways to express that, and they cannot be
combined with each other:

1. `Klass` — one specific class
2. `Grupp` — one specific group
3. `Skolform`, `Årskurs`, or both together — a school form, a year, or a year within a school form

Only one of these three alternatives may be used in the same member object, because two of them
together would contradict each other. If you combine `Klass` with `Skolform`, the document is rejected
with the message *"These rule names cannot be used together for member source Elevregister: Klass,
Skolform"*.

Two things about this restriction are easy to miss:

* __`Roll` and `Enhet` are not part of it.__ Either of them may be combined with any of the three
  alternatives, and either may also be used on its own.
* __`Skolform` and `Årskurs` count as one alternative, not two.__ Using both of them together is
  allowed, and so is using either one on its own.

Finally, every member object needs at least one rule. An `Elevregister` member object with no rules at
all is rejected.

Some valid examples:

```Json
{ "source": "Elevregister", "action": "Include", "rules": [
  { "name": "Roll", "value": "Elev" },
  { "name": "Klass", "value": "EG_41e60dc2-1300-471d-a3a9-674664320e25" }
] }
```

All pupils in one class. Without the `Roll` rule, this would also include the staff attached to the
class.

```Json
{ "source": "Elevregister", "action": "Include", "rules": [
  { "name": "Roll", "value": "Elev" },
  { "name": "Enhet", "value": "41e60dc2-1300-471d-a3a9-674664320e25" },
  { "name": "Årskurs", "value": "7" },
  { "name": "Årskurs", "value": "8" }
] }
```

All pupils in years 7 and 8 in compulsory school at one school unit. `Årskurs` may be repeated, so
this selects both years.

```Json
{ "source": "Elevregister", "action": "Include", "rules": [
  { "name": "Roll", "value": "Personal" },
  { "name": "Enhet", "value": "ARA" }
] }
```

Staff rather than pupils, at one school unit.

### Personalsystem in more detail

`Personalsystem` selects employees. `Organisation` is a Personec organisation code, and `Befattning`
is a job title.

You need at least one of the two. Using `Organisation` on its own selects everybody in that part of
the organization. Using `Befattning` on its own selects everybody with that job title, anywhere.
Using both together selects people who match both.

`Befattning` may be repeated, and repeating it widens the selection. Two `Befattning` rules select
people holding either of the two titles.

`IncludeManager` adds the manager of the selected organisation to the group. Because a manager is
always the manager *of* something, `IncludeManager` can only be used when `Organisation` is also
present. A member object with `Befattning` and `IncludeManager` but no `Organisation` is rejected
with the message *"Rule name IncludeManager can only be used together with Organisation"*.

```Json
{ "source": "Personalsystem", "action": "Include", "rules": [
  { "name": "Organisation", "value": "011JABCDEF12" },
  { "name": "Befattning", "value": "Lärare" },
  { "name": "Befattning", "value": "Rektor" },
  { "name": "IncludeManager", "value": "true" }
] }
```

Teachers and principals in one part of the organization, plus that organisation's manager.

### The three directory group sources

`AzureAdGroup`, `OnPremAdGroup` and `ExoGroup` all work the same way. Each takes a single `Group`
rule whose value is the GUID of the group to read members from.

None of them may name the document's own group. A document that used its own target group as a member
source would depend on itself, so this is rejected with *"The same group cannot be used both as
member source and target group"*.

```Json
{ "source": "AzureAdGroup", "action": "Include", "rules": [
  { "name": "Group", "value": "cc33dd44-ee55-ff66-1122-334455667788" }
] }
```

### Static, CustomView and OnPremAdQuery

`Static` lists members individually. The `Upn` rule may be repeated once per member.

```Json
{ "source": "Static", "action": "Include", "rules": [
  { "name": "Upn", "value": "first.last@example.com" },
  { "name": "Upn", "value": "other.person@example.com" }
] }
```

`CustomView` reads members from a database view. The `View` rule names the view.

`OnPremAdQuery` runs an LDAP query. `LdapFilter` is required and `SearchBase` is optional. When no
search base is given, the query runs from the directory's default location.

```Json
{ "source": "OnPremAdQuery", "action": "Include", "rules": [
  { "name": "LdapFilter", "value": "(&(objectClass=user)(department=IT))" },
  { "name": "SearchBase", "value": "OU=Users,DC=example,DC=com" }
] }
```

__Values for these three sources are not checked at all.__ A malformed LDAP filter, or the name of a
view that does not exist, will pass validation without complaint. The problem then appears when the
group is processed, and it is written to the event log rather than reported by
`Test-GrouperDocument`. If a document using one of these sources produces no members, the event log
is the place to look.

## Group stores

The `store` property says where the group itself lives. Grouper can write to four kinds of group:

| Store | What it is |
| --- | --- |
| `OnPremAd` | An on-premises Active Directory group |
| `AzureAd` | An Entra ID group |
| `Exo` | An Exchange Online distribution group |
| `OpenE` | A group in Open ePlatform |

### Not every source works with every store

A group can only contain members of a kind it is able to hold, so some combinations of store and
member source are rejected when the document is validated.

| Member source | Works with these stores |
| --- | --- |
| `OnPremAdGroup`, `OnPremAdQuery` | `OnPremAd` and `OpenE` |
| `AzureAdGroup`, `ExoGroup` | `AzureAd` and `Exo` |
| `Personalsystem`, `Elevregister`, `Static`, `CustomView` | All four |

In other words, the on-premises sources and the cloud sources cannot cross over, while the four
sources that read from the member database work anywhere. Mixing them produces the message *"Invalid
combination of group store and member source"*.

### Why the on-premises and cloud sources cannot cross over

This is a deliberate decision, not a technical limitation. Grouper's member database knows both
identifiers for most people, the on-premises Active Directory GUID and the Entra ID GUID, so it could
in principle translate between them and let an on-premises group control an Entra ID group.

The difficulty is that the translation is not always possible, because not every account exists on
both sides:

* An on-premises user who has not been synchronised to Entra ID has no Entra ID GUID, so that person
  cannot be added to an Entra ID group.
* A cloud-only user has no on-premises GUID, so that person cannot be added to an on-premises group.

If crossing over were allowed, Grouper would have to pick one of two behaviours every time it met such
an account, and neither one is good:

* __Skip the account silently.__ The group would be quietly incomplete, and nobody would be told which
  people were missing or why.
* __Report an error.__ A single unsynchronised account would block every update to that group,
  including all the changes that had nothing to do with that account.

Rejecting the combination while the document is being validated avoids both outcomes. The author is
told immediately, at the point where the choice of source can still be changed, instead of finding out
much later that a group has been quietly missing people or has stopped updating altogether.

#### The member database sources behave differently

The four sources that read from the member database — `Personalsystem`, `Elevregister`, `Static` and
`CustomView` — work with any store. Each person they return is resolved to whichever identifier the
target group needs. When somebody has no account in that directory at all, __they are silently left
out__.

For example, an `Elevregister` document targeting an Entra ID group will not contain a pupil who has
never been synchronised to Entra ID. The document is valid, the group updates without reporting any
error, and the member count is simply lower than expected. The same applies in the other direction: a
document targeting an on-premises group leaves out anybody who has no on-premises account.

This is the same "skip silently" outcome as above, reached by a different route. The difference is that
here the member database is the only record of who exists, so a missing identifier means the person
genuinely has no account in the directory the group lives in.

__If a group contains fewer people than you expected, an account that has not synchronised is the first
thing to check.__ Compare the group against its source with `Compare-GrouperDocumentAgainstStore`, or
look at what a document would produce with `Get-GrouperMemberDiff`.

## How Grouper decides who belongs in a group

A document can contain several member objects, and each one either includes people or excludes them.
The order in which they are applied is fixed, and it is not the order they appear in the document.
Understanding that order is the most important thing to know when authoring a document, because it
decides what happens when two member objects disagree about the same person.

### The four steps

Grouper builds the list of members it wants the group to contain in four steps:

1. Collect everybody from the __include__ member objects, except those using the `Static` source.
2. Remove everybody from the __exclude__ member objects, except those using the `Static` source.
3. Add everybody from the __`Static` include__ member objects.
4. Remove everybody from the __`Static` exclude__ member objects.

The consequence is that __`Static` membership always wins.__ A rule cannot exclude somebody that a
`Static` include has listed, because the `Static` include is applied afterwards. In the same way, a
`Static` exclude cannot be undone by anything, because nothing comes after it.

### A worked example

Suppose class 7A contains Anna, Bertil and Cecilia, and the document looks like this:

```Json
"members": [
  { "source": "Elevregister", "action": "Include", "rules": [
    { "name": "Roll", "value": "Elev" },
    { "name": "Klass", "value": "EG_41e60dc2-1300-471d-a3a9-674664320e25" }
  ] },
  { "source": "Static", "action": "Include", "rules": [
    { "name": "Upn", "value": "david@example.com" }
  ] },
  { "source": "Static", "action": "Exclude", "rules": [
    { "name": "Upn", "value": "cecilia@example.com" }
  ] }
]
```

Grouper works through it like this:

| Step | What happens | Members so far |
| --- | --- | --- |
| 1 | The `Elevregister` include returns class 7A | Anna, Bertil, Cecilia |
| 2 | No non-static exclude rules | Anna, Bertil, Cecilia |
| 3 | The `Static` include adds David | Anna, Bertil, Cecilia, David |
| 4 | The `Static` exclude removes Cecilia | Anna, Bertil, David |

David is a member since he is selected by the static rule, and Cecilia is not a member even though the class
rule did select her.

Now consider what would happen if the exclude were a rule rather than a `Static` entry. If a second
`Elevregister` member object with `"action": "Exclude"` had matched David, David would still end up in
the group. The rule exclude runs in step 2, and the `Static` include that adds him runs in step 3.

__When two member objects disagree, later steps win.__ If you need something to be excluded no matter
what, use a `Static` exclude.

Use `Get-GrouperMemberDiff` to see the result of all four steps before anything is written:

```PowerShell
Get-GrouperDocument -GroupName 'My Group' | Get-GrouperMemberDiff
```

### Documents with only exclude rules

Normally step 1 starts from an empty list. There is one exception. If a document contains __no
include member objects at all__, step 1 starts from the group's __current__ members instead.

Without this exception such a document would empty the group, because there would be nothing to
subtract from. With it, the document means "keep whoever is in this group, but make sure these people
are never in it".

This exists to support a pair of groups that must not overlap:

* Group A has one document with an __include__ rule for everybody in department A. Group A is
  therefore managed automatically.
* Group B has one document with an __exclude__ rule for everybody in department A. Group B can be
  managed by hand, and members can be added and removed freely, but Grouper guarantees that nobody
  from department A ever stays in it.

Note that a document like this still processes on its normal schedule, and it removes anybody
matching the exclude rule each time it runs.

### Group owners

The `owner` property decides whether the group's owners are protected from being removed as members.
It has three possible values:

| Value | What it does |
| --- | --- |
| `KeepExisting` | Owners who are already members stay members. Owners who are not members are not added. This is the default. |
| `AddAll` | All owners are added as members, whether they were members before or not. |
| `MatchSource` | Owners get no special treatment. Membership is exactly what the four steps produced, so an owner who is not selected by any rule is removed. |

Two things are worth knowing about how this is applied.

First, owners are handled __after__ all four steps, so an exclude rule naming an owner does not keep
that owner out of the group when `owner` is `AddAll` or `KeepExisting`.

Second, __owners are only resolved for Entra ID groups.__ Entra ID is currently the only store that
can report group owners, so for `OnPremAd`, `Exo` and `OpenE` documents the `owner` property has no
effect at all, whatever it is set to.

### The change ratio guard

Before writing anything, Grouper compares the size the group *would* have against the size it has
now:

```code
change ratio = resulting number of members / current number of members
```

If that ratio falls below a limit configured on the server, Grouper refuses to write and reports
`ChangeRatioException` instead. The change is not applied, and the failure appears in the event log.

Some examples, assuming a limit of `0.5`:

| Current members | Resulting members | Ratio | Result |
| --- | --- | --- | --- |
| 100 | 120 | 1.2 | Written. Growth always passes. |
| 100 | 100, but all different people | 1.0 | Written. See below. |
| 100 | 60 | 0.6 | Written. |
| 100 | 40 | 0.4 | __Refused.__ |
| 0 | 50 | — | Written. An empty group is never blocked. |

The guard protects against one specific failure: a member source that returns no data, or only part
of its data, because of a problem upstream. That always shows up as the group suddenly becoming much
smaller, which is exactly what this measure catches.

It deliberately does __not__ react to members being replaced. A group whose entire membership changes
while its size stays the same gives a ratio of 1.0 and is written without complaint. This is
intentional: many education groups replace all of their members at the start of a new school year, and
an earlier version of this check flagged so many groups every August that they all had to be reviewed
and re-run by hand.

If you have looked at the difference and you are satisfied it is correct, `Invoke-Grouper -Force`
writes it anyway:

```PowerShell
# Look at what would change first
Get-GrouperDocument -GroupName 'My Group' | Get-GrouperMemberDiff

# Then apply it, ignoring the change ratio limit
Get-GrouperDocument -GroupName 'My Group' | Invoke-Grouper -Force
```
