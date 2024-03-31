Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function MainEntry {
    $device = Get-IxpDevice
    $ip = $device.IP -join ""
    spin -NoTests -Target:$ip
}

try {
    MainEntry
}
catch {
    Write-Host "Exception:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.Exception.StackTrace -ForegroundColor Red
    exit 1
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
