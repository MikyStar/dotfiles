#!/usr/bin/env bash
# Fire a dummy freedesktop notification, to test the Quickshell notification
# widgets (bar/services/Notifications.qml, bar/modules/NotificationBell.qml).
#
# Uses dbus-send directly instead of notify-send (not installed on this
# system), talking to whatever is currently registered as
# org.freedesktop.Notifications -- i.e. Quickshell's NotificationServer.
#
# Usage:
#   ./test-notify.sh                       # send one dummy notification
#   ./test-notify.sh "Summary" "Body text"  # custom text
#   ./test-notify.sh "Summary" "Body" critical  # urgency: low|normal|critical
#
# Env overrides:
#   ICON="preferences-system"                        # freedesktop icon name (from the system icon theme)
#   ACTIONS="accept:Accept,decline:Decline,view:View"  # id:Label pairs, rendered as buttons by NotificationBell
#
# Requires: dbus-send (already present on this system)

set -euo pipefail

APP_NAME="TestNotify"
# "dialog-information" isn't in the icon theme actually installed here, so it rendered blank.
# "kitty" is a real installed icon (hicolor/*/apps/kitty.{svg,png}), so it's a reliable default for testing.
ICON="${ICON:-kitty}"
SUMMARY="${1:-Dummy notification}"
BODY="${2:-This is a test notification body with $RANDOM as dummy data.}"
ACTIONS="${ACTIONS:-accept:Accept,decline:Decline}"

case "${3:-normal}" in
    low) URGENCY=0 ;;
    critical) URGENCY=2 ;;
    *) URGENCY=1 ;;
esac

# Actions are passed to the Notify D-Bus method as a flat array alternating
# id, label, id, label, ... -- turn "id:Label,id2:Label2" into dbus-send's
# array:string:"id","Label","id2","Label2" syntax.
action_args=()
IFS=',' read -ra pairs <<< "$ACTIONS"
for pair in "${pairs[@]}"; do
    action_args+=("${pair%%:*}" "${pair#*:}")
done
actions_arg="array:string:$(printf '"%s",' "${action_args[@]}")"
actions_arg="${actions_arg%,}"

dbus-send --session --type=method_call --print-reply \
    --dest=org.freedesktop.Notifications \
    /org/freedesktop/Notifications \
    org.freedesktop.Notifications.Notify \
    string:"$APP_NAME" \
    uint32:0 \
    string:"$ICON" \
    string:"$SUMMARY" \
    string:"$BODY" \
    "$actions_arg" \
    dict:string:variant:"urgency",byte:"$URGENCY" \
    int32:5000
