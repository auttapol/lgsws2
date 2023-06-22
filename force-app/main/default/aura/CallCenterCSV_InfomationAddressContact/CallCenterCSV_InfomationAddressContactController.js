({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.fields', [
            'RTL_Primary_Address__c',
            'RTL_Registered_Address__c',
            'RTL_Office_Address__c',
            '',
            'RTL_Alternative_Number__c',
            'C_Home_phone_PE__c',
            'RTL_Office_Phone_Number__c',
            'Fax'
        ]);
        helper.getDescribeFieldResult(component, event, helper);

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
    recordUpdated: function (component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "CHANGED" && eventParams.changedFields) {
            Object.keys(eventParams.changedFields).forEach(function (fieldName) {
                var cmp = component.get('v.fields').find(f => f.fieldName == fieldName);
                if (cmp) {
                    cmp.value = eventParams.changedFields[fieldName].value;
                }
            });
            component.set('v.fields', component.get('v.fields'));
        }
    },
})