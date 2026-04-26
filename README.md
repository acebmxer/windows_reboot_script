Upload script to domain controller

create gpo to upload script to local pc and create scheduled task and Run script.

You can adjust ($ThresholdDays = 5) Change to $ThresholdHours = X or $thresholdMinutes = X.
also if ($Uptime.TotalDays -gt $ThresholdDays) accordingly.

You can adjust how long before the reboot process happens and prompt the user stating their total uptime before the reboot.
