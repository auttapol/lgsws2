({
    selectAccount: function (component, event, helper) {
        // get the selected Account from list  
        var getSelectIndustryMaster = component.get("v.objIndustryMaster");
        // call the event   
        var compEvent = component.getEvent("oSelectedIndustryMasterEvent");
        // set the Selected Account to the event attribute.  
        compEvent.setParams({
            "IndustryMasterByEvent": getSelectIndustryMaster
        });
        // fire the event  
        compEvent.fire();
    }
})