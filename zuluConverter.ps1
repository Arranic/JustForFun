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

# Create Title for the form
$title = New-Object System.Windows.Forms.Label
$title.Text = "Zulu Time Converter"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(20,20)
$title.Font = 'Microsoft Sans Serif,15,style=Bold'
$title.ForeColor = 'white'
$title.Add_MouseDown({$global:drag = $true
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
$close.FlatAppearance.MouseOverBackColor = 'red'
$close.add_Click({$form.Add_FormClosing({$_.Cancel=$false});$form.Close()})
$close.Show()

# Add a description
$description = New-Object System.Windows.Forms.Label
$description.Text = "Enter the current time in Eastern, select whether it is Daylight Savings or Standard, and then press 'Convert'."
$description.AutoSize = $false
$description.Width = 450
$description.Height = 50
$description.Location = New-Object System.Drawing.Point(20,50)
$description.Font = 'Microsoft Sans Serif,10'
$description.ForeColor = 'white'

# Add time type selector
$timeType = New-Object System.Windows.Forms.ComboBox
$timeType.Text = "Select Standard/Daylight Savings"
$timeType.Width = 230
$timeType.AutoSize = $true
@('Standard','Daylight Savings') | ForEach-Object {[void] $timeType.Items.Add($_)}
$timeType.Location = New-Object System.Drawing.Point(20,100)
$timeType.Font = 'Microsoft Sans Serif,10'
$timeType.FlatStyle = 'Flat'
$timeType_SelectedIndexChanged = {
    if ($timeEntry.Text -match '^(0[0-9]|1[0-9]|2[0-3])[0-5][0-9]$')
    {
        [int]$hours = $timeEntry.Text[0..1] -join ''
        [string]$minutes = '{0:d2}' -f $($timeEntry.Text[2..3] -join '')

        if ($timeType.Text -eq "Standard") # add 5 hours
        {
            $convertedHours = $hours + 5
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 23
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            $output.Text = $converted
        }
        elseif ($timeType.Text -eq "Daylight Savings") # add 4 hours
        {
            $convertedHours = $hours + 4
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 23
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            $output.Text = $converted
        }
        else {
            $output.Text = "Select Standard or Daylight Savings"
        }
    }
    elseif ($timeEntry.Text -match '^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$')
    {
        $timeEntry.Text = $timeEntry.Text.Split(":") -join '' # remove the colon :
        [int]$hours = $timeEntry.Text[0..1] -join ''
        [string]$minutes = '{0:d2}' -f $($timeEntry.Text[2..3] -join '')

        if ($timeType.Text -eq "Standard") # add 5 hours
        {
            $convertedHours = $hours + 5
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 23
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            $output.Text = $converted
        }
        elseif ($timeType.Text -eq "Daylight Savings") # add 4 hours
        {
            $convertedHours = $hours + 4
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 23
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            $output.Text = $timeEntry.Text
        }
        else {
            $output.Text = "Select Standard or Daylight Savings"
        }
    }
    elseif (($timeEntry.Text -eq "") -or ($timeEntry.Text -eq $null))
    {
        $output.Text = ""
    }
    else
    {
        $output.Text = "Invalid Entry"
    }
}

# Add time picker label
$timeEntryLabel = New-Object System.Windows.Forms.Label
$timeEntryLabel.Location = New-Object System.Drawing.Point(20,145)
$timeEntryLabel.AutoSize = $false
$timeEntryLabel.Width = 150
$timeEntryLabel.Font = 'Microsoft Sans Serif,10,style=Bold'
$timeEntryLabel.ForeColor = 'white'
$timeEntryLabel.Text = "Time to Convert:"

# Add time entry point
$timeEntry = New-Object System.Windows.Forms.TextBox
$timeEntry.Location = New-Object System.Drawing.Point(20,175)
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
$outputLabel.Location = New-Object System.Drawing.Point(20,210)
$outputLabel.AutoSize = $false
$outputLabel.Width = 150
$outputLabel.Font = 'Microsoft Sans Serif,10,style=Bold'
$outputLabel.ForeColor = 'white'
$outputLabel.Text = "Output:"

# Add the Output Result
$output = New-Object System.Windows.Forms.TextBox
$output.Location = New-Object System.Drawing.Point(20,240)
$output.Width = 250
$output.Font = 'Microsoft Sans Serif,10'

# Event handler for the Convert Button
$convertButton_Click = {
    if ($timeEntry.Text -match '^(0[0-9]|1[0-9]|2[0-3])[0-5][0-9]$')
    {
        [int]$hours = $timeEntry.Text[0..1] -join ''
        [string]$minutes = '{0:d2}' -f $($timeEntry.Text[2..3] -join '')

        if ($timeType.Text -eq "Standard") # add 5 hours
        {
            $convertedHours = $hours + 5
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 23
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            $output.Text = $converted
        }
        elseif ($timeType.Text -eq "Daylight Savings") # add 4 hours
        {
            $convertedHours = $hours + 4
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 23
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            $output.Text = $converted
        }
        else {
            $output.Text = "Select Standard or Daylight Savings"
        }
    }
    elseif ($timeEntry.Text -match '^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$')
    {
        $timeEntry.Text = $timeEntry.Text.Split(":") -join '' # remove the colon :
        [int]$hours = $timeEntry.Text[0..1] -join ''
        [string]$minutes = '{0:d2}' -f $($timeEntry.Text[2..3] -join '')

        if ($timeType.Text -eq "Standard") # add 5 hours
        {
            $convertedHours = $hours + 5
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 23
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            $output.Text = $converted
        }
        elseif ($timeType.Text -eq "Daylight Savings") # add 4 hours
        {
            $convertedHours = $hours + 4
            if ($convertedHours -gt 23)
            {
                $convertedHours = $convertedHours % 23
            }
            [string]$converted = '{0:d4}' -f [int]$("$($convertedHours)" + "$($minutes)")
            $output.Text = $timeEntry.Text
        }
        else {
            $output.Text = "Select Standard or Daylight Savings"
        }
    }
    elseif (($timeEntry.Text -eq "") -or ($timeEntry.Text -eq $null))
    {
        $output.Text = ""
    }
    else
    {
        $output.Text = "Invalid Entry"
    }
}

# Add the convert button
$convertButton = New-Object System.Windows.Forms.Button
$convertButton.Location = New-Object System.Drawing.Point(450,300)
$convertButton.Size = New-Object System.Drawing.Size(100,50)
$convertButton.Text = "Convert"
$convertButton.Font = 'Microsoft Sans Serif,11,style=Bold'
$convertButton.TextAlign = "MiddleCenter"
$convertButton.ForeColor = 'white'
$convertButton.FlatStyle = 'Flat'
$convertButton.FlatAppearance.BorderColor = '#0c1524'
$convertButton.FlatAppearance.BorderSize = '0'
$convertButton.FlatAppearance.MouseOverBackColor = '#0c1524'
$convertButton.add_Click($convertButton_Click)
$form.AcceptButton = $convertButton

# Add all the elements to the form
$form.Controls.Add($title)
$form.Controls.Add($description)
$form.Controls.Add($convertButton)
$form.Controls.Add($timeType)
$form.Controls.Add($timeEntry)
$form.Controls.Add($timeEntryLabel)
$form.Controls.Add($outputLabel)
$form.Controls.Add($output)
$form.Controls.Add($close)

$form.Activate()
$result = $null

while ($result -ne [System.Windows.Forms.DialogResult]::Cancel)
{
    $timeType.add_SelectedIndexChanged($timeType_SelectedIndexChanged)
    $result = $form.ShowDialog()
}