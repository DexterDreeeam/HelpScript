Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$device = Get-IxpDevice
$ip = $device.IP -join ""
spin -NoTests -Target:$ip

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
