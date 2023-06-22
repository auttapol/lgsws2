({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    displayErrorMessage: function (component, title, errMsg) {
        component.set('v.error.state', true);
        component.set('v.error.title', title);
        component.set('v.error.message', errMsg);
    },
    decodeObject: function (objFields) {
        return objFields ? JSON.parse(decodeURIComponent(atob(objFields))) : null;
    },
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    isEmployee: function (component) {
        return component.get('v.account.RTL_Is_Employee__c') ? true : false;
    },
    isEmployeePayroll: function (DepositeProduct) {
        return DepositeProduct.OutStanding == 0 && DepositeProduct.AvgOutStanding == 0 && DepositeProduct.isEmployee == true ? true : false;
    },
    doWorkspaceAPI: function (component, tabName) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.getTabInfo({
                tabId: tabId
            }).then(function (response) {
                if (response.isSubtab) {
                    workspaceAPI.setTabLabel({
                        tabId: response.tabId,
                        label: tabName,
                    });
                    workspaceAPI.setTabIcon({
                        tabId: response.tabId,
                        icon: "standard:product",
                        iconAlt: tabName,
                    });
                }
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    getDepositDetailView: function (component, event, helper,round) {
        helper.startSpinner(component);
        var action = component.get('c.getDepositProductDetail');
        action.setParams({
            'accountNumber': component.get('v.AccountNumber'),
            'accountType': component.get('v.AccountType'),
            'productType': component.get('v.ProductType'),
            'rmId': component.get('v.tmbCustId').substring(12),
            'fiiDent': component.get('v.FIIdent'),
            'tmbCustId': component.get('v.tmbCustId'),
            'recordId': component.get('v.recordId'),
            'productFrom01': component.get('v.product')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    if(result.StatusCode && result.StatusCode == '401' && round < component.get('v.numOfRetryTime')){
                        round += 1;
                        setTimeout(() => {
                            helper.getDepositDetailView(component,event,helper, round);
                        }, component.get('v.retrySetTimeOut'));
                    }else if (result.statusCode != '200') {
                        helper.displayToast('error', result.Message);
                        helper.displayErrorMessage(component, 'Warning!', result.Message);
                    } else {                   
                        helper.generateValue(component, helper, result);
                    }
                }
                helper.stopSpinner(component);
            } else {
                helper.stopSpinner(component);
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message);
                });
            }
        });
        $A.enqueueAction(action);
    },
    generateValue: function (component, helper, result) {           
        helper.doWorkspaceAPI(component, component.get('v.product').MarkedDepositAccountNumber);     
        const mapVariableField = [{
                key: 'v.fields.DepositAccountInfo',
                value: component.get('v.product')
            },
            {
                key: 'v.fields.DepositAccountInfo',
                value: result.DepositAccountInfo
            },
        ];
        mapVariableField.forEach(function (v) {
            component.set(v.key, component.get(v.key).map(function (i) {

                if (v.value.hasOwnProperty(i.fieldName)) {
                    i.value = v.value[i.fieldName];    

                    i.value = i.fieldName == 'ODLimit' ? (parseInt(v.value[i.fieldName]) != 0 ? parseFloat(v.value[i.fieldName]).toLocaleString('en-US') : '-') : v.value[i.fieldName];                 
                    i.value = i.value && i.type == 'DATE' ? new Date(i.value.match(/([0-9]{4}-[0-9]{2}-[0-9]{2})/g)) : i.value;                   
                    if( typeof i.value == 'string' && !isNaN(i.value) && !i.value.includes('x') && !(i.value ==  $A.get('$Label.c.Data_Condition_Hidden_Text'))  && (i.fieldName == "MarkedLedgerBalance" || i.fieldName == "MarkedOutStanding" || i.fieldName == "MarkedAvgBalanceMTD" || i.fieldName == "InterestEarned")){                        
                        i.value = (typeof(i.value) == 'string') ? Number(i.value) : i.value;
                        //INC0228947
                        //i.value = i.value.toLocaleString("en-US",{minimumFractionDigits: 2,maximumFractionDigits: 2}); 
                        i.type = 'NUMBER';                       
                    }
                    // else if( i.fieldName == 'InterestRate'){
                    //     i.type = 'PERCENT3';
                    // } 
                }
                return i;
            }));
        });

        if (result.JointAccountStatus) {
            var JointAccount = result.JointAccount;
            if(Array.isArray(JointAccount) && JointAccount.length > 0){
                component.set('v.fields.JointAccount',JointAccount.reduce(function (l, v, i) 
                {
                    l.push({
                        label: $A.get('$Label.c.Join_Account_Owner_Name') + ' ' + (i + 1),
                        fieldName: 'OwnerNumber',
                        value: v.OwnerNumber,
                        type: 'STRING',
                    });
                    l.push({
                        label: $A.get('$Label.c.Relationship'),
                        fieldName: 'Relationship',
                        value: v.Relationship,
                        type: 'STRING',
                    });
                    return l;
                }, []));
            }else if(JointAccount.length <= 0){
                component.set('v.fields.JointAccount',[{
                    label: $A.get('$Label.c.Join_Account_Owner_Name'),
                    fieldName: 'OwnerNumber',
                },
                {
                    label: $A.get('$Label.c.Relationship'),
                    fieldName: 'Relationship',
                },
                ])
            }
            else{
                component.log('Error');
                component.set('v.fields.JointAccount',[{
                    label: $A.get('$Label.c.Join_Account_Owner_Name'),
                    fieldName: 'OwnerNumber',
                    value: ''
                },
                {
                    label: $A.get('$Label.c.Relationship'),
                    fieldName: 'Relationship',
                    value: ''
                }])
            }
        }


        var LastMonthTransactionSummary = result.LastMonthTransactionSummary;
        component.set('v.fields.LastMonthTransactionSummary', component.get('v.fields.LastMonthTransactionSummary').map(function (m) {
            m.value = LastMonthTransactionSummary[m.fieldName] && LastMonthTransactionSummary[m.fieldName] != '' ? ( LastMonthTransactionSummary[m.fieldName]) : '0';
            return m;
        }));
    },
    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();
                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('STATE ERROR');
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
		});
		$A.enqueueAction(action);
	},getIsUnmaskData : function(component,helper){
        var action = component.get('c.getUnmaskBalance');
        var returnValue = "{}";
        var jsonData;
        action.setCallback(this,function(response){
            returnValue = response.getReturnValue();
            jsonData = JSON.parse(returnValue);
            component.set('v.unmasked',jsonData);                
        });

        $A.enqueueAction(action);
    },
})