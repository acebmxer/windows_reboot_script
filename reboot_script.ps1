# Configuration
$LogFile = Join-Path $PSScriptRoot "reboot_script.log"
$ThresholdDays = 5  # Set threshold in days (change this value as needed)

# Check for administrator privileges
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires administrator privileges."
    exit 1
}

# Ensure the log directory exists
$LogDir = Split-Path -Path $LogFile
if ($LogDir -and !(Test-Path $LogDir)) {
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

# Log the uptime
Write-Output "$(Get-Date) = Current Uptime: $Days days, $Hours hours, $Minutes minutes" | Out-File -Append -FilePath $LogFile

# Check if uptime exceeds threshold
if ($Uptime.TotalDays -gt $ThresholdDays) {
    $message = "Your computer has been up for $Days days, $Hours hours, and $Minutes minutes. A reboot is required."
    Write-Output "$(Get-Date) = Reboot threshold exceeded. Uptime: $Days days, $Hours hours, $Minutes minutes. Initiating reboot notification." | Out-File -Append -FilePath $LogFile

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $MaxPostpones = 3
    $postponeCount = 0
    $proceed = $false

    while (-not $proceed) {
        $script:remainingSeconds = 300

        $form = New-Object System.Windows.Forms.Form
        $form.Text = "System Reboot Required"
        $form.Size = New-Object System.Drawing.Size(460, 240)
        $form.StartPosition = "CenterScreen"
        $form.TopMost = $true
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false

        # Prevent Alt+F4 from closing the dialog
        $form.Add_FormClosing({
            param($s, $e)
            if ($e.CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing -and $null -eq $s.Tag) {
                $e.Cancel = $true
            }
        })

        $labelMsg = New-Object System.Windows.Forms.Label
        $labelMsg.Text = $message
        $labelMsg.Size = New-Object System.Drawing.Size(430, 45)
        $labelMsg.Location = New-Object System.Drawing.Point(10, 10)
        $form.Controls.Add($labelMsg)

        $labelCountdown = New-Object System.Windows.Forms.Label
        $labelCountdown.Text = "Rebooting in: 5:00"
        $labelCountdown.Size = New-Object System.Drawing.Size(430, 28)
        $labelCountdown.Location = New-Object System.Drawing.Point(10, 60)
        $labelCountdown.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
        $form.Controls.Add($labelCountdown)

        $postponesLeft = $MaxPostpones - $postponeCount
        $labelPostpones = New-Object System.Windows.Forms.Label
        $labelPostpones.Text = if ($postponesLeft -gt 0) { "Postponements remaining: $postponesLeft" } else { "No postponements remaining." }
        $labelPostpones.Size = New-Object System.Drawing.Size(430, 20)
        $labelPostpones.Location = New-Object System.Drawing.Point(10, 95)
        $form.Controls.Add($labelPostpones)

        $canPostpone = ($postponeCount -lt $MaxPostpones)

        $btnPostpone3 = New-Object System.Windows.Forms.Button
        $btnPostpone3.Text = "Postpone 3 min"
        $btnPostpone3.Size = New-Object System.Drawing.Size(110, 28)
        $btnPostpone3.Location = New-Object System.Drawing.Point(10, 123)
        $btnPostpone3.Enabled = $canPostpone
        $btnPostpone3.Add_Click({ $form.Tag = "postpone3"; $form.Close() })
        $form.Controls.Add($btnPostpone3)

        $btnPostpone5 = New-Object System.Windows.Forms.Button
        $btnPostpone5.Text = "Postpone 5 min"
        $btnPostpone5.Size = New-Object System.Drawing.Size(110, 28)
        $btnPostpone5.Location = New-Object System.Drawing.Point(130, 123)
        $btnPostpone5.Enabled = $canPostpone
        $btnPostpone5.Add_Click({ $form.Tag = "postpone5"; $form.Close() })
        $form.Controls.Add($btnPostpone5)

        $btnPostpone10 = New-Object System.Windows.Forms.Button
        $btnPostpone10.Text = "Postpone 10 min"
        $btnPostpone10.Size = New-Object System.Drawing.Size(120, 28)
        $btnPostpone10.Location = New-Object System.Drawing.Point(250, 123)
        $btnPostpone10.Enabled = $canPostpone
        $btnPostpone10.Add_Click({ $form.Tag = "postpone10"; $form.Close() })
        $form.Controls.Add($btnPostpone10)

        $btnAck = New-Object System.Windows.Forms.Button
        $btnAck.Text = "I understand, reboot now"
        $btnAck.Size = New-Object System.Drawing.Size(200, 28)
        $btnAck.Location = New-Object System.Drawing.Point(125, 168)
        $btnAck.Add_Click({ $form.Tag = "acknowledge"; $form.Close() })
        $form.Controls.Add($btnAck)

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 1000
        $timer.Add_Tick({
            $script:remainingSeconds--
            $mins = [math]::Floor($script:remainingSeconds / 60)
            $secs = $script:remainingSeconds % 60
            $labelCountdown.Text = "Rebooting in: {0}:{1:D2}" -f $mins, $secs
            if ($script:remainingSeconds -le 0) {
                $timer.Stop()
                $form.Tag = "timeout"
                $form.Close()
            }
        })
        $timer.Start()

        $form.ShowDialog() | Out-Null
        $timer.Stop()
        $timer.Dispose()

        $result = $form.Tag
        $form.Dispose()

        switch ($result) {
            "postpone3" {
                $postponeCount++
                Write-Output "$(Get-Date) = User postponed reboot by 3 minutes (postponement $postponeCount of $MaxPostpones)." | Out-File -Append -FilePath $LogFile
                Start-Sleep -Seconds 180
            }
            "postpone5" {
                $postponeCount++
                Write-Output "$(Get-Date) = User postponed reboot by 5 minutes (postponement $postponeCount of $MaxPostpones)." | Out-File -Append -FilePath $LogFile
                Start-Sleep -Seconds 300
            }
            "postpone10" {
                $postponeCount++
                Write-Output "$(Get-Date) = User postponed reboot by 10 minutes (postponement $postponeCount of $MaxPostpones)." | Out-File -Append -FilePath $LogFile
                Start-Sleep -Seconds 600
            }
            "acknowledge" {
                Write-Output "$(Get-Date) = User acknowledged reboot notification. Proceeding with reboot." | Out-File -Append -FilePath $LogFile
                $proceed = $true
            }
            default {
                # "timeout" — countdown expired
                Write-Output "$(Get-Date) = Reboot countdown expired. Proceeding with reboot." | Out-File -Append -FilePath $LogFile
                $proceed = $true
            }
        }
    }
} else {
    Write-Output "$(Get-Date) = Uptime: $Days days, $Hours hours, $Minutes minutes - reboot is not needed at this time." | Out-File -Append -FilePath $LogFile
    exit 0
}

# Log the reboot event with a fresh timestamp
Write-Output "$(Get-Date) = System has been Rebooted" | Out-File -Append -FilePath $LogFile

# Perform shutdown
try {
    Shutdown /r /t 0 /f
} catch {
    Write-Output "$(Get-Date) = ERROR: Shutdown failed: $_" | Out-File -Append -FilePath $LogFile
    exit 1
}

exit 0
