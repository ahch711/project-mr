#!/bin/sh
# v2.0 Mar 2026

LED="/sys/class/leds/tp-link:green:wps/brightness"
MODE_FILE="/tmp/current_mode"

# these line stop system from controlling the wps LED
echo none > /sys/class/leds/tp-link:green:wps/trigger
echo timer > /sys/class/leds/tp-link:green:wps/trigger

# safety
[ -e "$LED" ] || exit 0

while true
do  
    sleep 1
    # only run with LED_Ctrl right
    [ -f /tmp/daemon_LED_Ctrl ] || continue

    MODE=$(cat "$MODE_FILE" 2>/dev/null)

    # Emergency mode blinking (fast continuous)
    if [ -f /tmp/emergency_active ]; then
        echo 300 > /sys/class/leds/tp-link:green:wps/delay_on                        
        echo 100 > /sys/class/leds/tp-link:green:wps/delay_off 
        sleep 0.3
        continue
    fi

    case "$MODE" in
        MODE1) BLINKS=1 ;;
        MODE2) BLINKS=2 ;;
        MODE3) BLINKS=3 ;;
        *) BLINKS=0 ;;
    esac

    i=0
    while [ $i -lt $BLINKS ]
    do 
        i=$((i+1))
        [ -f /tmp/daemon_LED_Ctrl ] || continue
        # pattern (Quick double flash)
        echo 100 > /sys/class/leds/tp-link:green:wps/delay_on
        echo 150 > /sys/class/leds/tp-link:green:wps/delay_off
        sleep 0.3;
    done

    [ -f /tmp/daemon_LED_Ctrl ] || continue
    echo 500 > /sys/class/leds/tp-link:green:wps/delay_on
    echo 1500 > /sys/class/leds/tp-link:green:wps/delay_off

    logger "---- Daemon LED Exec ----"
done

