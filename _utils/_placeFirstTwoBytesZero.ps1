$file = "./trt_2_3_2.txt"
$fileBytes = Get-Content -Path $file -Encoding Byte -ReadCount 0
$firstTwoBytes = $fileBytes[0..1]
Write-Host "First two bytes ascii of the file:"
foreach ($byte in $firstTwoBytes) {
    Write-Host "0x$($byte.ToString('X2'))"
}

$replace = @(0x00, 0x00)
$stream = [System.IO.File]::Open(
    $file,
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::ReadWrite)
$stream.Position = 0
$stream.Write($replace, 0, $replace.Length)
$stream.Flush()
$stream.Close()
