({
    generateTable: function (component, existingList) {
        if (existingList[0].Product__r != null && existingList[0].Product__r.Financial_Product_Domain__c != null) {
            if (existingList[0].Product__r.Financial_Product_Domain__c == 'Credit') {
                component.set('v.isCredit',true);
                component.set('v.columns', [
                    {
                        label: 'Limit',
                        fieldName: 'Limit_inMill',
                    },
                    {
                        label: 'Ending Bal.',
                        fieldName: 'F_Projected_Balance_inMill',
                    },
                    {
                        label: 'Average Bal.',
                        fieldName: 'Average_Balance_inMill',
                    },
                    {
                        label: 'Account / Suffix / Ref',
                        fieldName: 'Account_Suffix_Ref__c',
                    },
                    {
                        label: 'Issue Date',
                        fieldName: 'Issue_Date__c',
                    },
                    {
                        label: 'Maturity Date',
                        fieldName: 'Maturity_Date__c',
                    },
                    {
                        label: 'Gross Rate',
                        fieldName: 'Gross_Rate__c',
                    },
                    {
                        label: 'NIIc',
                        fieldName: 'NI_Formula_inMill',
                    },
                    {
                        label: 'NIM',
                        fieldName: 'Forecast_NIM__c',
                    },
                    {
                        label: 'Interest Revenue',
                        fieldName: 'Interest_Revenue__c ',
                    },
                    {
                        label: 'วงเงินอายัต',
                        fieldName: 'Hold_Commitment_inMill',
                    },
                    {
                        label: 'RPN Type',
                        fieldName: 'RPN_Type__c',
                    },
                    {
                        label: 'Product Code',
                        fieldName: 'Product_Code__c',
                    },
                    {
                        label: 'Product Type',
                        fieldName: 'Product_Type__c',
                    },
                    {
                        label: 'Loan Status',
                        fieldName: 'Loan_Status__c',
                    },
                ]);
            } else {        
                component.set('v.isCredit',false);
                component.set('v.columns', [
                    {
                        label: 'Cur Book Bal Dep',
                        fieldName: 'F_Projected_Balance_inMill',
                    },
                    {
                        label: 'Avg Book Bal',
                        fieldName: 'Average_Balance_inMill',
                    },
                    {
                        label: 'Account / Suffix / Ref',
                        fieldName: 'Account_Suffix_Ref__c',
                    },
                    {
                        label: 'Gross Rate',
                        fieldName: 'Gross_Rate__c',
                    },
                    {
                        label: 'NIM',
                        fieldName: 'Forecast_NIM__c',
                    },
                    {
                        label: 'NIId',
                        fieldName: 'NI_Formula_inMill',
                    },
                    {
                        label: 'Interest Revenue',
                        fieldName: 'Interest_Revenue__c ',
                    },
                    {
                        label: 'Issue Date',
                        fieldName: 'Issue_Date__c',
                    },
                    {
                        label: 'Maturity Date',
                        fieldName: 'Maturity_Date__c',
                    },
                    {
                        label: 'Account Status Desc',
                        fieldName: 'Account_Status_Desc__c',
                    }
                ]);
            }
        }
    },

    getData: function (component, helper) {
        var myPageRef = component.get('v.pageReference');
        var recId = myPageRef.state.c__id;
        var product = myPageRef.state.c__productType;
        var month = myPageRef.state.c__month;
        var year = myPageRef.state.c__year;

        component.set('v.product', product);

        var action = component.get('c.getExistingDetail');

        action.setParams({
            Id: recId,
            Product: product,
            month: month,
            year: year
        });

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && component.isValid()) {
                var result = response.getReturnValue();
                var existingList = result.existingList;
                var drawdown = result.drawdown;
                var sumAvg = 0;
                var sumNIFor = 0;
                existingList.sort(function(a,b){
                    return new Date(b.Maturity_Date__c) - new Date(a.Maturity_Date__c);
                  });
                existingList.forEach((existingData) => {
                    var AccountSuffixRef = (existingData.TMB_Account_ID__c == null ? '-' : existingData.TMB_Account_ID__c) + ' / ' + (existingData.TMB_Suffix__c == null ? '-' : existingData.TMB_Suffix__c) + ' / ' + (existingData.Ref__c == null ? '-' : existingData.Ref__c);
                    existingData.Account_Suffix_Ref = AccountSuffixRef;
                    sumAvg += existingData.Average_Balance__c;
                    sumNIFor += existingData.NI_Formula__c;
                    existingData.Gross_Rate__c = existingData.Gross_Rate__c != null ? (existingData.Gross_Rate__c).toFixed(2) : (0).toFixed(2);
                    existingData.Forecast_NIM__c = existingData.Forecast_NIM__c != null ? parseFloat(existingData.Forecast_NIM__c).toFixed(2) : (0).toFixed(2);
                });

                var totalAverage_Balance = 0;
                var totalDrawdownAmount = 0;

                drawdown.forEach((drawdownData) => {
                    totalDrawdownAmount += drawdownData.F_Projected_Balance__c;
                    totalAverage_Balance += drawdownData.Average_Balance__c;
                });

                if(drawdown[0] != null){
                    var showDrawDown = drawdown[0];
                    var drawdownAccountSuffixRef = (showDrawDown.TMB_Account_ID__c == null ? '-' : showDrawDown.TMB_Account_ID__c) + ' / ' + (showDrawDown.TMB_Suffix__c == null ? '-' : showDrawDown.TMB_Suffix__c) + ' / ' + (showDrawDown.Ref__c == null ? '-' : showDrawDown.Ref__c);
                    showDrawDown.Account_Suffix_Ref= drawdownAccountSuffixRef
                    showDrawDown.F_Projected_Balance__c = totalDrawdownAmount;
                    showDrawDown.Average_Balance__c = totalAverage_Balance;
                    component.set('v.drawdownData', showDrawDown);      
                }
                var shortid = existingList[0].Customer__r.TMB_Customer_ID_PE__c != null ? existingList[0].Customer__r.TMB_Customer_ID_PE__c.substring(4).replace(/^0+/, '') : '';
                component.set('v.shortid', shortid);
                component.set('v.data', existingList)
                helper.generateTable(component, existingList);
            } else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', errors[0].message);
                    }
                }
            } else {
                console.error(response);
                helper.displayToast('error', response);
            }

            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    displayToast: function (type, message) {
        var duration = 5000;
        var toastEvent = $A.get('e.force:showToast');

        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });

        toastEvent.fire();
    },
});