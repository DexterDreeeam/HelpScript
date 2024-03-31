Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function MainEntry {
    # enable long file path
    git config --system core.longpaths true
    New-ItemProperty `
        -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
        -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

    $dst = $args[0]
    $dstDefault = ""
    $repoCacheServer = $null
    $vfsendpoint = "https://osgvfsserver.corp.microsoft.com"
    $os2020entry = "0d54b6ef" + "-" + "7283" + "-" + "444f" + "-" + "847a" + "-" + "343728d58a4d"
    $osentry = "7bc5fd9f" + "-" + "6098" + "-" + "479a" + "-" + "a87e" + "-" + "1533d288d438"

    while ($true) {
        $options = @("os.2020", "os", "OSClient", "XS.SDX.Settings")
        Write-Host "Choose an option:"
        for ($i=0; $i -lt $options.Count; $i++) {
            Write-Host "  $($i+1). $($options[$i])"
        }
        $choice = Read-Host "Enter which Repo you want to clone"
        if ($choice -eq "1") {
            $repo = "https://microsoft.visualstudio.com/OS/_git/os.2020"
            $repoCacheServer = $vfsendpoint + "/" + $os2020entry
            $dstDefault = "os.2020"
        }
        elseif ($choice -eq "2") {
            $repo = "https://microsoft.visualstudio.com/OS/_git/os"
            $repoCacheServer = $vfsendpoint + "/" + $osentry
            $dstDefault = "os"
        }
        elseif ($choice -eq "3") {
            $repo = "https://microsoft.visualstudio.com/DefaultCollection/OS/_git/OSClient"
            $dstDefault = "OSClient"
        }
        elseif ($choice -eq "4") {
            $repo = "https://microsoft.visualstudio.com/DefaultCollection/Universal%20Store/_git/XS.SDX.Settings"
            $dstDefault = "XS.SDX.Settings"
        }
        else {
            continue
        }

        break
    }

    if ([string]::IsNullOrWhiteSpace($dst)) {
        $dst = $dstDefault
    }

    $dstPath = Join-Path -Path $pwd -ChildPath $dst
    if (Test-Path -Path $dstPath -PathType Container) {
        $choice = Read-Host "$dstPath exists. Delete? (Y/N)"
        if ($choice -eq "Y" -or $choice -eq "y") {
            Remove-Item -Path $dstPath -Recurse -Force
        }
        elseif ($choice -eq "N" -or $choice -eq "n") {
            exit
        }
    }

    $international = $false
    if ($null -ne $repoCacheServer) {
        $choice = Read-Host "Use international cache server (for non-redmond dev machine)? (Y/N)"
        if ($choice -eq "y" -or $choice -eq "Y") {
            $international = $true
        }
    }

    set GIT_TEST_NO_WRITE_REV_INDEX=1
    git config --global pack.writeReverseIndex false

    $binaryPath = Join-Path -Path $pwd -ChildPath $binary

    if ($international) {
        gvfs clone $repo $dst --cache-server-url $repoCacheServer
    }
    elseif ($null -ne $repoCacheServer) {
        gvfs clone $repo $dst
    }
    else {
        git clone $repo $dst
    }
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
