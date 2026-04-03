#!/bin/sh
# MODE3 - WiFi WAN (wlan client) - Travel/Hotspot
# SSH: LAN + int WiFi (both)
# Setup MODE3 env with ext WiFi WAN
# Starts watchdog to monitor ext WiFi WAN
# v2.0 Mar 2026

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

echo "MODE3 $(date +%s)" > /tmp/mode3_running   #declaring mode3_running
echo MODE3 > /tmp/current_mode                                          
logger "MODE3: Preparing WiFi WAN env" 

# SSH Security: Flush all blocks to allow both doors open
iptables -D INPUT -i br-lan -p tcp --dport 22 -j DROP 2>/dev/null
iptables -D INPUT -i br-wifi_iso -p tcp --dport 22 -j DROP 2>/dev/null
logger "MODE3: SSH allowed on LAN + WiFi"

# Disable Ethernet WAN and restore eth0 to br-lan = clear mode2
ifdown wan_eth 2>/dev/null
brctl addif br-lan eth0 2>/dev/null

# Read GPIO3 predefined config
SSID=$(getcfg GPIO3 SSID)
KEY=$(getcfg GPIO3 KEY)
PROTO=$(getcfg GPIO3 PROTO)
IP=$(getcfg GPIO3 IP)
NETMASK=$(getcfg GPIO3 NETMASK)
GATEWAY=$(getcfg GPIO3 GATEWAY)
DNS=$(getcfg GPIO3 DNS)

# Apply SSID + key if predefined
if [ -n "$SSID" ]; then
    logger "MODE3: Applying predefined SSID: $SSID"
    uci set wireless.external_wwan.ssid="$SSID"
    uci set wireless.external_wwan.key="$KEY"
else
    logger "MODE3: No SSID defined, USB WAN baseline + WiFi SSH"
    ifup wan_usb
    echo MODE3 > /tmp/current_mode
    rm -f /tmp/mode3_running   #remove mode3_running state 
    logger "MODE3 applied (no ext WiFi defined)"
    exit 0
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


rm -f /tmp/mode3_running   #remove mode3_running state
logger "MODE3 env applied"

# Start watchdog (+ prevent double watchdog) to maintain WiFi connection
if ! pgrep -f mode3_watchdog.sh > /dev/null 2>&1; then
    /root/mode3_watchdog.sh &
else
    logger "MODE3: watchdog already running, skip spawn"
fi

