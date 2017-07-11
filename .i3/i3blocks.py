#!/usr/bin/env python3

################################### Imports ####################################

import os
import sys
import subprocess
import time

################################# Environment ##################################

BLOCK_NAME = os.environ[ "BLOCK_NAME" ] \
    if "BLOCK_NAME" in os.environ \
    else "MISSING_BLOCK_NAME"
BLOCK_INSTANCE = os.environ[ "BLOCK_INSTANCE" ] \
    if "BLOCK_INSTANCE" in os.environ \
    else ""
BLOCK_BUTTON = os.environ[ "BLOCK_BUTTON" ] \
    if "BLOCK_BUTTON" in os.environ \
    else "0"

CLICK = BLOCK_BUTTON and ( BLOCK_BUTTON in ( "1", "2", "3" ) )
CLICK_LEFT = BLOCK_BUTTON == "1"
CLICK_MIDDLE = BLOCK_BUTTON == "2"
CLICK_RIGHT = BLOCK_BUTTON == "3"
SCROLL_UP = BLOCK_BUTTON == "4"
SCROLL_DOWN = BLOCK_BUTTON == "5"

################################### Utility ####################################

def call( *args ):
    return subprocess.run( args,
        stdout = subprocess.PIPE,
        shell = True
    ).stdout.decode( "ascii" ).split( '\n', 1 )[0]

def call_multi( *args ):
    return subprocess.run( args,
        stdout = subprocess.PIPE,
        shell = True
    ).stdout.decode( "utf8" )

def color_str( color_or_r, g = None, b = None ):
    if g is None:
        r = int( color_or_r[0] )
        g = int( color_or_r[1] )
        b = int( color_or_r[2] )
    else:
        r = int( color_or_r )
        g = int( g )
        b = int( b )
    return '#%02X%02X%02X' % ( r, g, b )

def color_lerp( c_from, c_to, amt ):
    return color_str(
        c_from[0] + ( c_to[0] - c_from[0] ) * amt,
        c_from[1] + ( c_to[1] - c_from[1] ) * amt,
        c_from[2] + ( c_to[2] - c_from[2] ) * amt
    )

def color_fade( x, steps ):
    for i, s in enumerate( steps ):
        # Above highest step
        if x >= s[0] and i + 1 == len( steps ):
            return color_str( s[1] )
        if x < s[0]:
            if i == 0:
                # Less than first step
                return color_str( s[1] )
            else:
                si = steps[i-1]
                return color_lerp(
                    si[1], s[1],
                    ( x - si[0] ) / ( s[0] - si[0] )
                )

def print_output( icon, text = None, color = None, crit = False ):
    if text:
        t = "  %s  %s " % ( icon, text )
    else:
        t = "  %s  " % icon
    print( t )
    print( t )
    if color:
        if type( color ) is str:
            print( color )
        else:
            print( color_str( color ) )

    if crit:
        sys.exit( 33 )
    else:
        sys.exit( 0 )

def ticker_string( text, width = 30, speed = 2 ):

    lentxt = len( text )
    sample = text + "   ///   " + text

    if lentxt <= width:
        return text

    offset = int( time.time() * speed ) % ( lentxt + 9 )

    return sample[offset:(offset+width)]

block_mapping = {}
def block_name( name ):
    def block_decorator( fn ):
        block_mapping[ name ] = fn
        return fn
    return block_decorator

################################### Colours ####################################

C_LIGHTRED = ( 252, 164, 157 )
C_LIGHTGREEN = ( 177, 210, 143 )

C_WHITE = ( 238, 238, 238 )
C_YELLOW = ( 238, 230, 127 )
C_RED = ( 235, 60, 50 )

#################################### Volume ####################################

VOL_MUTED = "\uF026"
VOL_LOW = "\uF027"
VOL_HIGH = "\uF028"

@block_name( "volume" )
def get_volume():

    if CLICK_LEFT:
        call( "pactl set-sink-mute 0 toggle" )
    elif SCROLL_UP:
        call( "pactl set-sink-mute 0 0; pactl set-sink-volume 0 +5%" )
    elif SCROLL_DOWN:
        call( "pactl set-sink-mute 0 0; pactl set-sink-volume 0 -5%" )

    muted = call( """
        amixer -D pulse get Master | grep -o '\[off\]'
    """ ) == "[off]"

    if muted:
        print_output( VOL_MUTED, "Muted", C_LIGHTRED )
    else:
        vol = int( call( """
            amixer -D pulse get Master |
            grep -o '\[[0-9]*%\]' |
            sed 's/\[\([0-9]*\)%\]/\\1/'
        """ ) )

        if vol < 40:
            print_output( VOL_LOW, vol )
        else:
            print_output( VOL_HIGH, vol )

################################### Locking ####################################

LOCK = "\uF023"
UNLOCK = "\uF09C"

@block_name( "lock" )
def get_lock():

    locking = call_multi(
        "ps -aux | grep 'gnome-screensaver'"
    ).count( '\n' ) > 2

    if CLICK:
        if locking:
            call( "killall gnome-screensaver" )
        else:
            call( "gnome-screensaver-command -l" )
        locking = not locking

    print_output( LOCK if locking else UNLOCK )

################################### Battery ####################################

BAT_0 = "\uF244"
BAT_1 = "\uF243"
BAT_2 = "\uF242"
BAT_3 = "\uF241"
BAT_4 = "\uF240"
BAT_CHARGING = "\uF0E7"

@block_name( "battery" )
def get_battery():

    if CLICK:
        call( """
            notify-send "$( acpi -b )"
        """ )

    status = call( "acpi -b" )

    if "Full" in status:
        print_output( BAT_4 + " " + BAT_CHARGING, "Full", C_LIGHTGREEN )
    else:
        value = int( call( """
            acpi -b |
            sed 's/.*, \([0-9]*\)%.*/\\1/'
        """ ) )

        if value < 20:
            icon = BAT_0
        elif value < 40:
            icon = BAT_1
        elif value < 60:
            icon = BAT_2
        elif value < 80:
            icon = BAT_3
        else:
            icon = BAT_4

        if "Charging" in status:
            icon += " " + BAT_CHARGING
            color = C_LIGHTGREEN
        else:
            color = color_fade( value, [
                ( 15, C_RED ),
                ( 30, C_YELLOW ),
                ( 50, C_WHITE )
            ] )

        text = str( value ) + "%"

        print_output( icon, text, color, value <= 10 )

################################### Wireless ###################################

WIFI_ICON = "\uF1EB"

@block_name( "wireless" )
def get_wireless():

    if not "wlp" in call_multi( "ifconfig -s" ):
        sys.exit( 0 )
        return

    name = call( "iwgetid -r" )

    if len( name ) == 0:
        print_output( WIFI_ICON, None, C_RED )
        sys.exit( 0 )
        return

    id = call( "iwgetid -a | cut -f 1 -d ' '" )
    strength = round( int( float(
        call( "grep '%s' /proc/net/wireless" % id ).split()[2]
    ) ) * 100 / 70 )

    color = color_fade( strength, [
        ( 35, C_RED ),
        ( 50, C_YELLOW ),
        ( 65, C_WHITE )
    ] )

    text = "%s (%s%%)" % ( name, strength )

    print_output( WIFI_ICON, ticker_string( text ), color )

##################################### CPU ######################################

CPU_ICON = "\uF2DB"

@block_name( "cpu" )
def get_cpu():

    cpu = 100 - round( float(
        call( "mpstat 1 1 | grep Average" ).split()[11]
    ) )

    color = color_fade( cpu, [
        ( 35, C_WHITE ),
        ( 50, C_YELLOW ),
        ( 80, C_RED )
    ] )

    print_output( CPU_ICON, str( cpu ) + "%", color, cpu > 80 )

################################# Temperature ##################################

TEMP_0 = "\uF2CB"
TEMP_1 = "\uF2CA"
TEMP_2 = "\uF2C9"
TEMP_3 = "\uF2C8"
TEMP_4 = "\uF2C7"

@block_name( "temperature" )
def get_temp():

    temp = round( float( call(
        "cat /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input"
    ) ) / 1000 )

    if temp < 40:
        icon = TEMP_0
    elif temp < 60:
        icon = TEMP_1
    elif temp < 75:
        icon = TEMP_2
    elif temp < 90:
        icon = TEMP_3
    else:
        icon = TEMP_4

    color = color_fade( temp, [
        ( 75, C_WHITE ),
        ( 100, C_RED )
    ] )

    print_output( icon, str( temp ) + "\u00B0C", color, temp >= 90 )

################################## Brightness ##################################

BRIGHTNESS_ICON = "\uF185"

@block_name( "brightness" )
def get_brightness():

    if SCROLL_UP:
        call( "xbacklight -inc 5 -time 5" )
    elif SCROLL_DOWN:
        call( "xbacklight -dec 5 -time 5" )

    value = round( float( call( "xbacklight -get" ) ) )
    print_output( BRIGHTNESS_ICON, str( value ) + "%" )

##################################### Time #####################################

TIME_ICON = "\uF017"

@block_name( "time" )
def get_time():

    if CLICK:
        call( """
            notify-send "$( date -R )"
        """ )
    if CLICK_RIGHT:
        call( """
            notify-send "$( cal -h )"
        """ )

    value = call( "date +'%H:%M'" )
    print_output( TIME_ICON, value )

#################################### Audio #####################################

AUDIO_ICON = "\uF04B"
AUDIO_PAUSED_ICON = "\uf04c"

@block_name( "audio" )
def get_audio():

    raw = call_multi( "$HOME/.i3/scripts/audio_control.sh GetRaw" )

    titleLine = None
    artistLine = None
    titleOut = None
    artistOut = None

    for i, line in enumerate( raw.split( "\n" ) ):
        if "xesam:title" in line:
            titleLine = i + 1
        if "xesam:artist" in line:
            artistLine = i + 2
        if titleLine == i:
            titleOut = '"'.join( line.split('"')[1:-1] )
        if artistLine == i:
            artistOut = '"'.join( line.split('"')[1:-1] )

    icon = AUDIO_ICON
    if "Paused" in call( "$HOME/.i3/scripts/audio_control.sh GetPaused" ):
        icon = AUDIO_PAUSED_ICON

    if titleOut and artistOut:
        print_output( icon,
            ticker_string( titleOut + " -by- " + artistOut, 60 ) )

################################## Endpoints ###################################

if __name__ == "__main__":

    if BLOCK_NAME in block_mapping:
        block_mapping[ BLOCK_NAME ]()
    else:
        print_output( "Block %s not found!" % BLOCK_NAME, color = C_RED )
