#!/bin/bash

TEMP_FILE="/tmp/pavucontrol_toggle"

if pgrep -x pavucontrol > /dev/null; then
    echo "pavucontrol is running."
    hyprctl dispatch closewindow class:org.pulseaudio.pavucontrol
else
    echo "Opening pavucontrol"
    WIDTH=405
    HEIGHT=720

    # Get reserved space from focused monitor
    monitors_json=$(hyprctl -j monitors)
    RESERVED_TOP=$(echo "$monitors_json" | jq '.[0].reserved[1]' 2>/dev/null)
    SCREEN_WIDTH=$(echo "$monitors_json" | jq '.[0].width' 2>/dev/null)
    SCREEN_HEIGHT=$(echo "$monitors_json" | jq '.[0].height' 2>/dev/null)
    SCREEN_MAX_X=$(( SCREEN_WIDTH - WIDTH ))
    SCREEN_MAX_Y=$(( SCREEN_HEIGHT - HEIGHT ))

    # Get cursor position
    cursor_pos=$(hyprctl cursorpos)
    xoriginalpos=$(echo "$cursor_pos" | awk -F', ' '{print $1}')
    yoriginalpos=$(echo "$cursor_pos" | awk -F', ' '{print $2}')

    # Center x on cursor, position y under cursor
    x=$(( xoriginalpos - WIDTH / 2 ))
    y=$yoriginalpos

    # Keep window within screen bounds
    [ "$x" -lt 0 ] && x=0
    [ "$x" -gt "$SCREEN_MAX_X" ] && x=$SCREEN_MAX_X
    [ "$y" -lt "$RESERVED_TOP" ] && y=$RESERVED_TOP
    [ "$y" -gt "$SCREEN_MAX_Y" ] && y=$SCREEN_MAX_Y

    echo "Position: x=$x, y=$y"
    hyprctl dispatch "exec [float; pin; move $x $y; size $WIDTH $HEIGHT] pavucontrol -t 3"
fi
