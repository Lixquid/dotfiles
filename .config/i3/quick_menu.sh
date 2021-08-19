#!/bin/sh

OPT=$(dmenu -l 5 -p "Quick Menu" <<EOF
Restart Mullvad Daemon
Open Non-Mullvad Window
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
esac
