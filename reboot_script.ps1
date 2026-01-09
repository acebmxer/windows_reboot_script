# Get uptime and break down into Days, Hours, Minutes
$Uptime = (Get-Date) - (Get-CimInstance CIM_OperatingSystem).LastBootUpTime
$Days = $Uptime.Days
$Hours = $Uptime.Hours
$Minutes = $Uptime.Minutes
$Date = (Get-Date)

# Log the uptime before rebooting
Write-Output "$Date = Uptime before reboot: $Days days, $Hours hours, $Minutes minutes" | Out-File -Append -FilePath "C:\Scripts\reboot_script.log"

# Set threshold to 1 day (change this value as needed)
$ThresholdDays = 5
# $ThresholdHours = 5
# Check if uptime exceeds threshold (using TotalDays for comparison)
if ($Uptime.TotalDays -gt $ThresholdDays) {
    # Format notification with Days/Hours/Minutes
    $message = "Your computer has been up for $Days days, $Hours hours, and $Minutes minutes."
    Start-Process -NoNewWindow -Wait -FilePath "msg.exe" -ArgumentList "*", "$message The system will restart in 5 minute. Please save your work."
} else {
    Write-Output "$Date = Uptime: $Days days, $Hours hours, $Minutes minutes reboot is not needed at this time." | Out-File -Append -FilePath "C:\Scripts\reboot_script.log"
    exit  # Exit if uptime is below threshold
}
# Wait for 5 minute before restarting
Start-Sleep -Seconds 300
# Restart the computer
# Log the uptime before rebooting
Write-Output "$Date = System has been Rebooted" | Out-File -Append -FilePath "C:\Scripts\reboot_script.log"
Shutdown /r /t 0 /f
# Close the PowerShell window
exit
