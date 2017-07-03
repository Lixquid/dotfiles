#!/bin/bash

if [[ -d ~/Pictures/Backgrounds ]]; then
	files=(~/Pictures/Backgrounds/*)
	feh --bg-center "${files[RANDOM % ${#files[@]}]}"
else
	feh --bg-fill ~/.i3/bg.png
fi
