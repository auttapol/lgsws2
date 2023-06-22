({
    onInit: function (component, event, helper) {
        var action = component.get('c.getLeadFieldValues');
        action.setParams({
            "FieldAPIName": 'Province__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.provinceField', result);
                // console.log(result)
                // component.set('v.limitOffsetRecord', result);
            }
        });
        $A.enqueueAction(action);
    },
    onLoad: function (component, event, helper) {
        // console.log('Run on Loading Lead form');
        console.log('Lead Id :: ', component.get('v.leadObjId'));
        var leadObj = component.get('v.leadObj');

        // if (component.find('varPrimary_Campaign')) component.find('varPrimary_Campaign').set('v.value', leadObj.Primary_Campaign__c);
        // if (component.find('varParent_Company')) component.find('varParent_Company').set('v.value', leadObj.Primary_Campaign__c);
        // if (component.find('varGroup')) component.find('varGroup').set('v.value', leadObj.Primary_Campaign__c);
        // if (component.find('varIndustry')) component.find('varIndustry').set('v.value', leadObj.Primary_Campaign__c);
        // if (component.find('varPreferred_Branch')) component.find('varPreferred_Branch').set('v.value', leadObj.Primary_Campaign__c);
        // if (component.find('varBranch_Referred')) component.find('varBranch_Referred').set('v.value', leadObj.Primary_Campaign__c);
        // if (component.find('varRTL_Referral')) component.find('varRTL_Referral').set('v.value', leadObj.Primary_Campaign__c);

        component.set('v.showOnloading', true);
        component.set('v.isDisabledFeild', component.get('v.leadRecordTypeId') != component.get('v.leadObj.RecordTypeId') && component.get('v.leadObj.RecordTypeId') ? true : false);
        component.set('v.isEditedFieldPrimaryCampaign', leadObj.Primary_Campaign__c ? true || component.get('v.isDisabledFeild') : false);
        component.set('v.isEditedFieldContact', (leadObj.Mobile_No__c ? true : false || leadObj.Office_No__c ? true : false) && component.get('v.isDisabledFeild'));


        // var recordUI = event.getParam("recordUi");
        // console.log(helper.parseObj(recordUI));
        // console.log(helper.parseObj(component.get('v.companyDetail')));

        // console.log(component.get('v.leadRecordTypeId'));
        // helper.stopSpinner(component);
    },
    onSubmitValidateCustomeField: function (component, event, helper) {
        // document.getElementsByName("Company")[0].removeAttribute('required');
        // document.getElementsByName("lastName")[0].removeAttribute('required');

        var leadObj = helper.mapFields(component.find('LeadFormInput'));
        helper.validateField(component, helper, leadObj);
    },
    onSubmit: function (component, event, helper) {
        // console.log('onSubmit :: running!!');
        var LeadForm = Array.isArray(component.find('LeadForm')) ? component.find('LeadForm')[0] : component.find('LeadForm');
        event.preventDefault();
        helper.displayErrorMeassge(component, event, false);
        var leadObjId = component.get('v.leadObjId');
        var eventFields = helper.setFieldLeadForm(component, event, helper);

        var leadObj = eventFields;
        leadObj.Id = leadObjId;
        // Case isDisabledFeild be true is Recordtype is Commercial account
        leadObj.RecordTypeId = component.get('v.isDisabledFeild') ? component.get('v.leadObj.RecordTypeId') : component.get('v.leadRecordTypeId');
        console.log(helper.parseObj(leadObj));
        component.set('v.isValidInputField', helper.validateField(component, helper, leadObj));
        if (component.get('v.isValidInputField')) {
            helper.startSpinner(component);
            var action = component.get("c.validateDuplicateLeadAndAccount");
            action.setParams({
                "leadObj": leadObj
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var leadUpdateRecordWrapper = response.getReturnValue();
                    // console.log("From server: ", leadUpdateRecordWrapper);

                    // if (leadUpdateRecordWrapper.isOwner) {
                    eventFields = leadUpdateRecordWrapper.leadObj;
                    component.set('v.leadObj', helper.parseObj(eventFields));
                    delete eventFields['RecordTypeId'];
                    // }
                    component.set('v.leadObj.Name', component.get('v.leadObj.FirstName') + ' ' + component.get('v.leadObj.LastName'));
                    LeadForm.submit(eventFields);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                            helper.displayToast(component, 'Error', errors[0].message);
                            // helper.displayErrorMeassge(component, errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    helper.stopSpinner(component);
                }
            });
            $A.enqueueAction(action);
        }
    },
    onSuccess: function (component, event, helper) {
        // console.log('new lead form response :: ', helper.parseObj(event.getParam("response")));
        helper.updateLeadDetail(component, event, helper);

        var leadObj = event.getParam("response");
        if (leadObj.fields.Status.value == "Unqualified") {
            helper.displayToast(component, 'Error', $A.get("$Label.c.Lead_is_disqualified_error_message"));
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/n/My_Lead_Quick_CA',
                // "url": '/one/one.app#/alohaRedirect/apex/SmartBDM_MyLead_QuickCA',
                "isredirect": true
            });
            urlEvent.fire();
        } else {
            helper.displayToast(component, 'Success', 'Record updated successfully!');
            var compEvent = component.getEvent("varSimplifiedLeadProcessStatus");
            compEvent.setParams({
                "leadObjId": leadObj.id,
                "simplifiedLeadProcessStage": 1,
                "isAllowSimplifiedLeadProcessStage": true
            });
            compEvent.fire();
        }
        helper.stopSpinner(component);
    },
    onError: function (component, event, helper) {
        // console.log('onError :: running!!');
        helper.stopSpinner(component);
        helper.displayErrorMeassge(component, event, true);
    },
    onChanngRemoveInvalidInputField: function (component, event, helper) {
        if (component.get('v.showOnloading'))
            helper.removeInvalidInputField(component, event, helper);
    },
    onShowSearchingCompany: function (component, event, helper) {
        helper.toggleSearchingCompanyModal(component);
    },
    onSearchingCompany: function (component, event, helper) {
        var enliteSearchCompanyCmp = component.find('enliteSearchCompany');
        var typeKey = component.get('v.searchingCompanyKey');

        var inputCmp = component.find('inputSearching');
        if (!inputCmp.get('v.value')) {
            inputCmp.set('v.validity', {
                valid: false,
                valueMissing: true
            });
            inputCmp.showHelpMessageIfInvalid();
            // inputCmp.setCustomValidity($A.get('$Label.c.Error_message_searching_input'));
            // inputCmp.reportValidity();
            // } else if (!inputCmp.checkValidity()) {
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
            inputCmp.reportValidity();
        }

        if (!typeKey) return;
        if (inputCmp.get('v.validity').valid) enliteSearchCompanyCmp.searchingCompany(typeKey);
    },
    onHandlerCompanyEvent: function (component, event, helper) {
        var isSuccess = event.getParam("isSuccess") ? true : false;
        var errorMessage = event.getParam("errorMessage");
        var type = event.getParam("type");

        if (type == 'inputSearched') {
            component.set('v.isSearching', isSuccess);
        } else if (type == 'spinnerSelected') {
            component.set('v.showSpinnerLoadingOnModal', isSuccess);
        } else if (type == 'clickSelected') {
            component.set('v.isSelectedCompanyList', isSuccess);
        } else if (type == 'errorMessage') {
            var inputCmp = component.find('inputSearching');
            if (isSuccess) {
                inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
            } else {
                inputCmp.setCustomValidity(errorMessage);
            }
            inputCmp.reportValidity();
        }

        // get detail on companyDetail exist
        if (event.getParam("companyDetail")) {
            helper.rerenderNewLeadForm(component, event, helper);
        }
    },
    onValidateInputSearching: function (component, event, helper) {
        var inputCmp = event.getSource();
        if (inputCmp.get('v.validity').valueMissing && inputCmp.get('v.validity').tooShort) {
            inputCmp.setCustomValidity($A.get("$Label.c.Error_message_searching_input"));
        } else {
            inputCmp.setCustomValidity('');
        }
        // inputCmp.showHelpMessageIfInvalid();
        inputCmp.reportValidity();

    },
    onSelectedCompanyDetail: function (component, event, helper) {
        var enliteSearchCompanyCmp = component.find('enliteSearchCompany');
        if (enliteSearchCompanyCmp.get('v.companySelected')) enliteSearchCompanyCmp.submitSelected();
    },
})