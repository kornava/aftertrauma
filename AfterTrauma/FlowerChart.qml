import QtQuick 2.6
import QtQuick.Controls 2.1
import "flowerChart.js" as Flower
Canvas {
    id: control
    //
    //
    //
    //renderStrategy: Canvas.Threaded
    //renderTarget: Canvas.FramebufferObject
    //
    //
    //
    onPaint: {
        var ctx = getContext("2d");
        Flower.draw(ctx,stack.depth===1);
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

    function getStartDate() {
        return new Date( Flower.startDate );
    }
    function getEndDate() {
        return new Date( Flower.endDate );
    }

    function getCurrentDate() {
        return new Date( currentDate );
    }

    function setCurrentDate(date) {
        if ( currentDate !== date ) {
            console.log( 'FlowerChart.setCurrentDate : ' + date );
            currentDate = date;
            Flower.setCurrentDate(date);
            Flower.startAnimation();
            animate();
            dateChanged(new Date(date));
        }
    }
    //
    //
    //
    signal dateRangeChanged( var startDate, var endDate );
    signal dateChanged( var date );
    //
    //
    //
    property var animationHandle: null
    property var currentDate: 0
    //
    //
    //
    Component.onCompleted: {
        generateData();
        setCurrentDate(Flower.endDate);
        requestPaint();
    }
    //
    //
    //
    Connections {
        target: testDailyModel
        onDataChanged: {
            console.log( 'FlowerChart dataChanged : currentDate : ' + currentDate );
            generateData();
            Flower.setCurrentDate(currentDate);
            Flower.startAnimation();
            animate();
            requestPaint();
        }
    }
    Connections {
        target: stack
        onDepthChanged: {
            if ( stack.depth <= 1 ) {
                requestPaint();
            }
        }
    }
    //
    //
    //
    function generateData() {
        if( testDailyModel ) {
            var dataSet = {labels:[],data:[]};
            var n = testDailyModel.count;
            for ( var i = 0; i < n; i++ ) {
                var daily = testDailyModel.get(i);
                var dataPoint = [daily.date,[]];
                for ( var j = 0; j < 5; j++ ) {
                    var value = daily.values[j];
                    if ( i === 0 ) {
                        dataSet.labels.push( value.label );
                    }
                    dataPoint[ 1 ].push( value.value );
                }
                dataSet.data.push(dataPoint);
            }
            // TODO: got to be a better way of doing this
            Flower.setData(dataSet);
            //control.dateRangeChanged(new Date(Flower.startDate), new Date(Flower.endDate));
        }
    }

}
