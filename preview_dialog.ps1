Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$LogoPath = Join-Path $PSScriptRoot "logo.png"

$Days = 6; $Hours = 2; $Minutes = 14
$CountdownSeconds = 300
$MaxPostpones = 3

$bgDark    = [System.Drawing.Color]::FromArgb(30, 30, 30)
$bgPanel   = [System.Drawing.Color]::FromArgb(45, 45, 45)
$orange    = [System.Drawing.Color]::FromArgb(224, 112, 32)
$gold      = [System.Drawing.Color]::FromArgb(245, 194, 0)
$white     = [System.Drawing.Color]::White
$lightGray = [System.Drawing.Color]::FromArgb(210, 210, 210)
$mutedText = [System.Drawing.Color]::FromArgb(170, 170, 170)

$script:remaining = $CountdownSeconds
$script:allowClose = $false
$script:postponeSeconds = 0
$postponesLeft = $MaxPostpones

$form = New-Object System.Windows.Forms.Form
$form.Text = 'System Restart Required'
$form.Size = New-Object System.Drawing.Size(580, 500)
$form.StartPosition = 'CenterScreen'
$form.TopMost = $true
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ControlBox = $false
$form.BackColor = $bgDark

if ($LogoPath -and (Test-Path $LogoPath)) {
    $logoPicture = New-Object System.Windows.Forms.PictureBox
    $logoImage = [System.Drawing.Image]::FromFile($LogoPath)
    $logoAspect = $logoImage.Width / $logoImage.Height
    $logoH = 80
    $logoW = [int]($logoH * $logoAspect)
    $logoPicture.Image = $logoImage
    $logoPicture.Size = New-Object System.Drawing.Size($logoW, $logoH)
    $logoPicture.Location = New-Object System.Drawing.Point(([int]((580 - $logoW) / 2)), 12)
    $logoPicture.SizeMode = 'StretchImage'
    $logoPicture.BackColor = [System.Drawing.Color]::Transparent
    $form.Controls.Add($logoPicture)
}

$divider1 = New-Object System.Windows.Forms.Panel
$divider1.BackColor = $orange
$divider1.Location = New-Object System.Drawing.Point(0, 100)
$divider1.Size = New-Object System.Drawing.Size(580, 3)
$form.Controls.Add($divider1)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = 'Scheduled System Restart'
$titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = $white
$titleLabel.BackColor = [System.Drawing.Color]::Transparent
$titleLabel.Location = New-Object System.Drawing.Point(20, 110)
$titleLabel.Size = New-Object System.Drawing.Size(540, 42)
$titleLabel.TextAlign = 'MiddleCenter'
$form.Controls.Add($titleLabel)

$subLabel = New-Object System.Windows.Forms.Label
$subLabel.Text = 'Your computer requires a restart to apply updates and maintain performance.'
$subLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$subLabel.ForeColor = $mutedText
$subLabel.BackColor = [System.Drawing.Color]::Transparent
$subLabel.Location = New-Object System.Drawing.Point(20, 155)
$subLabel.Size = New-Object System.Drawing.Size(540, 22)
$subLabel.TextAlign = 'MiddleCenter'
$form.Controls.Add($subLabel)

$uptimeBox = New-Object System.Windows.Forms.Panel
$uptimeBox.BackColor = $bgPanel
$uptimeBox.Location = New-Object System.Drawing.Point(0, 185)
$uptimeBox.Size = New-Object System.Drawing.Size(580, 52)
$form.Controls.Add($uptimeBox)

$uptimeLabel = New-Object System.Windows.Forms.Label
$uptimeLabel.Text = "System has been running for:   $Days day(s)   $Hours hour(s)   $Minutes minute(s)"
$uptimeLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$uptimeLabel.ForeColor = $gold
$uptimeLabel.BackColor = [System.Drawing.Color]::Transparent
$uptimeLabel.Location = New-Object System.Drawing.Point(0, 14)
$uptimeLabel.Size = New-Object System.Drawing.Size(580, 22)
$uptimeLabel.TextAlign = 'MiddleCenter'
$uptimeBox.Controls.Add($uptimeLabel)

$saveLabel = New-Object System.Windows.Forms.Label
$saveLabel.Text = 'Please save all open work before the restart begins.'
$saveLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$saveLabel.ForeColor = $lightGray
$saveLabel.BackColor = [System.Drawing.Color]::Transparent
$saveLabel.Location = New-Object System.Drawing.Point(20, 245)
$saveLabel.Size = New-Object System.Drawing.Size(540, 22)
$saveLabel.TextAlign = 'MiddleCenter'
$form.Controls.Add($saveLabel)

$postponeLabel = New-Object System.Windows.Forms.Label
$postponeLabel.Text = "Need more time? You may postpone the restart ($postponesLeft remaining):"
$postponeLabel.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$postponeLabel.ForeColor = $mutedText
$postponeLabel.BackColor = [System.Drawing.Color]::Transparent
$postponeLabel.Location = New-Object System.Drawing.Point(20, 275)
$postponeLabel.Size = New-Object System.Drawing.Size(540, 20)
$postponeLabel.TextAlign = 'MiddleCenter'
$form.Controls.Add($postponeLabel)

$btnY = 300; $btnWidth = 160
$borderOn = $orange

$postpone3 = New-Object System.Windows.Forms.Button
$postpone3.Text = 'Postpone 3 min'
$postpone3.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$postpone3.Location = New-Object System.Drawing.Point(20, $btnY)
$postpone3.Size = New-Object System.Drawing.Size($btnWidth, 34)
$postpone3.FlatStyle = 'Flat'
$postpone3.FlatAppearance.BorderSize = 1
$postpone3.FlatAppearance.BorderColor = $borderOn
$postpone3.BackColor = $bgPanel
$postpone3.ForeColor = $lightGray
$postpone3.Add_Click({ $script:allowClose = $true; $form.Close() })
$form.Controls.Add($postpone3)

$postpone5 = New-Object System.Windows.Forms.Button
$postpone5.Text = 'Postpone 5 min'
$postpone5.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$postpone5.Location = New-Object System.Drawing.Point(200, $btnY)
$postpone5.Size = New-Object System.Drawing.Size($btnWidth, 34)
$postpone5.FlatStyle = 'Flat'
$postpone5.FlatAppearance.BorderSize = 1
$postpone5.FlatAppearance.BorderColor = $borderOn
$postpone5.BackColor = $bgPanel
$postpone5.ForeColor = $lightGray
$postpone5.Add_Click({ $script:allowClose = $true; $form.Close() })
$form.Controls.Add($postpone5)

$postpone10 = New-Object System.Windows.Forms.Button
$postpone10.Text = 'Postpone 10 min'
$postpone10.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$postpone10.Location = New-Object System.Drawing.Point(380, $btnY)
$postpone10.Size = New-Object System.Drawing.Size($btnWidth, 34)
$postpone10.FlatStyle = 'Flat'
$postpone10.FlatAppearance.BorderSize = 1
$postpone10.FlatAppearance.BorderColor = $borderOn
$postpone10.BackColor = $bgPanel
$postpone10.ForeColor = $lightGray
$postpone10.Add_Click({ $script:allowClose = $true; $form.Close() })
$form.Controls.Add($postpone10)

$initMins = [math]::Floor($CountdownSeconds / 60)
$initSecs = ($CountdownSeconds % 60).ToString('00')
$countdownLabel = New-Object System.Windows.Forms.Label
$countdownLabel.Text = "Restarting in:  ${initMins}:${initSecs}"
$countdownLabel.Font = New-Object System.Drawing.Font('Courier New', 20, [System.Drawing.FontStyle]::Bold)
$countdownLabel.ForeColor = $gold
$countdownLabel.BackColor = [System.Drawing.Color]::Transparent
$countdownLabel.Location = New-Object System.Drawing.Point(20, 344)
$countdownLabel.Size = New-Object System.Drawing.Size(540, 40)
$countdownLabel.TextAlign = 'MiddleCenter'
$form.Controls.Add($countdownLabel)

$divider2 = New-Object System.Windows.Forms.Panel
$divider2.BackColor = $orange
$divider2.Location = New-Object System.Drawing.Point(0, 394)
$divider2.Size = New-Object System.Drawing.Size(580, 3)
$form.Controls.Add($divider2)

$ackButton = New-Object System.Windows.Forms.Button
$ackButton.Text = 'I understand -- proceed with restart'
$ackButton.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$ackButton.BackColor = $orange
$ackButton.ForeColor = $white
$ackButton.Location = New-Object System.Drawing.Point(0, 397)
$ackButton.Size = New-Object System.Drawing.Size(580, 62)
$ackButton.FlatStyle = 'Flat'
$ackButton.FlatAppearance.BorderSize = 0
$ackButton.TextAlign = 'MiddleCenter'
$ackButton.Add_Click({ $script:allowClose = $true; $form.Close() })
$form.Controls.Add($ackButton)

$form.Add_FormClosing({
    param($s, $e)
    if (-not $script:allowClose) { $e.Cancel = $true }
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    $script:remaining--
    $mins = [math]::Floor($script:remaining / 60)
    $secs = $script:remaining % 60
    $secsStr = $secs.ToString('00')
    $countdownLabel.Text = "Restarting in:  ${mins}:${secsStr}"
    if ($script:remaining -le 60) { $countdownLabel.ForeColor = $orange }
    if ($script:remaining -le 0) { $script:allowClose = $true; $timer.Stop(); $form.Close() }
})
$timer.Start()
$form.ShowDialog() | Out-Null
$timer.Stop()
