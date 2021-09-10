#!/bin/sh

OPT=$(dmenu -i -l 5 -p "Quick Menu" <<EOF
Restart Mullvad Daemon
Open Non-Mullvad Window
Set Mullvad Relay Location
Disable Touchpad
Enable Touchpad
EOF
)

case "$OPT" in
    "Restart Mullvad Daemon")
        xfce4-terminal --command='systemctl restart mullvad-daemon'
        ;;
    "Open Non-Mullvad Window")
        mullvad disconnect
        mullvad always-require-vpn set off
        rm -rf /tmp/tempfirefoxprofile
        mkdir -p /tmp/tempfirefoxprofile
        firefox --private-window --profile /tmp/tempfirefoxprofile http://neverssl.com
        mullvad connect
        mullvad always-require-vpn set on
        ;;
    "Set Mullvad Relay Location")
        OPT=$(mullvad relay list | grep "^[A-z]" | dmenu -i -l 5 -p "Location")
        if [ -z "$OPT" ]; then exit; fi
        mullvad relay set location $(echo $OPT | sed "s/.*(\([a-z]*\)).*/\1/")
        ;;
    "Disable Touchpad")
        xinput disable 'DLL075B:01 06CB:76AD Touchpad'
        ;;
    "Enable Touchpad")
        xinput enable 'DLL075B:01 06CB:76AD Touchpad'
        ;;
esac
