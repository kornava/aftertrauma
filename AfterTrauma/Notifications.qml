import QtQuick 2.6

ListModel {
    id: model

    Component.onCompleted: {
        console.log( 'Notifications : starting update timer' );
        notificationTimer.start();
    }
    //
    //
    //
    signal updated()
    //
    //
    //
    function update() {
        if(!questionnaireModel.dailyCompleted()) {
            if ( !findNotification("questionnaire") ) {
                console.log( 'Notifications : adding questionnaire prompt' );
                append({subject:"questionnaire", text:"don't forget to complete your daily questionnaire"});
                updated();
            }
        } else {
            removeNotification("questionnaire");
            updated();
        }
    }
    function findNotification( subject ) {
        var nNotifications = model.count;
        for ( var i = 0; i < nNotifications; i++ ) {
            var notification = get(i);
            if ( notification.subject === subject ) {
                return notification;
            }
        }
        return undefined;
    }
    function removeNotification( subject ) {
        var nNotifications = model.count;
        for ( var i = 0; i < nNotifications; i++ ) {
            var notification = get(i);
            if ( notification.subject === subject ) {
                model.remove(i);
                return;
            }
        }
    }

}
