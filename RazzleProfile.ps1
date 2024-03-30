Add-Type -AssemblyName System.Windows.Forms
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function GetRazzleParameters {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select os.2020 folder"
    $folderBrowser.RootFolder = "MyComputer"
    $folderBrowser.ShowNewFolderButton = $true
    $result = $folderBrowser.ShowDialog()
    if ($result -eq 'OK') {
        $selectedFolder = $folderBrowser.SelectedPath
        if ((Get-Item $selectedFolder).Name -ne "src") {
            $selectedFolder = Join-Path -Path $selectedFolder -ChildPath "src"
        }
        Write-Output "Razzle path selected: $selectedFolder"

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
    }
    else {
        exit 1
    }

    return @{
        Path = $selectedFolder
        Arch = $arch
        Flag = $flag
    }
}

function DirectRazzle {
    $pars = GetRazzleParameters
    raz $pars.Path $pars.Arch -Flags $pars.Flag
}

function RazzleTerminalProfile {
    $options = @("Add Profile", "Remove Profile")
    Write-Host "Choose an option:"
    for ($i=0; $i -lt $options.Count; $i++) {
        Write-Host "  $($i+1). $($options[$i])"
    }
    $choice = Read-Host "Enter your operation"
    if ($choice -eq "1") {
        $pars = GetRazzleParameters
        New-RazzleTerminalProfile `
            -SrcDir $pars.Path `
            -Arch $pars.Arch `
            -Flags $pars.Flag
    }
    elseif ($choice -eq "2") {
        Remove-RazzleTerminalProfile
    }
}

$options = @("Direct Raz", "Razzle Terminal Profile")
Write-Host "Choose an option:"
for ($i=0; $i -lt $options.Count; $i++) {
    Write-Host "  $($i+1). $($options[$i])"
}
$choice = Read-Host "Enter your operation"

if ($choice -eq "1") {
    DirectRazzle
}
elseif ($choice -eq "2") {
    RazzleTerminalProfile
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
