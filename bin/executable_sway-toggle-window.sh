#!/usr/bin/env bash

APP_ID="${1:?Usage: $0 <app_id> [command]}"
CMD="${2:-$APP_ID}"

found=$(swaymsg -t get_tree | jq -r ".. | objects | select(.app_id? == \"$APP_ID\") | .app_id" | head -1)

if [ -n "$found" ]; then
    swaymsg "[app_id=\"$APP_ID\"] kill"
else
    setsid $CMD &
fi
