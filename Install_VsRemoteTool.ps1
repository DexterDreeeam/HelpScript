Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$binary = "RemoteTools.amd64ret.enu.exe"
$binaryPath = Join-Path -Path $pwd -ChildPath $binary
$downloadUrl = "https://aka.ms/vs/17/release/" + $binary

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
