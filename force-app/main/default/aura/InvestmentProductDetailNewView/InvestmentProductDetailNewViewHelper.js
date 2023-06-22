({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    displayErrorMessage: function (component, title, errMsg) {
        component.set('v.error.state', true);
        component.set('v.error.title', title);
        component.set('v.error.message', errMsg);
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
    getInvestmentAccountDetail: function (component, event, helper) {
        helper.startSpinner(component);
        var tmbCustId = component.get('v.tmbCustId');
        var action = component.get('c.getInvestmentDetailProduct');
        action.setParams({
            "unitHolderNo": component.get('v.UnitHolderNo'),
            "fundCode": component.get('v.FundCode'),
            "recordId": component.get('v.recordId'),
            'tmbCustId': tmbCustId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    
                    if(result.Status.StatusCode != '200'){
                        // helper.displayToast('error', result.Status.StatusDesc);
                        helper.displayToast('error', $A.get('$Label.c.ERR001_ProductHolding'));
                        helper.displayErrorMessage(component, 'Warning!', $A.get('$Label.c.ERR001_ProductHolding'));
                        component.get('v.fields.InvestmentInfo').find(function (i) {
                            return i.fieldName == 'UnitHolderNo';
                        }).value = component.get('v.UnitHolderNo');
                        component.set('v.fields.InvestmentInfo', component.get('v.fields.InvestmentInfo'));
                    } 
                    else {
                        if(result.Authorize == false){
                            component.set('v.fields.InvestmentInfo', component.get('v.fields.InvestmentInfo').map(function (i) {
                                i.value = $A.get('$Label.c.Data_Condition_Hidden_Text');
                                i.type= 'STRING';
                                return i;
                            }));
                        }
                        else{
                            if (result.GetInvestmentAccountDetailResponse.Result.Status == 'SUCCESS') {
                                var InvestmentDetail = result.InvestmentDetail;
    
                                helper.doWorkspaceAPI(component, InvestmentDetail.UnitHolderNo);
                                component.set('v.fields.InvestmentInfo', component.get('v.fields.InvestmentInfo').map(function (i) {
                                    if (InvestmentDetail.hasOwnProperty(i.fieldName))
                                        i.value = InvestmentDetail[i.fieldName];
                                    return i;
                                }));
                                var InvestmentInformation = result.GetInvestmentAccountDetailResponse.Result.InvestmentInformation;
                                // var CostOfInvestment = parseFloat(InvestmentInformation.CostOfInvestment);
                                // var NumberOfUnit = parseFloat(InvestmentInformation.NumberOfUnit);
                                // var UnrealizedGL = parseFloat(InvestmentInformation.UnrealizedGL);
                                // InvestmentInformation.AverageCostPerUnit = NumberOfUnit != 0 ? CostOfInvestment / NumberOfUnit : 0;
                                // InvestmentInformation.UnrealizedGLPerc = NumberOfUnit != 0 ? UnrealizedGL / CostOfInvestment * 100 : 0;
                                component.set('v.fields.InvestmentInfo', component.get('v.fields.InvestmentInfo').map(function (i) {
                                    if (InvestmentInformation.hasOwnProperty(i.fieldName))
                                        i.value = InvestmentInformation[i.fieldName];
                                    return i;
                                }));
    
                                var isSuccessAutoInvestmentPlan = result.GetInvestmentAccountDetailResponse.Result.AutoInvestmentPlan.Status == "SUCCESS";
                                if (isSuccessAutoInvestmentPlan) {
                                    var AutoInvestmentPlan = result.GetInvestmentAccountDetailResponse.Result.AutoInvestmentPlan.AutoInvestmentPlan;
                                    AutoInvestmentPlan = Array.isArray(AutoInvestmentPlan) ? AutoInvestmentPlan : (AutoInvestmentPlan ? [AutoInvestmentPlan] : []);
                                    component.set('v.AutoInvestmentPlan.datas', AutoInvestmentPlan.length > 0 ? AutoInvestmentPlan.reduce(function (l, i) {
                                        l.push({
                                            'Date': i.TempDate,
                                            // 'Date': 'Something',
                                            'SinceDate': i.SinceDate,
                                            // 'SinceDate': i.SinceDate ? new Date(i.SinceDate.match(/([0-9]{4}-[0-9]{2}-[0-9]{2})/g)) : '',
                                            'CreatedChannel': i.CreatedChannel,
                                            'Frequency': i.Frequency,
                                            // 'Balance': parseFloat(i.Balance).toLocaleString('en-US'),
                                            'Balance': i.Balance,
                                            'SavingAccountBundling': i.SavingAccountBundling,
                                        });
                                        return l;
                                    }, []) : []);
                                } else {
                                    component.set('v.AutoInvestmentPlan.datas', [{
                                        'Date': $A.get('$Label.c.ERR008'),
                                        'ERROR': 'notFound',
                                    }]);
                                }
    
                                var isSuccessInvestmentTransaction = result.GetInvestmentAccountDetailResponse.Result.InvestmentTransaction.Status == "SUCCESS";
                                if (isSuccessInvestmentTransaction) {
                                    var InvestmentTransaction = result.GetInvestmentAccountDetailResponse.Result.InvestmentTransaction.InvestmentTransaction;
                                    InvestmentTransaction = Array.isArray(InvestmentTransaction) ? InvestmentTransaction : (InvestmentTransaction ? [InvestmentTransaction] : []);
                                    component.set('v.InvestmentTransaction.datas', InvestmentTransaction.length > 0 ? InvestmentTransaction.reduce(function (l, i) {
                                        l.push({
                                            'SettlementDate': i.SettlementDate ? new Date(i.SettlementDate.match(/([0-9]{4}-[0-9]{2}-[0-9]{2})/g)) : '',
                                            'TransactionType': i.TransactionType,
                                            'InteractChannel': i.InteractChannel,
                                            // 'UnitMovement': parseFloat(i.UnitMovement).toLocaleString('en-US'),
                                            'UnitMovement': i.UnitMovement,
                                            // 'TransactionValue': parseFloat(i.TransactionValue).toLocaleString('en-US'),
                                            'TransactionValue': i.TransactionValue,
                                            'ValuePerUnit': i.ValuePerUnit,
                                            'Statue': i.Statue,
                                        });
                                        return l;
                                    }, []) : []);
                                } else {
                                    component.set('v.InvestmentTransaction.datas', [{
                                        'SettlementDate': $A.get('$Label.c.ERR008'),
                                        'ERROR': 'notFound',
                                    }]);
                                }
                            }
                        }
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
	},
})