({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.fields', [{
                fieldName: 'Customer_Type__c',
            },
            {
                fieldName: 'RTL_Relationship_Duration_Years__c',
            },
            {
                fieldName: 'RTL_Privilege1__c',
            },
            //Jirapa.H 21-MAY BRC Requirement
            {
                fieldName: 'RTL_Most_Operating_Branch__c',
            },
            // Jirapa.H 21-MAY Enable for New CSV & Convert Lightning
            // Disabled as of 25/05/2020
            //{
                 //fieldName: 'RTL_BA_FIRST_YEAR_PREMIUM__c',
            //},

            //Jirapa.H 25-MAY BRC Requirement
            {
                fieldName: 'RTL_Number_of_Benefit__c',
                type: 'TEXTAREA2READONLY',
            },
            {
                fieldName: 'RTL_Assigned_BRC__c',
            },
            // Jirapa.H 21-MAY Enable for New CSV & Convert Lightning
            // Disabled as of 25/05/2020
            //{
                 //fieldName: 'RTL_MF_TYPE_B_BALANCE__c',
            //},
            // Jirapa.H 21-MAY Enable for New CSV & Convert Lightning
            // Disabled as of 25/05/2020
            //{
                 //fieldName: 'RTL_HL_OUTSTANDING__c',
            //},
            {
                fieldName: 'RTL_AUM__c',
            },
            {
                fieldName: 'RTL_Wealth_RM__c',
            },
            {
                fieldName: 'RTL_Benefit_Validity_Period__C',
            },
            {
                 fieldName: 'RTL_WA_Name__c',
            },
            {
                fieldName: 'RTL_Average_AUM__c',
            },
            {
                fieldName: 'RTL_Commercial_RM__c'
            },
            // Jirapa.H 21-MAY Enable for New CSV & Convert Lightning
            {
                 fieldName: 'RTL_Calculated_WB_PB_Amount__c',
            },
            {
                fieldName: '',
            }
        ]);
        component.set('v.round',0);

        helper.getDescribeFieldResult(component, event, helper);

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
})