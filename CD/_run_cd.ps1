$options = @("Open CDM content folder")
Write-Host "Choose an option:"
for ($i=0; $i -lt $options.Count; $i++) {
    Write-Host "  $($i+1). $($options[$i])"
}
$choice = Read-Host "Enter option index"

if ($choice -eq "1") {
    $cdmFolder = [System.Environment]::GetFolderPath('UserProfile')
    $cdmFolder = Join-Path -Path $cdmFolder -ChildPath "AppData\Local\Packages"
    $cdmFolder = Join-Path -Path $cdmFolder -ChildPath "Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy"
    $cdmFolder = Join-Path -Path $cdmFolder -ChildPath "LocalState\ContentManagementSDK\Creatives\ADUNITID"
    Invoke-Item $cdmFolder
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
