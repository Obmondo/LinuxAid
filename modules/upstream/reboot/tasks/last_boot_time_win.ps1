$boot = Get-WmiObject -Class Win32_OperatingSystem
$dt = $boot.ConvertToDateTime($boot.LastBootUpTime)
Write-Output "$($dt.ToShortDateString()) $($dt.ToLongTimeString())"
