Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function CheckNonSystemPath {
    $windowsDir = [Environment]::GetFolderPath("Windows")
    $programFilesDir = [Environment]::GetFolderPath("ProgramFiles")
    $programFilesX86Dir = [Environment]::GetFolderPath("ProgramFilesX86")
    $systemDir = [Environment]::SystemDirectory
    $p = $pwd.Path
    if ($pwd.Path.StartsWith($systemFolder, [StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "Please switch to another non-system folder and retry" -ForegroundColor Red
        exit 1
    }
    if ($p.StartsWith($windowsDir, [StringComparison]::OrdinalIgnoreCase) -or
        $p.StartsWith($programFilesDir, [StringComparison]::OrdinalIgnoreCase) -or
        $p.StartsWith($programFilesX86Dir, [StringComparison]::OrdinalIgnoreCase) -or
        $p.StartsWith($systemDir, [StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "Please switch to another non-system folder and retry" -ForegroundColor Red
        exit 1
    }
}

function DownloadAndRun($downloadUrl, $binaryUrl) {
    Start-BitsTransfer -Source $downloadUrl -Destination $binaryPath -Force
    if (Test-Path $binaryPath -PathType Leaf) {
        Start-Process -FilePath $binaryPath
    }
    else {
        Write-Host "$binaryUrl download failed." -ForegroundColor Red
        exit 1
    }
}

function MainEntry {
    $binary = "RemoteTools.amd64ret.enu.exe"
    $binaryPath = Join-Path -Path $pwd -ChildPath $binary
    $downloadUrl = "https://aka.ms/vs/17/release/" + $binary
    
    CheckNonSystemPath
    DownloadAndRun $downloadUrl $binaryPath
}

try {
    MainEntry
}
catch {
    Write-Host "Exception:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
