#!/bin/sh

bat_status() {
    output=""
    for battery in /sys/class/power_supply/BAT*; do
        name=$(basename "$battery")
        capacity=$(<"$battery/energy_full")
        current=$(<"$battery/energy_now")
        percentage=$((100 * current / capacity))
        status=$(<"$battery/status")

        if [ "$status" = "Charging" ]; then
            emoji="🔌"
        elif [ "$percentage" -le 30 ]; then
            emoji="🪫"
        else
            emoji="🔋"
        fi

        output="$output$name$emoji$percentage%|"
    done

    echo "${output%|}" # Remove trailing comma
}

bat_status
