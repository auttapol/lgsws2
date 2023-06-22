({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
      
        component.set('v.allField', [
            'Fna_Avatar_Name__c',
            'Fna_Product_Interested__c',
            'Fna_Product_Holding__c',
            'RTL_Occupation_Details__c',
            'RTL_Income_Conditional__c',
            'Nationality__c',
            'RTL_Age__c',
            'RTL_Is_Employee__c',
            'RTL_Primary_Banking_All_Free_Benefit__c',
            'RTL_Most_Visited_Branch__c',
            'RTL_Fund_Risk_Mismatch__c',
            'RTL_Risk_Level_Details__c',
            'RTL_Suitability__c',
            'RTL_Fund_High_Concentration_Risk__c',
            'RTL_Occupation_Details__r.RTL_Occupation_Desc__c',
            'Consolidate_Status__c',
            'RTL_CC_STMT_status__c', 
            'RTL_RDC_STMT_status__c',
            'RTL_C2G_STMT_status__c',
            'TMB_Customer_ID_PE__c',
            'RTL_4THANA_Info__c',
            'RTL_4THANA_Fund_AMT__c',
            'RTL_4THANA_Aggregate_Bond_AMT__c',
            'RTL_4THANA_Bond_AMT__c',
            'RTL_4THANA_Short_Bond_AMT__c',
            'RTL_4THANA_Total_AMT__c',
            'RTL_OnSite_Service__c',
            'RTL_OnSite_Service_Update_Date__c',
            'RTL_Main_Bank_Desc__c',
            'RTL_OnSite_Service_User_Update__c',
            'RTL_Credit_Card_History__c',
            'RTL_Personal_Loan_History__c',
            'RTL_Entitled_Privilege2__c',
            'RTL_4THANA_Info__c',
            'RTL_Privilege2__c',
        ].map(m=> {
            return {
                'fieldName': m
            };
        }));
        component.set('v.messageAreaField',$A.get('$Label.c.RTL_Messenger_Area'));
        component.set('v.instantLendingField',$A.get('$Label.c.Instant_Lending'));
        component.set('v.campaignPromoField',$A.get('$Label.c.cyc_promo_cond'));


        // E_Statement
        component.set('v.eStatement.columns', [{
                label: 'Consolidate',
                fieldName: 'Consolidate',
                type: 'boolean'
            },
            {
                label: 'Credit Card',
                fieldName: 'CreditCard',
                type: 'boolean'
            },
            {
                label: 'RDC',
                fieldName: 'RDC',
                type: 'boolean'
            },
            {
                label: 'C2G',
                fieldName: 'C2G',
                type: 'boolean'
            },
        ]);
        component.set('v.eStatement.data', [{
            'Consolidate': false,
            'CreditCard': false,
            'RDC': false,
            'C2G': false,
        }]);

        // Touch/IB/Prompt Pay Status
        component.set('v.payStatus.columns', [{
                label: 'TMB Touch',
                fieldName: 'TMBTouch',
                type: 'boolean'
            },
            {
                label: 'Internet Banking',
                fieldName: 'InternetBanking',
                type: 'boolean'
            },
            {
                label: 'Prompt Pay',
                fieldName: 'PromptPay',
                type: 'boolean'
            },
        ]);
        component.set('v.payStatus.data', [{
            'TMBTouch': false,
            'InternetBanking': false,
            'PromptPay': false,
        }]);

        component.set('v.customColorField', {
            'RTL_Risk_Level_Details__c': {
                condition: 'equalIn',
                value: ['AC – ลูกค้าปกติ', 'A2 – ลูกค้าเสี่ยงระดับ 2'],
            }
        });
        // helper.getDescribeFieldResult(component, event, helper);
        helper.getDescribeFieldResults(component, event, helper);
        helper.CYCPrepareDataCustomer(component,event,helper);
        helper.getInstantLendingDetail(component,event,helper);
        // fire event get CVSAnalyticsData
        // $A.get("e.c:CVSAnalyticsData_Event").setParams({
        //     "isRequest": true
        // }).fire();

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
    // handleCVSAnalyticsDataEvent: function (component, event, helper) {
    //     if (event.getParam("CVSAnalyticsData"))
    //         component.set('v.CVSAnalyticsData', event.getParam("CVSAnalyticsData"))
    // },
    // onchangeCVSAnalyticsData: function (component, event, helper) {
    //     helper.generateCVSAnalyticsData(component, component.get('v.CVSAnalyticsData'));
    // },
})