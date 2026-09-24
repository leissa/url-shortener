#!/bin/sh
# Build a .plasmoid archive for upload to store.kde.org.
set -e
cd "$(dirname "$0")"
version=$(sed -n 's/.*"Version": *"\([^"]*\)".*/\1/p' package/metadata.json)
out="$PWD/url-shortener-$version.plasmoid"
rm -f "$out"
(cd package && zip -r -X "$out" metadata.json contents)
echo "Created $out"
