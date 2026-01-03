#!/bin/bash

TEMP_FILE="/tmp/pavucontrol_toggle"

if pgrep -x pavucontrol > /dev/null; then
    echo "pavucontrol is running."

    monitors_json=$(hyprctl -j monitors)
    clients_json=$(hyprctl -j clients)

    pavu_workspace=$(echo "$clients_json" | jq -r '
        .[] 
        | select(.class == "org.pulseaudio.pavucontrol") 
        | .workspace 
        | if .id != 0 then .name else (.id | tostring) end
    ')

    focused_workspace=$(echo "$monitors_json" | jq -r '
        .[] 
        | select(.focused == true) 
        | if .specialWorkspace.id != 0 
            then .specialWorkspace.name 
            else (.activeWorkspace.id | tostring) 
          end
    ')

    echo "pavucontrol workspace: $pavu_workspace"
    echo "Focused workspace: $focused_workspace"

    if [ "$pavu_workspace" = "$focused_workspace" ]; then
        echo "pavucontrol is already in the current workspace. Closing it."
        hyprctl dispatch closewindow class:org.pulseaudio.pavucontrol
    else
        echo "Moving pavucontrol to current workspace."
        hyprctl dispatch movetoworkspace "$focused_workspace",class:org.pulseaudio.pavucontrol
    fi

else
    echo "Opening pavucontrol"
    WIDTH=720
    HEIGHT=720

    # Get reserved space from focused monitor
    monitors_json=$(hyprctl -j monitors)
    RESERVED_TOP=$(echo "$monitors_json" | jq '.[0].reserved[1]' 2>/dev/null)

    cursor_pos=$(hyprctl cursorpos)
    x=$(echo "$cursor_pos" | awk -F', ' '{print $1}')
    y=$(echo "$cursor_pos" | awk -F', ' '{print $2}')
    x=$(( x - WIDTH / 2 ))

    [ "$y" -lt "$RESERVED_TOP" ] && y=$RESERVED_TOP

    hyprctl dispatch "exec [float; move $x $y; size $WIDTH $HEIGHT] pavucontrol -t 3"
fi
