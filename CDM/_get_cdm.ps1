function DownloadIfNotExist($url, $path) {
    $isExist = Test-Path $path -PathType Leaf
    if (-not $isExist) {
        Invoke-WebRequest -Uri $url -OutFile $path
    }
}

function RemoveFile($path) {
    Start-Process powershell -ArgumentList "Remove-Item `"$path`" -Force"
}

function ElevateLevel([string] $scriptFilePathAndArguments)
{
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent();
    $currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity);
    $administratorRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
    $isElevated = $currentPrincipal.IsInRole($administratorRole);
    if (-not $isElevated)
    {
        Write-Host -ForegroundColor Cyan "This script requires administrator privileges. Elevating..."
        Write-Host -ForegroundColor Cyan "$scriptFilePathAndArguments"
        Start-Process -FilePath Powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Unrestricted -NoProfile -File ""$scriptFilePathAndArguments"" -PauseOnCompletion"
        exit
    }
}

ElevateLevel $MyInvocation.MyCommand.Path

$repo = "https://raw.githubusercontent.com/dexterdreeeam/HelpScript/main/"
$cdUrl = "$repo/CDM/_run_cdm.ps1"
$cdPath = Join-Path -Path $pwd -ChildPath "_run_cdm.ps1"
$rjUrl = "$repo/CDM/regjump.exe"
$rjPath = Join-Path -Path $pwd -ChildPath "regjump.exe"

DownloadIfNotExist $cdUrl $cdPath
DownloadIfNotExist $rjUrl $rjPath

Start-Process powershell -ArgumentList "-Command `"$args`"" -Verb RunAs

# Delete Resources
RemoveFile $cdPath
RemoveFile $rjPath

# Delete Self
RemoveFile $MyInvocation.MyCommand.Path
