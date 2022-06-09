$user32 = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
Add-Type -Name win -Member $user32 -Namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

if ($PSVersionTable.PSVersion -eq '7.*')
{
    [void][System.Reflection.Assembly]::Load('System.Drawing')
    [void][System.Reflection.Assembly]::Load('System.Windows.Forms')
}
else {
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
}

$roundRectMethod = @"
[System.Runtime.InteropServices.DllImport("gdi32.dll")]
public static extern IntPtr CreateRoundRectRgn(int nLeftRect, int nTopRect, int nRightRect, int nBottomRect, int nWidthEllipse, int nHeightEllipse);
"@
$helpers = Add-Type -MemberDefinition $roundRectMethod -Name Helpers -Namespace gdi32 -PassThru

[System.Windows.Forms.Application]::EnableVisualStyles()

#region Functions
function ConvertTo-Zulu {
    [CmdletBinding()]
    param (
        # text value from the time entry box. MUST BE PASSED IN AS A STRING
        [Parameter(Mandatory = $true)]
        [string]$timeEntry,

        # parameter specifying daylight savings or standard
        [Parameter(Mandatory = $true)]
        [string]$timeType
    )
    
    if ($timeEntry -match '^(0[0-9]|1[0-9]|2[0-3])[0-5][0-9]$')
    {
        [int]$hours = $timeEntry[0..1] -join ''
        [string]$minutes = '{0:d2}' -f $($timeEntry[2..3] -join '')

        if ($timeType -eq "Standard") # add 5 hours
        {
            $convertedHours = $hours + 5
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 24
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            Return $converted
        }
        elseif ($timeType -eq "Daylight Savings") # add 4 hours
        {
            $convertedHours = $hours + 4
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 24
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            Return $converted
        }
        else {
            Return "Select Standard or Daylight Savings"
        }
    }
    elseif ($timeEntry -match '^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$')
    {
        $timeEntry = $timeEntry.Split(":") -join '' # remove the colon :
        [int]$hours = $timeEntry[0..1] -join ''
        [string]$minutes = '{0:d2}' -f $($timeEntry[2..3] -join '')

        if ($timeType -eq "Standard") # add 5 hours
        {
            $convertedHours = $hours + 5
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 24
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            Return $converted 
        }
        elseif ($timeType -eq "Daylight Savings") # add 4 hours
        {
            $convertedHours = $hours + 4
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 24
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            Return $converted
        }
        else {
            Return "Select Standard or Daylight Savings"
        }
    }
    elseif (($timeEntry -eq "") -or ($timeEntry -eq $null))
    {
        Return ""
    }
    else
    {
        Return "Invalid Entry"
    }
}

function ConvertTo-Eastern {
    [CmdletBinding()]
    param (
        # text value from the time entry box. MUST BE PASSED IN AS A STRING
        [Parameter(Mandatory = $true)]
        [string]$timeEntry,

        # parameter specifying daylight savings or standard
        [Parameter(Mandatory = $true)]
        [string]$timeType
    )
    
    if ($timeEntry -match '^(0[0-9]|1[0-9]|2[0-3])[0-5][0-9]$')
    {
        [int]$hours = $timeEntry[0..1] -join ''
        [string]$minutes = '{0:d2}' -f $($timeEntry[2..3] -join '')

        if ($timeType -eq "Standard") # add 5 hours
        {
            $convertedHours = $hours - 5
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 24
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            Return $converted
        }
        elseif ($timeType -eq "Daylight Savings") # add 4 hours
        {
            $convertedHours = $hours - 4
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 24
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            Return $converted
        }
        else {
            Return "Select Standard or Daylight Savings"
        }
    }
    elseif ($timeEntry -match '^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$')
    {
        $timeEntry = $timeEntry.Split(":") -join '' # remove the colon :
        [int]$hours = $timeEntry[0..1] -join ''
        [string]$minutes = '{0:d2}' -f $($timeEntry[2..3] -join '')

        if ($timeType -eq "Standard") # add 5 hours
        {
            $convertedHours = $hours - 5
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 24
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            Return $converted 
        }
        elseif ($timeType -eq "Daylight Savings") # add 4 hours
        {
            $convertedHours = $hours - 4
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 24
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            Return $converted
        }
        else {
            Return "Select Standard or Daylight Savings"
        }
    }
    elseif (($timeEntry -eq "") -or ($timeEntry -eq $null))
    {
        Return ""
    }
    else
    {
        Return "Invalid Entry"
    }
}
#endregion Functions

# create the form base
$form = New-Object -TypeName System.Windows.Forms.Form
$form.Text = "Zulu Converter"
$form.ClientSize = New-Object System.Drawing.Size(600,400)
$form.Width = 600
$form.Height = 400
$form.StartPosition = 'CenterScreen'
$form.BackColor = "#292e36"
$form.TopMost = $false
$form.FormBorderStyle = "None"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ControlBox = $false
$form.add_Load($form_Load)
$form.add_Load({
    $hrgn = $helpers::CreateRoundRectRgn(0,0,$form.Width, $form.Height, 20,20)
    $form.Region = [System.Drawing.Region]::FromHrgn($hrgn)
})
$formRect = New-Object System.Drawing.Rectangle
$formRect.Location = $form.Location
$formRect.Width = $form.Width
$formRect.Height = $form.Height
$form.add_Paint({
    $global:brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point($form.DisplayRectangle.X,$form.DisplayRectangle.Y)),(New-Object System.Drawing.Point($formRect.Width,$formRect.Height)),"#292e36","#20474f")
    $_.graphics.fillrectangle($brush,$form.DisplayRectangle)
})

# Create Title for the form
$title = New-Object System.Windows.Forms.Label
$title.Text = "Time Converter"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(20,20)
$title.Font = 'Microsoft Sans Serif,15,style=Bold'
$title.ForeColor = 'white'
$title.BackColor = 'transparent'
$title.Add_MouseDown({
    $global:drag = $true
    $global:mouseDragX = [System.Windows.Forms.Cursor]::Position.X - $form.Left
    $global:mouseDragY = [System.Windows.Forms.Cursor]::Position.Y - $form.Top
})
$title.Add_MouseMove({
    if($global:drag)
    {
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
        $currentX = [System.Windows.Forms.Cursor]::Position.X
        $currentY = [System.Windows.Forms.Cursor]::Position.Y
        [int]$newX = [System.Math]::Min($currentX-$global:mouseDragX, $screen.Right - $form.Width)
        [int]$newY = [System.Math]::Min($currentY-$global:mouseDragY, $screen.Bottom - $form.Height)
        $form.Location = New-Object System.Drawing.Point($newX,$newY)
    }
})
$title.Add_MouseUp({$global:drag = $false})

# Create close button
$close = New-Object System.Windows.Forms.Button
$close.BackColor = "transparent"
$close.Size = New-Object System.Drawing.Size(30,30)
$close.Location = New-Object System.Drawing.Point(555,0)
$close.DialogResult = "Cancel"
$close.Font = 'Microsoft Sans Serif, 11pt'
$close.ForeColor = 'white'
$close.Margin = "5,5,5,5"
$close.Text = "X"
$close.TextAlign = 'MiddleCenter'
$close.FlatStyle = "Flat"
$close.FlatAppearance.BorderColor = '#292e36'
$close.FlatAppearance.BorderSize = 0
$close.FlatAppearance.MouseOverBackColor = 'red'
$close.add_Click({$form.Add_FormClosing({$_.Cancel=$false});$form.Close()})
$close.Show()

# Add a description
$description = New-Object System.Windows.Forms.Label
$description.Text = "Enter the time to convert, select the time zone to convert to, select whether it is Daylight Savings or Standard, and then press 'Convert'."
$description.AutoSize = $false
$description.Width = 450
$description.Height = 50
$description.Location = New-Object System.Drawing.Point(20,50)
$description.Font = 'Microsoft Sans Serif,10'
$description.ForeColor = 'white'
$description.BackColor = 'transparent'

# Add zone label
$zoneLabel = New-Object System.Windows.Forms.Label
$zoneLabel.Location = New-Object System.Drawing.Point(260,105)
$zoneLabel.Text = "The time zone you are converting to."
$zoneLabel.Font = 'Microsoft Sans Serif,8,style=Italic'
$zoneLabel.BackColor = 'transparent'
$zoneLabel.ForeColor = 'gray'
$zoneLabel.Width = 250

# Add zone selector
$zone = New-Object System.Windows.Forms.ComboBox
$zone.Text = "Select Output Time Zone"
$zone.Width = 230
$zone.Height = 24
$zone.AutoSize = $false
$zoneItems = @("Eastern","Zulu")
$zone.Items.AddRange($zoneItems)
$zone.Location = New-Object System.Drawing.Point(20,100)

# Add time type selector
$timeType = New-Object System.Windows.Forms.ComboBox
$timeType.Text = "Select Standard/Daylight Savings"
$timeType.Width = 230
$timeType.Height = 24
$timeType.AutoSize = $false
@('Standard','Daylight Savings') | ForEach-Object {[void] $timeType.Items.Add($_)}
$timeType.Location = New-Object System.Drawing.Point(20,145)
$timeType.Font = 'Microsoft Sans Serif,10'
$timeType.FlatStyle = 'Flat'
$timeType_SelectedIndexChanged = {
    if ($zone.Text -eq "Zulu")
    {
        if ($timeEntry.Text)
        {
            $output.Text = ConvertTo-Zulu -timeEntry $timeEntry.Text -timeType $timeType.Text
        }
        else
        {
            $output.Text = ""
        }
    }
    elseif ($zone.Text -eq "Eastern")
    {
        if ($timeEntry.Text)
        {
            $output.Text = ConvertTo-Eastern -timeEntry $timeEntry.Text -timeType $timeType.Text
        }
        else
        {
            $output.Text = ""
        }
    }
    else { # if there is no selection, do nothing
        $output.Text = $null
    }
}
$timeType.add_SelectedIndexChanged($timeType_SelectedIndexChanged)

# Add time picker label
$timeEntryLabel = New-Object System.Windows.Forms.Label
$timeEntryLabel.Location = New-Object System.Drawing.Point(20,190)
$timeEntryLabel.AutoSize = $false
$timeEntryLabel.Width = 150
$timeEntryLabel.Font = 'Microsoft Sans Serif,10,style=Bold'
$timeEntryLabel.ForeColor = 'white'
$timeEntryLabel.BackColor = 'transparent'
$timeEntryLabel.Text = "Time to Convert:"

# Add time entry point
$timeEntry = New-Object System.Windows.Forms.TextBox
$timeEntry.Location = New-Object System.Drawing.Point(20,220)
$timeEntry.Font = 'Microsoft Sans Serif,10'
$timeEntry.Width = 60
$timeEntry.AcceptsReturn = $true
$timeEntry.Add_KeyDown({
    if (($_.KeyCode -eq "Return") -or ($_.KeyCode -eq "Enter"))
    {
        $convertButton_Click
    }
})

# Add the output result label
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Location = New-Object System.Drawing.Point(20,255)
$outputLabel.AutoSize = $false
$outputLabel.Width = 150
$outputLabel.Font = 'Microsoft Sans Serif,10,style=Bold'
$outputLabel.ForeColor = 'white'
$outputLabel.Text = "Output:"
$outputLabel.BackColor = 'transparent'

# Add the Output Result
$output = New-Object System.Windows.Forms.TextBox
$output.Location = New-Object System.Drawing.Point(20,285)
$output.Width = 250
$output.Font = 'Microsoft Sans Serif,10'

# Event handler for the Convert Button
$convertButton_Click = {
    if ($zone.Text -eq "Zulu")
    {
        if ($timeEntry.Text)
        {
            $output.Text = ConvertTo-Zulu -timeEntry $timeEntry.Text -timeType $timeType.Text
        }
        else
        {
            $output.Text = ""
        }
    }
    elseif ($zone.Text -eq "Eastern")
    {
        if ($timeEntry.Text)
        {
            $output.Text = ConvertTo-Eastern -timeEntry $timeEntry.Text -timeType $timeType.Text
        }
        else
        {
            $output.Text = ""
        }
    }
    else { # if there is no selection, do nothing
        $output.Text = $null
    }
}

# Add the convert button
$convertButton = New-Object System.Windows.Forms.Button
$convertButton.Location = New-Object System.Drawing.Point(470,300)
$convertButton.Size = New-Object System.Drawing.Size(100,50)
$convertButton.Text = "Convert"
$convertButton.Font = 'Microsoft Sans Serif,11,style=Bold'
$convertButton.TextAlign = "MiddleCenter"
$convertButton.ForeColor = 'white'
$convertButton.BackColor = 'transparent'
$convertButton.FlatStyle = 'Flat'
$convertButton.FlatAppearance.BorderColor = '#0c1524'
$convertButton.FlatAppearance.BorderSize = '0'
$convertButton.FlatAppearance.MouseOverBackColor = '#0c1524'
$convertButton.add_Click($convertButton_Click)
$form.AcceptButton = $convertButton

# Add all the elements to the form
[array]$controls = @(
    $title
    $description
    $convertButton
    $zoneLabel
    $zone
    $timeType
    $timeEntry
    $timeEntryLabel
    $outputLabel
    $output
    $close
)
$form.Controls.AddRange($controls)
$form.Activate()
$result = $null


# Main loop
while ($result -ne [System.Windows.Forms.DialogResult]::Cancel)
{
    $result = $form.ShowDialog()
}