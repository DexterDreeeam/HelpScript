Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$pageUrl = "https://www.voidtools.com/downloads/"
$response = Invoke-WebRequest -Uri $pageUrl
$pattern = "Everything-(\d+\.\d+\.\d+\.\d+)\.x64\.Lite-Setup\.exe"
$binary = "Everything-1.4.1.1024.x64.Lite-Setup.exe"

if ($response.Content -match $pattern) {
    $binary = $matches[0]
}

$binaryPath = Join-Path -Path $pwd -ChildPath $binary
$downloadUrl = "https://www.voidtools.com/" + $binary
Start-BitsTransfer -Source $downloadUrl -Destination $binaryPath

Start-Process -FilePath $binaryPath -Wait
Remove-Item -Path $binaryPath

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
