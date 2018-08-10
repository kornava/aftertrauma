import QtQuick 2.7
import QtQuick.Controls 2.1

import "controls" as AfterTrauma
import "colours.js" as Colours

Popup {
    id: container
    height: parent.height
    //
    //
    //
    background: AfterTrauma.Background {
        anchors.fill: parent
        fill: Colours.almostWhite
        //opacity: .5
    }
    //
    //
    //
    contentItem: Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 32
        padding: 16
        //
        //
        //
        Label {
            height: 48
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colours.veryDarkSlate
            font.pointSize: 36
            font.weight: Font.Light
            font.family: fonts.light
            text: "from date"
        }
        //
        //
        //
        AfterTrauma.DatePicker {
            id: from
            height: 128
            width: container.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            onCurrentDateChanged: {
                /*
                if ( !blockUpdates ) {
                    if ( currentDate.getTime() > to.currentDate.getTime() ) {
                        to.currentDate = currentDate;
                    }
                }
                */
            }
        }
        //
        //
        //
        Label {
            height: 48
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colours.veryDarkSlate
            font.pointSize: 36
            font.weight: Font.Light
            font.family: fonts.light
            text: "to date"
        }
        //
        //
        //
        AfterTrauma.DatePicker {
            id: to
            height: 128
            width: container.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            onCurrentDateChanged: {
                /*
                if ( !blockUpdates ) {
                    if ( currentDate.getTime() < from.currentDate.getTime() ) {
                        from.currentDate = currentDate;
                    }
                }
                */
            }
        }
        //
        //
        //
        Row {
            height: 64
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 32
            //
            //
            //
            AfterTrauma.Button {
                text: "cancel"
                textColour: Colours.veryDarkSlate
                onClicked: {
                    container.close();
                }
            }
            AfterTrauma.Button {
                text: "ok"
                textColour: Colours.veryDarkSlate
                onClicked: {
                    if ( callback ) {
                        callback( from.currentDate, to.currentDate );
                    }
                    container.close();
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "y"; from: parent.height; to: 0 }
    }

    exit: Transition {
        NumberAnimation { property: "y"; from: 0; to: parent.height }
    }
    //
    //
    //
    function show( callback, fromDate, toDate ) {
        blockUpdates = true;

        container.callback = callback;

        if ( fromDate ) {
            from.currentDate = fromDate;
        } else {
            from.currentDate = new Date();
        }

        if ( toDate ) {
            to.currentDate = toDate;
        } else {
            to.currentDate = new Date();
        }

        blockUpdates = false;
        from.updateUI();
        to.updateUI();
        open();
    }
    //
    //
    //
    property bool blockUpdates: false
    property var callback: null
}
