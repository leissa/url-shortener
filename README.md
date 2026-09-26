# <img src="package/contents/icons/io.github.leissa.urlshortener.svg" width="48" align="top"> URL Shortener (Plasma 6 Widget)

Panel icon that pops up a small field: paste a URL, press Enter or *Shorten*,
and get a short link back (da.gd, is.gd or TinyURL — whichever succeeds first) — optionally copied to the clipboard automatically.

![URL Shortener](assets/screenshot.png)

## Install

    ./install.sh

Then right-click the panel → *Add or Manage Widgets…* → search "URL Shortener".
If it doesn't show up right away: `systemctl --user restart plasma-plasmashell`.

## Hotkey

Right-click the icon → *Configure URL Shortener…* → *Keyboard Shortcuts*.

## Test without installing

    plasmoidviewer -a package

## Uninstall

    kpackagetool6 -t Plasma/Applet -r io.github.leissa.urlshortener

## Build a .plasmoid package

    ./package.sh

This creates `url-shortener-<Version>.plasmoid` (the version comes from `package/metadata.json`),
ready for upload to [store.kde.org](https://store.kde.org).
Bump `Version` in `package/metadata.json` before building a new release.
The package can also be installed directly with `kpackagetool6 -t Plasma/Applet -i url-shortener-<Version>.plasmoid`.

## Service order

Click the ⚙ button in the popup (or right-click → *Configure URL Shortener…*)
and use the arrows to reorder the services. They are tried top to bottom.

## Disclaimer

This plugin was mostly created with the help of AI.

## License

The code is licensed under the [MIT License](LICENSE).
