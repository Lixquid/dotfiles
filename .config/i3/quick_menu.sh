#!/bin/sh

OPT=$(dmenu -l 5 -p "Quick Menu" <<EOF
Restart Mullvad Daemon
EOF
)

case "$OPT" in
    "Restart Mullvad Daemon")
        xfce4-terminal --command='systemctl restart mullvad-daemon'
        ;;
esac
