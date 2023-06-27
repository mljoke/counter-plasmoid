import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.0
import QtMultimedia 5.4

ColumnLayout {
    property alias cfg_click_sound: click_sound.checked
    property alias cfg_click_sound_file: click_sound_file.text

    id: appearancePage

    Audio {
        id: sfx
    }

    GroupBox {
        Layout.fillWidth: true

        title: i18n("Sounds")

        flat: true
        ColumnLayout {
            width: parent.width

            RowLayout {
                Text { width: indentWidth } // indent
                CheckBox {
                    id: click_sound
                    text: i18n("Click:")
                }
                Button {
                    text: i18n("Choose")
                    onClicked: click_sound_fileDialog.visible = true
                    enabled: cfg_click_sound
                }
                TextField {
                    id: click_sound_file
                    Layout.fillWidth: true
                    enabled: cfg_click_sound
                    placeholderText: "/usr/share/sounds/freedesktop/stereo/dialog-information.oga"
                }
                Button {
                    iconName: "media-playback-start"
                    onClicked: {
                        sfx.source = click_sound_file.text
                        sfx.volume = 1.0
                        sfx.play()
                    }
                }
            }
        }
    }
    Item {
        // tighten layout
        Layout.fillHeight: true
    }

    function getPath(fileUrl) {
        // remove prefixed "file://"
        return fileUrl.toString().replace(/^file:\/\//,"");
    }

    FileDialog {
        id: click_sound_fileDialog
        title: i18n("Choose a sound effect")
        folder: '/usr/share/sounds'
        nameFilters: [ "Sound files (*.wav *.mp3 *.oga *.ogg)", "All files (*)" ]
        onAccepted: {
            console.log("You chose: " + fileUrls)
            cfg_click_sound_file = fileUrl
        }
        onRejected: {
            console.log("Canceled")
        }
    }

}
