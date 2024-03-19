function DownloadIfNotExist($url, $path) {
    $isExist = Test-Path $path -PathType Leaf
    if (-not $isExist) {
        Invoke-WebRequest -Uri $url -OutFile $path
    }
}

function RemoveFile($path) {
    Start-Process powershell -ArgumentList "Remove-Item `"$path`" -Force"
}

$repo = "https://raw.githubusercontent.com/dexterdreeeam/HelpScript/main/"
$cdUrl = "$repo/CDM/_run_cdm.ps1"
$cdPath = Join-Path -Path $pwd -ChildPath "_run_cd.ps1"
$rjUrl = "$repo/CDM/regjump.exe"
$rjPath = Join-Path -Path $pwd -ChildPath "regjump.exe"

DownloadIfNotExist($cdUrl, $cdPath)
DownloadIfNotExist($rjUrl, $rjPath)

Start-Process powershell -ArgumentList "-Command `"$args`"" -Verb RunAs

# Delete Resources
RemoveFile($cdPath)
RemoveFile($rjPath)

# Delete Self
RemoveFile($MyInvocation.MyCommand.Path)
