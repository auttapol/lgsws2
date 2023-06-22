({
    onInit: function (component, event, helper) {
        helper.doWorkspaceAPI(component, $A.get('$Label.c.Deposit_Product_Details'));
        component.set('v.fields.DepositAccountInfo', [{
                label: $A.get('$Label.c.Account_Number'),
                fieldName: 'MarkedDepositAccountNumber',
            },
            {
                label: $A.get('$Label.c.Product_Name'),
                fieldName: 'ProductName',
            },
            {
                label: $A.get('$Label.c.Account_Name'),
                fieldName: 'AccountName',
            },
            {
                label: $A.get('$Label.c.Product_Type'),
                fieldName: 'SubProductGroup',
            },
            {
                label: $A.get('$Label.c.Opened_Date'),
                fieldName: 'OpenedDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Ledger_Balance_Deposit'),
                fieldName: 'MarkedLedgerBalance',
                // type: 'NUMBER',

            },
            {
                label: $A.get('$Label.c.Status'),
                fieldName: 'AccountStatus',
            },
            {
                label: $A.get('$Label.c.OD_Balance_Deposit'),
                fieldName: 'ODLimit',
            },
            {
                label: $A.get('$Label.c.Has_Joint'),
                fieldName: 'HasJoint',
            },
            {
                label: $A.get('$Label.c.Available_Balance_Deposit'),
                fieldName: 'MarkedOutStanding',
                // type: 'NUMBER',

            },
            {
                label: $A.get('$Label.c.Maturity_Date'),
                fieldName: 'MaturityDate',
                //type: 'DATE',  //INC0228947
            },
            {
                label: $A.get('$Label.c.Avg_Outstanding_MTD'),
                fieldName: 'MarkedAvgBalanceMTD',
                // type: 'NUMBER',

            },
            {
                label: $A.get('$Label.c.Number_of_Active_Debit_Card_Bundling'),
                fieldName: 'NumberOfActiveDebitCardBundling',
            },
            {
                label: $A.get('$Label.c.Interest_Rate'),
                fieldName: 'InterestRate',
                type: 'PERCENT3',
            },
            {
                label: $A.get('$Label.c.SMS_Alert_Service'),
                fieldName: 'SMSAlertService',
            },
            {
                label: $A.get('$Label.c.Interest_Earned_YTD'),
                inlineHelpText: $A.get('$Label.c.Interested_YTD_Help_Text'),
                fieldName: 'InterestEarned',
                // type: 'NUMBER',
            },
        ].map(function (i) {
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));


        component.set('v.fields.LastMonthTransactionSummary', [{
                label: $A.get('$Label.c.of_Deposit'),
                fieldName: 'MonthlyAvgDepositTransactions',
            },
            {
                label: $A.get('$Label.c.of_Transfer_Out_Within_TMB'),
                fieldName: 'MonthlyAvgTransfersWithinTMB',
            },
            {
                label: $A.get('$Label.c.of_Withdrawal'),
                fieldName: 'MonthlyAvgWithdrawTransactions',
            },
            {
                label: $A.get('$Label.c.of_Transfer_Out_Other_Banks'),
                fieldName: 'MonthlyAvgTransfersToOtherBanks',
            },
            {
                label: $A.get('$Label.c.of_Bill_Payment'),
                fieldName: 'MonthlyAvgBillPaymentTransactions',
            },
        ].map(function (i) {
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));        
        component.set('v.product', helper.decodeObject(component.get('v.product')));
        helper.getDepositDetailView(component, event, helper,0);
        // Add Water Mark
        // helper.getWatermarkHTML(component);
        window.scrollTo(0, 0);
    },

    waterMark: function (component, event, helper) {
        var watermark = component.find('watermark');
        if (watermark && watermark.isValid()) {
            component.set('v.waterMarkImage', watermark.get('v.watermarkHtml'));
        }
    },
})