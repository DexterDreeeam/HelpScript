function RemoveFile($path) {
    Start-Process powershell -ArgumentList "Remove-Item `"$path`" -Force"
}

$repo = "https://raw.githubusercontent.com/dexterdreeeam/HelpScript/main/"
$cdUrl = "$repo/CDM/_run_cdm.ps1"
$cdPath = Join-Path -Path $pwd -ChildPath "_run_cd.ps1"
$rjUrl = "$repo/CDM/regjump.exe"
$rjPath = Join-Path -Path $pwd -ChildPath "regjump.exe"

$cdExist = Test-Path $cdPath -PathType Leaf
if (-not $cdExist) {
    Invoke-WebRequest -Uri $cdUrl -OutFile $cdPath
}

$rjExist = Test-Path $rjPath -PathType Leaf
if (-not $rjExist) {
    Invoke-WebRequest -Uri $rjUrl -OutFile $rjPath
}

Start-Process powershell -ArgumentList "-Command `"$args`"" -Verb RunAs

# Delete Resources
RemoveFile($cdPath)
RemoveFile($rjPath)

# Delete Self
RemoveFile($MyInvocation.MyCommand.Path)
