$options = @("Open CDM content", "Open CDM Lite content")
Write-Host "Choose an option:"
for ($i=0; $i -lt $options.Count; $i++) {
    Write-Host "  $($i+1). $($options[$i])"
}
$choice = Read-Host "Enter option index"

if ($choice -eq "1") {
    $cdmFolder = [System.Environment]::GetFolderPath('UserProfile')
    $cdmFolder = Join-Path -Path $cdmFolder -ChildPath "AppData\Local\Packages"
    $cdmFolder = Join-Path -Path $cdmFolder -ChildPath "Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy"
    $cdmFolder = Join-Path -Path $cdmFolder -ChildPath "LocalState\ContentManagementSDK\Creatives"
    Invoke-Item $cdmFolder
} elseif ($choice -eq "2") {
    $registryPath = "HKEY_CURRENT_USER\Software\Microsoft\Windows"
    Start-Process -FilePath "regedit.exe" -ArgumentList "/e, $registryPath"

    function jumpReg ($registryPath)
    {
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion" `
                         -Name "LastKey" `
                         -Value $registryPath `
                         -PropertyType String `
                         -Force
    
        regedit
    }
    
    jumpReg ("Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run") | Out-Null
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
