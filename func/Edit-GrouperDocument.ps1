<#
    .SYNOPSIS
        Opens a Grouper document in an editor window

    .DESCRIPTION
        Opens a window where a Grouper document can be edited as JSON. The document is validated
        as you type and the errors are listed below the editor, so there is no need to look for
        them in the console. Double-clicking an error moves the caret to the line it concerns,
        when that line can be worked out.

        Validation runs in this process, using the same GrouperLib that the API uses, so nothing
        here needs a connection to tell you whether a document is valid. The editor is a little
        stricter than the library in one respect: a property written twice in the same object is
        reported as an error, where the library would quietly keep the last one and discard the
        rest.

        Next validates the document and writes it to the pipeline. Skip discards the current
        document and loads the next one. Cancel discards the current document and stops processing
        the rest. Closing the window has the same effect as Cancel.

        Format rewrites the document the way Grouper itself writes it.

        Diff and Check group are the two buttons that need the API, because only the server can read
        the group. Diff lists the members that would be added and removed if the document were
        processed now, in the lower of the two lists, and empties that list again as soon as the
        document is edited, since it no longer describes what is on screen. Checking the "Unchanged"
        check box makes Diff also return members that will not change (they will stay in the group).
        Check group looks the group up in the store and reports whether it is still there; when it
        is there under a different name, the name in the document is replaced with the store's, as
        a single edit that Ctrl+Z undoes. Without a connection the editor still opens and everything
        else still works; those two buttons are greyed out, and their tooltips say why.

        The buttons on the second row put a new GUID, a member object for the source chosen next to
        it, or a rule with the name chosen next to it, at the caret. Inserted text is indented to
        match the line the caret is on, and for a member object or a rule the caret is left inside
        the first empty value so that the value can be typed straight away.

        Holding Ctrl while turning the mouse wheel over the text changes its size.

    .PARAMETER InputObject
        Grouper document or database document entry

    .INPUTS
        (see InputObject)

    .OUTPUTS
        Grouper document (if 'Next' button is pressed. 'Skip' och 'Cancel' will not produce any output)

    .EXAMPLE
        Get-GrouperDocument -GroupName 'MyGroup' | Edit-GrouperDocument | Save-GrouperDocument

    .LINK
        New-GrouperDocument

    .LINK
        Test-GrouperDocument

    .LINK
        Save-GrouperDocument

    .LINK
        Get-GrouperDocument
#>
function Edit-GrouperDocument
{
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [object]
        $InputObject
    )

    begin {
      # Deliberately nothing here that refuses to open the editor. Validation runs in this process,
      # so editing needs no connection; only Diff does, and that button is disabled further down
      # when there is none.
      [xml]$xaml =
@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:ae="clr-namespace:ICSharpCode.AvalonEdit;assembly=ICSharpCode.AvalonEdit"
        Title="Document Editor" Height="950" Width="900">
    <Window.Resources>
        <!-- The button states, kept together so the set can be retuned in one place. Normal is the
             Background the button already carries; these three are what it changes to. -->
        <SolidColorBrush x:Key="ButtonHover" Color="#C9C9C9" />
        <SolidColorBrush x:Key="ButtonPressed" Color="#B0B0B0" />
        <SolidColorBrush x:Key="ButtonDisabled" Color="#EEEEEE" />
        <Style TargetType="Button">
            <Setter Property="Padding" Value="12,4" />
            <Setter Property="Margin" Value="0,0,6,0" />
            <Setter Property="MinWidth" Value="64" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Chrome"
                                Background="{TemplateBinding Background}"
                                CornerRadius="3"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center"
                                              VerticalAlignment="Center"
                                              RecognizesAccessKey="True" />
                        </Border>
                        <!-- Replacing the template also replaces every state the theme's template
                             drew: the button would otherwise look the same under the pointer, while
                             held down, and when disabled. The order matters, because a later trigger
                             wins: pressed beats hover, and disabled beats both. -->
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Chrome"
                                        Property="Background"
                                        Value="{StaticResource ButtonHover}" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Chrome"
                                        Property="Background"
                                        Value="{StaticResource ButtonPressed}" />
                            </Trigger>
                            <!-- Diff and Check group are disabled when there is no connection to the
                                 API, and this is the only thing that says so at a glance. -->
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Chrome"
                                        Property="Background"
                                        Value="{StaticResource ButtonDisabled}" />
                                <Setter Property="Foreground"
                                        Value="{DynamicResource {x:Static SystemColors.GrayTextBrushKey}}" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ComboBox">
            <Setter Property="Margin" Value="0,0,16,0" />
            <Setter Property="Padding" Value="6,3" />
            <Setter Property="VerticalAlignment" Value="Center" />
        </Style>

        <Style x:Key="GroupDivider" TargetType="Border">
            <Setter Property="Width" Value="1" />
            <Setter Property="Margin" Value="4,1,10,1" />
            <Setter Property="Background"
                    Value="{DynamicResource {x:Static SystemColors.ControlDarkBrushKey}}" />
        </Style>
    </Window.Resources>

    <Grid>
        <!-- Main layout:
             toolbar
             editor
             splitter between editor and lower section
             lower section containing both lists
             status bar -->
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" MinHeight="150" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="340" MinHeight="120" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>

        <Border Grid.Row="0"
                Padding="8,7"
                BorderThickness="0,0,0,1"
                BorderBrush="{DynamicResource {x:Static SystemColors.ControlDarkBrushKey}}">
            <StackPanel>
                <!-- What happens to the document that is open -->
                <StackPanel Orientation="Horizontal" Margin="0,0,0,7">
                    <Button x:Name="Next"
                            Content="_Next"
                            ToolTip="Validate and write the document to the pipeline" />
                    <Button x:Name="Skip"
                            Content="S_kip"
                            ToolTip="Discard this document and load the next one" />
                    <Button x:Name="Cancel"
                            Content="_Cancel"
                            ToolTip="Discard this document and stop processing" />

                    <Border Style="{StaticResource GroupDivider}" />

                    <Button x:Name="Format"
                            Content="_Format"
                            ToolTip="Rewrite the document the way Grouper writes it" />

                    <Border Style="{StaticResource GroupDivider}" />

                    <!-- ShowOnDisabled, because the tooltip is the only place that can explain
                         why these are greyed out when there is no connection. -->
                    <Button x:Name="Diff"
                            Content="_Diff"
                            ToolTipService.ShowOnDisabled="True"
                            ToolTip="Show the membership changes this document would cause" />

                    <CheckBox x:Name="IncludeUnchanged"
                              Content="Unchanged"
                              ToolTip="Include unchanged members in the diff report."
                              Margin="0,5,5,0" />

                    <Border Style="{StaticResource GroupDivider}" />

                    <Button x:Name="CheckGroup"
                            Content="C_heck group"
                            ToolTipService.ShowOnDisabled="True"
                            ToolTip="Look the group up in the store, and take its name into the document if they differ" />
                </StackPanel>

                <!-- What can be put into it at the caret -->
                <StackPanel Orientation="Horizontal">
                    <Button x:Name="InsertGuid"
                            Content="Insert GUID"
                            ToolTip="Insert a new random GUID at the caret" />

                    <Border Style="{StaticResource GroupDivider}" />

                    <Label Content="Member:"
                           Margin="-5,0,0,0"
                           FontWeight="SemiBold" />

                    <ComboBox x:Name="MemberSource"
                              Width="150"
                              ToolTip="Member source to insert" />

                    <Button x:Name="InsertMemberSource"
                            Content="Insert"
                            Margin="-5,0,4,0"
                            ToolTip="Insert a member object for the source selected to the right" />

                    <Border Style="{StaticResource GroupDivider}" />

                    <Label Content="Rule:"
                           Margin="-5,0,0,0"
                           FontWeight="SemiBold" />

                    <ComboBox x:Name="RuleName"
                              Width="140"
                              ToolTip="Rule name to insert" />

                    <Button x:Name="InsertRule"
                            Content="Insert"
                            Margin="-5,0,4,0"
                            ToolTip="Insert a rule with the name selected to the right" />
                </StackPanel>
            </StackPanel>
        </Border>

        <ae:TextEditor Grid.Row="1"
                       x:Name="JsonContent"
                       FontFamily="Consolas"
                       FontSize="14"
                       ShowLineNumbers="True"
                       WordWrap="False" />

        <!-- Resizes editor vs the entire lower section -->
        <GridSplitter Grid.Row="2"
                      Height="5"
                      HorizontalAlignment="Stretch"
                      VerticalAlignment="Center"
                      ResizeDirection="Rows"
                      ResizeBehavior="PreviousAndNext" />

        <!-- The two lists now have their own layout scope.
             The splitter inside here cannot affect the editor. -->
        <Grid Grid.Row="3">
            <Grid.RowDefinitions>
                <RowDefinition Height="*" MinHeight="60" />
                <RowDefinition Height="Auto" />
                <RowDefinition Height="*" MinHeight="60" />
            </Grid.RowDefinitions>

            <ListView Grid.Row="0"
                      x:Name="ErrorList">
                <ListView.View>
                    <GridView>
                        <GridViewColumn Header="Line"
                                        Width="45"
                                        DisplayMemberBinding="{Binding Line}" />
                        <GridViewColumn Header="Property"
                                        Width="150"
                                        DisplayMemberBinding="{Binding Property}" />
                        <GridViewColumn Header="Message"
                                        Width="640"
                                        DisplayMemberBinding="{Binding Message}" />
                    </GridView>
                </ListView.View>
            </ListView>

            <!-- Only redistributes space between ErrorList and DiffList -->
            <GridSplitter Grid.Row="1"
                          Height="5"
                          HorizontalAlignment="Stretch"
                          VerticalAlignment="Center"
                          ResizeDirection="Rows"
                          ResizeBehavior="PreviousAndNext" />

            <ListView Grid.Row="2"
                      x:Name="DiffList">
                <ListView.View>
                    <GridView>
                        <GridViewColumn Header="Change"
                                        Width="55"
                                        DisplayMemberBinding="{Binding Change}" />
                        <GridViewColumn Header="Member"
                                        Width="800"
                                        DisplayMemberBinding="{Binding Member}" />
                    </GridView>
                </ListView.View>
            </ListView>
        </Grid>

        <StatusBar Grid.Row="4">
            <StatusBarItem>
                <TextBlock x:Name="StatusPosition" />
            </StatusBarItem>
            <Separator />
            <StatusBarItem>
                <TextBlock x:Name="StatusValidation" />
            </StatusBarItem>
            <Separator />
            <StatusBarItem>
                <TextBlock x:Name="StatusCaret" />
            </StatusBarItem>
        </StatusBar>
    </Grid>
</Window>
"@

        # Snippets are stored without leading indentation. InsertSnippet indents them to match
        # the line the caret is on, so where they land no longer decides how they look.
        $memberSources = [ordered]@{}

        $memberSources['Personalsystem'] =
@"
{
  "source": "Personalsystem",
  "action": "Include",
  "rules": [
    {
      "name": "Organisation",
      "value": ""
    },
    {
      "name": "IncludeManager",
      "value": "true"
    }
  ]
}
"@
        $memberSources['Elevregister'] =
@"
{
  "source": "Elevregister",
  "action": "Include",
  "rules": [
    {
      "name": "Enhet",
      "value": ""
    },
    {
      "name": "Roll",
      "value": "Personal"
    }
  ]
}
"@
        $memberSources['OnPremAdGroup'] =
@"
{
  "source": "OnPremAdGroup",
  "action": "Include",
  "rules": [
    {
      "name": "Group",
      "value": ""
    }
  ]
}
"@
        $memberSources['OnPremAdQuery'] =
@"
{
  "source": "OnPremAdQuery",
  "action": "Include",
  "rules": [
    {
      "name": "LdapFilter",
      "value": ""
    }
  ]
}
"@
        $memberSources['AzureAdGroup'] =
@"
{
  "source": "AzureAdGroup",
  "action": "Include",
  "rules": [
    {
      "name": "Group",
      "value": ""
    }
  ]
}
"@
        $memberSources['ExoGroup'] =
@"
{
  "source": "ExoGroup",
  "action": "Include",
  "rules": [
    {
      "name": "Group",
      "value": ""
    }
  ]
}
"@
        $memberSources['CustomView'] =
@"
{
  "source": "CustomView",
  "action": "Include",
  "rules": [
    {
      "name": "View",
      "value": ""
    }
  ]
}
"@
        $memberSources['Static'] =
@"
{
  "source": "Static",
  "action": "Include",
  "rules": [
    {
      "name": "Upn",
      "value": ""
    }
  ]
}
"@
        # Which of these names a source actually accepts is known only to the validator, and that
        # knowledge is internal to GrouperLib, so the list is kept here instead. It is the same set
        # the README documents, in the same order. Picking a name that the chosen source does not
        # accept is not prevented, but it is reported in the error list straight away.
        $ruleNames = @(
            'Befattning'
            'Enhet'
            'Group'
            'Grupp'
            'IncludeManager'
            'Klass'
            'LdapFilter'
            'Organisation'
            'Roll'
            'SearchBase'
            'Skolform'
            'Upn'
            'View'
            'Årskurs'
        )

        function NewRuleSnippet([string]$name) {
@"
{
  "name": "$name",
  "value": ""
}
"@
        }

        try {
            $reader = New-Object -TypeName 'System.Xml.XmlNodeReader' -ArgumentList @($xaml)
            $window = [Windows.Markup.XamlReader]::Load($reader)
            $window.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen
        }
        finally {
            if ($reader) {
                $reader.Dispose()
            }
        }

        $editor = $window.FindName('JsonContent')
        $editor.SyntaxHighlighting = [ICSharpCode.AvalonEdit.Highlighting.HighlightingManager]::Instance.GetDefinition('Json')
        $editor.Options.ConvertTabsToSpaces = $true
        $editor.Options.IndentationSize = 2
        $editor.Options.EnableHyperlinks = $false
        $editor.Options.EnableEmailHyperlinks = $false

        # System.Text.Json accepts a repeated property by default and keeps the last one, which
        # discards the other without saying so. In a document being written by hand a repeated
        # property is a mistake, and one the author cannot see in the result, so the editor
        # refuses it here instead of validating something other than what is on screen.
        $jsonOptions = [System.Text.Json.JsonDocumentOptions]::new()
        $jsonOptions.AllowDuplicateProperties = $false

        # Used to write a group name back into the text as a JSON string. The relaxed encoder is the
        # one GrouperDocument.ToJson uses, so a name with a Swedish letter in it is written as itself
        # rather than as an escape sequence, the way the rest of the document is.
        $jsonStringOptions = New-Object -TypeName 'System.Text.Json.JsonSerializerOptions'
        $jsonStringOptions.Encoder = [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping

        $errorList = $window.FindName('ErrorList')
        $diffList = $window.FindName('DiffList')
        $statusPosition = $window.FindName('StatusPosition')
        $statusValidation = $window.FindName('StatusValidation')
        $statusCaret = $window.FindName('StatusCaret')
        $includeUnchanged = $window.FindName('IncludeUnchanged')

        # Populating the list from the snippet keys is what keeps the two from drifting apart,
        # and the keys are the source names that end up in the document.
        $memberSourceList = $window.FindName('MemberSource')
        foreach ($sourceName in $memberSources.Keys) {
            $null = $memberSourceList.Items.Add($sourceName)
        }
        $memberSourceList.SelectedItem = 'Static'

        $ruleNameList = $window.FindName('RuleName')
        foreach ($ruleName in $ruleNames) {
            $null = $ruleNameList.Items.Add($ruleName)
        }
        $ruleNameList.SelectedIndex = 0

        function GetContent() {
            $editor.Text
        }

        function SetContent($doc) {
            $editor.Text = $doc.ToJson($true)
        }

        # ValidationError only names the property, not where it sits in the text, so the line is
        # a hint found by looking for the matching JSON key rather than something authoritative.
        function FindKeyLine([string]$json, [string]$propertyName) {
            if ([string]::IsNullOrEmpty($propertyName)) {
                return $null
            }
            $key = $propertyName.Substring(0, 1).ToLowerInvariant()
            if ($propertyName.Length -gt 1) {
                $key += $propertyName.Substring(1)
            }
            $index = $json.IndexOf('"' + $key + '"', [System.StringComparison]::Ordinal)
            if ($index -lt 0) {
                return $null
            }
            ([regex]::Matches($json.Substring(0, $index), "`n")).Count + 1
        }

        function NewErrorRow($line, [string]$property, [string]$message) {
            [pscustomobject]@{
                Line = $line
                Property = $property
                Message = $message
            }
        }

        function ShowErrors([string]$summary, $rows) {
            $errorList.Items.Clear()
            foreach ($row in $rows) {
                $null = $errorList.Items.Add($row)
            }
            $statusValidation.Text = $summary
        }

        function NewDiffRow([string]$change, [string]$member) {
            [pscustomobject]@{
                Change = $change
                Member = $member
            }
        }

        function ShowDiff($rows) {
            $diffList.Items.Clear()
            foreach ($row in $rows) {
                $null = $diffList.Items.Add($row)
            }
        }

        # Validates in process. This is what runs while the user types, and at 0.3 ms a document
        # it is cheap enough to run on every pause. The API is only consulted on request.
        function ValidateLocal([string]$json) {
            $rows = New-Object -TypeName 'System.Collections.ArrayList'
            try {
                $jsonDocument = [System.Text.Json.JsonDocument]::Parse($json, $jsonOptions)
            }
            catch [System.Text.Json.JsonException] {
                # A syntax error carries a zero-based line. A repeated property carries no position
                # at all, only the name of the property in the message, so the line is looked up
                # from that name instead.
                $line = $null
                if ($null -ne $_.Exception.LineNumber) {
                    $line = [int]$_.Exception.LineNumber + 1
                }
                else {
                    $quoted = [regex]::Match($_.Exception.Message, "'([^']+)'")
                    if ($quoted.Success) {
                        $line = FindKeyLine $json $quoted.Groups[1].Value
                    }
                }
                $null = $rows.Add((NewErrorRow $line 'JSON' $_.Exception.Message))
                return [pscustomobject]@{ Rows = $rows; Document = $null }
            }
            finally {
                if ($jsonDocument) {
                    $jsonDocument.Dispose()
                }
            }

            $validationErrors = New-Object -TypeName 'System.Collections.Generic.List[GrouperLib.Core.ValidationError]'
            $document = $null
            $unexpected = $null
            try {
                $document = [GrouperLib.Core.GrouperDocument]::FromJson($json, $validationErrors)
            }
            catch {
                # Validation runs on a timer while a document is still being typed, so anything the
                # validator did not expect has to end up in the list rather than escape into the
                # dispatcher, where it would surface as a crash with no obvious cause.
                $unexpected = $_.Exception.Message
            }

            foreach ($validationError in $validationErrors) {
                $null = $rows.Add((NewErrorRow (FindKeyLine $json $validationError.PropertyName) $validationError.PropertyName $validationError.ErrorMessage))
            }

            if ($null -ne $unexpected) {
                $document = $null
                $null = $rows.Add((NewErrorRow $null 'Document' "The document could not be checked: $unexpected"))
            }

            [pscustomobject]@{ Rows = $rows; Document = $document }
        }

        function RefreshValidation() {
            $result = ValidateLocal (GetContent)
            if ($result.Rows.Count -eq 0) {
                ShowErrors 'Document is valid' @()
            }
            else {
                ShowErrors "$($result.Rows.Count) error(s)" $result.Rows
            }
            $result
        }

        # PlaceCaretAfter leaves the caret inside the first empty value rather than after the whole
        # snippet, so the value can be typed without moving there first. It falls back to the end of
        # the snippet when the marker is not part of the text, as it is not for a bare GUID.
        function InsertSnippet([string]$text, [string]$placeCaretAfter) {
            $line = $editor.Document.GetLineByOffset($editor.CaretOffset)
            $indent = [regex]::Match($editor.Document.GetText($line.Offset, $line.Length), '^[ \t]*').Value
            $lines = $text -split "`r?`n"
            $builder = New-Object -TypeName 'System.Text.StringBuilder'
            $null = $builder.Append($lines[0])
            for ($i = 1; $i -lt $lines.Count; $i++) {
                $null = $builder.Append("`r`n").Append($indent).Append($lines[$i])
            }
            $snippet = $builder.ToString()
            $start = $editor.SelectionStart
            $editor.Document.Replace($start, $editor.SelectionLength, $snippet)
            $caret = $start + $snippet.Length
            if (-not [string]::IsNullOrEmpty($placeCaretAfter)) {
                $marker = $snippet.IndexOf($placeCaretAfter, [System.StringComparison]::Ordinal)
                if ($marker -ge 0) {
                    $caret = $start + $marker + $placeCaretAfter.Length
                }
            }
            $editor.CaretOffset = $caret
            $null = $editor.Focus()
        }

        # Replaces the group name's value where it sits in the text, rather than rewriting the document
        # from the parsed object. Both would be undoable, but this way one Ctrl+Z puts the old name
        # back and nothing else about the document moves -- not its formatting, not the caret.
        function ReplaceGroupName([string]$name) {
            $match = [regex]::Match($editor.Text, '(?<="groupName"\s*:\s*)"(?:[^"\\]|\\.)*"')
            if (-not $match.Success) {
                return $false
            }
            $encoded = [System.Text.Json.JsonSerializer]::Serialize($name, [string], $jsonStringOptions)
            $editor.Document.Replace($match.Index, $match.Length, $encoded)
            $true
        }

        function GoToLine($line) {
            if ($null -eq $line) {
                return
            }
            $lineNumber = [Math]::Max(1, [Math]::Min([int]$line, $editor.Document.LineCount))
            $documentLine = $editor.Document.GetLineByNumber($lineNumber)
            $editor.Select($documentLine.Offset, $documentLine.Length)
            $editor.ScrollToLine($lineNumber)
            $null = $editor.Focus()
        }

        # Validating on every keystroke would revalidate mid-token while a value is half typed,
        # so the work waits for a short pause instead.
        $validationTimer = New-Object -TypeName 'System.Windows.Threading.DispatcherTimer'
        $validationTimer.Interval = [TimeSpan]::FromMilliseconds(250)
        $validationTimer.Add_Tick({
            $validationTimer.Stop()
            $null = RefreshValidation
        })

        $editor.Add_TextChanged({
            $validationTimer.Stop()
            $validationTimer.Start()
            # A diff describes the document it was asked about. The moment the text moves it no longer
            # does, and a stale list of member changes is worse than an empty one.
            $diffList.Items.Clear()
        })

        # Ctrl and the wheel change the size of the text, the way an editor usually does. The bounds
        # are there so that one careless gesture cannot leave the document unreadable.
        $fontSizeMinimum = 5
        $fontSizeMaximum = 60

        function ChangeFontSize([bool]$increase) {
            if ($increase) {
                $editor.FontSize = [Math]::Min($fontSizeMaximum, $editor.FontSize + 1)
            }
            else {
                $editor.FontSize = [Math]::Max($fontSizeMinimum, $editor.FontSize - 1)
            }
        }

        $editor.Add_PreviewMouseWheel({
            param($sendr, $e)
            if ([System.Windows.Input.Keyboard]::Modifiers -ne [System.Windows.Input.ModifierKeys]::Control) {
                return
            }
            ChangeFontSize ($e.Delta -gt 0)
            $e.Handled = $true
        })

        $editor.TextArea.Caret.Add_PositionChanged({
            $statusCaret.Text = "Ln $($editor.TextArea.Caret.Line), Col $($editor.TextArea.Caret.Column)"
        })

        $errorList.Add_MouseDoubleClick({
            if ($null -ne $errorList.SelectedItem) {
                GoToLine $errorList.SelectedItem.Line
            }
        })

        $control = $window.FindName('Format')
        $control.Add_Click({
            $result = RefreshValidation
            if ($null -eq $result.Document) {
                $statusValidation.Text = 'The document has to be valid before it can be formatted'
                return
            }
            $caret = $editor.CaretOffset
            SetContent $result.Document
            $editor.CaretOffset = [Math]::Min($caret, $editor.Document.TextLength)
            $null = $editor.Focus()
        })

        $control = $window.FindName('Next')
        $control.Add_Click({
            $local = RefreshValidation
            if ($local.Rows.Count -gt 0) {
                $statusValidation.Text = "$($local.Rows.Count) error(s). Correct them, or click Skip to leave this document."
                return
            }
            $Script:nextClicked = $true
            $window.Hide()
        })

        # Diff and Check group are the only things here that need the API, because only the server can
        # read the group. CheckApi throws when there is no connection rather than returning false,
        # which is why it is asked inside a try instead of being used as a plain condition.
        $apiAvailable = $false
        try {
            $apiAvailable = [bool](CheckApi)
        }
        catch {
            $apiAvailable = $false
        }

        if (-not $apiAvailable) {
            foreach ($apiButton in @('Diff', 'CheckGroup')) {
                $control = $window.FindName($apiButton)
                $control.IsEnabled = $false
                $control.ToolTip = 'No connection to the API, so the store cannot be reached. Run Connect-Grouper and open the editor again.'
            }
        }

        $control = $window.FindName('Diff')
        $control.Add_Click({
            $result = RefreshValidation
            if ($null -eq $result.Document) {
                $statusValidation.Text = 'The document has to be valid before a diff can be made'
                return
            }

            $unchanged = $includeUnchanged.IsChecked -eq $true

            try {
                $diff = @(Get-GrouperMemberDiff -InputObject $result.Document -IncludeUnchanged:$unchanged)
            }
            catch {
                $detail = $_.ErrorDetails.Message
                if ([string]::IsNullOrWhiteSpace($detail)) {
                    $detail = $_.Exception.Message
                }
                ShowDiff @()
                ShowErrors 'The diff could not be made' @((NewErrorRow $null 'API' $detail))
                return
            }

            $rows = New-Object -TypeName 'System.Collections.ArrayList'
            foreach ($change in $diff) {
                $null = $rows.Add((NewDiffRow $change.Operation $change.Member.DisplayName))
            }
            ShowDiff $rows
            # The diff has its own list, so the status line is the only place left to say that an
            # empty one means there is nothing to do rather than that nothing was asked.
            if ($rows.Count -eq 0) {
                $statusValidation.Text = 'The group already has the members this document describes'
            }
            else {
                $statusValidation.Text = "$($rows.Count) member change(s)"
            }
        })

        $control = $window.FindName('CheckGroup')
        $control.Add_Click({
            $result = RefreshValidation
            if ($null -eq $result.Document) {
                $statusValidation.Text = 'The document has to be valid before the group can be looked up'
                return
            }
            # OutputAll, because without it the cmdlet writes nothing at all when the group exists and
            # the names already match, and that is one of the three answers worth reporting.
            try {
                $comparison = @(Compare-GrouperDocumentAgainstStore -InputObject $result.Document -OutputAll)[0]
            }
            catch {
                $detail = $_.ErrorDetails.Message
                if ([string]::IsNullOrWhiteSpace($detail)) {
                    $detail = $_.Exception.Message
                }
                ShowErrors 'The store could not be asked about the group' @((NewErrorRow $null 'API' $detail))
                return
            }
            if ($null -eq $comparison) {
                $statusValidation.Text = 'The store gave no answer about the group'
                return
            }
            if (-not $comparison.GroupExists) {
                $statusValidation.Text = 'Group not found in store'
                return
            }
            if ($comparison.NamesMatch) {
                $statusValidation.Text = 'Group found in store, and names match'
                return
            }
            if (-not (ReplaceGroupName $comparison.NameInStore)) {
                $statusValidation.Text = "Group found in store as '$($comparison.NameInStore)', but the group name could not be found in the text"
                return
            }
            # Changing the text starts the validation timer, and when it fires it writes its own
            # summary over the status line. Validating here and stopping the timer is what keeps the
            # message about the rename, which is the part worth reading.
            $validationTimer.Stop()
            $null = RefreshValidation
            $statusValidation.Text = 'Group found in store, but with another name. Name updated in document.'
        })

        $control = $window.FindName('Skip')
        $control.Add_Click({
            $Script:skipClicked = $true
            $window.Hide()
        })

        $control = $window.FindName('Cancel')
        $control.Add_Click({
            $Script:cancelRequested = $true
            $window.Hide()
        })

        $control = $window.FindName('InsertGuid')
        $control.Add_Click({
            InsertSnippet ([Guid]::NewGuid().ToString())
        })

        $control = $window.FindName('InsertMemberSource')
        $control.Add_Click({
            $sourceName = $memberSourceList.SelectedItem
            if ($null -eq $sourceName) {
                return
            }
            $source = $memberSources[$sourceName]
            if ($null -eq $source) {
                $statusValidation.Text = "There is no snippet for member source '$sourceName'"
                return
            }
            InsertSnippet $source '"value": "'
        })

        $control = $window.FindName('InsertRule')
        $control.Add_Click({
            $ruleName = $ruleNameList.SelectedItem
            if ($null -eq $ruleName) {
                return
            }
            InsertSnippet (NewRuleSnippet $ruleName) '"value": "'
        })

        $window.Add_Closing({
            $Script:cancelRequested = $true
            $Script:windowClosed = $true
        })

        $Script:cancelRequested = $false
        $Script:windowClosed = $false
        $documentList = New-Object -TypeName 'System.Collections.ArrayList'
    }

    process {
        $document = GetDocumentFromInputObject $InputObject
        if ($null -eq $document) {
            return
        }
        $null = $documentList.Add($document)
    }

    end {
        $n = 1
        foreach ($document in $documentList) {
            $position = ($n++).ToString() + '/' + $documentList.Count
            $window.Title = "Document Editor ($position)"
            $statusPosition.Text = "Document $position"
            $Script:skipClicked = $false
            $Script:nextClicked = $false
            SetContent $document
            $null = RefreshValidation
            $async = $window.Dispatcher.InvokeAsync({
                $null = $window.ShowDialog()
            })
            $null = $async.Wait()
            if ($Script:nextClicked) {
                ConvertTo-GrouperDocument -InputObject (GetContent)
            }
            if ($Script:cancelRequested) {
                break
            }
        }
        if ($window -and -not $Script:windowClosed) {
            $window.Close()
        }
    }
}
