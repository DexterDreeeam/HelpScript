$uninstaller = Get-ChildItem "C:\Program Files\Git\unins*.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

if ($uninstaller) {
    Write-Output "Git is installed. Uninstalling..."
    Start-Process -FilePath $uninstaller -ArgumentList "/SILENT" -Wait
}

# Install Git
$version = $args[0]
if ($version) {
    Write-Output "Installing Git version $version..."
    winget install --id Git.Git -e --source winget --version $version
} elseif ($version -eq "vfs") {
    Write-Output "Installing VFS Git ..."
    winget install --id Microsoft.Git
    winget install --id Microsoft.VFSforGit
} else {
    Write-Output "Installing latest Git version..."
    winget install --id Git.Git -e --source winget
}
