Set-ExecutionPolicy RemoteSigned -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$bootstrapScript = (Invoke-WebRequest https://aka.ms/install-ixptools -EA Stop).Content
$bytes = [System.Text.Encoding]::Unicode.GetBytes( $bootstrapScript )
$sig = Get-AuthenticodeSignature -Source 'BootstrapInstall.ps1' -Content $bytes
if ( $sig.Status -eq 'Valid' ) {
  Invoke-Expression "& { $bootstrapScript }"
} else {
  Write-Error "Failed to validate signature: $($sig.Status)"
}