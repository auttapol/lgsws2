({
    onInit: function (component, event, helper) {
        component.set('v.subDebtLabel',$A.get("$Label.c.Sub_Debt_Transaction_Flag") );
        // component.set('v.touchLabel',$A.get("$Label.c.Sub_Debt_Transaction_Flag") );

        helper.startSpinner(component);
        // component.set('v.fields', [{
        //         fieldName: 'RTL_Customer_Name_TH__c',
        //         class: 'blueColor',
        //     },
        //     {
        //         fieldName: 'Customer_Name_PE_Eng__c',              
        //     },
        //     {
        //         fieldName: 'RTL_Gender_View__c',
        //     },
        //     {
        //         fieldName: 'ID_Type_PE__c',
                
        //     },
        //     {
        //         fieldName: 'NID__c',
        //     },
        //     {
        //         fieldName: 'RTL_CitizenID_Expiration_Date__c',

        //     },
        //     {
        //         fieldName: 'RTL_Date_Of_Birth__c',
        //         class: 'blueColor',
        //     },
        //     {
        //         fieldName: 'RTL_Birthday__c',
        //     },
        //     {
        //         fieldName: 'RTL_Zodiac__c', 
        //         class: 'blueColor',               
        //     },
        //     {
        //         fieldName: 'Mobile_Number_PE__c',
        //         class: 'blueColor',
        //     },
        //     {
        //         fieldName: 'Email_Address_PE__c',
        //         class: 'blueColor',
        //     },
        //     {
        //         fieldName: 'FATCA__c',
        //     },
        //     {
        //         fieldName: 'Account_Type__c',
        //     },
        //     {
        //         fieldName: 'Core_Banking_Suggested_Segment__c',
        //         //class: 'blueColor',
        //     },
        //     {
        //         fieldName: 'Market_Consent__c',
        //     },
        //     {
        //         fieldName: 'RTL_Average_AUM__c',
        //         // isAccessible: false,
        //     },
        //     // [2020-06-19] Add SBO flag
        //     {
        //         fieldName: 'RTL_SBO_FLAG__c',
        //     },
        //     {
        //         id: 'rtl_AUM',
        //         fieldName: 'RTL_AUM__c',
        //         // isAccessible: true,
        //     },
        //     {
        //         fieldName: 'RTL_Wealth_RM__c',
        //         class: 'blueColor',
        //     },
        //     {
        //         fieldName: 'TMB_Customer_ID_PE__c',
        //     },
        //     {
        //         fieldName: 'RTL_Customer_Reference_Id__c',
        //     },
        //     {
        //         fieldName: 'RTL_Privilege1__c',
        //         // isAccessible: true,
        //     },
        //     {
        //         fieldName: 'Payroll__c',
        //     },
        //     {
        //         fieldName: 'IAL__c',
        //     },
        //     {
        //         fieldName: 'RTL_Do_Not_Contact__c',
        //     },
        //     {
        //         fieldName: 'KYC_Update__c',
        //     },
        //     {
        //         fieldName: 'E_KYC__c',
        //     },          
        //     {
        //         name: 'ttb touch',
        //         label: 'ttb touch',
        //         fieldName: '',
        //         type: 'STRING',
        //         value_addon: ''
        //     },
        //     {
        //         fieldName: 'KYC_flag__c',
        //     },
        //     {
        //         fieldName: 'Action_box__c',
        //     },  
        //     {
        //         name: 'PDPA',
        //         label: 'PDPA',
        //         fieldName: '',
        //         type: 'STRING',
        //         value_addon: ''
        //     },
        //     {
        //         name: 'Market Conduct',
        //         label: 'Market Conduct',
        //         fieldName: '',
        //         type: 'STRING',
        //         value_addon: ''
        //     },
        //     {
        //         name: 'Sub Debt Flag',
        //         label: $A.get("$Label.c.Sub_Debt_Transaction_Flag"),
        //         fieldName: '',
        //         type: 'STRING',
        //         value_addon: ''
        //     },
        // ]);

        component.set('v.allField', [
            'RTL_Customer_Name_TH__c',
            'Customer_Name_PE_Eng__c',
            'RTL_Gender_View__c',
            'ID_Type_PE__c',
            'NID__c',
            'RTL_CitizenID_Expiration_Date__c',
            'RTL_Date_Of_Birth__c',
            'RTL_Birthday__c',
            'RTL_Zodiac__c',
            'Mobile_Number_PE__c',
            'Email_Address_PE__c',
            'FATCA__c',
            'Account_Type__c',
            'Core_Banking_Suggested_Segment__c',
            'Market_Consent__c',
            'RTL_Average_AUM__c',            
            'RTL_SBO_FLAG__c',
            'VIP_Status__c',
            'RTL_Wealth_RM__c',
            'TMB_Customer_ID_PE__c',
            'RTL_AUM__c',
            'RTL_Privilege1__c',
            'Payroll__c',
            'RTL_Customer_Reference_Id__c',
            'RTL_Do_Not_Contact__c',
            'KYC_Update__c',
            'IAL__c',
            'KYC_flag__c',
            'E_KYC__c',
            'Action_box__c',
            'Sub_segment__c',
            'RTL_AUM_Last_Calculated_Date__c',
            'RTL_EXIST_NONJU_FLAG__c',
            'RTL_Check_WM_RM_as_PWA__c',
            'Wealth_RM_EMP_Code__c',
            'RTL_Benefit_Status__c',
            'Segment_crm__c'
        ].map(m=> {
            return {
                'fieldName': m
            };
        }));

       
        component.set('v.numberOfRetry',$A.get("$Label.c.Number_Of_Retry_Times"));
        component.set('v.retrySetTimeOut',$A.get("$Label.c.Retry_SetTimeOut"));
        component.set('v.round',0);


        // Add field to query account
        helper.getDescribeFieldResult(component, event, helper);

        // Dynamic custom color field to be green or red
        // if equal value to be ture(green) or not(red)
        component.set('v.customColorField', {
            'FATCA__c': {
                condition: 'equal',
                value: 'ทำ FATCA (complete)',
            }
        });

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
    onHandlerAccount: function (component, event, helper) {
        // console.log(helper.parseObj(component.get('v.account')));
    },
    // fireCVSAnalyticsData: function (component, event, helper) {
    //     if(event.getParam('isRequest')){
    //         $A.get("e.c:CVSAnalyticsData_Event").setParams({
    //             "CVSAnalyticsData": component.get('v.CVSAnalyticsData')
    //         }).fire();
    //     }
    // },
})