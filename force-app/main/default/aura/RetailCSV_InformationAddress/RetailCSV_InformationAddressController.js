({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.width', component.get('v.width') ? component.get('v.width').toLowerCase() : '');

        component.set('v.dataPartion', {
            'Primary_Address_Line_1_PE__c': 'RtlCust:Address Information',
            'Office_Address_Line_1_PE__c': 'RtlCust:Address Information',
            'Registered_Address_Line_1_PE__c': 'RtlCust:Address Information',
            'RTL_Preferred_Contact_Channel__c': 'RtlCust:Contact Number and Email Address',
            'Mobile_Number_PE__c': 'RtlCust:Contact Number and Email Address',
            'C_Home_phone_PE__c': 'RtlCust:Contact Number and Email Address',
            'RTL_Office_Phone_Number__c': 'RtlCust:Contact Number and Email Address',
            'RTL_Alternative_Number__c': 'RtlCust:Contact Number and Email Address',
            'Fax': 'RtlCust:Contact Number and Email Address',
        });
        component.set('v.fields_translate', ['RTL_Preferred_Contact_Channel__c']);
        component.set('v.fields', [
            'Primary_Address_Line_1_PE__c',
            'Primary_Address_Line_2_PE__c',
            'Primary_Address_Line_3_PE__c',
            'Province_Primary_PE__c',
            'Zip_Code_Primary_PE__c',
            'RTL_Office_Address__c',
            'Office_Address_Line_1_PE__c',
            'Office_Address_Line_2_PE__c',
            'Office_Address_Line_3_PE__c',
            'Province_Office_PE__c',
            'Zip_Code_Office_PE__c',
            'RTL_Registered_Address__c',
            'Registered_Address_Line_1_PE__c',
            'Registered_Address_Line_2_PE__c',
            'Registered_Address_Line_3_PE__c',
            'Province_Registered_PE__c',
            'Zip_Code_Registered_PE__c',
            'RTL_Preferred_Contact_Channel__c',
            'Mobile_Number_PE__c',
            'C_Home_phone_PE__c',
            'RTL_Office_Phone_Number__c',
            'RTL_Alternative_Number__c',
            'Fax',
        ].map(m => {
            return {
                'fieldName': m
            };
        }));

        // get profile name first
        helper.getProfileName(component);
        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
    handleProfileName: function (component, event, helper) {
        helper.runInitialize(component, event, helper);
    },
    handleRefreshfield: function (component, event, helper) {
        var params = event.getParams();
        var translateFields = component.get(`v.fields_translate`);
        if (params.isRefresh) {
            Object.keys(params.fieldUpdate).forEach(e => {
                if (component.get(`v.dataFields.${e}`)) {
                    component.set(`v.dataFields.${e}.value`, params.fieldUpdate[e]);
                }
                if (translateFields.includes(e)) {
                    helper.runInitialize(component, event, helper);
                }
            });
        }  
    }
})