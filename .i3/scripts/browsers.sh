#!/bin/bash

SEL=`dmenu -l 10 -p "Browser: " <<DMENU
c: Chromium
C: Chromium (Private)
f: Firefox
F: Firefox (Private)

s: Spotify
S: Steam Chat
m: Facebook Messenger
d: Discord Chat
g: Google Account
DMENU`

case $SEL in
	"c: Chromium")
		chromium-browser --profile-directory=Default;;
	"C: Chromium (Private)")
		chromium-browser --profile-directory=Default --incognito;;
	"f: Firefox")
		firefox;;
	"F: Firefox (Private)")
		firefox --private;;
	"s: Spotify")
		google-chrome-stable "https://open.spotify.com/collection/playlists" &
		spotify
		;;
	"S: Steam Chat")
		chromium-browser --profile-directory="Profile 1" "https://steamcommunity.com/chat";;
	"m: Facebook Messenger")
		chromium-browser --profile-directory="Profile 2" "https://messenger.com";;
	"d: Discord Chat")
		chromium-browser --profile-directory="Profile 3" "https://discordapp.com/channels/@me";;
	"g: Google Account")
		chromium-browser --profile-directory="Profile 4" "https://mail.google.com";;
esac
