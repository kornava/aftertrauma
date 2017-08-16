import QtQuick 2.7
import QtQuick.Controls 2.1

import "controls" as AfterTrauma
import "colours.js" as Colours
import "utils.js" as Utils

AfterTrauma.Page {
    title: "TIMELINE"
    colour: Colours.slate
    //
    //
    //
    ListView {
        id: dailyList
        //
        //
        //
        anchors.fill: parent
        //
        //
        //
        clip: true
        spacing: 8
        //
        //
        //
        model: dailyModel
        //
        //
        //
        /*
        delegate: Text {
            height: 32
            anchors.left: parent?parent.left:undefined
            anchors.right: parent?parent.right:undefined
            text: Utils.shortDate(model.date)
        }
        */

        delegate: TimelineItem {
            anchors.left: parent?parent.left:undefined
            anchors.right: parent?parent.right:undefined
            date: model.date
            //images: model.images
            //notes: model.notes
            //values: model.values
            imagesModel: model.images
            notesModel: model.notes
            valuesModel: model.values
            //
            //
            //
            /*
            Component.onCompleted: {
                itemCount++;
                console.log('timeline item created : ' + itemCount );
            }
            Component.onDestruction: {
                itemCount--;
                console.log('timeline item destroyed : ' + itemCount );
            }
            */
        }
        //
        //
        //
        section.property: "year"
        section.delegate: Text {
            height: 48
            anchors.left: parent.left
            anchors.right: parent.right
            font.weight: Font.Light
            font.family: fonts.light
            font.pixelSize: 32
            color: Colours.almostWhite
            text: section
        }
    }
    //
    //
    //
    StackView.onActivated: {
        //dailyList.forceLayout();
    }
    //
    //
    //
    Connections {
        target: dailyModel
        onUpdated : {
            console.log('dailyModel.onUpdate');
            //dailyList.forceLayout();
        }
        onDataChanged : {
            console.log('dailyModel.onDataChanged');
            //dailyList.forceLayout();
        }
    }
    property int itemCount: 0
}
