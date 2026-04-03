#!/bin/sh
# MODE1 - USB WAN (eth1) - Daily 4G driver
# SSH: LAN only
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

echo MODE1 > /tmp/current_mode             
logger "MODE1: Activating USB WAN"

# SSH Security: Flush old rules and block WiFi SSH by default
iptables -D INPUT -i br-wifi_iso -p tcp --dport 22 -j DROP 2>/dev/null
iptables -I INPUT -i br-wifi_iso -p tcp --dport 22 -j DROP   
logger "MODE1: SSH restricted to LAN (WiFi Blocked)"  


# Stop Ethernet WAN and restore eth0 to br-lan = clear mode2       
ifdown wan_eth 2>/dev/null                               
brctl addif br-lan eth0 2>/dev/null

# Stop ext WiFi WAN 
ifdown wan_wifi 2>/dev/null
# Disable ext WiFi WAN
uci set wireless.external_wwan.disabled='1'
uci commit wireless
wifi reload >/dev/null 2>&1
sleep 2

# Bring up USB WAN
ifup wan_usb

logger "MODE1 Applied"
