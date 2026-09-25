#!/bin/sh
# Install or upgrade the widget for the current user.
set -e
cd "$(dirname "$0")"
id=org.kde.plasma.urlshortener
kpackagetool6 -t Plasma/Applet -u package >/dev/null 2>&1 || kpackagetool6 -t Plasma/Applet -i package
# The widget picker only looks icons up in the theme, never in the package.
install -Dm644 "package/contents/icons/$id.svg" "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/$id.svg"
