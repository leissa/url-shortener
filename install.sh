#!/bin/sh
# Install or upgrade the widget for the current user.
set -e
cd "$(dirname "$0")"
kpackagetool6 -t Plasma/Applet -u package >/dev/null 2>&1 || kpackagetool6 -t Plasma/Applet -i package
