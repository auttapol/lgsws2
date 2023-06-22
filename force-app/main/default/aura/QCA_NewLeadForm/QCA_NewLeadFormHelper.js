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
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },
    toggleSearchingCompanyModal: function (component) {
        component.set('v.showSearchingCompany', !component.get('v.showSearchingCompany'));
        component.set('v.isSearching', false);
        component.set('v.isSelectedCompanyList', false);
        // component.set('v.searchingCompanyKey', '');
    },
    rerenderNewLeadForm: function (component, event, helper) {
        component.set('v.isSelectedCompanyList', true);
        var enliteSearchCompanyCmp = component.find('enliteSearchCompany');
        var companyDetail = enliteSearchCompanyCmp.get('v.companyDetailSelected');
        var mapFieldCompanyDetail = {
            'Customer_Type__c': 'Juristic',
            'Company': companyDetail.Name,
            'Mobile_No__c': companyDetail.Mobile_Number_PE__c,
            'Office_No__c': companyDetail.RTL_Office_Phone_Number__c,
            'Ext__c': companyDetail.Primary_Phone_Ext_PE__c,
            'ID_Type__c': 'BRN ID',
            'ID_Number__c': companyDetail.ID_Number_PE__c,
            // 'Country__c': 'Thailand',
            'Zipcode__c': companyDetail.Zip_Code_Registered_PE__c,
            'Province__c': component.get('v.provinceField').reduce((list, item) => {
                list.push(item.value);
                return list;
            }, []).find((value) => {
                return value == companyDetail.Province_Registered_PE__c;
            }),
            'Address_Line_3__c': companyDetail.Registered_Address_Line_3_PE__c,
            'Address_Line_2__c': companyDetail.Registered_Address_Line_2_PE__c,
            'Address_Line_1__c': companyDetail.Registered_Address_Line_1_PE__c,
        }
        component.set('v.companyDetail', mapFieldCompanyDetail);
        component.set('v.hasChangeRecordEditForm', false);

        component.set('v.refreshRecordEditForm', false);
        component.set('v.refreshRecordEditForm', true);
        component.set('v.tabSet', 'Other_Info');
        setTimeout(function () {
            component.set('v.tabSet', 'Lead_Info');
            component.set('v.showSpinnerLoadingOnModal', false);
            component.set('v.isSelectedCompanyList', false);
            helper.toggleSearchingCompanyModal(component);
        }, 800);
    },
    setFieldLeadForm: function (component, event, helper) {
        var eventFields = event.getParam("fields");
        if (!eventFields['Pre_screening_Result__c']) eventFields['Pre_screening_Result__c'] = 'Passed';
        if (!eventFields['Status']) eventFields['Status'] = 'Passed Prescreening';
        if (component.find('varPrimary_Campaign')) eventFields['Primary_Campaign__c'] = component.find('varPrimary_Campaign').get('v.value');
        if (component.find('varParent_Company')) eventFields['Parent_Company__c'] = component.find('varParent_Company').get('v.value');
        if (component.find('varGroup')) eventFields['Group__c'] = component.find('varGroup').get('v.value');
        if (component.find('varIndustry')) eventFields['Industry__c'] = component.find('varIndustry').get('v.value');
        if (component.find('varPreferred_Branch')) eventFields['Preferred_Branch__c'] = component.find('varPreferred_Branch').get('v.value');
        if (component.find('varBranch_Referred')) eventFields['Branch_Referred__c'] = component.find('varBranch_Referred').get('v.value');
        if (component.find('varRTL_Referral')) eventFields['RTL_Referral__c'] = component.find('varRTL_Referral').get('v.value');

        // from search company detail
        if (Object.keys(component.get('v.companyDetail')).length != 0 && !component.get('v.hasChangeRecordEditForm')) {
            eventFields['Customer_Type__c'] = component.get('v.companyDetail')['Customer_Type__c'];
            eventFields['Company'] = component.get('v.companyDetail')['Company'];
            eventFields['Mobile_No__c'] = component.get('v.companyDetail')['Mobile_No__c'];
            eventFields['Office_No__c'] = component.get('v.companyDetail')['Office_No__c'];
            eventFields['Ext__c'] = component.get('v.companyDetail')['Ext__c'];
            eventFields['ID_Type__c'] = component.get('v.companyDetail')['ID_Type__c'];
            eventFields['ID_Number__c'] = component.get('v.companyDetail')['ID_Number__c'];

            eventFields['Country__c'] = component.get('v.companyDetail')['Country__c'];
            eventFields['Zipcode__c'] = component.get('v.companyDetail')['Zipcode__c'];
            eventFields['Province__c'] = component.get('v.companyDetail')['Province__c'];
            eventFields['Address_Line_3__c'] = component.get('v.companyDetail')['Address_Line_3__c'];
            eventFields['Address_Line_2__c'] = component.get('v.companyDetail')['Address_Line_2__c'];
            eventFields['Address_Line_1__c'] = component.get('v.companyDetail')['Address_Line_1__c'];
        }
        return eventFields;
    },
    updateLeadDetail: function (component, event, helper) {
        var leadObjId = event.getParam("response").id;
        var leadObj = component.get('v.leadObj');
        if (!leadObj.Id) leadObj.Id = leadObjId;

        var action = component.get("c.updateLeadDetail");
        action.setParams({
            "leadObj": leadObj
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        helper.displayToast(component, 'Error', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    displayErrorMeassge: function (component, event, isDisplay) {
        if (isDisplay) {
            var tabSetId = ['Lead_Info', 'Other_Info', 'Detail_Info', 'Lead_Source'];
            var leadInfoTab = ['Customer_Type__c', 'Company', 'ID_Type__c', 'Customer_Name_EN__c', 'ID_Number__c', 'Mobile_No__c', 'Name', 'Phone__c', 'Title', 'Decision_Map__c']
            var otherInfoTab = ['Office_No__c', 'Ext__c', 'Email__c', 'Country__c', 'Province__c', 'Address_Line_2__c', 'Zipcode__c', 'Address_Line_3__c', 'Address_Line_1__c'];
            var detailInfoTab = ['Rating', 'Total_Expected_Revenue__c', 'Link_Document__c', 'Sales_amount_per_year__c', 'No_of_Years_Business_Run__c'];
            var leadSourceTab = ['Referral_Staff_ID__c', 'Referral_Staff_Name__c', 'LeadSource', 'Other_Source__c'];

            var output = event.getParam('output');
            var errorMessageList = Object.keys(output.fieldErrors).reduce((list, fieldName) => {
                if (leadInfoTab.indexOf(fieldName) != -1) {
                    component.set('v.tabSet', tabSetId[0]);
                } else if (otherInfoTab.indexOf(fieldName) != -1) {
                    component.set('v.tabSet', tabSetId[1]);
                } else if (detailInfoTab.indexOf(fieldName) != -1) {
                    component.set('v.tabSet', tabSetId[2]);
                } else if (leadSourceTab.indexOf(fieldName) != -1) {
                    component.set('v.tabSet', tabSetId[3]);
                }
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
    validateField: function (component, helper, leadObj) {
        // console.log(helper.parseObj(leadObj));
        var leadObj = helper.parseObj(leadObj);
        var validInputFieldCritical = ['Salutation', 'FirstName', 'LastName'];
        var validInputFiledContact = ['Mobile_No__c', 'Office_No__c'];
        var validInputField = ['Customer_Type__c', 'ID_Type__c', 'ID_Number__c', 'Company', 'Phone__c'];
        var allValid_validInputField = component.find('LeadFormInput').reduce((validSoFar, inputCmp) => {
            if (validInputField.indexOf(inputCmp.get("v.fieldName")) != -1) {
                var inputFieldName = validInputField[validInputField.indexOf(inputCmp.get("v.fieldName"))];
                var inputFieldValue = leadObj[inputFieldName];
                var container = component.find(inputFieldName);

                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        element.destroy();
                        body.splice(index, 1);
                    }
                });
                // console.log(inputCmp.get("v.fieldName"), inputCmp.get("v.value"));
                // console.log(inputCmp.get("v.fieldName"), inputFieldName, inputFieldValue);
                // console.log(validSoFar, inputFieldValue, inputCmp.isValid());

                if (inputFieldValue) {
                    $A.util.removeClass(inputCmp, 'slds-has-error');
                    $A.util.removeClass(container, 'slds-has-error');
                    // if (body.length == 2) body[1].destroy();
                    return validSoFar && true;
                } else {
                    $A.util.addClass(inputCmp, 'slds-has-error');
                    $A.util.addClass(container, 'slds-has-error');
                    $A.createComponent(
                        "aura:html", {
                            tag: "div",
                            HTMLAttributes: {
                                "id": "errorMessageInputField",
                                "class": "slds-form-element__help"
                            },
                            body: "Complete this field."
                        },
                        function (compo) {
                            if (inputCmp.isValid() && inputFieldName != 'Company') {
                                // var body = container.get("v.body");
                                body.splice(body.length, 0, compo);
                                container.set("v.body", body);
                            } else if (inputCmp.isValid() && !component.get('v.isValidInputFieldCompany') && inputFieldName == 'Company') {
                                body.splice(body.length, 0, compo);
                                container.set("v.body", body);
                                component.set('v.isValidInputFieldCompany', true);
                            }
                        }
                    );
                    return validSoFar && false;
                }
            }
            return validSoFar;
        }, true);

        var validInputField_Name = validInputFieldCritical.reduce((valid, inputFieldName) => {
            var inputFieldValue = leadObj[inputFieldName];
            // console.log(valid, inputFieldValue, valid && inputFieldValue ? true : false);
            return valid && inputFieldValue ? true : false;
        }, true);

        var fieldName_Name = component.find('LeadFormInput').find((inputCmp) => {
            return inputCmp.get('v.fieldName') == 'Name';
        });
        if (fieldName_Name.get('v.fieldName') == 'Name') {
            var container = component.find(fieldName_Name.get('v.fieldName'));
            var body = container.get("v.body");
            body.forEach((element, index) => {
                if (index != 0 && element.isValid()) {
                    element.destroy();
                }
            });
            if (validInputField_Name) {
                $A.util.removeClass(fieldName_Name, 'slds-has-error');
                $A.util.removeClass(container, 'slds-has-error');
            } else {
                $A.util.addClass(fieldName_Name, 'slds-has-error');
                $A.util.addClass(container, 'slds-has-error');
                $A.createComponent(
                    "aura:html", {
                        tag: "div",
                        HTMLAttributes: {
                            "id": "errorMessageInputField",
                            "class": "slds-form-element__help"
                        },
                        body: "Complete this field."
                    },
                    function (compo) {
                        if (fieldName_Name.isValid()) {
                            body.forEach(element => {
                                if (element.isValid()) {
                                    body.push(compo);
                                }
                            });
                            container.set("v.body", body);
                        }
                    }
                );
            }
        }

        // Mobile_No__c, Office_No__c
        var inputCmp_Contact_MobileNo = component.find('LeadFormInput').find((inputCmp) => {
            if (inputCmp.get('v.fieldName') == validInputFiledContact[0]) {

                var container = component.find(inputCmp.get('v.fieldName'));
                $A.util.removeClass(container, 'slds-has-error');

                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        body.splice(index, 1);
                        element.destroy();
                    }
                });
            }
            return inputCmp.get('v.fieldName') == validInputFiledContact[0];
        });
        var inputCmp_Contact_OfficeNo = component.find('LeadFormInput').find((inputCmp) => {
            if (inputCmp.get('v.fieldName') == validInputFiledContact[1]) {

                var container = component.find(inputCmp.get('v.fieldName'));
                $A.util.removeClass(container, 'slds-has-error');

                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        body.splice(index, 1);
                        element.destroy();
                    }
                });
            }
            return inputCmp.get('v.fieldName') == validInputFiledContact[1];
        });
        var validContact = (inputCmp_Contact_MobileNo.get('v.value') ? true : false || inputCmp_Contact_OfficeNo.get('v.value') ? true : false);

        if (!validContact) {
            var container_MobileNo = component.find(inputCmp_Contact_MobileNo.get('v.fieldName'));
            var container_OfficeNo = component.find(inputCmp_Contact_OfficeNo.get('v.fieldName'));
            $A.util.addClass(container_MobileNo, 'slds-has-error');
            $A.util.addClass(container_OfficeNo, 'slds-has-error');

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
                    if (inputCmp_Contact_MobileNo.isValid()) {
                        var body = container_MobileNo.get("v.body");
                        body.splice(body.length, 0, compo);
                        container_MobileNo.set("v.body", body);
                    }
                    if (inputCmp_Contact_MobileNo.isValid()) {
                        var body = container_OfficeNo.get("v.body");
                        body.splice(body.length, 0, compo);
                        container_OfficeNo.set("v.body", body);
                    }
                }
            );

        }

        return allValid_validInputField && validInputField_Name && validContact;
    },
    removeInvalidInputField: function (component, event, helper) {
        component.set('v.hasChangeRecordEditForm', true);
        var validInputFieldCritical = ['Customer_Type__c', 'ID_Type__c'];
        var validInputField = ['ID_Number__c', 'Phone__c', 'Company']; // 'Company',
        var inputCmp = event.getSource();
        var inputFieldName = inputCmp.get('v.fieldName');
        var inputFieldValue = inputCmp.get('v.value');
        var container = component.find(inputFieldName);

        if (validInputField.indexOf(inputFieldName) != -1) {
            if (inputFieldValue) {
                $A.util.removeClass(inputCmp, 'slds-has-error');
                $A.util.removeClass(container, 'slds-has-error');
                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        body.splice(index, 1);
                        element.destroy();
                    }
                });
            } else {
                // $A.util.addClass(inputCmp, 'slds-has-error');
                $A.util.addClass(container, 'slds-has-error');
                $A.createComponent(
                    "aura:html", {
                        tag: "div",
                        HTMLAttributes: {
                            "id": "errorMessageInputField",
                            "class": "slds-form-element__help"
                        },
                        body: "Complete this field."
                    },
                    function (compo) {
                        var body = container.get("v.body");
                        if (inputCmp.isValid() || !component.get('v.isValidInputFieldCompany')) {
                            body.splice(body.length, 0, compo);
                            container.set("v.body", body);
                            component.set('v.isValidInputFieldCompany', true);
                        }
                    }
                );
            }
        }

        if (validInputFieldCritical.indexOf(inputFieldName) != -1) {
            var body = container.get("v.body");
            body.forEach((element, index) => {
                if (index != 0 && element.isValid()) {
                    element.destroy();
                }
            });
            if (inputFieldValue) {
                $A.util.removeClass(inputCmp, 'slds-has-error');
                $A.util.removeClass(container, 'slds-has-error');
            } else {
                if (component.get('v.onInitValidInputField')) {
                    $A.util.addClass(inputCmp, 'slds-has-error');
                    $A.util.addClass(container, 'slds-has-error');
                    $A.createComponent(
                        "aura:html", {
                            tag: "div",
                            HTMLAttributes: {
                                "id": "errorMessageInputField",
                                "class": "slds-form-element__help"
                            },
                            body: "Complete this field."
                        },
                        function (compo) {
                            if (inputCmp.isValid()) {
                                // var body = container.get("v.body");
                                body.forEach(element => {
                                    if (element.isValid()) {
                                        body.push(compo);
                                    }
                                });
                                container.set("v.body", body);
                            }
                        }
                    );
                }
            }
        }

        if (inputFieldName == 'Name') {
            // console.log(helper.parseObj(inputFieldValue));
            var Salutation = inputFieldValue.Salutation ? true : false;
            var FirstName = inputFieldValue.FirstName ? true : false;
            var LastName = inputFieldValue.LastName ? true : false;
            var validInputField_Name = (Salutation && FirstName && LastName);

            var body = container.get("v.body");
            body.forEach((element, index) => {
                if (index != 0 && element.isValid()) {
                    element.destroy();
                }
            });
            if (validInputField_Name) {
                $A.util.removeClass(inputCmp, 'slds-has-error');
                $A.util.removeClass(container, 'slds-has-error');
            } else {
                if (component.get('v.onInitValidInputField')) {
                    $A.util.addClass(inputCmp, 'slds-has-error');
                    $A.util.addClass(container, 'slds-has-error');
                    $A.createComponent(
                        "aura:html", {
                            tag: "div",
                            HTMLAttributes: {
                                "id": "errorMessageInputField",
                                "class": "slds-form-element__help"
                            },
                            body: "Complete this field."
                        },
                        function (compo) {
                            if (inputCmp.isValid()) {
                                body.forEach(element => {
                                    if (element.isValid() && LastName) {
                                        body.push(compo);
                                    }
                                });
                                container.set("v.body", body);
                            }
                        }
                    );
                } else {
                    component.set('v.onInitValidInputField', true);
                }
            }
        }

        if (inputFieldName == 'Mobile_No__c' || inputFieldName == 'Office_No__c') {
            if (inputFieldValue) {
                // $A.util.removeClass(inputCmp, 'slds-has-error');
                $A.util.removeClass(component.find('Mobile_No__c'), 'slds-has-error');
                $A.util.removeClass(component.find('Office_No__c'), 'slds-has-error');
                $A.util.removeClass(component.find('Mobile_No__c'), 'customRequiredField');
                $A.util.removeClass(component.find('Office_No__c'), 'customRequiredField');

                var body = component.find('Mobile_No__c').get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        body.splice(index, 1);
                        element.destroy();
                    }
                });
                var body = component.find('Office_No__c').get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        body.splice(index, 1);
                        element.destroy();
                    }
                });
            } else {
                // $A.util.addClass(inputCmp, 'slds-has-error');
                $A.util.addClass(container, 'slds-has-error');
                $A.util.addClass(container, 'customRequiredField');
                $A.createComponent(
                    "aura:html", {
                        tag: "div",
                        HTMLAttributes: {
                            "id": "errorMessageInputField",
                            "class": "slds-form-element__help"
                        },
                        body: "Complete this field."
                    },
                    function (compo) {
                        if (inputCmp.isValid()) {
                            var body = container.get("v.body");
                            if (inputCmp.isValid()) {
                                body.splice(body.length, 0, compo);
                                container.set("v.body", body);
                            }
                        }
                    }
                );
            }
        }
    }
})