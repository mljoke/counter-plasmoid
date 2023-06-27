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
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    property var textSrc: 0
    property var stepV: 0
    property var textLimitSrc: plasmoid.configuration.limitUnreached
    property var limitLeft: getLimitLeft()
    property var limitColor: plasmoid.configuration.limitUnreachedColor

    //Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    function scroll(wheelDelta, eventDelta, sfx) {
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
                (increment > 0) ? increase(sfx, stepV) : decrease(sfx, stepV)
                increment += (increment < 0) ? 1 : -1;
            }

            return wheelDelta;
    }
    function getLimitLeft() {
        return plasmoid.configuration.limitLeft - textSrc
    }

    function increase(sfx, step) {
        (step == 0) ? textSrc++ : textSrc += step
        set_values(sfx)
    }

    function decrease(sfx, step) {
        (step == 0) ? textSrc-- : textSrc -= step
        set_values(sfx)
    }

    function reset() {
        limitColor = plasmoid.configuration.limitUnreachedColor
        textSrc = 0
    }

    Plasmoid.compactRepresentation: MouseArea {
        id: compactRoot

        anchors.fill: parent
        hoverEnabled: true

        property int wheelDelta: 0

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: (mouse.button == Qt.LeftButton) ? plasmoid.expanded = !plasmoid.expanded : reset()
        onWheel: wheelDelta = scroll(wheelDelta, wheel.angleDelta.y, sfx)

        RowLayout {
            anchors.centerIn: parent
            PlasmaComponents.Label {
                id: label
                text: textSrc
                horizontalAlignment: Text.AlignHCenter
            }

            PlasmaComponents.Label {
                id: limit
                text: "/ " + limitLeft
                color: limitColor
                visible: plasmoid.configuration.limitEnabled
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Audio {
            id: sfx
        }
    }

    function set_values(sfx) {
            if(plasmoid.configuration.click_sound) {
                sfx.source = plasmoid.configuration.click_sound_file
                sfx.volume = 1.0
                sfx.play()
            }
            if(plasmoid.configuration.limitEnabled) {
                if(limitLeft > 0) {
                    limitColor = plasmoid.configuration.limitUnreachedColor
                    textLimitSrc = plasmoid.configuration.limitUnreached
                } else {
                    limitColor = plasmoid.configuration.limitReachedColor
                    textLimitSrc = plasmoid.configuration.limitReached
                }
            }
    }

    Plasmoid.fullRepresentation: Item {
        id: fullRoot
        Layout.minimumWidth: fullRoot.implicitWidth
        Layout.minimumHeight: fullRoot.implicitHeight
        Layout.preferredWidth: 200 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 200 * PlasmaCore.Units.devicePixelRatio

        Audio {
            id: sfx
        }

        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                id: stepRow
                Layout.alignment: Qt.AlignCenter
                PlasmaComponents.Label {
                    text: i18n("Step:")
                }
                PlasmaComponents3.SpinBox {
                    implicitWidth: 100
                    id: stepValue
                    from: 1
                    value: stepV
                    stepSize: 1
                    onValueModified: stepV = stepValue.value
                }
            }

            PlasmaComponents.Label {
                id: currentCount
                Layout.alignment: Qt.AlignCenter
                text: textSrc
                font.family: "Noto Sans"
                font.pointSize: 30 * PlasmaCore.Units.devicePixelRatio
                horizontalAlignment: Text.AlignHCenter
            MouseArea {
                anchors.fill: parent
                property int wheelDelta: 0

                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                onClicked: {
                    if (mouse.button == Qt.LeftButton) {
                        plasmoid.expanded = !plasmoid.expanded
                    } else {
                        limitLeft = plasmoid.configuration.limitLeft
                        textSrc = 0
                    }
                }
                onWheel: wheelDelta = scroll(wheelDelta, wheel.angleDelta.y, sfx)
            }
            }

            PlasmaComponents.Label {
                id: limitLeftLabel
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true

                text: limitLeft
                visible: plasmoid.configuration.limitEnabled
                font.family: "Noto Sans"
                font.pointSize: 10 * PlasmaCore.Units.devicePixelRatio
                horizontalAlignment: Text.AlignHCenter
            }

            PlasmaComponents.Label {
                id: limitStatus
                Layout.alignment: Qt.AlignCenter
                text: textLimitSrc
                visible: plasmoid.configuration.limitEnabled
                font.family: "Noto Sans"
                font.pointSize: 10 * PlasmaCore.Units.devicePixelRatio
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
            id: buttonsRow
            spacing: 10
            Layout.alignment: Qt.AlignCenter

            PlasmaComponents.Button {
                implicitWidth: minimumWidth
                iconSource: "cursor-cross"
                onClicked: increase(sfx, stepValue.value)
            }

            PlasmaComponents.Button {
                implicitWidth: minimumWidth
                iconSource: "media-track-remove-amarok"
                onClicked: decrease(sfx, stepValue.value)
            }

            PlasmaComponents.Button {
                implicitWidth: minimumWidth
                iconSource: "close-symbolic"
                onClicked: reset()
            }
        }

        }
    }

}
