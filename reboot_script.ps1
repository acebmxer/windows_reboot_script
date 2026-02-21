# Configuration
$LogFile = "C:\Scripts\reboot_script.log"
$ThresholdDays = 5  # Set threshold in days (change this value as needed)

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
    # Format notification with Days/Hours/Minutes
    $message = "Your computer has been up for $Days days, $Hours hours, and $Minutes minutes."
    Start-Process -NoNewWindow -Wait -FilePath "msg.exe" -ArgumentList "*", "$message The system will restart in 5 minutes. Please save your work."
} else {
    Write-Output "$(Get-Date) = Uptime: $Days days, $Hours hours, $Minutes minutes reboot is not needed at this time." | Out-File -Append -FilePath $LogFile
    exit  # Exit if uptime is below threshold
}

# Wait for 5 minutes before restarting
Start-Sleep -Seconds 300

# Log the reboot event with a fresh timestamp
Write-Output "$(Get-Date) = System has been Rebooted" | Out-File -Append -FilePath $LogFile
Shutdown /r /t 0 /f
exit