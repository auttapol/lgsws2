({
    convertListToCSV : function(component, sObjectList){
        if (sObjectList == null || sObjectList.length == 0) {
            return null; // 
        }

        // CSV file parameters.
        var columnEnd = ',';
        var lineEnd =  '\n';

        // Get the CSV header from the list.
        var keys = new Set();
        sObjectList.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                keys.add(key);
            });
        });

        // 
        keys = Array.from(keys);

        var csvString = '';
        csvString += keys.join(columnEnd);
        csvString += lineEnd;

        for(var i=0; i < sObjectList.length; i++){
            var counter = 0;

            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;

                // add , after every value except the first.
                if(counter > 0){
                    csvString += columnEnd;
                }

                // If the column is undefined, leave it as blank in the CSV file.
                var value = sObjectList[i][skey] === undefined ? '' : sObjectList[i][skey];
                csvString += '"'+ value +'"';
                counter++;
            }

            csvString += lineEnd;
        }

        return csvString;
    },
})