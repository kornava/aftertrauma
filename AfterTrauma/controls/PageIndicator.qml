import QtQuick 2.6
import QtQuick.Controls 2.1

import "../colours.js" as Colours

PageIndicator {
    id: control
    delegate: Rectangle {
        implicitWidth: 16
        implicitHeight: 16

        radius: width / 2
        color: control.colour

        opacity: index === control.currentIndex ? 0.95 : 0.45

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }
    }
    property var colour: Colours.darkOrange
}
