({
    onPageReferenceChange: function(component, evt, helper) {
       helper.getData(component, helper);
    },

    onRecordUpdate: function(component, event, helper) {
        var shortid = component.get('v.data[0].Customer__r.TMB_Customer_ID_PE__c') != null ?(component.get('v.data[0].Customer__r.TMB_Customer_ID_PE__c').substring(4)).replace(/^0+/, '') : '';
        if(component.get('v.shortid') == '') component.set('v.shortid', shortid);
    }
})