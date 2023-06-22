({
    doInit: function (component, event, helper) {
        console.log('Do initial visit plan report!!');
        helper.startSpinner(component);
        var flowType = component.get("v.flowType");
        var action;
        if (flowType == 'QCALeadType') {
            action = component.get("c.getMyVisitPlanReportLastedInforamtion");
            action.setParams({
                "leadObjId": component.get('v.leadObjId'),
                "flowType": component.get('v.flowType'),
                "opptyId": null,
            });
        } else if (flowType == 'QCAOpptyType') {
            action = component.get("c.getMyVisitPlanReportLastedInforamtion");
            action.setParams({
                "leadObjId": null,
                "flowType": component.get('v.flowType'),
                "opptyId": component.get('v.opptyId'),
            });
        }
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var callReportObj = response.getReturnValue();
                // console.log("From server: ", callReportObj);
                if (callReportObj) {
                    component.set('v.varVisitPlanReportRecordId', callReportObj.Id);
                    component.set('v.callReportObj', callReportObj);
                    // var recordUi = event.getParam("recordUi").record;
                    if (callReportObj.Status__c != '1 - Open' &&
                        callReportObj.RecordType.Name != 'Visit Plan for Lead') {
                        component.set('v.isDisabledField', true);
                    }
                    if (callReportObj.Date_of_Visit__c != null) {
                        component.set('v.isDisabledOnlyDateVisitField', true);
                    }
                }
                component.set('v.showOnInit', true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);

        helper.getFieldValuePicklist(component, 'Main_purpose__c', 'Sub_Purpose__c');
    },
    onLoad: function (component, event, helper) {
        console.log('Run on Loading visit plan report!!');
        component.set('v.showOnloading', true);
        // console.log(helper.parseObj(component.get('v.callReportObj')), helper.parseObj(event.getParam("recordUi").record.fields));

        var callReportObj = component.get('v.callReportObj');
        if (callReportObj) {
            var inputfieldName = Object.keys(helper.parseObj(component.get('v.callReportObj')));
            var visitResultFieldName = ['Actual_Visit_Date__c', 'Meeting_Place__c', 'Outcome__c', 'Loss_Incomplete_reason__c', 'Business_talk_and_opportunity__c']
            component.find('VisitPlanFormInput').forEach((inputCmp) => {
                if (inputfieldName.indexOf(inputCmp.get('v.fieldName')) != -1 && visitResultFieldName.indexOf(inputCmp.get('v.fieldName')) != -1) {
                    inputCmp.set('v.value', callReportObj[inputCmp.get('v.fieldName')]);
                }
            });
            component.set('v.showOnloading', true);
        }
    },
    onSubmit: function (component, event, helper) {
        helper.startSpinner(component);
        event.preventDefault();
        // if win oppyt to redirect to product sls
        var recordId = component.get('v.varVisitPlanReportRecordId');
        var eventFields = event.getParam("fields");
        eventFields['Lead__c'] = component.get('v.leadObj.id');
        component.find('visitPlanForm').submit(eventFields);

    },
    onSuccess: function (component, event, helper) {
        helper.stopSpinner(component);
        helper.displayToast(component, 'Success', 'Record updated successfully!')
        var visitPlanReportObj = event.getParam("response");
        // console.log(helper.parseObj(visitPlanReportObj));
        // var compEvent = component.getEvent("varSimplifiedLeadProcessStatus");
        // compEvent.setParams({
        //     "varVisitPlanReportRecordId": visitPlanReportObj.id,
        //     // "showPreScreenForm": true,
        //     "showVisitPlanForm": false,
        // });
        // compEvent.fire();
    },
    onError: function (component, event, helper) {
        console.log('onError :: running!!');
        helper.stopSpinner(component);

    },
    onValidLogVisitHandler: function (component, event, helper) {
        var params = event.getParam('arguments');
        var VisitPlanFormInput = component.find("VisitPlanFormInput");
        var callReportObj = helper.mapFields(VisitPlanFormInput);
        if (params) {
            return helper.validateField(component, helper, callReportObj);
        }
    },
    onSaveLogVisit: function (component, event, helper) {
        var VisitPlanFormInput = component.find("VisitPlanFormInput");
        var callReportObj = helper.mapFields(VisitPlanFormInput);
        // component.set('v.callReportObj.Id', varVisitPlanReportRecordId);
        // component.set('v.callReportObj.RecordTypeId', varVisitPlanReportRecordTypeId);
        callReportObj.Id = component.get('v.varVisitPlanReportRecordId');;
        callReportObj.RecordTypeId = component.get('v.varVisitPlanReportRecordTypeId');
        callReportObj.Lead__c = component.get('v.leadObjId');
        component.set('v.callReportObj', callReportObj);
        // console.log('callReportObj :: ', helper.parseObj(component.get('v.callReportObj')));



        var params = event.getParam('arguments');
        var callback;
        if (params) callback = params.callback;
        var validField = helper.validateField(component, helper, callReportObj);
        // console.log('validField :  ', validField);
        if (validField) {
            if (!component.get('v.isDisabledField')) {
                helper.startSpinner(component);
                var action = component.get('c.UpdateVisitPlanReport')
                action.setParams({
                    "callReportObj": component.get('v.callReportObj'),
                });
                action.setCallback(this, function (response) {
                    helper.stopSpinner(component);
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var callReportObj = response.getReturnValue();
                        component.set('v.isDisabledField', true);
                        callback(callReportObj);
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +
                                    errors[0].message);
                                helper.displayToast(component, 'Error', errors[0].message)
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            } else {
                callback(callReportObj);
            }
        }

    },
    searchAccount: function (component, event, helper) {
        //your criteria
        component.find('VisitPlanFormInput').showHelpMessageIfInvalid();
    },
    onSaveLogVisitOppty: function (component, event, helper) {
        var VisitPlanFormInput = component.find("VisitPlanFormInput");
        var callReportObj = helper.mapFields(VisitPlanFormInput);
        // component.set('v.callReportObj.Id', varVisitPlanReportRecordId);
        // component.set('v.callReportObj.RecordTypeId', varVisitPlanReportRecordTypeId);
        callReportObj.Id = component.get('v.varVisitPlanReportRecordId');;
        callReportObj.RecordTypeId = component.get('v.varVisitPlanReportRecordTypeId');
        callReportObj.Customer_name__c = component.get('v.accId');
        // callReportObj.Lead__c = component.get('v.leadObjId');
        component.set('v.callReportObj', callReportObj);
        // console.log('callReportObj :: ', helper.parseObj(component.get('v.callReportObj')));


        var params = event.getParam('arguments');
        var callback;
        if (params) callback = params.callback;

        var validField = helper.validateField(component, helper, callReportObj);
        // console.log('validField :  ', validField);

        if (validField) {
            if (!component.get('v.isDisabledField')) {
                helper.startSpinner(component);
                var action = component.get('c.UpdateVisitPlanReportOppty')
                action.setParams({
                    "callReportObj": component.get('v.callReportObj'),
                    "opptyId": component.get('v.opptyId'),
                });
                action.setCallback(this, function (response) {
                    helper.stopSpinner(component);
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var callReportObj = response.getReturnValue();
                        component.set('v.isDisabledField', true);
                        callback(callReportObj);
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +
                                    errors[0].message);
                                helper.displayToast(component, 'Error', errors[0].message)
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            } else {
                callback(callReportObj);
            }
        }
    },
    onChanngRemoveInvalidInputField: function (component, event, helper) {
        if (component.get('v.showOnloading'))
            helper.removeInvalidInputField(component, event, helper);
    }
})