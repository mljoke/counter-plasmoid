/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtMultimedia 5.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    property var textSrc: 0

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.compactRepresentation: MouseArea {
        id: compactRoot

        anchors.fill: parent
        hoverEnabled: true

        property int wheelDelta: 0

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: {
            if (mouse.button == Qt.LeftButton) {
                plasmoid.expanded = !plasmoid.expanded
            } else {
                textSrc = 0
            }
        }
        onWheel: {
            wheelDelta = scroll(wheelDelta, wheel.angleDelta.y)
        }
        PlasmaComponents.Label {
            id: label
            anchors.fill: parent
            text: textSrc
            horizontalAlignment: Text.AlignHCenter
        }

        Audio {
            id: sfx
        }

        function scroll(wheelDelta, eventDelta) {
            // magic number 120 for common "one click"
            // See: https://doc.qt.io/qt-6/qml-qtquick-wheelevent.html#angleDelta-prop
            wheelDelta += eventDelta;

            var increment = 0;

            while (wheelDelta >= 120) {
                wheelDelta -= 120;
                increment++;
            }

            while (wheelDelta <= -120) {
                wheelDelta += 120;
                increment--;
            }

            while (increment != 0) {
                if(increment > 0) {
                    textSrc++
                } else {
                     textSrc--
                }
            sfxPlay(sfx)
            increment += (increment < 0) ? 1 : -1;
            }

            return wheelDelta;
        }
    }

    function sfxPlay(sfx) {
            if(plasmoid.configuration.click_sound) {
                sfx.source = plasmoid.configuration.click_sound_file
                sfx.volume = 1.0
                sfx.play()
            }
    }

    Plasmoid.fullRepresentation: Item {
        Layout.minimumWidth: label.implicitWidth
        Layout.minimumHeight: label.implicitHeight
        Layout.preferredWidth: 200 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 200 * PlasmaCore.Units.devicePixelRatio

        PlasmaComponents.Label {
            id: label
            anchors.fill: parent
            text: textSrc
            font.family: "Noto Sans"
            font.pointSize: 30 * PlasmaCore.Units.devicePixelRatio
            horizontalAlignment: Text.AlignHCenter
        }

        Audio {
            id: sfx
        }

        RowLayout {
            id: buttonsRow
            spacing: 10

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            PlasmaComponents.Button {
                implicitWidth: minimumWidth
                iconSource: "cursor-cross"
                onClicked: { textSrc++, sfxPlay(sfx) }
            }

            PlasmaComponents.Button {
                implicitWidth: minimumWidth
                iconSource: "media-track-remove-amarok"
                onClicked: { textSrc--, sfxPlay(sfx) }
            }

            PlasmaComponents.Button {
                implicitWidth: minimumWidth
                iconSource: "close-symbolic"
                onClicked: { textSrc = 0, sfxPlay(sfx) }
            }
        }
    }

}
