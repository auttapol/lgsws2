({
    onInit: function (component, event, helper) {
        helper.doWorkspaceAPI(component, $A.get('$Label.c.Credit_Card_RDC_Product_Details'));
    
        component.set('v.fields.CreditCardInfo', [{
                label: $A.get('$Label.c.Card_Number'),
                fieldName: 'MarkedCardNumber',
            },
            {
                label: $A.get('$Label.c.Product_Name'),
                fieldName: 'ProductName',
            },
            {
                label: $A.get('$Label.c.Activated_Date'),
                fieldName: 'OpenedDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Product_Type'),
                fieldName: 'ProductType',
            },
            // {
            //     label: $A.get('$Label.c.Status'),
            //     fieldName: 'UsageStatus',
            // },
            {
                label: $A.get('$Label.c.Account_Agreement_Status'),
                fieldName: 'AccountAgreementStatus',
            },
            {
                label: $A.get('$Label.c.Outstanding_Credit'),
                fieldName: 'MarkedCurrentBalance',
                // type: 'PARSE',
                // fieldKey: 'CurrentBalance',
                // funcName: 'MarkedCurrentBalance'
            },
            {
                label: $A.get('$Label.c.Block_Code'),
                fieldName: 'BlockCode',
            },
            {
                label: $A.get('$Label.c.Credit_Limit'),
                fieldName: 'MarkedCreditLimit',
                // fieldName: 'CreditLimit',
                // type: 'INTEGER',
            },
            {
                label: $A.get('$Label.c.Card_Account_Status'),
                fieldName: 'CardAccountStatus',
            },
            {
                label: $A.get('$Label.c.Temporary_Line'),
                fieldName: 'TemporaryLine',
            },
            {
                label: $A.get('$Label.c.Card_Stop'),
                fieldName: 'CardStop',
            },
            {
                label: $A.get('$Label.c.Reward_Points'),
                fieldName: 'RewardPoints',
            },
            {
                label: $A.get('$Label.c.Card_Stop_Reason'),
                fieldName: 'CardStopReason',
            },
            {
                label: $A.get('$Label.c.Next_Expired_Points'),
                fieldName: 'NextExpiredPoints',
            },
            {
                label: $A.get('$Label.c.Acknowledgement_Date'),
                fieldName: 'AcknowledgementDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Next_Expired_Point_On'),
                fieldName: 'NextExpiredPointOn',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Card_Expiry_Date'),
                fieldName: 'CardExpiryDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Direct_Debit_Account_Number'),
                fieldName: 'MarkedDirectDebitAccountNumber',
            },
            {
                label: $A.get('$Label.c.Previous_Expiry_Date'),
                fieldName: 'PreviousExpiryDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Last_6_Months_Transactor_Revolver'),
                fieldName: 'UsageBehavior',
            },
            {
                label: $A.get('$Label.c.Last_Payment_Date'),
                fieldName: 'LastPaymentDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Payment_Behavior'),
                fieldName: 'PaymentBehavior',
            },
            {
                label: $A.get('$Label.c.Cycle_Cut'),
                fieldName: 'CycleCut',
            },
            
            {
                label: $A.get('$Label.c.Payment_Due'),
                fieldName: 'PaymentDue',
                // type: 'DATE',
            },           
            // {
            //     fieldName: ' ',
            // },

        ].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            if (i.value == null) {
                i.ErrorMsg = $A.get('$Label.c.ERR008');
            }
            return i;
        }));


        component.set('v.fields.PayPlanRecord', [{
                label: $A.get('$Label.c.Txn_of_Non_Interest_Charged'),
                fieldName: 'NumberOfNonInterestChargeTransactions',
            },
            {
                label: $A.get('$Label.c.Amount_of_Non_Interest_Charged'),
                fieldName: 'AmountOfNonInterestChargeTransactions',
            },
            {
                label: $A.get('$Label.c.Txn_of_Interest_Charged'),
                fieldName: 'NumberOfInterestChargeTransactions',
            },
            {
                label: $A.get('$Label.c.Amount_of_Interest_Charged'),
                fieldName: 'AmountOfInterestChargeTransactions',
            },
            {
                label: $A.get('$Label.c.Total_Txn'),
                fieldName: 'TotalNumberOfTransactions',
            },
            {
                label: $A.get('$Label.c.Total_Amount'),
                fieldName: 'TotalAmountOfTransactions',
            },
        ].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            if (i.value == null) {
                i.ErrorMsg = $A.get('$Label.c.ERR008');
            }
            return i;
        }));

        component.set('v.product', helper.decodeObject(component.get('v.product')));
        helper.getCreditCardDetailsView(component, event, helper);
        helper.getWatermarkHTML(component);
        window.scrollTo(0, 0);
    },
    onRetryGetcard: function (component, event, helper) {
        helper.GetCardData(component, event, helper);
    },
    onRetryGetunbilled: function (component, event, helper) {
        helper.GetUnbilledData(component, event, helper);
    },
    onRetryGetsummary: function (component, event, helper) {
        helper.GetSummaryData(component, event, helper);
    },
    onRetryGetcardAndGetUnbilled: function (component, event, helper) {
        helper.GetCardData(component, event, helper);
        helper.GetUnbilledData(component, event, helper);
    },
    onRetryGetcardAndGetSummary: function (component, event, helper) {
        helper.GetCardData(component, event, helper);
        helper.GetSummaryData(component, event, helper);
    },
    onRetryGetUnbilledAndGetSummary: function (component, event, helper) {
        helper.GetUnbilledData(component, event, helper);
        helper.GetSummaryData(component, event, helper);
    },
    onRetryCreditCard: function (component, event, helper) {
        helper.getCreditCardDetailsView(component, event, helper);
    },

})