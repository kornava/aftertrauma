import QtQuick 2.7
import SodaControls 1.0

DatabaseList {
    id: model
    collection: "daily"
    roles: [ "date", "year", "month", "day", "values", "notes", "images" ]
    //
    //
    //
    Component.onCompleted: {
        if ( count <= 0 ) {
            //
            // generate test data if database is empty
            //
            var week = 1000 * 60 * 60 * 24 * 7;
            for ( var i = 0; i < 52; i++ ) {
                var day = new Date(Date.now()-(week*i));
                var multiplier = ( ( 51 - i ) + 1 ) / 52.;
                var daily = {
                    date: day.getTime(),
                    year: day.getFullYear(),
                    month: day.getMonth(), // 0 - 11
                    day: day.getDate(), // 1 - 31
                    values: [
                        { label: 'emotions', value: Math.random() * multiplier },
                        { label: 'mind', value: Math.random() * multiplier },
                        { label: 'body', value: Math.random() * multiplier },
                        { label: 'life', value: Math.random() * multiplier },
                        { label: 'relationships', value: Math.random() * multiplier },
                    ],
                    notes: [],
                    images: []
                }
                if ( i > 0 ) {
                    var nImages = Math.random() * 4;
                    for ( var j = 0; j < nImages; j++ ) {
                        daily.images.push( { image: "icons/image.png" });
                    }
                    var nNotes = Math.random() * 4;
                    for ( j = 0; j < nNotes; j++ ) {
                        daily.notes.push( {title:"",note:""} );
                    }
                }
                add(daily);
            }
            save();
        }
    }
    function getDateRange() {
        var range = {
            min: Number.MAX_VALUE,
            max: Number.MIN_VALUE
        };
        for ( var i = 0; i < model.count; i++ ) {
            var date = model.get(i).date;
            if ( date < range.min ) range.min = date;
            if ( date > range.max ) range.max = date;
        }
        return range;
    }
    //
    //
    //
    function getDayIndex( date ) {
        var day = date.getDate();
        var month = date.getMonth();
        var year = date.getFullYear();

        var n = model.count;
        for ( var i = 0; i < n; i++ ) {
            var item = model.get(i);
            //console.log( 'year:' + item.year + ' month:' + item.month + ' day:' + item.day );
            if ( item.year === year && item.month === month && item.day === day ) {
                //console.log( 'found year:' + item.year + ' month:' + item.month + ' day:' + item.day );
                return i;
            }
        }
        //console.log( 'unable to find year:' + year + ' month:' + month + ' day:' + day );
        return -1;
    }
    function getDay( date ) {
        var query = {
            day: date.getDate(),
            month: date.getMonth(),
            year: date.getFullYear()
        }
        var finds = model.find(query);
        return finds.length > 0 ? finds[ 0 ] : undefined
    }
    function getToday() {
        var today = new Date();
        var day = getDay( today );
        return day || createToday();
    }
    function createToday() {
        console.log( 'Daily.createToday')
        var today = new Date();
        var daily = {
            date: today.getTime(),
            year: today.getFullYear(),
            month: today.getMonth(), // 0 - 11
            day: today.getDate(), // 1 - 31
            values: [
                { label: 'emotions', value: 0. },
                { label: 'mind', value: 0. },
                { label: 'body', value: 0. },
                { label: 'life', value: 0. },
                { label: 'relationships', value: 0. },
            ],
            notes: [],
            images: []
        }
        return model.add(daily);
    }
}
