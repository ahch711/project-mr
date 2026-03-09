#!/bin/sh
# mode3_watchdog.sh
# Keeps WiFi WAN alive in MODE3
# If WiFi drops: retry, then fallback to USB WAN
# Checks every 30 seconds - light on CPU and data

INTERVAL=30

while true
do
    sleep $INTERVAL

    # Only run if still in MODE3
    MODE=$(cat /tmp/current_mode 2>/dev/null)
    [ "$MODE" = "MODE3" ] || exit 0

    # Check connectivity
    if ifstatus wan_wifi | grep -q '"address"'; then
        continue
    fi

    logger "MODE3 WATCHDOG: WiFi lost, retrying..."

    # Attempt reconnect
    ifdown wan_wifi 2>/dev/null
    wifi down >/dev/null 2>&1
    sleep 3
    wifi up >/dev/null 2>&1
    sleep 10
    ifup wan_wifi
    sleep 10

    if ifstatus wan_wifi | grep -q '"address"'; then
        logger "MODE3 WATCHDOG: WiFi restored"
        ifdown wan_usb 2>/dev/null
    else
        logger "MODE3 WATCHDOG: WiFi still down, falling back to USB WAN"
        ifup wan_usb
    fi

done
