# HelpScript

```
$uninstalls = @()
$uninstalls += "DevHome"
$uninstalls += "GetHelp"
$uninstalls += "YourPhone"

function RemoveSoftware($name, $displayName=$name) {
    $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Inquire
    $t = Get-AppxPackage *$name*
    $nonRemovable =  $t|Where-Object{$_.NonRemovable -eq $True}
    $t =  $t|Where-Object{$_.NonRemovable -eq $False}
    $r = 0
    $n = $t.length
    if ($nonRemovable.length -gt 0) {
        $nr_name = ($nonRemovable.Name -join ', ')
        log "[NoRM] - Packages $nr_name cannot be removed."
        if ($n -eq 0 ) {
            return ($nonRemovable.length * -1)
        }
    }
    if ( $n -eq 1 ) { 
        $pkg = $t.name
        log "[one ] - Package $pkg installed."
        $r = $wshell.Popup("Uninstall $displayName : $pkg ?", 0, "Remove 1 Package", 32 + 4)
    } elseif ($n -gt 1) {        
        log "[many] - $n package for *$name*."
        $list = ($t.name -join ", ")
        $r = $wshell.Popup("Uninstall $displayName ($n): $list ?", 0, "Remove $n Package", 32 + 4)
    } else {
        log "[none] - Package $name not installed."
        return
    }

    if (($r -eq 6)) {
        $t | Remove-AppxPackage
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

foreach ($appx in $uninstalls) {
    RemoveSoftware $appx
}
```
