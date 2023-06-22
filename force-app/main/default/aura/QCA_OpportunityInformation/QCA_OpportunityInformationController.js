({
    onInit: function (component, event, helper) {
        // helper.startSpinner(component);


    },
    onLoad: function (component, event, helper) {
        // console.log('Run on Loading Oppty form');
        component.set('v.showOnloading', true);
        // var opptyId = component.get("v.opptyId");
        // var opptyObj = component.get("v.opptyObj");
        // console.log('opptyId : ' , opptyId);
        // console.log('opptyObj : ', opptyObj);

        // var recordUI = event.getParam("recordUi");
        // console.log(helper.parseObj(recordUI));
        // console.log(component.get('v.leadRecordTypeId'));
        // helper.stopSpinner(component);
    },
    onChangeExpectedSubmitDate: function (component, event, helper) {
        helper.validExpectedSubmitDate(component, event, helper);
    },
    onChangeRemoveValidateField: function (component, event, helper) {
        helper.removeValidateField(component, event, helper);
    },
    onSubmitValidateOpportunity: function (component, event, helper) {
        helper.validateField_CloseDateAndExpectedSubmitDate(component, event, helper);
        helper.validateField_NameAndStageName(component, event, helper);
    },
    onSubmit: function (component, event, helper) {
        helper.startSpinner(component);
        // helper.displayErrorMeassge(component, event, false);
        event.preventDefault();

        var allValid = helper.validateField(component, event, helper);
        if (allValid) {
            var eventFields = helper.setFieldOpportunityForm(component, event, helper);
            component.set('v.opptyObj', eventFields);
            // console.log(helper.parseObj(eventFields));
            component.find('opptyForm').submit(eventFields);
        } else {
            helper.stopSpinner(component);
        }
    },
    onSuccess: function (component, event, helper) {
        helper.displayToast(component, 'Success', 'Record updated successfully!')
        var opptyObj = event.getParam("response");
        // console.log(helper.parseObj(opptyObj));

        if (opptyObj.recordTypeInfo.name == 'SE Credit Product3' && opptyObj.fields.StageName.value == "Closed Lost") {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/n/My_Customer_Quick_CA',
                // "url": '/one/one.app#/alohaRedirect/apex/SmartBDM_MyCustomer_QuickCA',
                "isredirect": true
            });
            urlEvent.fire();
        } else {
            var compEvent = component.getEvent("varSimplifiedOpportunityProcessStatus");
            compEvent.setParams({
                "opptyObjId": opptyObj.id,
                "simplifiedOpportunityProcessStage": 1,
                "isAllowSimplifiedOpportunityProcessStage": true
            });
            compEvent.fire();
        }

        helper.stopSpinner(component);
    },
    onError: function (component, event, helper) {
        console.log('onError :: running!!');
        helper.stopSpinner(component);
        // helper.displayErrorMeassge(component, event, true);
        // console.log(event);
    }
})