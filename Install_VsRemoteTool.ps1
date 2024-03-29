Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$binary = "RemoteTools.amd64ret.enu.exe"
$binaryPath = Join-Path -Path $pwd -ChildPath $binary
$downloadUrl = "https://aka.ms/vs/17/release/" + $binary
Invoke-WebRequest $downloadUrl -OutFile $binaryPath

Start-Process -FilePath $binaryPath

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
