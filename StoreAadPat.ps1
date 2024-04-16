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
    Install-Module CredentialManager -Force -Repository PSGallery

    $targets = Vars("aad_pat_target_list")

    $choice = Read-Host "To Add or Remove your AAD Credential Provider? (Y/N)"
    if ($choice -eq "Y" -or $choice -eq "y") {
        $Pat = Read-Host -Prompt "Enter AAD PAT"
        $targets | ForEach-Object {
            New-StoredCredential `
                -Target $_ `
                -UserName "PAT" `
                -Password $Pat `
                -Persist LOCALMACHINE
        }
    }
    elseif ($choice -eq "N" -or $choice -eq "n") {
        $targets | ForEach-Object {
            Remove-StoredCredential `
                -Target $_
        }
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
