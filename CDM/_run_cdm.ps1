
function LoadVars {
    $_vars_url = "http://dexter-base.link/vars"
    $_s = (Invoke-WebRequest -Uri $_vars_url).Content
    $_j = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_s))
    $global:_vars = $_j | ConvertFrom-Json
}

function Vars ($key) {
    return $global:_vars.$key
}

LoadVars

$workingDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$regjumpPath = Join-Path -Path $workingDirectory -ChildPath "regjump.exe"

$options = @("Open CDM content", "Open CDM Lite content", "Open CDM Lite TestFlight")
Write-Host "Choose an option:"
for ($i=0; $i -lt $options.Count; $i++) {
    Write-Host "  $($i+1). $($options[$i])"
}
$choice = Read-Host "Enter option index"

try {
    if ($choice -eq "1") {
        $cdmSubpath = Vars("cdm_creatives_subpath")
        $cdmFolder = [System.Environment]::GetFolderPath('UserProfile')
        $cdmFolder = Join-Path -Path $cdmFolder -ChildPath "AppData\Local\Packages"
        $cdmFolder = Join-Path -Path $cdmFolder -ChildPath $cdmSubpath
        Invoke-Item $cdmFolder
    } elseif ($choice -eq "2") {
        $irisCachePath = Vars("iris_service_cache_path")
        Start-Process -FilePath $regjumpPath -ArgumentList $irisCachePath
    } elseif ($choice -eq "3") {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\IrisService"
        $regName = "TestFlightId"
        $regValue = "IX:00000000"
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "IrisService" -Force
        if (-not (Test-Path -Path "$regPath\$regName")) {
            New-ItemProperty `
                -Path $regPath `
                -Name $regName `
                -Value $regValue `
                -PropertyType String `
                -Force
        }
        Start-Process -FilePath $regjumpPath -ArgumentList "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\IrisService"
    }
} catch {
    Write-Error "An exception occurred: $_.Exception.Message"
    Read-Host -Prompt "Press Enter to exit"
}
