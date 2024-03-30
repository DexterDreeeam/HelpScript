Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$ixpCmd = Get-Command -Name New-TestMachine -ErrorAction SilentlyContinue
if (-not $ixpCmd) {
    Write-Error "IXP is not installed"
    exit 1
}

$branches = @(
    "official/ni_current_directshell_dev1",
    "official/ni_current_directshell_dev2",
    "official/ni_current_directshell_dev3",
    "official/rs_we_sigx_dev1",
    "official/vb_release_svc_cfedge",
    "official/vb_release_svc_cfewebxt",
    "official/main"
)
$branchDefault = "official/ni_current_directshell_dev1"
$branchChoice = Read-Host "Enter your Branch or Index (default is $branchDefault)"
if ([string]::IsNullOrWhiteSpace($branchChoice)) {
    $branch = $branchDefault
}
elseif ($branchChoice -as [int] -gt 0 -and $branchChoice -as [int] -le $branches.Count) {
    $branchIndex = [int]$branchChoice
    $branch = $branches[$branchIndex]
}
else {
    $branch = $branchChoice
}

$flavors = @(
    "CloudEdition",
    "ClientCore",
    "Desktop",
    "OnecoreUAP",
    "ProfDesktop",
    "Server",
    "ServerCore",
    "ServerRDSH",
    "TeamOS",
    "WindowsCore"
)
$flavorDefault = "ProfDesktop"
$flavorChoice = Read-Host "Enter your Flavor or Index (default is $flavorDefault)"
if ([string]::IsNullOrWhiteSpace($flavorChoice)) {
    $flavor = $flavorDefault
}
elseif ($flavorChoice -as [int] -gt 0 -and $flavorChoice -as [int] -le $flavors.Count) {
    $flavorIndex = [int]$flavorChoice
    $flavor = $flavors[$flavorIndex]
}
else {
    $flavor = $flavorChoice
}

Write-Host "Branch [$branch]"
Write-Host "Flavor [$flavor]"

# $vmName = "TestVm"
# while ($true) {
#     $name = Read-Host "Enter your VM Name"
#     $exists = Get-VM -Name $vmName -ErrorAction SilentlyContinue
#     if ($exists) {
#         Write-Warning "$name exists"
#     } else {
#         $vmName = $name
#         break
#     }
# }

$vmNames = Get-VM | Select-Object -ExpandProperty Name
for ($i = 0; $i -lt 100; $i++) {
    $prefix = "vm$i-"
    $vmsWithPrefix = $vmNames -like $prefix
    if ($vmsWithPrefix) {
        Write-Warning "VM Prefix [$prefix] exists"
    } else {
        $length = 8
        $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        $randomString = -join ((Get-Random -Count $length -InputObject $characters.ToCharArray()))
        $vmName = $prefix + $randomString
        break
    }
}

Write-Host "Creating VM: $vmName"

$externalSwitch = Get-VMSwitch | Where-Object { $_.SwitchType -eq 'External' } | Select-Object -First 1
if ([bool]$externalSwitch) {
    $switch = $externalSwitch.Name
} else {
    $switch = "Default Switch"
}

Write-Host "Network Switch [$switch]"

$volumeD = Get-Volume -DriveLetter D -ErrorAction SilentlyContinue
if ($volumeD) {
    $vhdPath = "d:\vhd\"
    $cachePath = "d:\ixpCache\"
} else {
    $vhdPath = "c:\vhd\"
    $cachePath = "c:\ixpCache\"
}

Set-IxpDownloadCache $cachePath

New-TestMachine `
    -Name $vmName `
    -MachineName $vmName `
    -VirtualSwitchName $switch `
    -KdSetupMode Disable `
    -VmNumProcessors 8 `
    -VmMemInGb 8 `
    -Branch $branch `
    -Flavor $flavor `
    -SavePath $vhdPath `
    -Cache

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
