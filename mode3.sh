#!/bin/sh
# MODE3 - WiFi WAN (wlan client) - Travel/Hotspot
# SSH: LAN + WiFi (both)
# Falls back to USB WAN if WiFi fails
# Starts watchdog to reconnect if WiFi drops

CONFIG="/root/GPIO-Predefined"

# Safe config parser - handles commented blocks
getcfg() {
    awk -F= -v sec="[$1]" -v key="$2" '
        $0==sec{f=1;next}
        /^\[/{f=0}
        f && /^#/{next}
        f && $1==key{print $2; exit}
    ' "$CONFIG"
}

logger "MODE3: Activating WiFi WAN"

# Read GPIO3 predefined config
SSID=$(getcfg GPIO3 SSID)
KEY=$(getcfg GPIO3 KEY)
PROTO=$(getcfg GPIO3 PROTO)
IP=$(getcfg GPIO3 IP)
NETMASK=$(getcfg GPIO3 NETMASK)
GATEWAY=$(getcfg GPIO3 GATEWAY)
DNS=$(getcfg GPIO3 DNS)

# Disable Ethernet WAN
ifdown wan_eth 2>/dev/null

# Apply SSID + key if predefined
if [ -n "$SSID" ]; then
    logger "MODE3: Applying predefined SSID: $SSID"
    uci set wireless.external_wwan.ssid="$SSID"
    uci set wireless.external_wwan.key="$KEY"
else
    # If no SSID predefined, skip WiFi - behave like Mode1 + SSH via WiFi
    if [ -z "$SSID" ]; then
       logger "MODE3: No SSID defined, USB WAN baseline + WiFi SSH"
       ifup wan_usb
       echo MODE3 > /tmp/current_mode
       logger "MODE3 applied (no ext WiFi)"
       exit 0
    fi
fi

# Apply static or DHCP to wan_wifi
if [ "$PROTO" = "static" ] && [ -n "$IP" ]; then
    logger "MODE3: Applying static IP $IP"
    uci set network.wan_wifi.proto='static'
    uci set network.wan_wifi.ipaddr="$IP"
    uci set network.wan_wifi.netmask="$NETMASK"
    uci set network.wan_wifi.gateway="$GATEWAY"
    uci set network.wan_wifi.dns="$DNS"
else
    uci set network.wan_wifi.proto='dhcp'
fi
uci commit network

# Enable WiFi client
uci set wireless.external_wwan.disabled='0'
uci commit wireless
wifi reload >/dev/null 2>&1
sleep 5

# Try to connect - retry loop until success or give up after 3 attempts
ATTEMPTS=0
MAX=3
CONNECTED=0

while [ $ATTEMPTS -lt $MAX ]; do
    ifup wan_wifi
    sleep 10

    if ifstatus wan_wifi | grep -q '"address"'; then
        logger "MODE3: WiFi WAN connected"
        CONNECTED=1
        break
    fi

    ATTEMPTS=$((ATTEMPTS+1))
    logger "MODE3: WiFi attempt $ATTEMPTS failed, retrying..."
    wifi down >/dev/null 2>&1
    sleep 3
    wifi up >/dev/null 2>&1
    sleep 5
done

if [ "$CONNECTED" = "0" ]; then
    logger "MODE3: WiFi failed after $MAX attempts, fallback to USB WAN"
    uci set wireless.external_wwan.disabled='1'
    uci commit wireless
    wifi reload >/dev/null 2>&1
    ifup wan_usb
else
    # Disable USB WAN - WiFi is primary
    ifdown wan_usb 2>/dev/null
fi

# SSH: LAN + WiFi (both) - delete Interface restriction
uci delete dropbear.@dropbear[0].Interface 2>/dev/null
uci commit dropbear
/etc/init.d/dropbear restart >/dev/null 2>&1

echo MODE3 > /tmp/current_mode
logger "MODE3 applied"

# Start watchdog to maintain WiFi connection
/root/mode3_watchdog.sh &
