Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function MainEntry {
    $options = @("Git with VFS", "Latest Git")
    Write-Host "Choose an option:"
    for ($i=0; $i -lt $options.Count; $i++) {
        Write-Host "  $($i+1). $($options[$i])"
    }
    $choice = Read-Host "Enter 1 or 2 or Specific Git Version"
    
    $uninstaller = Get-ChildItem "C:\Program Files\Git\unins*.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    if ($uninstaller) {
        Write-Output "Git is installed. Uninstalling..."
        Start-Process -FilePath $uninstaller -ArgumentList "/SILENT" -Wait
    }
    
    # Install Git
    if ($choice -eq "1") {
        Write-Output "Installing VFS Git ..."
        winget install --id Microsoft.Git
        winget install --id Microsoft.VFSforGit
    }
    elseif ($choice -eq "2") {
        Write-Output "Installing latest Git version..."
        winget install --id Git.Git -e --source winget
    }
    else {
        Write-Output "Installing Git version $choice..."
        winget install --id Git.Git -e --source winget --version $choice
    }
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
