$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Unity Apps Launcher'
$form.ClientSize = New-Object System.Drawing.Size(620, 305)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$form.AutoScaleMode = 'Dpi'

function Add-Label($text, $x, $y, $width) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.Size = New-Object System.Drawing.Size($width, 25)
    $form.Controls.Add($label)
}

Add-Label 'Build path (.exe)' 20 18 550

$pathBox = New-Object System.Windows.Forms.TextBox
$pathBox.SetBounds(20, 48, 455, 28)
$form.Controls.Add($pathBox)

$browse = New-Object System.Windows.Forms.Button
$browse.Text = 'Browse...'
$browse.SetBounds(485, 46, 115, 32)
$form.Controls.Add($browse)

$browse.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Select a Unity build'
    $dialog.Filter = 'Windows applications (*.exe)|*.exe'
    $dialog.CheckFileExists = $true
    $dialog.Multiselect = $false

    try {
        if ($dialog.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
            $pathBox.Text = $dialog.FileName
        }
    } finally {
        $dialog.Dispose()
    }
})

Add-Label 'Screen Mode' 20 100 240

$mode = New-Object System.Windows.Forms.ComboBox
$mode.DropDownStyle = 'DropDownList'
$mode.SetBounds(20, 130, 240, 30)
[void]$mode.Items.AddRange([object[]]@('Windowed', 'Fullscreen'))
$mode.SelectedIndex = 0
$form.Controls.Add($mode)

Add-Label 'Width (px)' 280 100 150
Add-Label 'Height (px)' 450 100 150

$widthInput = New-Object System.Windows.Forms.NumericUpDown
$widthInput.SetBounds(280, 130, 150, 30)
$widthInput.Minimum = 1
$widthInput.Maximum = 32768
$widthInput.Value = 1920
$form.Controls.Add($widthInput)

$heightInput = New-Object System.Windows.Forms.NumericUpDown
$heightInput.SetBounds(450, 130, 150, 30)
$heightInput.Minimum = 1
$heightInput.Maximum = 32768
$heightInput.Value = 1080
$form.Controls.Add($heightInput)

$launch = New-Object System.Windows.Forms.Button
$launch.Text = 'Launch'
$launch.SetBounds(450, 232, 150, 44)
$form.Controls.Add($launch)
$form.AcceptButton = $launch

$launch.Add_Click({
    try {
        $buildPath = [Environment]::ExpandEnvironmentVariables(
            $pathBox.Text.Trim().Trim('"')
        )

        if (-not [System.IO.Path]::IsPathRooted($buildPath)) {
            throw 'Enter the full path to the .exe file.'
        }

        if (-not (Test-Path -LiteralPath $buildPath -PathType Leaf)) {
            throw 'File not found. Select an existing Unity build.'
        }

        $build = Get-Item -LiteralPath $buildPath -ErrorAction Stop

        if ($build.Extension -ine '.exe') {
            throw 'Select a file with the .exe extension.'
        }

        [void]$form.Validate()

        $fullscreen = if ($mode.SelectedIndex -eq 1) { 1 } else { 0 }

        $playerArguments = @(
            '-screen-fullscreen', $fullscreen,
            '-screen-width', [int]$widthInput.Value,
            '-screen-height', [int]$heightInput.Value
        )

        Start-Process `
            -FilePath $build.FullName `
            -WorkingDirectory $build.DirectoryName `
            -ArgumentList $playerArguments `
            -ErrorAction Stop
    } catch {
        [void][System.Windows.Forms.MessageBox]::Show(
            $form,
            $_.Exception.Message,
            'Unity Apps Launcher',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
})

try {
    [void]$form.ShowDialog()
} finally {
    $form.Dispose()
}