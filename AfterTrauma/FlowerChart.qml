import QtQuick 2.6
import QtQuick.Controls 2.1
import "flowerChart.js" as Flower
Canvas {
    id: control

    onPaint: {
        var ctx = getContext("2d");
        Flower.draw(ctx);
    }
    //
    //
    //
    function animate() {
        var moreFrames = Flower.update();
        control.requestPaint();
        if( moreFrames ) {
            animationHandle = requestAnimationFrame(animate);
        }
    }

    function setCurrentDate(date) {
        console.log( 'FlowerChart.setCurrentDate : ' + JSON.stringify(date) );
        if ( currentDate !== date ) {
            console.log( 'setting date' );
            currentDate = date;
            Flower.setCurrentDate(date);
            Flower.startAnimation();
            animate();
        }
    }
    //
    //
    //
    signal dateRangeChanged( var startDate, var endDate );
    //
    //
    //
    property var animationHandle: null
    property int currentDate: 0
    //
    //
    //
    Component.onCompleted: {
        generateData();
    }
    //
    //
    //
    Connections {
        target: dailyModel
        onUpdated: {
            generateData()
        }
    }
    //
    //
    //
    function generateData() {
        if ( dailyModel ) {
            var dataSet = {labels:[],data:[]};
            var n = dailyModel.count;
            for ( var i = 0; i < n; i++ ) {
                var daily = dailyModel.get(i);
                var dataPoint = [daily.date,[]];
                for ( var j = 0; j < 5; j++ ) {
                    var value = daily.values.get(j);
                    if ( i === 0 ) dataSet.labels.push( value.name );
                    dataPoint[ 1 ].push( value.value );
                }
                dataSet.data.push(dataPoint);
            }
            // TODO: got to be a better way of doing this
            Flower.setData(dataSet);
            setCurrentDate(Flower.endDate);
            control.dateRangeChanged(new Date(Flower.startDate), new Date(Flower.endDate));
        }
    }
}
