import QtQuick 2.7
import QtQuick.Controls 2.1

import "controls" as AfterTrauma
import "colours.js" as Colours

AfterTrauma.Page {
    colour: "transparent"
    //
    //
    //
    Item {
        id: content
        anchors.top: parent.verticalCenter
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: parent.height / 6
        //
        //
        //
        DateSlider {
            id: dateSlider
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            onDateChanged: {
                if ( flowerChart ) {
                    flowerChart.setCurrentDate(currentDate.getTime());
                }
            }
        }
        //
        //
        //
        SwipeView {
            id: notifications
            anchors.top: dateSlider.bottom
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            //
            //
            //
            Repeater {
                id: notificationsRepeater
                //
                //
                //
                model: notificationModel.count
                //
                //
                //
                delegate: Page {
                    background: Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                    }
                    Text {
                        anchors.fill: parent
                        color: Colours.almostWhite
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: notificationModel.get( index ).text
                    }
                }
            }
        }
        //
        //
        //
        AfterTrauma.PageIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            currentIndex: notifications.currentIndex
            count: notifications.count
            colour: Colours.almostWhite
        }
    }
    //
    //
    //
    Timer {
        id: scrollTimer
        interval: 30 * 1000
        repeat: true
        onTriggered: {
            if ( notifications.count ) {
                if ( notifications.currentIndex < notifications.count - 1 ) {
                    notifications.currentIndex = 0;
                } else {
                    notifications.currentIndex++;
                }
            }
        }
    }
    //
    //
    //
    Component.onCompleted:  {
        scrollTimer.start();
        var dateRange = testDailyModel.getDateRange();
        console.log( 'dateRange : ' + JSON.stringify(dateRange) );
        dateSlider.startDate = new Date(dateRange.min);
        dateSlider.endDate = new Date(dateRange.max);
        dateSlider.setDate(dateSlider.endDate);
    }

    //
    //
    //
    StackView.onActivated: {
        scrollTimer.start();
        var dateRange = testDailyModel.getDateRange();
        console.log( 'dateRange : ' + JSON.stringify(dateRange) );
        dateSlider.startDate = new Date(dateRange.min);
        dateSlider.endDate = new Date(dateRange.max);
        dateSlider.setDate(dateSlider.endDate);
        /*
        if ( flowerChart ) {
            dateSlider.setDate(flowerChart.getCurrentDate());
        }
        */
    }
    StackView.onDeactivated: {
        scrollTimer.stop();
    }
    //
    //
    //
    Connections {
        target: notificationModel
        onUpdated: {
            notificationsRepeater.model = notificationModel.count
        }
    }
}
