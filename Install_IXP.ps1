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
    winget install --id Microsoft.Powershell --source winget
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $ixptoolUrl = Vars("ixptool_install_url")
    $bootstrapScript = (Invoke-WebRequest $ixptoolUrl -EA Stop).Content
    $bytes = [System.Text.Encoding]::Unicode.GetBytes( $bootstrapScript )
    $sig = Get-AuthenticodeSignature -Source 'BootstrapInstall.ps1' -Content $bytes
    if ( $sig.Status -eq 'Valid' ) {
      Invoke-Expression "& { $bootstrapScript }"
    }
    else {
      Write-Error "Failed to validate signature: $($sig.Status)"
    }
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
