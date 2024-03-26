Add-Type -AssemblyName System.Windows.Forms

Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$options = @("Add Profile", "Remove Profile")
Write-Host "Choose an option:"
for ($i=0; $i -lt $options.Count; $i++) {
    Write-Host "  $($i+1). $($options[$i])"
}
$choice = Read-Host "Enter your operation"
if ($choice -eq "1") {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select os.2020 folder"
    $folderBrowser.RootFolder = "MyComputer"
    $folderBrowser.ShowNewFolderButton = $true
    $result = $folderBrowser.ShowDialog()
    if ($result -eq 'OK') {
        $selectedFolder = $folderBrowser.SelectedPath
        Write-Output "Folder selected: $selectedFolder"

        $archDefault = "amd64fre"
        $arch = Read-Host -Prompt "Input Arch (Enter for default: $archDefault)"
        if ($arch -eq "") {
            $arch = $archDefault
        }

        $flagDefault = "dev_build"
        $flag = Read-Host -Prompt "Input Flag (Enter for default: $flagDefault)"
        if ($flag -eq "") {
            $flag = $flagDefault
        }

        New-RazzleTerminalProfile `
            -SrcDir $selectedFolder `
            -Arch $arch `
            -Flags $flag
    }
} elseif ($choice -eq "2") {
    Remove-RazzleTerminalProfile
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
