import QtQuick 2.7
import SodaControls 1.0

DatabaseList {
    id: model
    collection: "daily"
    roles: [ "date", "year", "month", "day", "values", "blocks" ]
    sort: { "date": -1 }
    //
    //
    //
    Component.onCompleted: {
    }

    function getDateRange() {
        var range = {
            min: Number.MAX_VALUE,
            max: Number.MIN_VALUE
        };
        for ( var i = 0; i < count; i++ ) {
            var date = get(i).date;
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

        var n = count;
        for ( var i = 0; i < n; i++ ) {
            var item = get(i);
            ////console.log( 'year:' + item.year + ' month:' + item.month + ' day:' + item.day );
            if ( item.year === year && item.month === month && item.day === day ) {
                ////console.log( 'found year:' + item.year + ' month:' + item.month + ' day:' + item.day );
                return i;
            }
        }
        ////console.log( 'unable to find year:' + year + ' month:' + month + ' day:' + day );
        return -1;
    }

    function updateDay( date, data ) {
        var query = {
            day: date.getDate(),
            month: date.getMonth(),
            year: date.getFullYear()
        };
        update( query, data );
    }

    function getDay( date, create ) {
        var query = {
            day: date.getDate(),
            month: date.getMonth(),
            year: date.getFullYear()
        };

        var day = findOne(query);
        if ( !day && create ) {
            day = createDate(date);
            //
            // interpolate values
            //
            var before = dayBefore(date.getTime());
            var after = dayAfter(date.getTime());
            if ( before || after ) {
                var values = day.values;
                if ( before && after ) {
                    //console.log( 'Daily.getDay : interpolating between : ' + JSON.stringify(before) + ' and ' + JSON.stringify(after) );
                    for ( var i = 0; i < values.length; i++ ) {
                        values[ i ].value = ( before.values[ i ].value + after.values[ i ].value ) / 2.;
                    }
                } else if ( before ) {
                    //console.log( 'Daily.getDay : setting values to previous : ' + JSON.stringify(before) );
                    values = before.values;
                } else if ( after ) {
                    //console.log( 'Daily.getDay : setting values to next : ' + JSON.stringify(after) );
                    values = after.values;
                }
                update({date: day.date},{values: values});
                save();
            }
        }

        return day;
    }
    function getToday() {
        var today = new Date();
        var day = getDay( today );
        return day || createToday();
    }
    function createToday() {
        //console.log( 'Daily.createToday')
        var today = new Date();
        return createDate(today);
    }
    function createDate(date) {
        date.setHours(0,0,0);
        var daily = {
            date: date.getTime(),
            year: date.getFullYear(),
            month: date.getMonth(), // 0 - 11
            day: date.getDate(), // 1 - 31
            values: [
                { label: 'emotions', value: 0. },
                { label: 'confidence', value: 0. },
                { label: 'body', value: 0. },
                { label: 'life', value: 0. },
                { label: 'relationships', value: 0. },
            ],
            blocks: []
        }
        add(daily);
        save();
        return daily;
    }
    //
    //
    //
    function indexOf( date ) {
        return 0;
    }
    function indexOfFirstDayBefore( d ) {
        var date = d.getTime();
        for ( var i = 0; i < count; i++ ) {
            var day = get(i);
            if ( day.date < date ) {
                return Math.min( i, count - 1);
            }
        }
        return count - 1;
    }
    function indexOfFirstDayAfter( d ) {
        var date = d.getTime();
        for ( var i = count - 1; i >= 0; i-- ) {
            var day = get(i);
            if ( day.date > date ) {
                return Math.max( i, 0);
            }
        }
        return 0;
    }
    //
    //
    //
    function dayBefore( date ) {
        for ( var i = 0; i < count; i++ ) {
            var day = get(i);
            //if ( day.date <= date ) return day;
            if ( day.date < date ) return day;
        }
        return undefined;
    }
    function dayAfter( date ) {
        for ( var i = count - 1; i >= 0; i-- ) {
            var day = get(i);
            if ( day.date >= date ) return day;
            //if ( day.date > date ) return day;
        }
        return undefined;
    }
    function valuesForDate( date ) {
        var before = dayBefore( date );
        var after = dayAfter( date );
        var values = [];
        var i;
        if ( before && after ) {
            if ( before.date === date ) {
                for ( i = 0; i < 5; i++ ) {
                    values.push(before.values[ i ].value);
                }
            } else if ( after.date === date ) {
                for ( i = 0; i < 5; i++ ) {
                    values.push(after.values[ i ].value);
                }
            } else {
                var range = after.date - before.date;
                var position = date - before.date;
                var interpolation = position / range;
                for ( i = 0; i < 5; i++ ) {
                    var value = before.values[ i ].value + ( ( after.values[ i ].value - before.values[ i ].value ) * interpolation );
                    values.push(value);
                }
            }
            return values;
        } else if ( before ) {
            for ( i = 0; i < 5; i++ ) {
                values.push(before.values[ i ].value);
            }
            return values;
        } else if ( after ) {
            for ( i = 0; i < 5; i++ ) {
                values.push(after.values[ i ].value);
            }
            return values;
        } else {
            //console.log( 'Daily.valuesForDate(' + date + ') not found')
        }

        return [ 0., 0., 0., 0., 0.]
    }
    function startValues() {
        var first = get(0);
        var last = get(count-1);
        //console.log( 'f : ' + first.date );
        //console.log( 'l : ' + last.date );
    }
    function dateRange() {

        return count > 0 ? { min: get(count-1).date, max: get(0).date } : { min: Date.now(), max: Date.now() };
    }
    function blocksForDate( date ) {
        var query = { date: date };
        var day = findOne( query );
        if ( day && day.blocks ) {
            return day.blocks;
        }
        return [];
    }
    //
    //
    //
    function addChallenge( date, challenge ) {
        var query = {
            day: date.getDate(),
            month: date.getMonth(),
            year: date.getFullYear()
        };
        var day = findOne( query ) || createDate( date );
        if ( !day.challenges ) {
            day.challenges = [];
        }
        var done = false;
        for ( var i = 0; i < day.challenges.length; i++ ) {
            if ( day.challenges[ i ]._id === challenge._id ) {
                done = true;
                break;
            }
        }
        if ( !done ) {
            day.challenges.push( challenge );
            update(query,{challenges:day.challenges});
        }
        save();
    }
    function removeChallenge( date, challenge ) {
        var query = {
            day: date.getDate(),
            month: date.getMonth(),
            year: date.getFullYear()
        };
        var day = findOne( query );
        if ( day && day.challenges ) {
            var done = false;
            for ( var i = 0; i < day.challenges.length; i++ ) {
                if ( day.challenges[ i ]._id === challenge._id ) {
                    day.challenges.splice(i,1);
                    update(query,{challenges:day.challenges});
                    break;
                }
            }
        }
        save();
    }
    function dayHasChallenge( date ) {
        var query = {
            day: date.getDate(),
            month: date.getMonth(),
            year: date.getFullYear()
        };
        var day = findOne( query );
        //console.log( "dayHasChallenge: " + JSON.stringify(day) );
        return ( day && day.challenges !== undefined && day.challenges.length > 0 );
    }
    //
    //
    //
    function minimumDate() {
        if ( count === 0 ) {
            return new Date();
        }
        var day = get(count-1);
        return new Date(day.date)
    }
    function maximumDate() {
        if ( count === 0 ) {
            return new Date();
        }
        var day = get(0);
        return new Date(day.date)
    }
    function generateTestData() {
        //
        // generate test data if database is empty
        //
        //console.log( 'generating daily test data');
        var images = [
                    "lotus-1205631_640.jpg",
                    "emotions.cominghomefromhospital.image2.png",
                    "Foot pumps copy.jpg",
                    "Physio with patient touching knee wide 1.jpg",
                    "relaxing.jpg"
                ];
        dailyModel.clear();
        var week = 1000 * 60 * 60 * 24 * 7;
        beginBatch();
        for ( var i = 0; i < 52; i++ ) {
            var day = new Date(Date.now()-(week*i));
            day.setHours(0,0,0);
            var multiplier = ( ( 51 - i ) + 1 ) / 52.;
            var daily = {
                date: day.getTime(),
                year: day.getFullYear(),
                month: day.getMonth(), // 0 - 11
                day: day.getDate(), // 1 - 31
                values: [
                    { label: 'emotions', value: Math.random() * multiplier },
                    { label: 'confidence', value: Math.random() * multiplier },
                    { label: 'body', value: Math.random() * multiplier },
                    { label: 'life', value: Math.random() * multiplier },
                    { label: 'relationships', value: Math.random() * multiplier },
                ],
                blocks: []
            }
            if ( i > 0 ) {
                var nBlocks = Math.random() * 8;
                for ( var j  = 0; j < nBlocks; j++ ) {
                    if ( j % 2 ) {
                        daily.blocks.push(
                                    {
                                        type: "text",
                                        title: "test note " + i + "." + j,
                                        content: "test note " + i + "." + j,
                                        tags: []
                                    } );
                    } else {
                        var imageIndex = Math.floor((Math.random()*100) % images.length );
                        daily.blocks.push(
                                    {
                                        type: "image",
                                        title: "test image " + i + "." + j,
                                        content: images[ imageIndex ],
                                        tags: []
                                    } );

                    }
                }
            }
            batchAdd(daily);
        }
        endBatch();
        save();
        //
        //
        //
        globalMinimumDate = dailyModel.minimumDate();
        globalMaximumDate = dailyModel.maximumDate();
        flowerChart.update();
        if ( questionnaireModel.dailyCompleted() && flowerChartAnimator.running ) flowerChartAnimator.stop()
    }
}
