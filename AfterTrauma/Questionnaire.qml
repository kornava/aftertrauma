import QtQuick 2.7
import QtQuick.Controls 2.1

import "controls" as AfterTrauma
import "colours.js" as Colours

AfterTrauma.Page {
    title: "MY RECOVERY"
    subtitle: questionnaires.currentItem.title || ""
    colour: Colours.blue
    //
    //
    //
    SwipeView {
        id: questionnaires
        visible: false
        //
        //
        //
        anchors.fill: parent
        //anchors.bottomMargin: 36
        //
        //
        //
        clip: true
        //
        //
        //
        currentIndex: 0
        //
        //
        //
        Repeater {
            id: questionnaireRepeater
            //
            //
            //
            model: questionnaireModel
            //
            //
            //
            delegate: Page {
                title: questionnaireModel.get(index).title
                //
                //
                //
                background: Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                }
                //
                //
                //
                ListView {
                    id: questionnaire
                    anchors.fill: parent
                    //anchors.bottomMargin: 36
                    clip: true
                    spacing: 4
                    model: questionnaireModel.get(index).questions
                    delegate: Question {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        question: formatQuestion(ListView.view.questionnaireIndex,index)
                        questionIndex: index
                        score: questionnaireModel.getScore(ListView.view.questionnaireIndex,index)
                        onScoreChanged: {
                            var category = questionnaireModel.get(ListView.view.questionnaireIndex).category;
                            console.log( 'category:' + category + ' questionnaire:' + ListView.view.questionnaireIndex + ' question:' + questionIndex + ' score:' + score);
                            questionnaireModel.putScore( category, ListView.view.questionnaireIndex, questionIndex, score );
                            recomendations.forceLayout();
                        }
                    }
                    //
                    //
                    //
                    add: Transition {
                        NumberAnimation { properties: "y"; from: questionnaire.height; duration: 250 }
                    }
                    //
                    //
                    //
                    property int questionnaireIndex: index
                }
                //
                //
                //
                property string category: questionnaireModel.get(index).category
            }
        }
        //
        //
        //
        Page {
            title: "Recomendations"
            //
            //
            //
            background: Rectangle {
                anchors.fill: parent
                color: "transparent"
            }
            //
            //
            //
            ListView {
                id: recomendations
                anchors.fill: parent
                anchors.bottomMargin: 36
                clip: true
                spacing: 8
                model: ListModel {
                }
                delegate: Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    height: recomendation.height + 16
                    Text {
                        id: recomendation
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        //
                        //
                        //
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        color: Colours.almostWhite
                        //
                        //
                        //
                        font.weight: Font.Light
                        font.family: fonts.light
                        font.pointSize: 18
                        //
                        //
                        //
                        horizontalAlignment: Text.AlignLeft
                        text: recomendationModel.getRecomendation(model.category)
                        onLinkActivated: {
                            console.log( 'link clicked : ' + link + ' : index : ' + link.indexOf('link://') );
                            if ( link.indexOf('link://') === 0 ) {
                                linkPopup.find([model.category]);
                            }
                        }
                    }
                }
                //
                //
                //
                section.property: "category"
                section.delegate: Text {
                    height: 48
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    font.weight: Font.Light
                    font.family: fonts.light
                    font.pixelSize: 32
                    color: Colours.almostWhite
                    text: section
                }
                //
                //
                //
                add: Transition {
                    NumberAnimation { properties: "y"; from: recomendations.height; duration: 250 }
                }
            }
        }
        onCurrentIndexChanged: {
            recomendations.model.clear();
            if ( currentIndex === count - 1 ) {
                [
                    { category: "emotions" },
                    { category: "confidence" },
                    { category: "body" },
                    { category: "life" },
                    { category: "relationships" }
                ].forEach( function( category ) {
                    recomendations.model.append(category);
                });
            }
        }
    }
    //
    //
    //
    footer: Item {
        height: 64
        width: parent.width
        AfterTrauma.Button {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            image: "icons/left_arrow.png"
            visible: questionnaires.currentIndex > 0
            onClicked: {
                questionnaires.decrementCurrentIndex();
            }
        }
        AfterTrauma.PageIndicator {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: questionnaires.currentIndex
            count: questionnaires.count
            colour: Colours.lightSlate
        }
        AfterTrauma.Button {
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            image: "icons/right_arrow.png"
            visible: questionnaires.currentIndex < questionnaires.count - 1
            onClicked: {
                questionnaires.incrementCurrentIndex();
            }
        }
    }
    //
    //
    //
    Component.onCompleted: {
        questionnaires.currentIndex = 0;
        questionnaires.visible = true;
    }
    //
    //
    //
    StackView.onActivated: {
        questionnaires.currentIndex = 0;
        questionnaireModel.loadScores();
    }
    StackView.onDeactivated: {
        questionnaireModel.saveScores();
        dailyModel.save();
    }
    //
    //
    //
    function formatQuestion( questionnaireIndex, questionIndex ) {
        return questionnaireModel.get( questionnaireIndex ).questions[ questionIndex ].question;
    }
}
