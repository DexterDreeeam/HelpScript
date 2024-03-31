Set-StrictMode -Version 2

####################
#
# Adjust for Best Performance setting (in Performance > Visual Effects)
# Note that this requires that the "Themes" service is restarted
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/73d72328-38ed-4abe-a65d-83aaad0f9047/adjust-for-best-performance?forum=winserverpowershell
#
####################

$out = @'
Windows Registry Editor Version 5.00

; ###
; Visual Effects
; ###

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
"VisualFXSetting"=dword:00000002

; Do not Animate windows when minimizing and maximizing
[HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics]
"MinAnimate"="0"

; Disable Animations in Taskbar and Start Menu
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAnimations"=0
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAnimations"=-

; Disable desktop composition
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"CompositionPolicy"=0

; Enable transparent glass
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"ColorizationOpaqueBlend"=0

; Disable Taskbar Thumbnail Previews
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"AlwaysHibernateThumbnails"=dword:00000000

; Disable Explorer Thumbnails (All Users)
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"DisableThumbnails"=dword:00000001

; Disable translucent selection rectangle
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ListviewAlphaSelect"=0

; Dont show window contents while dragging
[HKEY_CURRENT_USER\Control Panel\Desktop]
"DragFullWindows"=0

; Dont smooth Edges of Screen Fonts
[HKEY_CURRENT_USER\Control Panel\Desktop]
"FontSmoothing"="0"

; Use drop shadows for icon labels on the desktop
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ListviewShadow"=0

; Disable visual styles on windows and buttons
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ThemeManager]
"ThemeActive"="0"
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager]
"ThemeActive"=-

; Disable following:
; * Animate controls and elements inside windows
; * Smooth-scroll list boxes
; * Slide open combo boxes
; * Fade or slide menus into view
; * Show shadows under mouse pointer
; * Fade or slide ToolTips into view
; * Fade out menu items after clicking
; * Show shadows under windows
; * Use Visual styles on windows and buttons
[HKEY_CURRENT_USER\Control Panel\Desktop]
"UserPreferencesMask"=hex:90,12,01,80,10,00,00,00
'@

function MainEntry {
    $out | Out-File -FilePath "$Env:TEMP\AdjustForBestPerformanceVisual.reg" -Force -Encoding oem
    Invoke-Command { reg import "$Env:TEMP\AdjustForBestPerformanceVisual.reg" *>&1 | Out-Null }
    # Must restart the Themes service
    Restart-Service Themes -Force
}

try {
    MainEntry
}
catch {
    Write-Host "Exception:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Delete Self
$myPsPath = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "Remove-Item `"$myPsPath`" -Force"
