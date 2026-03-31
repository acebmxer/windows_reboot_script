# Configuration
$LogFile = "C:\Scripts\reboot_script.log"
$ThresholdDays = 5   # Set threshold in days (change this value as needed)
$MaxPostpones = 3    # Maximum number of times the user can postpone the reboot

# Ensure the log directory exists
$LogDir = Split-Path -Path $LogFile
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Get uptime and break down into Days, Hours, Minutes
try {
    $Uptime = (Get-Date) - (Get-CimInstance CIM_OperatingSystem).LastBootUpTime
} catch {
    Write-Output "$(Get-Date) = ERROR: Failed to retrieve system uptime: $_" | Out-File -Append -FilePath $LogFile
    exit 1
}

$Days = $Uptime.Days
$Hours = $Uptime.Hours
$Minutes = $Uptime.Minutes

# Log the uptime before rebooting
Write-Output "$(Get-Date) = Current Uptime: $Days days, $Hours hours, $Minutes minutes" | Out-File -Append -FilePath $LogFile

# Check if uptime exceeds threshold (using TotalDays for comparison)
if ($Uptime.TotalDays -gt $ThresholdDays) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $CountdownSeconds = 300  # 5 minutes
    $script:postponeCount = 0
    $script:postponeSeconds = 0

    do {
        $script:postponeSeconds = 0
        $script:remaining = $CountdownSeconds
        $script:allowClose = $false
        $postponesLeft = $MaxPostpones - $script:postponeCount

        $form = New-Object System.Windows.Forms.Form
        $form.Text = '!! SYSTEM REBOOT WARNING !!'
        $form.Size = New-Object System.Drawing.Size(560, 465)
        $form.StartPosition = 'CenterScreen'
        $form.TopMost = $true
        $form.FormBorderStyle = 'FixedDialog'
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.ControlBox = $false
        $form.BackColor = [System.Drawing.Color]::FromArgb(160, 0, 0)

        # Warning icon
        $iconLabel = New-Object System.Windows.Forms.Label
        $iconLabel.Text = [char]0x26A0
        $iconLabel.Font = New-Object System.Drawing.Font('Segoe UI Emoji', 38)
        $iconLabel.ForeColor = [System.Drawing.Color]::Yellow
        $iconLabel.Location = New-Object System.Drawing.Point(15, 15)
        $iconLabel.Size = New-Object System.Drawing.Size(70, 70)
        $iconLabel.TextAlign = 'MiddleCenter'
        $form.Controls.Add($iconLabel)

        # Title
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = 'MANDATORY SYSTEM REBOOT'
        $titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
        $titleLabel.ForeColor = [System.Drawing.Color]::White
        $titleLabel.Location = New-Object System.Drawing.Point(95, 25)
        $titleLabel.Size = New-Object System.Drawing.Size(455, 45)
        $form.Controls.Add($titleLabel)

        # Divider
        $divider = New-Object System.Windows.Forms.Panel
        $divider.BackColor = [System.Drawing.Color]::FromArgb(220, 50, 50)
        $divider.Location = New-Object System.Drawing.Point(0, 90)
        $divider.Size = New-Object System.Drawing.Size(560, 3)
        $form.Controls.Add($divider)

        # Message
        $msgLabel = New-Object System.Windows.Forms.Label
        $msgLabel.Text = "Your computer has been running for:`nDay(s): $Days   Hour(s): $Hours   Minute(s): $Minutes`n`nSave all open work NOW. Your system will restart automatically."
        $msgLabel.Font = New-Object System.Drawing.Font('Segoe UI', 12)
        $msgLabel.ForeColor = [System.Drawing.Color]::White
        $msgLabel.Location = New-Object System.Drawing.Point(20, 105)
        $msgLabel.Size = New-Object System.Drawing.Size(520, 100)
        $form.Controls.Add($msgLabel)

        # Postpone section label
        $postponeLabel = New-Object System.Windows.Forms.Label
        $postponeLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
        $postponeLabel.Location = New-Object System.Drawing.Point(20, 215)
        $postponeLabel.Size = New-Object System.Drawing.Size(520, 22)
        if ($postponesLeft -gt 0) {
            $postponeLabel.Text = "Postpone reboot ($postponesLeft postpone(s) remaining):"
            $postponeLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
        } else {
            $postponeLabel.Text = "No postpones remaining -- reboot cannot be delayed further."
            $postponeLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 120, 120)
        }
        $form.Controls.Add($postponeLabel)

        # Postpone buttons
        $btnY = 242
        $btnWidth = 160
        $btnEnabled = $postponesLeft -gt 0
        $btnOnColor  = [System.Drawing.Color]::FromArgb(100, 60, 0)
        $btnOffColor = [System.Drawing.Color]::FromArgb(80, 0, 0)
        $btnOnText   = [System.Drawing.Color]::White
        $btnOffText  = [System.Drawing.Color]::FromArgb(120, 80, 80)
        $borderColor = [System.Drawing.Color]::FromArgb(255, 200, 100)

        $postpone3 = New-Object System.Windows.Forms.Button
        $postpone3.Text = 'Postpone 3 min'
        $postpone3.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
        $postpone3.Location = New-Object System.Drawing.Point(20, $btnY)
        $postpone3.Size = New-Object System.Drawing.Size($btnWidth, 38)
        $postpone3.FlatStyle = 'Flat'
        $postpone3.FlatAppearance.BorderSize = 1
        $postpone3.FlatAppearance.BorderColor = $borderColor
        $postpone3.Enabled = $btnEnabled
        $postpone3.BackColor = if ($btnEnabled) { $btnOnColor } else { $btnOffColor }
        $postpone3.ForeColor = if ($btnEnabled) { $btnOnText } else { $btnOffText }
        $postpone3.Add_Click({ $script:postponeSeconds = 180; $timer.Stop(); $script:allowClose = $true; $form.Close() })
        $form.Controls.Add($postpone3)

        $postpone5 = New-Object System.Windows.Forms.Button
        $postpone5.Text = 'Postpone 5 min'
        $postpone5.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
        $postpone5.Location = New-Object System.Drawing.Point(190, $btnY)
        $postpone5.Size = New-Object System.Drawing.Size($btnWidth, 38)
        $postpone5.FlatStyle = 'Flat'
        $postpone5.FlatAppearance.BorderSize = 1
        $postpone5.FlatAppearance.BorderColor = $borderColor
        $postpone5.Enabled = $btnEnabled
        $postpone5.BackColor = if ($btnEnabled) { $btnOnColor } else { $btnOffColor }
        $postpone5.ForeColor = if ($btnEnabled) { $btnOnText } else { $btnOffText }
        $postpone5.Add_Click({ $script:postponeSeconds = 300; $timer.Stop(); $script:allowClose = $true; $form.Close() })
        $form.Controls.Add($postpone5)

        $postpone10 = New-Object System.Windows.Forms.Button
        $postpone10.Text = 'Postpone 10 min'
        $postpone10.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
        $postpone10.Location = New-Object System.Drawing.Point(360, $btnY)
        $postpone10.Size = New-Object System.Drawing.Size($btnWidth, 38)
        $postpone10.FlatStyle = 'Flat'
        $postpone10.FlatAppearance.BorderSize = 1
        $postpone10.FlatAppearance.BorderColor = $borderColor
        $postpone10.Enabled = $btnEnabled
        $postpone10.BackColor = if ($btnEnabled) { $btnOnColor } else { $btnOffColor }
        $postpone10.ForeColor = if ($btnEnabled) { $btnOnText } else { $btnOffText }
        $postpone10.Add_Click({ $script:postponeSeconds = 600; $timer.Stop(); $script:allowClose = $true; $form.Close() })
        $form.Controls.Add($postpone10)

        # Countdown label
        $initMins = [math]::Floor($CountdownSeconds / 60)
        $initSecs = ($CountdownSeconds % 60).ToString('00')
        $countdownLabel = New-Object System.Windows.Forms.Label
        $countdownLabel.Text = "Restarting in:  ${initMins}:${initSecs}"
        $countdownLabel.Font = New-Object System.Drawing.Font('Courier New', 22, [System.Drawing.FontStyle]::Bold)
        $countdownLabel.ForeColor = [System.Drawing.Color]::Yellow
        $countdownLabel.Location = New-Object System.Drawing.Point(20, 295)
        $countdownLabel.Size = New-Object System.Drawing.Size(520, 45)
        $countdownLabel.TextAlign = 'MiddleCenter'
        $form.Controls.Add($countdownLabel)

        # Acknowledge button
        $ackButton = New-Object System.Windows.Forms.Button
        $ackButton.Text = 'I ACKNOWLEDGE -- MY SYSTEM WILL REBOOT'
        $ackButton.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
        $ackButton.BackColor = [System.Drawing.Color]::FromArgb(220, 100, 0)
        $ackButton.ForeColor = [System.Drawing.Color]::White
        $ackButton.Location = New-Object System.Drawing.Point(20, 355)
        $ackButton.Size = New-Object System.Drawing.Size(515, 60)
        $ackButton.FlatStyle = 'Flat'
        $ackButton.FlatAppearance.BorderSize = 0
        $ackButton.Add_Click({
            $ackButton.Enabled = $false
            $ackButton.Text = 'Acknowledged -- Reboot proceeding after countdown'
            $ackButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 0)
            Write-Output "$(Get-Date) = User acknowledged reboot warning" | Out-File -Append -FilePath $LogFile
        })
        $form.Controls.Add($ackButton)

        # Block Alt+F4 -- only the countdown or a postpone button can dismiss this dialog
        $form.Add_FormClosing({
            param($s, $e)
            if ($script:remaining -gt 0 -and -not $script:allowClose) { $e.Cancel = $true }
        })

        # Countdown timer
        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 1000
        $timer.Add_Tick({
            $script:remaining--
            $mins = [math]::Floor($script:remaining / 60)
            $secs = $script:remaining % 60
            $secsStr = $secs.ToString('00')
            $countdownLabel.Text = "Restarting in:  ${mins}:${secsStr}"
            if ($script:remaining -le 60) {
                $countdownLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
                $form.BackColor = [System.Drawing.Color]::FromArgb(120, 0, 0)
            }
            if ($script:remaining -le 0) {
                $script:allowClose = $true
                $timer.Stop()
                $form.Close()
            }
        })
        $timer.Start()
        $form.ShowDialog() | Out-Null
        $timer.Stop()

        if ($script:postponeSeconds -gt 0) {
            $script:postponeCount++
            $postponeMins = $script:postponeSeconds / 60
            Write-Output "$(Get-Date) = User postponed reboot for $postponeMins minutes (postpone $script:postponeCount of $MaxPostpones)" | Out-File -Append -FilePath $LogFile
            Start-Sleep -Seconds $script:postponeSeconds
        }

    } while ($script:postponeSeconds -gt 0)

} else {
    Write-Output "$(Get-Date) = Uptime: $Days days, $Hours hours, $Minutes minutes reboot is not needed at this time." | Out-File -Append -FilePath $LogFile
    exit  # Exit if uptime is below threshold
}

# Log the reboot event with a fresh timestamp
Write-Output "$(Get-Date) = System has been Rebooted" | Out-File -Append -FilePath $LogFile
Shutdown /r /t 0 /f
exit
