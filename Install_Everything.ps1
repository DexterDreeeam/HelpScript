Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function CheckNonSystemPath {
    $windowsDir = [Environment]::GetFolderPath("Windows")
    $programFilesDir = [Environment]::GetFolderPath("ProgramFiles")
    $programFilesX86Dir = [Environment]::GetFolderPath("ProgramFilesX86")
    $systemDir = [Environment]::SystemDirectory
    $_p = $pwd.Path
    if ($_p.StartsWith($windowsDir, [StringComparison]::OrdinalIgnoreCase) -or
        $_p.StartsWith($programFilesDir, [StringComparison]::OrdinalIgnoreCase) -or
        $_p.StartsWith($programFilesX86Dir, [StringComparison]::OrdinalIgnoreCase) -or
        $_p.StartsWith($systemDir, [StringComparison]::OrdinalIgnoreCase)) {
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
    $pageUrl = "https://www.voidtools.com/downloads/"
    $response = Invoke-WebRequest -Uri $pageUrl
    $pattern = "Everything-(\d+\.\d+\.\d+\.\d+)\.x64\.Lite-Setup\.exe"
    $binary = "Everything-1.4.1.1024.x64.Lite-Setup.exe"
    
    if ($response.Content -match $pattern) {
        $binary = $matches[0]
    }
    
    $binaryPath = Join-Path -Path $pwd -ChildPath $binary
    $downloadUrl = "https://www.voidtools.com/" + $binary
    
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
