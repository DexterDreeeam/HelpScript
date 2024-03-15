Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$ixpCmd = Get-Command -Name New-TestMachine -ErrorAction SilentlyContinue
if (-not $ixpCmd) {
    Write-Error "IXP is not installed"
    exit 1
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
$branch = $args[0]
$flavor = $args[1]

if ($flavor -in $flavors) {
    Write-Host "Flavor is $flavor"
} else {
    $flavor = "ProfDesktop"
    Write-Warning "Flavor not found, fallback to ProfDesktop"
}

$vmName = ""
for ($i = 0; $i -lt 10; $i++) {
    $name = "vm$i"
    $exists = Get-VM -Name $name -ErrorAction SilentlyContinue
    if ($exists) {
        Write-Warning "$name exists"
    } else {
        $vmName = $name
        break
    }
}

if ($vmName -eq "") {
    Write-Error "VM names are occuppied."
    exit 1
}

Write-Host "Creating VM: $vmName"

$externalSwitch = Get-VMSwitch | Where-Object { $_.SwitchType -eq 'External' } | Select-Object -First 1
if ([bool]$externalSwitch) {
    $switch = $externalSwitch.Name
} else {
    $switch = "Default Switch"
}

Write-Host "Use Switch: $switch"

$volumeD = Get-Volume -DriveLetter D -ErrorAction SilentlyContinue
if ($volumeD) {
    $vhdPath = "d:\vhd\"
    $cachePath = "d:\ixpCache\"
} else {
    $vhdPath = "c:\vhd\"
    $cachePath = "c:\ixpCache\"
}

New-TestMachine `
    -Name $vmName `
    -MachineName $vmName `
    -VirtualSwitchName $switch `
    -KdSetupMode Disable `
    -VmNumProcessors 8 `
    -VmMemInGb 8 `
    -SavePath $vhdPath `
    -Cache $cachePath `
    -Flavor $flavor `
    -Branch $branch `
    -Latest

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
