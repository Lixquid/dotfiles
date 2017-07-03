#!/bin/bash

SEL=`dmenu -i -l 10 -p "Action: " <<DMENU
Log Off
Suspend
Restart
Hibernate
Power Off
DMENU`

case $SEL in
	"Log Off")
		i3-msg exit
		;;
	"Suspend / Sleep")
		systemctl suspend -i
		;;
	"Restart")
		systemctl reboot -i
		;;
	"Hibernate")
		systemctl hibernate -i
		;;
	"Power Off")
		systemctl poweroff -i
		;;
esac
