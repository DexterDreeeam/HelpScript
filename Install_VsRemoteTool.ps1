Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$binary = "RemoteTools.amd64ret.enu.exe"
$binaryPath = Join-Path -Path $pwd -ChildPath $binary
$downloadUrl = "https://aka.ms/vs/17/release/" + $binary
Start-BitsTransfer -Source $downloadUrl -Destination $binaryPath

if (Test-Path $binaryPath -PathType Leaf) {
    Start-Process -FilePath $binaryPath
}
else {
    Write-Host "Please switch to another non-system folder and retry" -ForegroundColor Red
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
