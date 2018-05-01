import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.0
import SodaControls 1.0
import QtQuick.Dialogs 1.0

import "controls" as AfterTrauma
import "colours.js" as Colours

ApplicationWindow {
    id: appWindow
    visible: true
    width: 480
    height: 640
    //
    //
    //
    title: qsTr("AfterTrauma")
    //
    // global font
    //
    AfterTrauma.Fonts {
        id: fonts
        anchors.fill: parent
        z:10
    }
    //
    // global models
    //
    Settings {
        id: settingsModel
    }
    Daily {
        id: dailyModel
    }
    Challenges {
        id: challengeModel
    }
    Questionnaires {
        id: questionnaireModel
    }
    Chats {
        id: chatModel
    }
    Categories {
        id: categoryModel
    }
    Documents {
        id: documentModel
    }
    Tags {
        id: tagsModel
    }
    Recomendations {
        id: recomendationModel
    }
    BodyPartList {
        id: bodyPartModel
    }
    //
    // notifications
    //
    Timer {
        id: notificationTimer
        interval: 60 * 1000
        repeat: true
        onTriggered: {
            notificationModel.update();
        }
    }
    Notifications {
        id: notificationModel
    }
    //
    //
    //
    background: Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Colours.blue }
            GradientStop { position: 1.0; color: Colours.darkBlue }
        }
    }
    //
    //
    //
    FlowerChart {
        id: flowerChart
        height: width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: titleBar.height
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        enabled: false
        onEnabledChanged: {
            update();
        }
    }
    //
    //
    //
    TitleBar {
        id: titleBar
    }
    //
    //
    //
    StackView {
        id: stack
        anchors.fill: parent
        //visible: depth > 1
        anchors.topMargin: depth > 1 ? 0 : titleBar.height
        transitions: Transition {
            AnchorAnimation { duration: 100 }
        }
        //
        //
        //
        function navigateTo( qmlSource, properties ) {
            var item = find(function(current) {
                //console.log( 'item url:' + current);
                return current.qmlSource === qmlSource;
            });

            if ( item ) {
                pop(item);
            } else {
                item = push(qmlSource, properties);
                if ( item && item.qmlSource !== undefined ) {
                    item.qmlSource = qmlSource;
                }
            }

        }
    }
    MainMenu {
        id: mainMenu
    }
    ShortcutPopup {
        id: shortcut
    }
    //
    // dialogs
    //
    Intro {
        id: intro
        x: 0; y: 0; width: appWindow.width; height: appWindow.height;
    }
    Register {
        id: register
    }
    AfterTrauma.ConfirmDialog {
        id: confirmDialog
        x: 0
        y: 0
        modal: true
        width: appWindow.width
        height: appWindow.height
    }
    AfterTrauma.ErrorDialog {
        id: errorDialog
        x: 0
        y: 0
        modal: true
        width: appWindow.width
        height: appWindow.height
    }
    //
    //
    //
    AfterTrauma.BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
    }
    //
    //
    //
    Text {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 2
        text: "(" + parent.width + "," + parent.height + ")"
    }
    //
    //
    //
    /*
    AfterTrauma.TokenisedTextField {
        id: testInput
        font.family: fonts.light.name
        font.pointSize: 32
        width: parent.width - 16
        anchors.centerIn: parent

    }
    NewQuestion {
        id: testQuestion
        width: parent.width - 16
        anchors.centerIn: parent
    }
    */
    //
    //
    //
    Component.onCompleted: {
        //
        // TODO: check settings for first use
        //
        if ( SystemUtils.isFirstRun() ) {
            console.log( 'installing' );
            //stack.push("qrc:///Install.qml")
            //SystemUtils.install();
            intro.open();
        } else {
            //
            //
            //
            stack.push("qrc:///Dashboard.qml");
            flowerChart.enabled = true;
            intro.open();
        }
    }
    //
    //
    //
    Connections {
        target: SystemUtils
        //
        //
        //
        onInstallComplete: {
            stack.push("qrc:///Dashboard.qml");
            flowerChart.enabled = true;
        }
    }
    function testUser() {
        return { id:"{5f9ba729-6a16-48c6-81a2-2de6d3db69ca}", username: "justTestin" };
    }
    Shortcut {
        sequence: StandardKey.Back
        onActivated: {
            console.log( 'Back' );
            if ( stack.depth <= 1 ) {
                Qt.quit();
            } else {
                stack.pop();
            }
        }
    }
    Connections {
        target: BackKeyFilter
        onBackKeyPressed : {
            if ( Qt.platform === 'android' ) {
                console.log( 'BackKeyPressed' );
                if ( stack.depth <= 1 ) {
                    Qt.quit();
                } else {
                    stack.pop();
                }
            }
        }
    }
    //
    // global properties
    //
    property bool loggedIn: false
    property var userProfile: null //testUser()
    property string baseURL: "https://aftertrauma.uk:4000"
    property string baseWS: "wss://aftertrauma.uk:4000"
}
