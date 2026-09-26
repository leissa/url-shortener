# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A KDE Plasma 6 panel widget (plasmoid, id `io.github.leissa.urlshortener`) written in pure QML + JavaScript. It has no build step, test suite or linter. Everything that gets installed lives under `package/`.

## Commands

- `plasmoidviewer -a package`: run the widget in a standalone window without installing it. This is the main way to test changes.
- `./install.sh`: install the widget for the current user, or upgrade it if it's already installed (`kpackagetool6 -u`, falling back to `-i`). Run `systemctl --user restart plasma-plasmashell` if the panel still shows the old version.
- `./package.sh`: build `url-shortener-<Version>.plasmoid` (a zip of `metadata.json` + `contents/`) for store.kde.org. The version is read from `package/metadata.json`.
- `kpackagetool6 -t Plasma/Applet -r io.github.leissa.urlshortener`: uninstall.

## Architecture

- `package/contents/ui/services.js` (`.pragma library`, a shared singleton) is the single source of truth for shortening services. Each entry has an `id`, a display `name` and a GET `endpoint` prefix that gets the URL-encoded long URL appended and returns the short URL as plain text. `ordered(order)` turns the saved list of ids into service objects: it drops unknown ids and appends services the list doesn't mention, so adding a service to `all` makes it show up for existing users without a config migration.
- `package/contents/ui/main.qml` holds the popup (`fullRepresentation`). `shorten()` prepends `https://` when the input has no scheme, then `tryService()` walks the ordered services one after another with `XMLHttpRequest`, falling back to the next service on failure. A response counts as success only if the status is 200 **and** the body looks like a single `http(s)://` URL, because is.gd returns errors with status 200. The failure messages from each service are collected and shown if every service fails. A custom `compactRepresentation` shows `contents/icons/url-shortener-symbolic.svg` as a `Kirigami.Icon` with `isMask: true`, so it follows the panel's text color. Qt Quick has no clipboard API, so text is copied through a hidden `TextEdit`.
- Icons: `metadata.json` sets `"Icon": "/icons/io.github.leissa.urlshortener.svg"` — a path relative to `package/contents/`, not an icon-theme name. Plasma's widget picker resolves an `Icon` that starts with `/` inside the package (`PlasmaAppletItem` in plasma-workspace), so the bundled colored logo also shows for users who install from store.kde.org, where nothing ever touches the icon theme. Keep the leading slash; a bare name or `./foo.svg` falls back to a theme lookup and yields the generic plasmoid icon. The settings dialog's *About* page (`configuration/AboutPlugin.qml` in the desktop shell) resolves the same form via `StandardPaths.locate`, so it shows the logo too — but `plasmoidviewer`'s own copy of that file doesn't, so the About page shows the generic icon there. That's a plasmoidviewer artifact, not a packaging bug.
- Config: `package/contents/config/main.xml` defines the keys (`autoCopy`: Bool, `serviceOrder`: StringList of service ids). The code reads them as `Plasmoid.configuration.<key>`. `config.qml` registers the one settings page, `configGeneral.qml`, which binds keys through the `cfg_<key>` / `cfg_<key>Default` property convention. The popup's ⚙ button opens this same dialog via `Plasmoid.internalAction("configure")`.
- To add a service, add an entry to `all` in `services.js`. You can also update the `serviceOrder` default in `main.xml` and the description in `metadata.json` and `README.md`, which list the services by name.

## Conventions

- User-visible strings are wrapped in `i18n()`.
- Use Plasma components (`org.kde.plasma.components`) in the popup and QtQuick.Controls + Kirigami in the config page, following Plasma's own split.
- Bump `Version` in `package/metadata.json` before running `./package.sh` for a release.
