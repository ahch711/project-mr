#!/bin/sh
# MODE2 - Ethernet WAN (eth0) - Hotel/Lab/NBN
# SSH: WiFi only (wlan0-1 AP stays live)
# LAN: WiFi AP only - eth0 dedicated to WAN
# v2.0 Mar 2026

CONFIG="/root/GPIO-Predefined"

# Safe config parser
getcfg() {
    awk -F= -v sec="[$1]" -v key="$2" '
        $0==sec{f=1;next}
        /^\[/{f=0}
        f && /^#/{next}
        f && $1==key{print $2; exit}
    ' "$CONFIG"
}

echo MODE2 > /tmp/current_mode 
logger "MODE2: Activating RJ45 WAN"

# SSH Security: Flush old rules and block LAN SSH (since RJ45 is WAN)
iptables -D INPUT -i br-lan -p tcp --dport 22 -j DROP 2>/dev/null    
iptables -D INPUT -i br-wifi_iso -p tcp --dport 22 -j DROP 2>/dev/null
iptables -I INPUT -i br-lan -p tcp --dport 22 -j DROP                 
logger "MODE2: SSH restricted to WiFi (LAN Blocked)"  


# Read GPIO2 predefined config
PROTO=$(getcfg GPIO2 PROTO)
IP=$(getcfg GPIO2 IP)
NETMASK=$(getcfg GPIO2 NETMASK)
GATEWAY=$(getcfg GPIO2 GATEWAY)
DNS=$(getcfg GPIO2 DNS)

# Stop other WANs
ifdown wan_usb 2>/dev/null
ifdown wan_wifi 2>/dev/null

# Disable WiFi client (external_wwan)
uci set wireless.external_wwan.disabled='1'
uci commit wireless
wifi reload >/dev/null 2>&1
sleep 2

# KEY STEP: Remove eth0 from LAN bridge
# Dedicates eth0 exclusively to WAN
# LAN clients use WiFi AP (wlan0-1) only from this point
brctl delif br-lan eth0 2>/dev/null
logger "MODE2: eth0 removed from br-lan, dedicated to WAN"

# Apply static or DHCP to wan_eth
if [ "$PROTO" = "static" ] && [ -n "$IP" ]; then
    logger "MODE2: Applying static IP $IP"
    uci set network.wan_eth.proto='static'
    uci set network.wan_eth.ipaddr="$IP"
    uci set network.wan_eth.netmask="$NETMASK"
    uci set network.wan_eth.gateway="$GATEWAY"
    uci set network.wan_eth.dns="$DNS"
else
    logger "MODE2: Using DHCP on wan_eth"
    uci set network.wan_eth.proto='dhcp'
fi
uci commit network

# Bring up Ethernet WAN
ifup wan_eth
sleep 3

# Confirm WAN up
if ifstatus wan_eth | grep -q '"up": true'; then
    logger "MODE2: wan_eth up"
else
    logger "MODE2: wan_eth not up yet, continuing..."
fi

logger "MODE2 applied"

