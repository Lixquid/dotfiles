#!/usr/bin/env python3

################################### Imports ####################################

import sys
import subprocess

################################### Utility ####################################

def call( *args ):
    return subprocess.run( args,
        stdout = subprocess.PIPE,
        shell = True
    ).stdout.decode( "ascii" ).split( '\n', 1 )[0]

def color_int( r1, g1, b1, r2, g2, b2, x ):
    return color_str(
        r1 + ( r2 - r1 ) * x,
        g1 + ( g2 - g1 ) * x,
        b1 + ( b2 - b1 ) * x
    )

def color_str( r, g, b ):
    r = int( r )
    g = int( g )
    b = int( b )
    return '#' + hex( r )[2:] + hex( g )[2:] + hex( b )[2:]

def get_volume():
    return call( """
        amixer -D pulse get Master |
        grep -o '\[[0-9]*%\]' |
        sed 's/\[\([0-9]*\)%\]/\\1/'
    """ )

def get_muted():
    return call( """
        amixer -D pulse get Master |
        grep -o '\[off\]'
    """ ) == '[off]'

# Battery 0: Charging, 92%, 00:17:11 until charged
# Battery 0: Full, 100%
# Battery 0: Discharging, 96%, 05:23:04 remaining
# Battery 0: Unknown, 96%, rate information unavailable
def get_battery():
    out = call( "acpi -b" )
    val = int( call( """
        acpi -b |
        sed 's/.*, \([0-9]*\)%.*/\\1/'
    """ ) )

    return {
        'full': "Full" in out,
        'charging': "Charging" in out,
        'discharging': "Discharging" in out,
        'val': val
    }

################################## Endpoints ###################################

VOL_MUTED = ''
VOL_LOW = ''
VOL_HIGH = ''
def e_get_volume():
    if get_muted():
        print( "  %s  Muted " % VOL_MUTED )
        print()
        print( "#fca49d" )
    else:
        vol = int( get_volume() )
        if vol < 40:
            print( "  %s  %s " % ( VOL_LOW, vol ) )
        else:
            print( "  %s  %s " % ( VOL_HIGH, vol ) )

BATTERY_0=''
BATTERY_1=''
BATTERY_2=''
BATTERY_3=''
BATTERY_4=''
BATTERY_C=''
def e_get_battery():
    out = get_battery()

    if out["full"]:
        print( "  %s  Full " % BATTERY_4 )
        print()
        print( "#B1D28F" )
    else:

        val = out["val"]

        s = BATTERY_4
        if val < 20:
            s = BATTERY_0
        elif val < 40:
            s = BATTERY_1
        elif val < 60:
            s = BATTERY_2
        elif val < 80:
            s = BATTERY_3

        print( "  %s  %s%% " % ( s, val ) )

        print()

        if out["charging"]:
            print( "#99DCC6" )
        elif val < 15:
            print( color_str( 235, 60, 50 ) )
        elif val < 30:
            print( color_int(
                238, 230, 127,
                235, 60, 50,
                ( 30 - val ) / 15
            ) )
        elif val < 50:
            print( color_int(
                238, 238, 238,
                238, 230, 127,
                ( 50 - val ) / 20
            ) )
        else:
            print( color_str( 238, 238, 238 ) )

################################# Main Switch ##################################

if __name__ == '__main__':
    # try:
        command = sys.argv[1]

        if command == 'get_volume':
            e_get_volume()
        elif command == 'get_battery':
            e_get_battery()
        else:
            pass
    # except:
        # pass
