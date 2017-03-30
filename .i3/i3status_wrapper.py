#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import subprocess

## Tooling ##

def generate( j ):
	# Separators
	j.insert( 3, { "name": "separator", "full_text": "        " } )
	j.insert( 6, { "name": "separator", "full_text": "        " } )
	j.insert( 9, { "name": "separator", "full_text": "        " } )

	# Brightness
	brightness = 'ERR'
	try:
		brightness = round( float( subprocess.Popen( "xbacklight", shell = True, stdout = subprocess.PIPE ).stdout.read().strip() ) )
	except Exception:
		pass
	j.insert( 8, { "name": "brightness", "full_text": "🔆 %s" % brightness } )

	# Volume

	# t = "🔈 ERR"
	#
	# try:
	# 	muted = subprocess.Popen( "pactl list sinks | grep 'Mute:' | head -n 1", shell = True, stdout = subprocess.PIPE ).stdout.read().strip()
	# 	if muted == "Mute: yes":
	# 		t = "🔇 MUT"
	# 	else:
	# 		vol = round( float( subprocess.Popen( "pactl list sinks | grep 'Volume:' | head -n 1 | awk '{ print $5 }' | tr -d '%'", shell = True, stdout = subprocess.PIPE ).stdout.read().strip() ) )
	#
	# 		if vol < 11:
	# 			t = "🔈 %s%%" % vol
	# 		elif vol < 31:
	# 			t = "🔉 %s%%" % vol
	# 		else:
	# 			t = "🔊 %s%%" % vol
	# except Exception:
	# 	pass
	# j.insert( 9, { "name": "volume", "full_text": t } )


## Boilerplate ##

def print_unbuf( msg ):
	""" Non-buffered stdout printing. """
	sys.stdout.write( msg + '\n' )
	sys.stdout.flush()

def read_line():
	""" Interruptable stdin reader. """
	try:
		line = sys.stdin.readline().strip()
		if not line:
			sys.exit()
		return line
	except KeyboardInterrupt:
		sys.exit()

if __name__ == "__main__":
	# Version header
	print_unbuf( read_line() )
	# Start of array
	print_unbuf( read_line() )

	while True:
		line, prefix = read_line(), ""
		if line.startswith(','):
			line, prefix = line[1:], ','

		j = json.loads( line )
		generate( j )

		print_unbuf( prefix + json.dumps( j ) )
