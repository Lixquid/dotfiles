#!/bin/bash

case $1 in
	Next|Previous|Play|Pause|PlayPause)
		;;
	GetRaw|GetPaused)
		;;
	*)
		echo "Invalid argument $1. Available:"
		echo "Next, Prevous, Play, Pause, PlayPause"
		echo "GetRaw"
		exit 1
esac

if pidof spotify >/dev/null; then
	if test "$1" = GetRaw; then
		dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
			"/org/mpris/MediaPlayer2" "org.freedesktop.DBus.Properties.Get" \
			"string:org.mpris.MediaPlayer2.Player" "string:Metadata"
		exit
	elif test "$1" = GetPaused; then
		dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
			"/org/mpris/MediaPlayer2" "org.freedesktop.DBus.Properties.Get" \
			"string:org.mpris.MediaPlayer2.Player" "string:PlaybackStatus" |
			grep -o Paused
		exit
	fi

	dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
		/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.$1 >/dev/null
else
	echo die
fi
