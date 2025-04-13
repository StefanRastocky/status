#!/bin/sh

xsetroot -name "" #initialise the var where dwm reads for bar with null

vpn_status() {
    # DISABLED TO SAVE BATTERY 
    # Detect if a VPN interface is active (wg0, tun0, etc.)
    #vpn_interface=$(ip link | grep -E 'wg[0-9]*|tun[0-9]*' | awk '{print $2}' | tr -d :)

    # Fetch public IP
    # disabled to save time and power
    #public_ip=$(curl -s ifconfig.me)

    # Fetch city and country code using ipinfo.io
    #location=$(curl -s "https://ipinfo.io/$public_ip" | jq -r '.city, .country' | paste -sd ",")
    # Fetch location & IP data using mullvad status
    
    # USING MULLVAD NATIVE FUNCTIONS TO SAVE POWER AND CLOCK CYCLES
    mullvad_status=$(mullvad status)
    grep -q "Connected" <<< "$mullvad_status" && location="🔒Sec:$(grep -oP '(?<=location: ).*?(?=\. IPv4|\. IPv6|$)' <<< "$mullvad_status" | sed 's/ //g')" || location="❌Unsec:noVPN."
    
    echo "$location" > /tmp/vpn_status.tmp 

    # Check if VPN interface is found and update vpn status file
    #[ -n "$vpn_interface" ] && echo "🔒Sec:$location" > /tmp/vpn_status.tmp || echo "❌Unsec:$location-$public_ip" > /tmp/vpn_status.tmp


}

bat_status() {
    output=""
    # cycle through all batteries present on the system - useful for powerbridge thinkpads
    for battery in /sys/class/power_supply/BAT*; do
        name=$(basename "$battery")
        capacity=$(<"$battery/energy_full")
        current=$(<"$battery/energy_now")
        percentage=$((100 * current / capacity))
        status=$(<"$battery/status")

        if [ "$status" = "Charging" ]; then
            emoji="🔌"
        elif [ "$percentage" -le 40 ]; then
            emoji="🪫"
        else
            emoji="🔋"
        fi

        output="$output$name$emoji$percentage%|"
    done

    echo "${output%|}" # Remove trailing comma
}

powerdraw() {
	# adjust according to amount of batteries in the system:
	power_draw0=$(cat /sys/class/power_supply/BAT0/power_now 2>/dev/null) 
	power_draw1=$(cat /sys/class/power_supply/BAT1/power_now 2>/dev/null)
	total_power=$(( power_draw0 + power_draw1 ))
	watts=$(echo "scale=1; $total_power / 1000000" | bc)   
	echo "$watts"
}

network_status() {
    output=""
    for iface in $(ip link show | awk -F': ' '{print $2}' | grep -v -E 'lo|tun|tap|wg|ovpn'); do
        status=$(ip link show "$iface" | grep -oP '(?<=state )\w+')
        if [ "$status" = "UP" ]; then
            ip_address=$(ip addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
            if [ -n "$ip_address" ]; then
                output="🌍$output$iface🟢$ip_address|"
            else
                output="$output$iface⏳No IP|"
            fi
        else
            output="$output❌|"
        fi
    done
    echo "${output%|}" > /tmp/network_status.tmp 
}

while true; do
	vpn_status
	network_status
	sleep 8
done &

while true; do
	NET=$(cat /tmp/network_status.tmp)
	BAT=$(bat_status)
	FAN=$(cat /proc/acpi/ibm/fan | grep "speed:" | awk '{print $2}')
	LOCALTIME=$(date "+%a%F|%R")
	#CPUTEMP=$(sensors | grep 'Core 0' | awk '{print $3}')
	#CPUTEMP="🧠CPU:$(sensors | grep -oP '(?<=Core 0: ).*?(?=C)' | sed 's/ //g' | sed 's/+//g' | sed 's/.0//g')"
	CPUTEMP="🧠cpu$(echo $(( $(cat /sys/class/thermal/thermal_zone6/temp) / 1000 )))°"
	#GPUTEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
	POWERDRAW=$(powerdraw)
	#FREEMEM=$(free -h | grep "Mem:" | cut -b 40-43)
	#BATTERY_LEVEL=$(acpi | grep -P -o '[0-9]+(?=%)')
	#[ -f /tmp/CurIP.tmp ] && IP=$(cat /tmp/CurIP.tmp) || IP="No Connection" 
	VOL=$(amixer get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')
	#xsetroot -name "$VPN|🌍$NET|🔊$VOL%|🧠CPU:$CPUTEMP|🎮GPU:$GPUTEMP°|🌀"$FAN"rpm|"$POWERDRAW"W|$BAT|$LOCALTIME" &&
	xsetroot -name "$VPN|$NET|🔊$VOL%|$CPUTEMP|🌀"$FAN"rpm|"$POWERDRAW"W|$BAT|$LOCALTIME" &&
	sleep 4
	VPN=$(cat /tmp/vpn_status.tmp)
done &
