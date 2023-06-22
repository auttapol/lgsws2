({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.width', component.get('v.width') ? component.get('v.width').toLowerCase() : '');

        component.set('v.dataPartion', {
            'RTL_Credit_Card_History__c': 'RtlCust:Sales Support Information',
            'RTL_Personal_Loan_History__c': 'RtlCust:Sales Support Information',
            'RTL_Entitled_Privilege2__c': 'RtlCust:MI Benefits',
            'RTL_Privilege2__c': 'RtlCust:MI Benefits',
            'RTL_Lifetime_Code__c': 'RtlCust:Sales Support Information',
            'KYC__c' : 'RtlCust:Sales Support Information',
            'RTL_Lifetime_link__c': 'RtlCust:Sales Support Information',
            'KYC_CCI1_Completed__c': 'RtlCust:Sales Support Information',
            'Consolidate_Status__c': 'RtlCust:Sales Support Information',
            'RTL_CC_STMT_status__c': 'RtlCust:Sales Support Information',
            'RTL_RDC_STMT_status__c': 'RtlCust:Sales Support Information',
            'RTL_C2G_STMT_status__c': 'RtlCust:Sales Support Information',
            'Fna_Product_Interested__c': 'RtlCust:Sales Support Information',
            'Fna_Product_Holding__c': 'RtlCust:Sales Support Information',
            'RTL_4THANA_Info__c': 'RtlCust:Sales Support Information',
            'RTL_4THANA_Fund_AMT__c': 'RtlCust:Sales Support Information',
            'RTL_4THANA_Aggregate_Bond_AMT__c': 'RtlCust:Sales Support Information',
            'RTL_4THANA_Bond_AMT__c': 'RtlCust:Sales Support Information',
            'RTL_4THANA_Short_Bond_AMT__c': 'RtlCust:Sales Support Information',
            'RTL_4THANA_Total_AMT__c': 'RtlCust:Sales Support Information',
            'RTL_OnSite_Service__c': 'RtlCust:Sales Support Information',
            'RTL_OnSite_Service_Update_Date__c': 'RtlCust:Sales Support Information',

            'regisStateTable': 'RtlCust:Sales Support Information',
            'e_statement': 'RtlCust:Sales Support Information',
            'CYC_Campaign_PromoCond_api' : 'RtlCust:MI Benefits'

        });

        component.set('v.fields', [
            'TMB_Customer_ID_PE__c',
            'KYC__c',
            'KYC_CCI1_Completed__c',
            'RTL_Lifetime_Code__c',
            'RTL_Lifetime_link__c',
            'RTL_Credit_Card_History__c',
            'RTL_Personal_Loan_History__c',
            'RTL_4THANA_Info__c',
            'RTL_4THANA_Fund_AMT__c',
            'RTL_4THANA_Aggregate_Bond_AMT__c',
            'RTL_4THANA_Bond_AMT__c',
            'RTL_4THANA_Short_Bond_AMT__c',
            'RTL_4THANA_Total_AMT__c',
            'RTL_Entitled_Privilege2__c',
            'RTL_Privilege2__c',
            'Consolidate_Status__c',
            'RTL_CC_STMT_status__c',
            'RTL_RDC_STMT_status__c',
            'RTL_C2G_STMT_status__c',
            'Fna_Product_Interested__c',
            'Fna_Product_Holding__c',
            'RTL_OnSite_Service__c',
            'RTL_OnSite_Service_Update_Date__c',
            'RTL_OnSite_Service_User_Update__c',
            'Name',
            'Core_Banking_Suggested_Segment__c'
        ].map(m => {
            return {
                'fieldName': m
            };
        }));

      
        helper.getProfileName(component, event, helper);
        
       
    },
    handleProfileName: function (component, event, helper) {
        helper.runInitialize(component, event, helper);
    },
    handleRefreshfield: function (component, event, helper) {
        var params = event.getParams();
        // var translateFields = component.get(`v.fields_translate`);
        if (params.isRefresh) {
            Object.keys(params.fieldUpdate).forEach(e => {
                if (component.get(`v.dataFields.${e}`)) {
                    component.set(`v.dataFields.${e}.value`, params.fieldUpdate[e]);
                }
                // if (translateFields.includes(e)) {
                //     helper.runInitialize(component, event, helper);
                // }
            });
        }  
    }
})