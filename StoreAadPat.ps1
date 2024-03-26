Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$DropPat = Read-Host -Prompt "Enter AAD Drop PAT"
Install-Module CredentialManager -Force -Repository PSGallery

$targets = "vpack:https://microsoft.artifacts.visualstudio.com", 
           "vpack:https://microsoft.vsblob.visualstudio.com", 
           "vcas-cms:https://microsoft.artifacts.visualstudio.com", 
           "vcas-cms:https://microsoft.vsblob.visualstudio.com"

$targets | ForEach-Object {
    New-StoredCredential `
        -Target $_ `
        -UserName "PAT" `
        -Password $DropPat `
        -Persist LOCALMACHINE
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
