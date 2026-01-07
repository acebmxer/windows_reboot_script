Start-Transcript -Path "c:\scripts\reboot_script.log" -Append
# Get uptime and break down into Days, Hours, Minutes
$LastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$Uptime = (Get-Date) - $LastBoot
$Days = $Uptime.Days
$Hours = $Uptime.Hours
$Minutes = $Uptime.Minutes

# Set threshold to 1 day (change this value as needed)
$ThresholdDays = 5

# Check if uptime exceeds threshold (using TotalDays for comparison)
if ($Uptime.TotalDays -gt $ThresholdDays) {
    # Format notification with Days/Hours/Minutes
    $message = "Your computer has been up for $Days days, $Hours hours, and $Minutes minutes."
    Start-Process -NoNewWindow -Wait -FilePath "msg.exe" -ArgumentList "*", "$message The system will restart in 5 minute. Please save your work."
}

# Wait for 5 minute before restarting
Start-Sleep -Seconds 300

# Restart the computer
Shutdown /r /t 0 /f

# Close the PowerShell window
exit
