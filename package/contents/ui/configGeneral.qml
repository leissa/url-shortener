import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "services.js" as Services

KCM.SimpleKCM {
    id: page

    property alias cfg_autoCopy: autoCopy.checked
    property bool cfg_autoCopyDefault
    property var cfg_serviceOrder
    property var cfg_serviceOrderDefault

    readonly property var services: Services.ordered(cfg_serviceOrder)

    function move(from, to) {
        const ids = services.map(s => s.id);
        ids.splice(to, 0, ids.splice(from, 1)[0]);
        cfg_serviceOrder = ids;
    }

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: autoCopy
            Kirigami.FormData.label: i18n("Clipboard:")
            text: i18n("Automatically copy short URL")
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Service order:")
            spacing: 0

            Repeater {
                model: page.services

                RowLayout {
                    required property var modelData
                    required property int index

                    QQC2.Label {
                        Layout.minimumWidth: Kirigami.Units.gridUnit * 6
                        text: (index + 1) + ". " + modelData.name
                    }
                    QQC2.ToolButton {
                        icon.name: "arrow-up"
                        enabled: index > 0
                        onClicked: page.move(index, index - 1)
                        QQC2.ToolTip.text: i18n("Move up")
                        QQC2.ToolTip.visible: hovered
                    }
                    QQC2.ToolButton {
                        icon.name: "arrow-down"
                        enabled: index < page.services.length - 1
                        onClicked: page.move(index, index + 1)
                        QQC2.ToolTip.text: i18n("Move down")
                        QQC2.ToolTip.visible: hovered
                    }
                }
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Services are tried top to bottom until one succeeds.")
            font: Kirigami.Theme.smallFont
            wrapMode: Text.Wrap
        }
    }
}
