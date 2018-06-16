import QtQuick 2.6
import QtQuick.Controls 2.1

import "../colours.js" as Colours

SwipeDelegate {
    id: container
    //
    //
    //
    height: 64
    //
    //
    //
    leftPadding: swipeEnabled ? 4 : 0
    rightPadding: swipeEnabled ? 4 : 0
    //
    //
    //
    Component {
        id: editComponent
        Label {
            id: editLabel
            text: "Edit"
            color: Colours.almostWhite
            verticalAlignment: Label.AlignVCenter
            padding: 12
            height: parent.height
            anchors.left: parent.left
            background: Rectangle {
                color: Colours.darkGreen
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    container.edit();
                }
            }
        }
    }
    //
    //
    //
    Component {
        id: deleteComponent
        Label {
            id: deleteLabel
            text: "Delete"
            color: Colours.almostWhite
            verticalAlignment: Label.AlignVCenter
            padding: 12
            height: parent.height
            anchors.right: parent.right
            background: Rectangle {
                color: Colours.red
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    swipe.close();
                    container.remove();
                }
            }
        }
    }
    //
    //
    //
    background: Item {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.horizontalCenter
            color: Colours.darkGreen
        }
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            color: Colours.red
        }
    }
    //
    //
    //
    signal edit()
    signal remove()
    //
    //
    //
    function updateControls() {
        if ( swipe.position === 0 ) {
            //swipe.left = swipeEnabled ? editComponent : emptyComponent;
            //swipe.right = swipeEnabled ? deleteComponent : emptyComponent;
            swipe.left = swipeEnabled ? editComponent : null;
            swipe.right = swipeEnabled ? deleteComponent : null;
        } else {
            console.log( 'EditableListItem : defering control update' );
            Qt.callLater( updateControls );
        }
    }
    //
    //
    //
    onSwipeEnabledChanged: {
        if ( swipe.position !== 0 ) {
            console.log( 'EditableListItem.onSwipeEnabledChanged : closing swipe' );
            swipe.close();
        } else {
            updateControls();
        }
    }
    //
    //
    //
    swipe.onPositionChanged: {
        if ( swipe.position === 0 ) {
            Qt.callLater( updateControls );
        }
    }
    //
    //
    //
    Component.onCompleted: {
        updateControls();
    }
    //
    //
    //
    property bool swipeEnabled: true
}
