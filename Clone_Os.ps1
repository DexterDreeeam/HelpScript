Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function LoadVars {
    $_vars_url = "https://raw.githubusercontent.com/dexterdreeeam/HelpScript/main/vars.txt"
    $_s = (Invoke-WebRequest -Uri $_vars_url).Content
    $_j = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_s))
    $global:_vars = $_j | ConvertFrom-Json
}

function Vars ($key) {
    return $global:_vars.$key
}

function MainEntry {
    # enable long file path
    git config --system core.longpaths true
    New-ItemProperty `
        -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
        -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

    $dst = ""
    $dstDefault = ""
    $repoCacheServer = $null
    $vfsendpoint = Vars("vfs_osgendpoint")
    $os2020entry = Vars("osg_os2020_entry")
    $osentry = Vars("osg_os_entry")

    while ($true) {
        $options = Vars("os_repo_list")
        Write-Host "Choose an option:"
        for ($i=0; $i -lt $options.Count; $i++) {
            Write-Host "  $($i+1). $($options[$i])"
        }
        $choice = [int](Read-Host "Enter which Repo you want to clone")
        if ($choice -eq 1) {
            $repo = Vars("os_2020_repo")
            $repoCacheServer = $vfsendpoint + "/" + $os2020entry
        }
        elseif ($choice -eq 2) {
            $repo = Vars("os_repo")
            $repoCacheServer = $vfsendpoint + "/" + $osentry
        }
        elseif ($choice -eq 3) {
            $repo = Vars("osc_repo")
        }
        elseif ($choice -eq 4) {
            $repo = Vars("xs_sdx_settings_repo")
        }
        else {
            continue
        }

        $dstDefault = $options[$choice - 1]
        break
    }

    $dst = Read-Host "Enter your local repo name (default: $dstDefault)"
    if ([string]::IsNullOrWhiteSpace($dst)) {
        $dst = $dstDefault
    }

    $dstPath = Join-Path -Path $pwd -ChildPath $dst
    Write-Host "Clone Path: " -ForegroundColor Yellow -NoNewline
    Write-Host $dstPath       -ForegroundColor Green

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
    LoadVars
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
