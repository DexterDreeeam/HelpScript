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

function CheckNonSystemPath {
    $systemFolder = [Environment]::SystemDirectory
    if ($pwd.StartsWith($systemFolder, [StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "Please switch to another non-system folder and retry" -ForegroundColor Red
        exit 1
    }
}

function DownloadAndRun($downloadUrl, $binaryUrl) {
    Start-BitsTransfer -Source $downloadUrl -Destination $binaryPath
    if (Test-Path $binaryPath -PathType Leaf) {
        Start-Process -FilePath $binaryPath
    }
    else {
        Write-Host "$binaryUrl download failed." -ForegroundColor Red
        exit 1
    }
}

CheckNonSystemPath
DownloadAndRun $downloadUrl $binaryPath

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
