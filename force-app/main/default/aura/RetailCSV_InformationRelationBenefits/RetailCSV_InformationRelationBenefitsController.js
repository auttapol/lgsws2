({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.width', component.get('v.width') ? component.get('v.width').toLowerCase() : '');

        component.set('v.dataPartion', {
            // 'RTL_Benefit_Status__c': '',
            'RTL_Privilege1__c': 'RtlCust:Customer Relationship',
            'RTL_SBO_FLAG__c': 'RtlCust:Customer Relationship',
            'RTL_Number_of_Benefit__c': 'RtlCust:Customer Relationship',
            'RTL_Benefit_Validity_Period__c': 'RtlCust:Customer Product Holding (High)',
            'RTL_Average_AUM__c': 'RtlCust:Customer Product Holding (High)',
            'RTL_Calculated_WB_PB_Amount__c': 'RtlCust:Customer Product Holding (High)',
            'RTL_BA_FIRST_YEAR_PREMIUM__c': 'RtlCust:Customer Product Holding (High)',
            'RTL_MF_TYPE_B_BALANCE__c': 'RtlCust:Customer Product Holding (High)',
            'RTL_HL_OUTSTANDING__c': 'RtlCust:Customer Product Holding (High)',
            'RTL_Relationship_Duration_Years__c': 'RtlCust:Customer Relationship Duration',
        });

        component.set('v.fields', [
            'RTL_Benefit_Status__c',
            'RTL_Privilege1__c',
            'RTL_SBO_FLAG__c',
            'RTL_EXIST_NONJU_FLAG__c',
            'RTL_Number_of_Benefit__c',
            'RTL_Benefit_Validity_Period__c',
            'RTL_Average_AUM__c',
            'RTL_Calculated_WB_PB_Amount__c',
            'RTL_BA_FIRST_YEAR_PREMIUM__c',
            'RTL_MF_TYPE_B_BALANCE__c',
            'RTL_HL_OUTSTANDING__c',
            'RTL_Relationship_Duration_Years__c',
        ].map(m => {
            return {
                'fieldName': m
            };
        }));

        // get profile name first
        helper.getProfileName(component, event, helper);

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
    handleProfileName: function (component, event, helper) {
        helper.runInitialize(component, event, helper);
    }
})