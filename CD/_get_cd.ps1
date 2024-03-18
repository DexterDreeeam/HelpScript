$repo = "https://raw.githubusercontent.com/dexterdreeeam/HelpScript/main/"
$cdUrl = "$repo/CD/_run_cd.ps1"
$cdPath = Join-Path -Path $pwd -ChildPath "_run_cd.ps1"

$cdExist = Test-Path $cdPath -PathType Leaf
if (-not $cdExist) {
    Invoke-WebRequest -Uri $cdUrl -OutFile $cdPath
}

& $cdPath $args

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
