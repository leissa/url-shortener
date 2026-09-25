import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "services.js" as Services

PlasmoidItem {
    id: root

    Plasmoid.icon: "insert-link"
    toolTipMainText: i18n("URL Shortener")
    toolTipSubText: i18n("Shorten a URL")

    // Monochrome panel icon, tinted with the theme's text color like Breeze symbolic icons.
    compactRepresentation: MouseArea {
        property bool wasExpanded: false

        hoverEnabled: true
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        Kirigami.Icon {
            anchors.fill: parent
            source: Qt.resolvedUrl("../icons/url-shortener-symbolic.svg")
            isMask: true
            color: Kirigami.Theme.textColor
            active: parent.containsMouse
        }
    }

    fullRepresentation: ColumnLayout {
        id: popup

        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredWidth: Kirigami.Units.gridUnit * 24
        spacing: Kirigami.Units.smallSpacing

        property bool busy: false
        property string error: ""

        // Qt Quick has no clipboard API; an invisible TextEdit is the usual workaround.
        TextEdit {
            id: clipboardHelper
            visible: false
        }

        function copyToClipboard(text) {
            clipboardHelper.text = text;
            clipboardHelper.selectAll();
            clipboardHelper.copy();
        }

        function shorten() {
            let url = inputField.text.trim();
            if (url === "" || busy)
                return;
            if (!/^[a-z][a-z0-9+.-]*:/i.test(url))
                url = "https://" + url;

            busy = true;
            error = "";
            resultField.text = "";
            tryService(Services.ordered(Plasmoid.configuration.serviceOrder), 0, encodeURIComponent(url), []);
        }

        function tryService(services, i, encodedUrl, failures) {
            if (i >= services.length) {
                busy = false;
                error = failures.join("\n");
                return;
            }
            const service = services[i];
            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function () {
                if (xhr.readyState !== XMLHttpRequest.DONE)
                    return;
                const body = xhr.responseText.trim();
                // is.gd reports errors with status 200, so check the body too.
                if (xhr.status === 200 && /^https?:\/\/\S+$/.test(body)) {
                    busy = false;
                    resultField.text = body;
                    if (Plasmoid.configuration.autoCopy)
                        copyToClipboard(body);
                } else {
                    const reason = xhr.status === 0 ? i18n("network error") : (body || xhr.statusText);
                    tryService(services, i + 1, encodedUrl, failures.concat(service.name + ": " + reason));
                }
            };
            xhr.open("GET", service.endpoint + encodedUrl);
            xhr.send();
        }

        Connections {
            target: root
            function onExpandedChanged() {
                if (root.expanded) {
                    inputField.forceActiveFocus();
                    inputField.selectAll();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.TextField {
                id: inputField
                Layout.fillWidth: true
                placeholderText: i18n("Paste a long URL…")
                enabled: !popup.busy
                onAccepted: popup.shorten()
                Keys.onEscapePressed: root.expanded = false
            }

            PlasmaComponents.Button {
                icon.name: "go-next"
                text: i18n("Shorten")
                enabled: !popup.busy && inputField.text.trim() !== ""
                onClicked: popup.shorten()
            }
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.TextField {
                id: resultField
                Layout.fillWidth: true
                readOnly: true
                placeholderText: popup.busy ? i18n("Shortening…") : i18n("Short URL appears here")
            }

            PlasmaComponents.ToolButton {
                icon.name: "edit-copy"
                enabled: resultField.text !== ""
                onClicked: popup.copyToClipboard(resultField.text)
                PlasmaComponents.ToolTip.text: i18n("Copy to clipboard")
                PlasmaComponents.ToolTip.visible: hovered
            }
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.CheckBox {
                text: i18n("Automatically copy to clipboard")
                checked: Plasmoid.configuration.autoCopy
                onToggled: Plasmoid.configuration.autoCopy = checked
            }

            Item { Layout.fillWidth: true }

            PlasmaComponents.BusyIndicator {
                visible: popup.busy
                running: visible
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
            }

            PlasmaComponents.ToolButton {
                icon.name: "configure"
                onClicked: Plasmoid.internalAction("configure").trigger()
                PlasmaComponents.ToolTip.text: i18n("Settings (service order)")
                PlasmaComponents.ToolTip.visible: hovered
            }
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            visible: popup.error !== ""
            text: popup.error
            color: Kirigami.Theme.negativeTextColor
            wrapMode: Text.Wrap
        }
    }
}
