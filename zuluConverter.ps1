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
$title.Font = 'Microsoft Sans Serif,13,style=Bold'
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
    if ($timeType.Text -eq "Standard")
    {
        $output.Text = "$($inputTimePicker.Value.AddHours(5).TimeOfDay.ToString().Split(':')[0..1] -join '')Z"
    }
    elseif ($timeType.Text -eq "Daylight Savings")
    {
        $output.Text = "$($inputTimePicker.Value.AddHours(4).TimeOfDay.ToString().Split(':')[0..1] -join '')Z"
    }
    else
    {
        $output.Text = "Select Standard or Daylight Savings"
    }
}

# Add time picker label
$inputTimePickerLabel = New-Object System.Windows.Forms.Label
$inputTimePickerLabel.Location = New-Object System.Drawing.Point(20,145)
$inputTimePickerLabel.AutoSize = $false
$inputTimePickerLabel.Width = 150
$inputTimePickerLabel.Font = 'Microsoft Sans Serif,10,style=Bold'
$inputTimePickerLabel.ForeColor = 'white'
$inputTimePickerLabel.Text = "Time to Convert:"

# Add time picker
$inputTimePicker = New-Object System.Windows.Forms.DateTimePicker
$inputTimePicker.Location = New-Object System.Drawing.Point(20,175)
$inputTimePicker.Font = 'Microsoft Sans Serif,10'
$inputTimePicker.Width = 60
$inputTimePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
$inputTimePicker.CustomFormat = "HHmm"
$inputTimePicker.ShowUpDown = $true

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
    if ($timeType.Text -eq "Standard")
    {
        $output.Text = "$($inputTimePicker.Value.AddHours(5).TimeOfDay.ToString().Split(':')[0..1] -join '')Z"
    }
    elseif ($timeType.Text -eq "Daylight Savings")
    {
        $output.Text = "$($inputTimePicker.Value.AddHours(4).TimeOfDay.ToString().Split(':')[0..1] -join '')Z"
    }
    else {
        $output.Text = "Select Standard or Daylight Savings"
    }
}

# Add the convert button
$convertButton = New-Object System.Windows.Forms.Button
$convertButton.Location = New-Object System.Drawing.Point(365,300)
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

# Add the cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(475,300)
$cancelButton.Size = New-Object System.Drawing.Size(100,50)
$cancelButton.Text = "Cancel"
$cancelButton.Font = 'Microsoft Sans Serif,11'
$cancelButton.TextAlign = "MiddleCenter"
$cancelButton.ForeColor = 'white'
$cancelButton.FlatStyle = 'Flat'
$cancelButton.FlatAppearance.BorderColor = '#0c1524'
$cancelButton.FlatAppearance.BorderSize = '0'
$cancelButton.FlatAppearance.MouseOverBackColor = '#0c1524'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.AcceptButton = $cancelButton

# Add all the elements to the form
$form.Controls.Add($title)
$form.Controls.Add($description)
$form.Controls.Add($convertButton)
$form.Controls.Add($cancelButton)
$form.Controls.Add($timeType)
$form.Controls.Add($inputTimePicker)
$form.Controls.Add($inputTimePickerLabel)
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