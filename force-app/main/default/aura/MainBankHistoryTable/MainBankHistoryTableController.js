({
    doInit: function (component, event, helper) {
        var action = component.get("c.getMainBankLabels");
        action.setCallback(this, function (response) {
            component.set('v.fieldLabelsMap',response.getReturnValue());
            var fieldWithLabelsMap = component.get('v.fieldLabelsMap')
            component.set('v.columns', [
                { label: fieldWithLabelsMap['main_bank_status__c'] , fieldName: 'Main_Bank_Status__c', type: 'text',hideDefaultActions: true},
                { label: fieldWithLabelsMap['calculation_date__c'], fieldName: 'Calculation_Date__c', type: 'date',hideDefaultActions: true,typeAttributes: {day: "numeric",month: "numeric",year: "numeric"}},
                { label: fieldWithLabelsMap['description__c'], fieldName: 'Description__c', type: 'text',hideDefaultActions: true,wrapText:true,initialWidth:200},
            ]);
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.getMainBankHistoryList");
        var accId = component.get("v.recordId");
        action.setParams({
            recordId: accId
        });
        action.setCallback(this, function (response) {
            var returnedList = response.getReturnValue();
            if ( returnedList == null) {
                component.set("v.permission_no", true);
            } else if (returnedList.length == 0) {
                component.set("v.blankList", true);
            } else {
                component.set("v.mainBankList", returnedList);
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
})