({
    downloadCsv : function(component, event, helper){
        var recordsList = component.get("v.records");

        // call the helper function which returns the CSV data as a String
        var csv = helper.convertListToCSV(component, recordsList);
        if (csv == null){return;}

        // Create a temporal <a> html tag to download the CSV file
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';
        hiddenElement.download = component.get("v.fileName");
        document.body.appendChild(hiddenElement); //Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
})