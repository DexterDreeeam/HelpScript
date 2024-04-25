Set-ExecutionPolicy RemoteSigned -Scope Process -Force

function MainEntry {
    winget install --accept-package-agreements "WinDbg Preview"
    winget install --accept-package-agreements "Windows Performance Analyzer"
    winget install --accept-package-agreements "Sysinternals Suite"
    winget install --accept-package-agreements "ILSpy Fresh"
    
    # Setup Symbol Environment
    md C:\Symbols
    md C:\Symbols\Src
    md C:\Symbols\Sym
    md C:\Symbols\SymCache
    echo PingMe > C:\Symbols\Sym\pingme.txt
    echo Index2 > C:\Symbols\Sym\index2.txt
    compact.exe /C /S:"C:\Symbols"
    setx /m DBGHELP_HOMEDIR C:\Symbols # symbol tree location
    setx /m _NT_SOURCE_PATH SRV*C:\Symbols\Src # source code download location
    setx /m _NT_SYMBOL_PATH SRV*C:\Symbols\Sym*http://idcsymproxy.fareast.corp.microsoft.com/symbols*http://symweb*http://msdl.microsoft.com/download/symbols # symbol file source
    setx /m _NT_SYMCACHE_PATH SRV*C:\Symbols\SymCache # WPA symbol cache location
    
    # Setup Dump register handler
    md C:\Dumps
    compact.exe /C /S:"C:\Dumps"
    procdump.exe -ma -i C:\Dumps
    # to unregister handler using:
    # procdump.exe -u
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
