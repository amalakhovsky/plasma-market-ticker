#!/usr/bin/env bash
# Install or upgrade the Market Ticker plasmoid for the current user.
set -euo pipefail
cd "$(dirname "$0")"
ID=org.kde.plasma.marketticker
if kpackagetool6 -t Plasma/Applet -l 2>/dev/null | grep -qx "$ID"; then
    kpackagetool6 -t Plasma/Applet --upgrade package
else
    kpackagetool6 -t Plasma/Applet --install package
fi
echo "Installed $ID. Add it via right-click panel -> Add Widgets -> 'Market Ticker' (one per asset),"
echo "then right-click it -> Configure to pick a coin or a stock symbol."
