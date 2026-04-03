#!/bin/sh
# V1.0 hotspot_swap.sh
# Swaps active hotspot set in GPIO-Predefined and reconnects Mode3
# Called by WPS button 3-7sec hold
# Sets file: /root/hotspot_sets

SETS_FILE="/root/hotspot_sets"
CONFIG="/root/GPIO-Predefined"

# Safe parser - same as getcfg in mode3.sh
getcfg() {
    awk -F= -v sec="[$1]" -v key="$2" '
        $0==sec{f=1;next}
        /^\[/{f=0}
        f && /^#/{next}
        f && $1==key{print $2; exit}
    ' "$3"
}

# Read current active set
#CURRENT=$(getcfg Active "$SETS_FILE" Current)
CURRENT=$(getcfg Active Current "$SETS_FILE")
logger "HOTSPOT SWAP: current=$CURRENT"

# Determine next set
if [ "$CURRENT" = "SET1" ]; then
    NEXT="SET2"
else
    NEXT="SET1"
fi

# Read new SSID+KEY from sets file
#NEW_SSID=$(getcfg "$NEXT" "$SETS_FILE" SSID)                        
#NEW_KEY=$(getcfg "$NEXT" "$SETS_FILE" KEY) 
NEW_SSID=$(getcfg "$NEXT" SSID "$SETS_FILE")
NEW_KEY=$(getcfg "$NEXT" KEY "$SETS_FILE")

if [ -z "$NEW_SSID" ]; then
    logger "HOTSPOT SWAP: ERROR - no SSID found for $NEXT, aborting"
    exit 1
fi

logger "HOTSPOT SWAP: switching to $NEXT SSID=$NEW_SSID"

# Update Active section in hotspot_sets file
sed -i "s/^Current=.*/Current=$NEXT/" "$SETS_FILE"

# Update GPIO-Predefined [GPIO3] section
sed -i "/^\[GPIO3\]/,/^\[/ s/^SSID=.*/SSID=$NEW_SSID/" "$CONFIG"
sed -i "/^\[GPIO3\]/,/^\[/ s/^KEY=.*/KEY=$NEW_KEY/" "$CONFIG"

logger "HOTSPOT SWAP: GPIO-Predefined updated"

# Trigger Mode3 reconnect, but ONLY run if still in MODE3
MODE=$(cat /tmp/current_mode 2>/dev/null)
[ "$MODE" = "MODE3" ] || exit 0
logger "HOTSPOT SWAP calling mode_manager MODE3"
/root/mode_manager.sh MODE3

