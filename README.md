# HelpScript

```
RemoveSoftware "DevHome"
RemoveSoftware "GetHelp"
RemoveSoftware "YourPhone"

function RemoveSoftware($name, $displayName=$name){
    # Ask user if they wants to remove the application(s) matching a name if it is
    # installed and removable. $displayName is shown to the user. $name is used to
    # match the application(s) to remove.
    $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Inquire
    $t = Get-AppxPackage *$name*
    $nonRemovable =  $t|Where-Object{$_.NonRemovable -eq $True}
    $t =  $t|Where-Object{$_.NonRemovable -eq $False}
    $r = 0
    $n = $t.length
    if ($nonRemovable.length -gt 0){
        $nr_name = ($nonRemovable.Name -join ', ')
        log "[NoRM] - Packages $nr_name cannot be removed."
        if ($n -eq 0 ){
            return ($nonRemovable.length * -1)
        }
    }
    if ( $n -eq 1 ){ 
        ## PROMPT TO REMOVE ONE PACKAGE ##
        $pkg = $t.name
        log "[one ] - Package $pkg installed."
        $r = $wshell.Popup("Uninstall $displayName : $pkg ?", 0, "Remove 1 Package", 32 + 4)

    } elseif ($n -gt 1){        
        ## PROMPT TO REMOVE MANY PACKAGES ##
        log "[many] - $n package for *$name*."
        $list = ($t.name -join ", ")
        $r = $wshell.Popup("Uninstall $displayName ($n): $list ?", 0, "Remove $n Package", 32 + 4)
    } else {
        log "[none] - Package $name not installed."
        return
    }

    if (($r -eq 6)){
        # REMOVE PACKAGE IF USER ACCEPTED ##
        $t | Remove-AppxPackage
        if ($? -eq $False){
            # If an error happened during deinstallation warn user
            log "[ERR ] Package $displayName not removed."
            $wshell.Popup("Impossible to remove $displayName.", 1, "Remove Software", 48)
            return 0
        }
        log "[DEL ] Package $displayName removed."
        # $wshell.Popup("$displayName Uninstalled.", 1, "Remove Software", 64)
        infoPopup("$displayName Uninstalled.")
        return $n
    }
    log "[skip] Skipping $displayName..."
    return
}
```
