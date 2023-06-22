({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.width', component.get('v.width') ? component.get('v.width').toLowerCase() : '');

        component.set('v.dataPartion', {
            'Fna_Avatar_Image__c': 'RtlCust:Sales Support Information',
            'Fna_Avatar_Name__c': 'RtlCust:Sales Support Information',
            'Nationality__c': 'RtlCust:Customer Demographic (Medium)',
            'RTL_Marital_Details__c': 'RtlCust:Customer Demographic (High)',
            'RTL_No_of_Children__c': 'RtlCust:Customer Demographic (High)',
            'RTL_Occupation_Details__c': 'RtlCust:Customer Demographic (High)',
            'RTL_Education_Details__c': 'RtlCust:Customer Demographic (High)',
            'Business_Type_Code__c': 'ComCust:Account Information',
            'Business_Type_Description__c': 'ComCust:Account Information',
            'Payroll__c': 'RtlCust:Customer Relationship',
            'Safebox_Status__c': '',
            'RTL_Customer_Reference_Id__c': 'RtlCust:WOW Reference ID',
        });

        component.set('v.fields', [
            'Fna_Avatar_Image__c',
            'Fna_Avatar_Name__c',
            'Nationality__c',
            'RTL_Marital_Details__c',
            'RTL_Marital_Details__r.Marital_Status_Desc__c',
            'RTL_No_of_Children__c',
            'RTL_Occupation_Details__c',
            'RTL_Occupation_Details__r.RTL_Occupation_Desc__c',
            'RTL_Education_Details__c',
            'RTL_Education_Details__r.RTL_Education_Level_Desc__c',
            'Business_Type_Code__c',
            'Business_Type_Description__c',
            'Payroll__c',
            'Safebox_Status__c',
            'RTL_Customer_Reference_Id__c',
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
    }
})