#!/bin/bash

SEL=`dmenu -i -l 10 -p "Window Format: " <<DMENU
Youtube
Spotify
Quick Terminal
DMENU`

RESOLUTION=`xrandr --current | grep "*" | sed 's_\s*\(\w*\).*_\1_'`
# SWIDTH=`echo $RESOLUTION | sed 's_^\(\d*\).*_\1_'`
SWIDTH=`echo $RESOLUTION | sed 's_^\([0-9]*\).*_\1_'`
SHEIGHT=`echo $RESOLUTION | sed 's_^.*x\([0-9]*\).*_\1_'`

case $SEL in
	"Youtube")
		i3-msg "
			mark youtube;
			fullscreen disable;
			floating enable;
			resize set 600 400;
			sticky enable;
			move position
				$(( $SWIDTH - 20 - 600 ))
				$(( $SHEIGHT - 20 - 400 ));
		"
		;;
	"Spotify")
		# i3-msg "
			# mark spotify;
			# fullscreen disable;
			# floating enable;
			# resize set 200 410;
			# sticky enable;
			# move position
				# $(( $SWIDTH - 20 - 200 ))
				# $(( $SHEIGHT - 20 - 410 ));
		# "
		i3-msg "
			mark spotify;
			fullscreen disable;
			floating enable;
			resize set 735 90;
			sticky enable;
			move position
				$(( $SWIDTH - 20 - 735 ))
				$(( 24 + 20 ));
		"
		;;
	"Quick Terminal")
		i3-msg "
			mark qterminal;
			fullscreen disable;
			floating enable;
			resize set $SWIDTH $(( $SHEIGHT / 2 ));
			sticky enable;
			move scratchpad;
			[con_mark=\"qterminal\"] scratchpad show;
			[con_mark=\"qterminal\"] move position 0 0;
		"
		;;
esac
