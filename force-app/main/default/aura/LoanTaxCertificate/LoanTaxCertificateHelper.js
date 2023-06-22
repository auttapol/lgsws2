({
    parseObj: function(objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    setTabDetail: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
                if (tabId) {
                    var focusedTabId = tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Tax Certificate"
                    });

                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "standard:form",
                        iconAlt: "form"
                    });
                }
            })
            .catch(function(error) {
                // console.log(error);
            });
    },

    getSearchPermission: function(component, helper) {
        var action = component.get('c.getSearchBtnPermission');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (result == true) {
                    component.set('v.isSearchAble', true);
                } else if (result == false) {
                    component.set('v.isSearchAble', false);
                } else {
                    component.set('v.isError.noData', true);
                }

            } else if (response.getState() === "ERROR") {
                component.set('v.isError.noData', true);
            }
            helper.stopSpinner(component);
        });

        $A.enqueueAction(action);
    },

    getOSC04Data: function(component, helper) {

        var action = component.get('c.getLoanInformationData');
        var acctNo = component.get('v.accountNo');
        var acctType = component.get('v.passAccountType');
        var rmId = component.get('v.passRMID');
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        action.setParams({
            'body': JSON.stringify({
                "GetLoanAccountRequest": {
                    "RMID": '',
                    "FIIdent": '',
                    "AccountNumber": acctNo,
                    "AccountType": acctType,
                    "ProductType": ''
                }
            }),
            'tmbCustId': rmId,
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result.coborrow) {
                    if (rmId) component.set('v.displayAccountNo', result.accountNumber);
                    component.set('v.fiident', result.fiident);
                    component.set('v.creditLimit', result.creditLimit);
                    component.set('v.openDate', result.openDate);
                    component.set('v.productName', result.prodName);

                    var coborrowList = result.coborrow;
                    var coborrowIndex = 1;

                    if (coborrowList[0].Relationship == 'PRIIND') {
                        component.set(`v.taxForm.coborrower0.name`, coborrowList[0].Name);
                        helper.getConsent(component, helper, coborrowList[0].RMID, 0);
                    } else {
                        coborrowList.forEach(coborrower => {
                            //Set PRIJNT always in first position
                            if (coborrower.Relationship == 'PRIJNT') {
                                component.set(`v.taxForm.coborrower0.name`, coborrower.Name);
                                helper.getConsent(component, helper, coborrower.RMID, 0);
                            } else {
                                component.set(`v.taxForm.coborrower${coborrowIndex}.name`, coborrower.Name);
                                helper.getConsent(component, helper, coborrower.RMID, coborrowIndex);
                                coborrowIndex++;
                            }
                        });
                    }
                    component.set("v.is04CallFinish","true");
                } else if (result.statusDesc04 == 'ERROR') {
                    component.set('v.isError.noData', true);
                    component.set("v.is04CallFinish","true");
                    component.set("v.isTaxConsentCallFinish","true");
                } else if (result.statusDesc04 == 'Account not found') {
                    helper.displayToast('error', 'Account No does not found in the system.');
                    component.set("v.is04CallFinish","true");
                    component.set("v.isTaxConsentCallFinish","true");
                } else if (result.statusDesc04 == 'TIMEOUT') {
                    component.set('v.isError.timeout', true);
                    component.set("v.is04CallFinish","true");
                } else if (result.statusDesc04 == 'Unauthorized'){
                    this.retryOSC04(component, helper, numOfRetryTime);
                }else {
                    component.set('v.isError.noData', true);
                    component.set("v.is04CallFinish","true");
                    component.set("v.isTaxConsentCallFinish","true");
                }

            } else if (response.getState() === "ERROR") {
                component.set('v.isError.noData', true);
                component.set("v.is04CallFinish","true");
                component.set("v.isTaxConsentCallFinish","true");
            } else {
                component.set('v.isError.noData', true);
                component.set("v.is04CallFinish","true");
                component.set("v.isTaxConsentCallFinish","true");
            }
            this.stopRetrySpinner(component,event,helper);
        });
        if (acctNo) $A.enqueueAction(action);
    },

    retryOSC04 : function(component, helper, numOfRetryTime){
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        numOfRetryTime -= 1;
        setTimeout(() => {
            var action = component.get('c.getLoanInformationData');
            var acctNo = component.get('v.accountNo');
            var acctType = component.get('v.passAccountType');
            var rmId = component.get('v.passRMID');
    
            action.setParams({
                'body': JSON.stringify({
                    "GetLoanAccountRequest": {
                        "RMID": '',
                        "FIIdent": '',
                        "AccountNumber": acctNo,
                        "AccountType": acctType,
                        "ProductType": ''
                    }
                }),
                'tmbCustId': rmId,
            });
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if (result.coborrow) {
                        if (rmId) component.set('v.displayAccountNo', result.accountNumber);
                        component.set('v.fiident', result.fiident);
                        component.set('v.creditLimit', result.creditLimit);
                        component.set('v.openDate', result.openDate);
                        component.set('v.productName', result.prodName);
    
                        var coborrowList = result.coborrow;
                        var coborrowIndex = 1;
    
                        if (coborrowList[0].Relationship == 'PRIIND') {
                            component.set(`v.taxForm.coborrower0.name`, coborrowList[0].Name);
                            helper.getConsent(component, helper, coborrowList[0].RMID, 0);
                        } else {
                            coborrowList.forEach(coborrower => {
                                //Set PRIJNT always in first position
                                if (coborrower.Relationship == 'PRIJNT') {
                                    component.set(`v.taxForm.coborrower0.name`, coborrower.Name);
                                    helper.getConsent(component, helper, coborrower.RMID, 0);
                                } else {
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.name`, coborrower.Name);
                                    helper.getConsent(component, helper, coborrower.RMID, coborrowIndex);
                                    coborrowIndex++;
                                }
                            });
                        }
                        component.set("v.is04CallFinish","true");
                    } else if (result.statusDesc04 == 'ERROR') {
                        component.set('v.isError.noData', true);
                        component.set("v.is04CallFinish","true");
                        component.set("v.isTaxConsentCallFinish","true");
                    } else if (result.statusDesc04 == 'Account not found') {
                        helper.displayToast('error', 'Account No does not found in the system.');
                        component.set("v.is04CallFinish","true");
                        component.set("v.isTaxConsentCallFinish","true");
                    } else if (result.statusDesc04 == 'TIMEOUT') {
                        component.set('v.isError.timeout', true);
                        component.set("v.is04CallFinish","true");
                        component.set("v.isTaxConsentCallFinish","true");
                    } else if(result.statusDesc04 == 'Unauthorized'){
                        if(numOfRetryTime > 0){
                            this.retryOSC04(component, helper, numOfRetryTime);
                        }
                        else{
                            component.set('v.isError.noData', true);
                            component.set("v.is04CallFinish","true");
                            component.set("v.isTaxConsentCallFinish","true");
                        }
                    } 
                    else {
                        component.set('v.isError.noData', true);
                        component.set("v.is04CallFinish","true");
                        component.set("v.isTaxConsentCallFinish","true");
                    }
    
                } else if (response.getState() === "ERROR") {
                    component.set('v.isError.noData', true);
                    component.set("v.is04CallFinish","true");
                    component.set("v.isTaxConsentCallFinish","true");
                } else {
                    component.set('v.isError.noData', true);
                    component.set("v.is04CallFinish","true");
                    component.set("v.isTaxConsentCallFinish","true");
                }
                this.stopRetrySpinner(component,event,helper);

            });
            if (acctNo) $A.enqueueAction(action);
        }, retrySetTimeOut);
    },

    getConsent: function(component, helper, rmid, coborrowIndex) {
        var action = component.get('c.getTaxConsentDataByRMID');
        var passRMID = component.get('v.passRMID');
        var isFound = false;
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));

        action.setParams({
            'rmid': rmid
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                if (response.getReturnValue() == 'TIMEOUT') {
                    component.set(`v.isError.consentTimeout.co${coborrowIndex}`, true);
                    component.set("v.isTaxConsentCallFinish","true");
                }
                else if( response.getReturnValue() == 'Unauthorized' ){
                    this.retryGetConsent(component, helper, rmid, coborrowIndex, numOfRetryTime);
                }
                else {
                    var result = JSON.parse(response.getReturnValue());
                    if (result) {
                        if (result.status.code == '0000') {
                            for (var i in result.customer.tax_certificate_consents) {
                                var coborrower = helper.parseObj(component.get(`v.taxForm.coborrower${coborrowIndex}`));
                                coborrower.rmid = rmid;

                                if (passRMID) {
                                    if (passRMID == rmid) {
                                        coborrower.editable = true;
                                    }
                                } else {
                                    coborrower.editable = true;
                                }

                                if (result.customer.tax_certificate_consents[i].acct_nbr == component.get('v.accountNo')) {
                                    coborrower.currentFlag = result.customer.tax_certificate_consents[i].flag;
                                    coborrower.oldFlag = result.customer.tax_certificate_consents[i].flag;
                                    isFound = true;
                                }

                                component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);

                                //convert flag
                                if (coborrower.currentFlag == 'Y') {
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.currentFlag`, 'Yes');
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.oldFlag`, 'Yes');
                                } else if (coborrower.currentFlag == 'N') {
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.currentFlag`, 'No');
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.oldFlag`, 'No');
                                }
                                if (isFound) { break; }
                            }
                            component.set("v.isTaxConsentCallFinish","true");
                            component.set('v.allowEditBtn', true);
                        } else if (result.status.code == '4001') {
                            component.set(`v.taxForm.coborrower${coborrowIndex}.rmid`, rmid);
                            if (passRMID) {
                                if (passRMID == rmid) {
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.editable`, true);
                                    component.set('v.allowEditBtn', true);
                                }
                            } else {
                                component.set(`v.taxForm.coborrower${coborrowIndex}.editable`, true);
                                component.set('v.allowEditBtn', true);
                            }
                            component.set("v.isTaxConsentCallFinish","true");
                        }
                        else if (result.status.code == '401'){
                            this.retryGetConsent(component, helper, rmid, coborrowIndex, numOfRetryTime);
                        }
                        else {
                            component.set(`v.isError.getFlag.co${coborrowIndex}`, true);
                            component.set("v.isTaxConsentCallFinish","true");
                        }
                    } else {
                        component.set(`v.isError.getFlag.co${coborrowIndex}`, true);
                        component.set("v.isTaxConsentCallFinish","true");
                    }
                    component.set("v.isTaxConsentCallFinish","true");
                }
            } else {
                component.set(`v.isError.getFlag.co${coborrowIndex}`, true);
                component.set("v.isTaxConsentCallFinish","true");
            }
            this.stopRetrySpinner(component,event,helper);
        });
        $A.enqueueAction(action);
    },

    retryGetConsent : function(component, helper, rmid, coborrowIndex, numOfRetryTime){
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        numOfRetryTime -= 1;
        setTimeout(()=>{
            var action = component.get('c.getTaxConsentDataByRMID');
        var passRMID = component.get('v.passRMID');
        var isFound = false;

        action.setParams({
            'rmid': rmid
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                if (response.getReturnValue() == 'TIMEOUT') {
                    component.set(`v.isError.consentTimeout.co${coborrowIndex}`, true);
                    component.set("v.isTaxConsentCallFinish","true");
                }
                else if(response.getReturnValue() == 'Unauthorized'){
                    if(numOfRetryTime > 0){
                        this.retryGetConsent(component, helper, rmid, coborrowIndex, numOfRetryTime);
                    }
                    else{
                        component.set("v.isTaxConsentCallFinish","true");
                        component.set(`v.isError.getFlag.co${coborrowIndex}`, true);
                    }
                }
                else {
                    var result = JSON.parse(response.getReturnValue());
                    if (result) {
                        if (result.status.code == '0000') {
                            for (var i in result.customer.tax_certificate_consents) {
                                var coborrower = helper.parseObj(component.get(`v.taxForm.coborrower${coborrowIndex}`));
                                coborrower.rmid = rmid;

                                if (passRMID) {
                                    if (passRMID == rmid) {
                                        coborrower.editable = true;
                                    }
                                } else {
                                    coborrower.editable = true;
                                }

                                if (result.customer.tax_certificate_consents[i].acct_nbr == component.get('v.accountNo')) {
                                    coborrower.currentFlag = result.customer.tax_certificate_consents[i].flag;
                                    coborrower.oldFlag = result.customer.tax_certificate_consents[i].flag;
                                    isFound = true;
                                }

                                component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);

                                //convert flag
                                if (coborrower.currentFlag == 'Y') {
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.currentFlag`, 'Yes');
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.oldFlag`, 'Yes');
                                } else if (coborrower.currentFlag == 'N') {
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.currentFlag`, 'No');
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.oldFlag`, 'No');
                                }
                                if (isFound) { break; }
                            }
                            component.set('v.allowEditBtn', true);
                            component.set("v.isTaxConsentCallFinish","true");
                        } else if (result.status.code == '4001') {
                            component.set(`v.taxForm.coborrower${coborrowIndex}.rmid`, rmid);
                            if (passRMID) {
                                if (passRMID == rmid) {
                                    component.set(`v.taxForm.coborrower${coborrowIndex}.editable`, true);
                                    component.set('v.allowEditBtn', true);
                                }
                                component.set("v.isTaxConsentCallFinish","true");
                            }
                            else if(result.Status.StatusCode == '401' && numOfRetryTime > 0){
                                this.retryGetConsent(component, helper, rmid, coborrowIndex, numOfRetryTime);
                            } 
                            else {
                                component.set(`v.taxForm.coborrower${coborrowIndex}.editable`, true);
                                component.set('v.allowEditBtn', true);
                                component.set("v.isTaxConsentCallFinish","true");
                            }
                        } else {
                            component.set("v.isTaxConsentCallFinish","true");
                            component.set(`v.isError.getFlag.co${coborrowIndex}`, true);
                        }
                    } else {
                        component.set("v.isTaxConsentCallFinish","true");
                        component.set(`v.isError.getFlag.co${coborrowIndex}`, true);
                    }
                }
            } else {
                component.set(`v.isError.getFlag.co${coborrowIndex}`, true);
                component.set("v.isTaxConsentCallFinish","true");
            }
            this.stopRetrySpinner(component,event,helper);
        });
        $A.enqueueAction(action);
        }, retrySetTimeOut);
    },

    saveConsent: function(component, helper, coborrower, coborrowIndex) {
        var action = component.get('c.CreateUpdateTaxConsent');
        var acctNo = component.get('v.accountNo');
        var fiident = component.get('v.fiident');
        var credentialName;
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        if (coborrower.oldFlag) {
            credentialName = 'TaxCert_UpdateConsents';
        } else {
            credentialName = 'TaxCert_CreateConsents';
        }

        var convertedFlag;
        //convert flag
        if (coborrower.currentFlag == 'Yes') {
            convertedFlag = 'Y';
        } else if (coborrower.currentFlag == 'No') {
            convertedFlag = 'N';
        }

        action.setParams({
            'rmid': coborrower.rmid,
            'acctNo': acctNo,
            'consentFlag': convertedFlag,
            'fiident': fiident,
            'credentialName': credentialName
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result == 'TIMEOUT') {
                    coborrower.currentFlag = coborrower.oldFlag;
                    component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                    component.set(`v.isError.consentTimeout.co${coborrowIndex}`, true);
                    helper.stopSpinner(component);
                }
                else if( result == '401'){
                    this.retrySaveConsent(component, helper, coborrower, coborrowIndex, numOfRetryTime);
                }
                else if (result == 'true') {
                    coborrower.oldFlag = coborrower.currentFlag;
                    component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                    component.set(`v.isSaveSuccess.co${coborrowIndex}`, true);
                    helper.stopSpinner(component);
                } else {
                    coborrower.currentFlag = coborrower.oldFlag;
                    component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                    component.set(`v.isError.saveForm.co${coborrowIndex}`, true);
                    helper.stopSpinner(component);
                }
            } else if (response.getState() === "ERROR") {
                coborrower.currentFlag = coborrower.oldFlag;
                component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                component.set(`v.isError.saveForm.co${coborrowIndex}`, true);
                helper.stopSpinner(component);
            } else {
                coborrower.currentFlag = coborrower.oldFlag;
                component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                component.set(`v.isError.saveForm.co${coborrowIndex}`, true);
                helper.stopSpinner(component);
            }

        });
        $A.enqueueAction(action);
    },

    retrySaveConsent : function(component, helper, coborrower, coborrowIndex, numOfRetryTime){
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        numOfRetryTime -= 1;
        setTimeout(() => {
            var action = component.get('c.CreateUpdateTaxConsent');
            var acctNo = component.get('v.accountNo');
            var fiident = component.get('v.fiident');
            var credentialName;
            if (coborrower.oldFlag) {
                credentialName = 'TaxCert_UpdateConsents';
            } else {
                credentialName = 'TaxCert_CreateConsents';
            }

            var convertedFlag;
            //convert flag
            if (coborrower.currentFlag == 'Yes') {
                convertedFlag = 'Y';
            } else if (coborrower.currentFlag == 'No') {
                convertedFlag = 'N';
            }

            action.setParams({
                'rmid': coborrower.rmid,
                'acctNo': acctNo,
                'consentFlag': convertedFlag,
                'fiident': fiident,
                'credentialName': credentialName
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if (result == 'TIMEOUT') {
                        coborrower.currentFlag = coborrower.oldFlag;
                        component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                        component.set(`v.isError.consentTimeout.co${coborrowIndex}`, true);
                        helper.stopSpinner(component);
                    }
                    else if( result == '401'){
                        if(numOfRetryTime > 0){
                            this.retrySaveConsent(component, helper, coborrower, coborrowIndex, numOfRetryTime);
                        }
                        else{
                            coborrower.currentFlag = coborrower.oldFlag;
                            component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                            component.set(`v.isError.saveForm.co${coborrowIndex}`, true);
                            helper.stopSpinner(component);
                        }
                    }
                    else if (result == 'true') {
                        coborrower.oldFlag = coborrower.currentFlag;
                        component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                        component.set(`v.isSaveSuccess.co${coborrowIndex}`, true);
                        helper.stopSpinner(component);
                    } else {
                        coborrower.currentFlag = coborrower.oldFlag;
                        component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                        component.set(`v.isError.saveForm.co${coborrowIndex}`, true);
                        helper.stopSpinner(component);
                    }
                } else if (response.getState() === "ERROR") {
                    coborrower.currentFlag = coborrower.oldFlag;
                    component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                    component.set(`v.isError.saveForm.co${coborrowIndex}`, true);
                    helper.stopSpinner(component);
                } else {
                    coborrower.currentFlag = coborrower.oldFlag;
                    component.set(`v.taxForm.coborrower${coborrowIndex}`, coborrower);
                    component.set(`v.isError.saveForm.co${coborrowIndex}`, true);
                    helper.stopSpinner(component);
                }
            });

            $A.enqueueAction(action);
        }, retrySetTimeOut);
    },

    startSpinner: function(component) {
        component.set('v.isLoading', true);
    },

    stopSpinner: function(component) {
        component.set('v.isLoading', false);
    },

    getWatermarkHTML: function(component) {
        var action = component.get("c.getWatermarkHTML");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var watermarkHTML = response.getReturnValue();
                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";
                component.set('v.waterMarkImage', bg);
            } else if (state === 'ERROR') {
                // console.log('STATE ERROR');
                // console.log('error: ', response.error);
            } else {
                // console.log('Unknown problem, state: ' + state + ', error: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    displayToast: function(type, message) {
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

    resetForm: function(component) {
        component.set('v.accountNo', '');
        component.set('v.allowEditBtn', false);
        component.set('v.creditLimit', '');
        component.set('v.openDate', '');
        component.set('v.productName', '');
        for (var i = 0; i <= 5; i++) {
            component.set(`v.taxForm.coborrower${i}.name`, '')
            component.set(`v.taxForm.coborrower${i}.rmid`, '');
            component.set(`v.taxForm.coborrower${i}.oldFlag`, '');
            component.set(`v.taxForm.coborrower${i}.currentFlag`, '');
            component.set(`v.taxForm.coborrower${i}.editable`, false)
        }
        component.set('v.isError', {})
        component.set('v.isSaveSuccess', {})
    },

    stopRetrySpinner : function(component,event,helper){
        var call04 = component.get('v.is04CallFinish');
        var getTax = component.get('v.isTaxConsentCallFinish');
        if(call04 == "true" && getTax == "true"){
            helper.stopSpinner(component);
        }
    }
})