({
    handleRefreshfield: function (component, event, helper) {
        var recordId = event.getParam('recordId');
        var fieldUpdate = event.getParam('fieldUpdate');
        var RetailCSV = component.find('RetailCSV');
        if (RetailCSV && fieldUpdate && recordId == component.get('v.recordId')) {
            RetailCSV.refreshPage(fieldUpdate);
        }
    }
})