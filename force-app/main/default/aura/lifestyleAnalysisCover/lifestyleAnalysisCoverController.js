({
    handleRefreshfield : function(component, event, helper) {
        var recordId = event.getParam('recordId');
        var fieldUpdate = event.getParam('fieldUpdate');
        var lifestyleAnalysisCSV = component.find('lifestyleAnalysisCSV');
        lifestyleAnalysisCSV.refreshPage(fieldUpdate);
    }
})