Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function LoadVars {
    $_vars_url = "http://dexter-base.link/vars"
    $_s = (Invoke-WebRequest -Uri $_vars_url).Content
    $_j = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_s))
    $global:_vars = $_j | ConvertFrom-Json
}

function Vars ($key) {
    return $global:_vars.$key
}

function MainEntry {
    $ixpCmd = Get-Command -Name New-TestMachine -ErrorAction SilentlyContinue
    if (-not $ixpCmd) {
        Write-Error "IXP is not installed"
        exit 1
    }

    $branchDefault = Vars("os_branch_default")
    $branches = Vars("os_branch_list")

    $flavorDefault = Vars("os_flavor_default")
    $flavors = Vars("os_flavor_list")

    Write-Host "Choose an option:"
    for ($i=0; $i -lt $branches.Count; $i++) {
        Write-Host "  $($i+1). $($branches[$i])" -ForegroundColor Yellow
    }
    $branchChoice = Read-Host "Enter Index or Branch (default $branchDefault)"
    if ([string]::IsNullOrWhiteSpace($branchChoice)) {
        $branch = $branchDefault
    }
    elseif ($branchChoice -as [int] -gt 0 -and $branchChoice -as [int] -le $branches.Count) {
        $branchIndex = [int]$branchChoice - 1
        $branch = $branches[$branchIndex]
    }
    else {
        $branch = $branchChoice
    }
    
    Write-Host "Branch " -ForegroundColor Yellow -NoNewline
    Write-Host $branch   -ForegroundColor Green

    Write-Host "Choose an option:"
    for ($i=0; $i -lt $flavors.Count; $i++) {
        Write-Host "  $($i+1). $($flavors[$i])" -ForegroundColor Yellow
    }
    $flavorChoice = Read-Host "Enter Index or Flavor (default $flavorDefault)"
    if ([string]::IsNullOrWhiteSpace($flavorChoice)) {
        $flavor = $flavorDefault
    }
    elseif ($flavorChoice -as [int] -gt 0 -and $flavorChoice -as [int] -le $flavors.Count) {
        $flavorIndex = [int]$flavorChoice - 1
        $flavor = $flavors[$flavorIndex]
    }
    else {
        $flavor = $flavorChoice
    }
    
    Write-Host "Flavor " -ForegroundColor Yellow -NoNewline
    Write-Host $flavor   -ForegroundColor Green

    $vmNames = Get-VM | Select-Object -ExpandProperty Name
    for ($i = 0; $i -lt 100; $i++) {
        $prefix = "vm$i-"
        $vmsWithPrefix = $vmNames -like ($prefix + "*")
        if ($vmsWithPrefix) {
            Write-Warning "VM Prefix [$prefix] exists"
        } else {
            $length = 8
            $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            $randomStr = -join ((Get-Random -Count $length -InputObject $chars.ToCharArray()))
            $vmName = $prefix + $randomStr
            break
        }
    }

    Write-Host "Creating VM " -ForegroundColor Yellow -NoNewline
    Write-Host $vmName        -ForegroundColor Green
    
    $externalSwitch = Get-VMSwitch | Where-Object { $_.SwitchType -eq 'External' } | Select-Object -First 1
    if ([bool]$externalSwitch) {
        $switch = $externalSwitch.Name
    }
    else {
        $switch = "Default Switch"
    }
    
    Write-Host "Network Switch " -ForegroundColor Yellow -NoNewline
    Write-Host $switch           -ForegroundColor Green
    
    $driveLetter = "C"
    $drives = Get-PSDrive -PSProvider FileSystem
    $i = 1
    foreach ($drive in $drives) {
        Write-Host "${i}: $($drive.Name)"
        $i++
    }
    $choice = Read-Host "Select a drive to Cache VHD (default: [C])"
    $number = 0
    $isNumeric = [int]::TryParse($choice, [ref]$number)
    if ($isNumeric) {
        $driveLetter = $drives[$number - 1].Name
    }
    elseif (![string]::IsNullOrEmpty($choice)) {
        $driveLetter = "$choice"
    }
    
    $vhdPath = "${driveLetter}:\vhd\"
    $cachePath = "${driveLetter}:\ixpCache\"

    Write-Host "VHD Cache Path " -ForegroundColor Yellow -NoNewline
    Write-Host $vhdPath          -ForegroundColor Green
    Write-Host "IXP Cache Path " -ForegroundColor Yellow -NoNewline
    Write-Host $cachePath        -ForegroundColor Green

    Set-IxpDownloadCache $cachePath

    $params = @{
        Name                   = $vmName
        MachineName            = $vmName
        VirtualSwitchName      = $switch
        KdSetupMode            = "Disable"
        VmNumProcessors        = 8
        VmMemInGb              = 8
    }

    $choice = Read-Host "Skip OOBE? (Y/N, default: Y)"
    if ($choice -eq "N" -or $choice -eq "n") {
        $params["NoUnattend"] = $true
    }

    $choice = Read-Host "Need [Download VHD] and [Create VM] in 2 different network? (Y/N, default N)"
    if ($choice -eq "Y" -or $choice -eq "y") {
        Write-Host "Prepare your network environment to download VHD"
        Read-Host  "Press any button to download VHD"
        Copy-VhdFromBuildShare -Branch $branch -Flavor $flavor

        Write-Host "Prepare your network environment to create VM"
        Read-Host "Press any button to select VHD path and create VM"

        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Virtual Hard Disk files (*.vhd;*.vhdx)|*.vhd;*.vhdx"
        $openFileDialog.Title = "Choose a VHD or VHDX file"
        $openFileDialog.InitialDirectory = $cachePath + "vhd\"
        $result = $openFileDialog.ShowDialog()
        if ($result -eq 'OK') {
            $selectedVhd = $openFileDialog.FileName
            Write-Output "Selected VHD: $selectedVhd"
        }
        else {
            exit 1
        }

        Write-Host "Selected VHD " -ForegroundColor Yellow -NoNewline
        Write-Host $selectedVhd    -ForegroundColor Green

        $params["VhdSource"] = $selectedVhd
        $params["AllowOffline"] = $true
        $params["NoNestedVirtualization"] = $true
    }
    else {
        net use \\ntdev\release

        $params["Branch"] = $branch
        $params["Flavor"] = $flavor
        $params["SavePath"] = $vhdPath
        $params["Cache"] = $true
    }

    New-TestMachine @params
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
