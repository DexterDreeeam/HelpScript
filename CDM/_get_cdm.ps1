function DownloadIfNotExist($url, $path) {
    $isExist = Test-Path $path -PathType Leaf
    if (-not $isExist) {
        Invoke-WebRequest -Uri $url -OutFile $path
    }
}

function RunWaitPowershell($pathAndArgs) {
    $psCmd = "-ExecutionPolicy Unrestricted -NoProfile -File ""$pathAndArgs"" -PauseOnCompletion"
    Start-Process -FilePath Powershell.exe -ArgumentList $psCmd -Wait
}

function ElevateLevel()
{
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent();
    $currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity);
    $administratorRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
    $isElevated = $currentPrincipal.IsInRole($administratorRole);
    if (-not $isElevated)
    {
        Write-Host -ForegroundColor Cyan "This script requires administrator privileges. Elevating..."
        $psCmd = "-ExecutionPolicy Unrestricted -NoProfile -File "
        $psCmd += $MyInvocation.MyCommand.Path
        $psCmd += " -PauseOnCompletion"
        Start-Process -FilePath Powershell.exe -Verb RunAs -ArgumentList $psCmd
        exit
    }
}

ElevateLevel

$repo = "https://raw.githubusercontent.com/dexterdreeeam/HelpScript/main/"
$cdUrl = "$repo/CDM/_run_cdm.ps1"
$cdPath = Join-Path -Path $pwd -ChildPath "_run_cdm.ps1"
$rjUrl = "$repo/CDM/regjump.exe"
$rjPath = Join-Path -Path $pwd -ChildPath "regjump.exe"

DownloadIfNotExist $cdUrl $cdPath
DownloadIfNotExist $rjUrl $rjPath

RunWaitPowershell $cdPath

# Delete Resources
Remove-Item $cdPath -Force
Remove-Item $rjPath -Force

# Delete Self
Remove-Item $MyInvocation.MyCommand.Path -Force
