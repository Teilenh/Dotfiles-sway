#!/bin/bash

# if pgrep -x "waybar" > /dev/null; then
    # Si Waybar est actif, on le tue
#     killall waybar
# fi

waybar &
# echo "Waybar relancé."
