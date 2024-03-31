# query
# Get-AppxPackage -AllUsers | Select-Object -ExpandProperty Name

$uninstalls = @(
    "549981C3F5F10", # Cortana
    "BingNews",
    "BingWeather",
    "Clipchamp.Clipchamp",
    "CloudExperienceHost",
    "Copilot",
    "DevHome",
    "GetHelp",
    "MicrosoftOffice",
    "MicrosoftSolitaireCollection",
    "MicrosoftTeams",
    "Microsoft.People",
    "Microsoft.Todos",
    "OneDrive",
    "Outlook",
    "PowerAutomateDesktop",
    "QuickAssist",
    "ScreenSketch",
    "StickyNotes",
    "WindowsCamera",
    "windowscommunicationsapps",
    "WindowsFeedbackHub",
    "WindowsMaps",
    "YourPhone",
    "ZuneMusic",
    "ZuneVideo"
)

function log($msg = "") {
    Write-Output $msg;
}

function infoPopup($message, $timeout=1, $icon=64){
    $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Inquire
    return $wshell.Popup($message, $timeout, "Info", $icon + 0)
}

function RemoveSoftware($name, $displayName=$name) {
    $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Inquire
    $t = Get-AppxPackage -AllUsers *$name*
    $nonRemovable =  $t | Where-Object{$_.NonRemovable -eq $True}
    $t =  $t | Where-Object{$_.NonRemovable -eq $False}
    $r = 0
    $n = $t.length
    if ($nonRemovable.length -gt 0) {
        $nr_name = ($nonRemovable.Name -join ', ')
        log "[NoRM] - Packages $nr_name cannot be removed."
        if ($n -eq 0 ) {
            return ($nonRemovable.length * -1)
        }
    }
    if ($n -eq 1) { 
        $pkg = $t.name
        log "[one ] - Package $pkg installed."
        $r = $wshell.Popup("Uninstall $displayName : $pkg ?", 0, "Remove 1 Package", 32 + 4)
    }
    elseif ($n -gt 1) {        
        log "[many] - $n package for *$name*."
        $list = ($t.name -join ", ")
        $r = $wshell.Popup("Uninstall $displayName ($n): $list ?", 0, "Remove $n Package", 32 + 4)
    }
    else {
        log "[none] - Package $name not installed."
        return
    }

    if (($r -eq 6)) {
        $t | Remove-AppxPackage -AllUsers
        if ($? -eq $False) {
            log "[ERR ] Package $displayName not removed."
            $wshell.Popup("Impossible to remove $displayName.", 1, "Remove Software", 48)
            return 0
        }
        log "[DEL ] Package $displayName removed."
        infoPopup("$displayName Uninstalled.")
        return $n
    }
    log "[skip] Skipping $displayName..."
    return
}

function MainEntry {
    foreach ($appx in $uninstalls) {
        RemoveSoftware $appx
    }
    
    # Clean TaskBar - Teams Chat
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type "DWord" -Value 0
    # Clean TaskBar - Task View
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type "DWord" -Value 0
    # Clean TaskBar - Copilot
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type "DWord" -Value 0
    # Clean TaskBar - Widget
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type "DWord" -Value "0"
    # Clean TaskBar - Search Box
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type "DWord" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarModeCache" -Type "DWord" -Value 1
    
    winget install --id Microsoft.Powershell --source winget
    winget install Microsoft.PowerToys
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
