[CmdletBinding()]
Param(
  [String]$message = "",
  [Int]$timeout = 3,
  [Boolean]$shutdown_only = $false
)
# If an error is encountered, the script will stop instead of the default of "Continue"
$ErrorActionPreference = "Stop"

If (Test-Path -Path $env:SYSTEMROOT\sysnative\shutdown.exe) {
  $executable = "$env:SYSTEMROOT\sysnative\shutdown.exe"
}
ElseIf (Test-Path -Path $env:SYSTEMROOT\system32\shutdown.exe) {
  $executable = "$env:SYSTEMROOT\system32\shutdown.exe"
}
Else {
  $executable = "shutdown.exe"
}

# Force a minimum timeout of 3 second to allow the response to be returned.
If ($timeout -lt 3) {
  $timeout = 3
}

$reboot_param = "/r"
If ($shutdown_only) {
  $reboot_param = "/s"
}

If ($message -ne "") {
  & $executable $reboot_param /t $timeout /d p:4:1 /c $message
}
Else {
  & $executable $reboot_param /t $timeout /d p:4:1
}

Write-Output "{""status"":""queued"",""timeout"":${timeout}}"
