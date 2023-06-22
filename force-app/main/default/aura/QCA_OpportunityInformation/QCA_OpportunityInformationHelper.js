({
    displayToast: function (component, type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    displayErrorMeassge: function (component, event, isDisplay) {
        if (isDisplay) {
            var output = event.getParam('output');
            var errorMessageList = Object.keys(output.fieldErrors).reduce((list, fieldName) => {
                var errorMessage = output.fieldErrors[fieldName][0];
                list.push({
                    'errorHeader': errorMessage.fieldLabel,
                    'errorMessage': errorMessage.message,
                });
                return list;
            }, []);
            errorMessageList = output.errors.reduce((list, error) => {
                list.push({
                    'errorHeader': error.errorCode,
                    'errorMessage': error.message,
                });
                return list;
            }, errorMessageList);
            component.set('v.errorMessageList', errorMessageList);
        }
        component.set('v.showErrorMessage', isDisplay);
    },
    parseObj: function (objFields) {
        return JSON.parse(JSON.stringify(objFields));
    },
    mapFields: function (params) {
        var tmpObj = {};
        for (var i = 0; i < params.length; i++) {
            var key = params[i].get("v.fieldName");
            var value = params[i].get("v.value");
            tmpObj[key] = value ? value : null;

        }
        return tmpObj;
    },
    setFieldOpportunityForm: function (component, event, helper) {
        var eventFields = event.getParam("fields");
        eventFields['RecordTypeId'] = component.get('v.opptyRecordTypeId');
        if (!eventFields['Host_System__c']) eventFields['Host_System__c'] = 'SLS';
        if (component.find('varAccountId')) eventFields['AccountId'] = component.find('varAccountId').get('v.value');
        if (component.find('varCampaignId')) eventFields['CampaignId'] = component.find('varCampaignId').get('v.value');
        if (component.find('varBranch')) eventFields['Main_Branch__c'] = component.find('varBranch').get('v.value');
        if (component.find('varBranchReferred')) eventFields['Branch_Referred__c'] = component.find('varBranchReferred').get('v.value');
        if (component.find('varCommercialNBO')) eventFields['product_campaign_recommend__c'] = component.find('varCommercialNBO').get('v.value');
        if (component.find('varReferralId')) eventFields['RTL_Referral__c'] = component.find('varReferralId').get('v.value');
        return eventFields;
    },
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },
    setTimeToZero: function (time) {
        time.setHours(0);
        time.setMinutes(0);
        time.setSeconds(0);
        time.setMilliseconds(0);
        return time;
    },
    validExpectedSubmitDate: function (component, event, helper) {
        var inputCmp = event.getSource();
        var inputCmp_CloseDate = component.find('opptyInputForm').find((inputCmp) => {
            return inputCmp.get('v.fieldName') == 'CloseDate';
        });

        var ExpectedSubmitDate = helper.setTimeToZero(new Date(inputCmp.get('v.value')));
        var ExpectedCloseDate = helper.setTimeToZero(new Date(inputCmp_CloseDate.get('v.value')));
        var today = helper.setTimeToZero(new Date());

        var container = component.find(inputCmp.get('v.fieldName'));
        var body = container.get("v.body");
        body.forEach((element, index) => {
            if (index != 0 && element.isValid()) {
                body.splice(index, 1);
                element.destroy();
            }
        });
        if (ExpectedSubmitDate >= today && ExpectedSubmitDate <= ExpectedCloseDate) {
            $A.util.removeClass(container, 'slds-has-error');
        } else {
            $A.util.addClass(container, 'slds-has-error');
            $A.createComponent(
                "aura:html", {
                    tag: "div",
                    HTMLAttributes: {
                        "id": "errorMessageInputField",
                        "class": "slds-form-element__help slds-p-horizontal_xx-small"
                    },
                    body: "Expected Submit Date cannot be the date in the past or before Expected Complete Date"
                },
                function (compo) {
                    if (inputCmp.isValid()) {
                        // body.push(compo);
                        body.splice(body.length, 0, compo);
                        container.set("v.body", body);
                    }
                }
            );
        }
    },
    validateField_CloseDateAndExpectedSubmitDate: function (component, event, helper) {
        var inputCmp_ExpectedSubmitDate = component.find('opptyInputForm').find((inputCmp) => {
            return inputCmp.get('v.fieldName') == 'Expected_submit_date__c';
        });
        var inputCmp_CloseDate = component.find('opptyInputForm').find((inputCmp) => {
            return inputCmp.get('v.fieldName') == 'CloseDate';
        });

        var ExpectedSubmitDate = helper.setTimeToZero(new Date(inputCmp_ExpectedSubmitDate.get('v.value')));
        var ExpectedCloseDate = helper.setTimeToZero(new Date(inputCmp_CloseDate.get('v.value')));
        var today = helper.setTimeToZero(new Date());
        var validExpectedSubmitDate = ExpectedSubmitDate >= today && ExpectedSubmitDate <= ExpectedCloseDate;

        var container_ExpectedSubmitDate = component.find(inputCmp_ExpectedSubmitDate.get('v.fieldName'));
        var body_ExpectedSubmitDate = container_ExpectedSubmitDate.get("v.body");
        body_ExpectedSubmitDate.forEach((element, index) => {
            if (index != 0 && element.isValid()) {
                body_ExpectedSubmitDate.splice(index, 1);
                element.destroy();
            }
        });

        var container_ExpectedCloseDate = component.find(inputCmp_CloseDate.get('v.fieldName'));
        var body_ExpectedCloseDate = container_ExpectedCloseDate.get("v.body");
        body_ExpectedCloseDate.forEach((element, index) => {
            if (index != 0 && element.isValid()) {
                body_ExpectedCloseDate.splice(index, 1);
                element.destroy();
            }
        });

        if (validExpectedSubmitDate) {
            $A.util.removeClass(container_ExpectedSubmitDate, 'slds-has-error');
            $A.util.removeClass(container_ExpectedCloseDate, 'slds-has-error');
        } else {
            $A.util.addClass(container_ExpectedSubmitDate, 'slds-has-error');
            $A.util.addClass(container_ExpectedCloseDate, 'slds-has-error');
            $A.createComponent(
                "aura:html", {
                    tag: "div",
                    HTMLAttributes: {
                        "id": "errorMessageInputField",
                        "class": "slds-form-element__help slds-p-horizontal_xx-small"
                    },
                    body: "Expected Submit Date cannot be the date in the past or before Expected Complete Date"
                },
                function (compo) {
                    if (inputCmp_ExpectedSubmitDate.isValid()) {
                        // body.push(compo);
                        body_ExpectedSubmitDate.splice(body_ExpectedSubmitDate.length, 0, compo);
                        container_ExpectedSubmitDate.set("v.body", body_ExpectedSubmitDate);
                    }
                }
            );
            $A.createComponent(
                "aura:html", {
                    tag: "div",
                    HTMLAttributes: {
                        "id": "errorMessageInputField",
                        "class": "slds-form-element__help slds-p-horizontal_xx-small"
                    },
                    body: "Expected Complete Date จะต้องเกิดหลังจาก Expected Submit Date เท่านั้น"
                },
                function (compo) {
                    if (inputCmp_CloseDate.isValid()) {
                        // body.push(compo);
                        body_ExpectedCloseDate.splice(body_ExpectedCloseDate.length, 0, compo);
                        container_ExpectedCloseDate.set("v.body", body_ExpectedCloseDate);
                    }
                }
            );

        }
        return validExpectedSubmitDate;
    },
    removeValidateField: function (component, event, helper) {
        var inputCmp = event.getSource();
        var inputFieldName = inputCmp.get("v.fieldName");
        var inputFieldValue = inputCmp.get("v.value");
        var container = component.find(inputCmp.get('v.fieldName'));
        var body = container.get("v.body");
        body.forEach((element, index) => {
            if (index != 0 && element.isValid()) {
                body.splice(index, 1);
                element.destroy();
            }
        });

        if (inputFieldValue) {
            $A.util.removeClass(container, 'slds-has-error');
        } else {
            if (component.get('v.onInitValidInputField')) {
                $A.util.addClass(container, 'slds-has-error');
                $A.createComponent(
                    "aura:html", {
                        tag: "div",
                        HTMLAttributes: {
                            "id": "errorMessageInputField",
                            "class": "slds-form-element__help slds-p-horizontal_xx-small"
                        },
                        body: "Complete this field."
                    },
                    function (compo) {
                        if (inputCmp.isValid() && inputFieldName != 'Name') {
                            body.splice(body.length, 0, compo);
                            container.set("v.body", body);
                        }
                    }
                );
            } else {
                component.set('v.onInitValidInputField', true);
            }
        }
    },
    validateField_NameAndStageName: function (component, event, helper) {
        var inputCmp_Name = component.find('opptyInputForm').find((inputCmp) => {
            if (inputCmp.get('v.fieldName') == 'Name') {
                var inputFieldName = inputCmp.get("v.fieldName");
                var inputFieldValue = inputCmp.get("v.value");
                var container = component.find(inputFieldName);
                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        body.splice(index, 1);
                        element.destroy();
                    }
                });

                if (inputFieldValue) {
                    $A.util.removeClass(container, 'slds-has-error');
                } else {
                    $A.util.addClass(container, 'slds-has-error');
                    $A.createComponent(
                        "aura:html", {
                            tag: "div",
                            HTMLAttributes: {
                                "id": "errorMessageInputField",
                                "class": "slds-form-element__help slds-p-horizontal_xx-small"
                            },
                            body: "Complete this field."
                        },
                        function (compo) {
                            if (inputCmp.isValid() && !component.get('v.isValidInputFieldName')) {
                                body.splice(body.length, 0, compo);
                                container.set("v.body", body);
                                component.set('v.isValidInputFieldName', true);
                            }
                        }
                    );
                }
            }
            return inputCmp.get('v.fieldName') == 'Name';
        });

        var inputCmp_StageName = component.find('opptyInputForm').find((inputCmp) => {
            if (inputCmp.get('v.fieldName') == 'StageName') {
                var inputFieldName = inputCmp.get("v.fieldName");
                var inputFieldValue = inputCmp.get("v.value");
                var container = component.find(inputFieldName);
                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        body.splice(index, 1);
                        element.destroy();
                    }
                });

                if (inputFieldValue) {
                    $A.util.removeClass(container, 'slds-has-error');
                } else {
                    $A.util.addClass(container, 'slds-has-error');
                    $A.createComponent(
                        "aura:html", {
                            tag: "div",
                            HTMLAttributes: {
                                "id": "errorMessageInputField",
                                "class": "slds-form-element__help slds-p-horizontal_xx-small",
                                "style": "margin-top: -.375rem;"
                            },
                            body: "Complete this field."
                        },
                        function (compo) {
                            if (inputCmp.isValid()) {
                                body.splice(body.length, 0, compo);
                                container.set("v.body", body);
                            }
                        }
                    );
                }
            }
            return inputCmp.get('v.fieldName') == 'StageName';
        });
    },
    validateField: function (component, event, helper) {
        return helper.validateField_CloseDateAndExpectedSubmitDate(component, event, helper) &&
            component.find('opptyInputForm').reduce((valid, inputCmp) => {
                var inputFiled = ['Name', 'StageName', 'Expected_submit_date__c', 'CloseDate'];
                if (inputFiled.indexOf(inputCmp.get("v.fieldName")) != -1) {
                    var inputFieldName = inputCmp.get("v.fieldName");
                    var inputFieldValue = inputCmp.get("v.value");
                    var container = component.find(inputFieldName);
                    var body = container.get("v.body");
                    body.forEach((element, index) => {
                        if (index != 0 && element.isValid()) {
                            body.splice(index, 1);
                            element.destroy();
                        }
                    });

                    if (inputFieldValue) {
                        $A.util.removeClass(container, 'slds-has-error');
                        return valid && true;
                    } else {
                        $A.util.addClass(container, 'slds-has-error');
                        $A.createComponent(
                            "aura:html", {
                                tag: "div",
                                HTMLAttributes: {
                                    "id": "errorMessageInputField",
                                    "class": "slds-form-element__help slds-p-horizontal_xx-small"
                                },
                                body: "Complete this field."
                            },
                            function (compo) {
                                if (inputCmp.isValid()) {
                                    body.splice(body.length, 0, compo);
                                    container.set("v.body", body);
                                }
                            }
                        );
                        return valid && false;
                    }
                }
                return valid;
            }, true);
    }
})