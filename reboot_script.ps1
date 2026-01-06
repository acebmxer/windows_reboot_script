# Check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as administrator, restart script with admin privileges
if (-not (Test-Administrator)) {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$LastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$UptimeMinutes = ((Get-Date) - $LastBoot).TotalMinutes
if ($UptimeMinutes -gt 3) {
    # Send a User Notification using msg.exe
    Start-Process -NoNewWindow -Wait -FilePath "msg.exe" -ArgumentList "*", "Your computer has been up for $UptimeMinutes. The system will restart in 1 minute. Please save your work."
}
    # Wait for 1 minute before restarting
    Start-Sleep -Seconds 60
powershell -Command "Set-ExecutionPolicy Restricted -Scope CurrentUser"
    # Restart the computer
    Restart-Computer
    # Close the PowerShell window
    exit