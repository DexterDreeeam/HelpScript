Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$dst = $args[0]
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
    } elseif ($choice -eq "2") {
        $repo = "https://microsoft.visualstudio.com/OS/_git/os"
        $repoCacheServer = $vfsendpoint + "/" + $osentry
    } elseif ($choice -eq "3") {
        $repo = "https://microsoft.visualstudio.com/DefaultCollection/OS/_git/OSClient"
    } elseif ($choice -eq "4") {
        $repo = "https://microsoft.visualstudio.com/DefaultCollection/Universal%20Store/_git/XS.SDX.Settings"
    } else {
        continue
    }

    break
}

$international = $false
if ($null -ne $repoCacheServer) {
    $choice = Read-Host "Use international cache server (for non-redmond dev machine)? (Y/N)"
    if ($choice -eq "y" -or $choice -eq "Y") {
        $international = $true
    }
}

if ($international) {
    gvfs clone $repo $dst --cache-server-url $repoCacheServer
} elseif ($null -ne $repoCacheServer) {
    gvfs clone $repo $dst
} else {
    git clone $repo $dst
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"