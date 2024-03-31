Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function MainEntry {
    $Pat = Read-Host -Prompt "Enter AAD PAT"
    Install-Module CredentialManager -Force -Repository PSGallery
    
    $targets = "vpack:https://microsoft.artifacts.visualstudio.com", 
               "vpack:https://microsoft.vsblob.visualstudio.com", 
               "vcas-cms:https://microsoft.artifacts.visualstudio.com", 
               "vcas-cms:https://microsoft.vsblob.visualstudio.com"
    
    $targets | ForEach-Object {
        New-StoredCredential `
            -Target $_ `
            -UserName "PAT" `
            -Password $Pat `
            -Persist LOCALMACHINE
    }
}

try {
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
