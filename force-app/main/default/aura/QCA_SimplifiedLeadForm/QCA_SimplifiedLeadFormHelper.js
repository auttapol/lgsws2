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
            // console.log(params[i].get("v.fieldName"), params[i].get("v.value"));
            var key = params[i].get("v.fieldName");
            var value = params[i].get("v.value");
            tmpObj[key] = value ? value : null;

        }
        return tmpObj;
    },
    setupStage: function (component) {
        var leadObjStage = component.get('v.leadObj.SmartBDM_QuickCA_ProcessStatus__c');
        var tmpStage = ['NewLead', 'Contact', 'AddProduct', 'Convert', 'SubmitSLS'];
        var stage = tmpStage.indexOf(leadObjStage) != -1 ? tmpStage.indexOf(leadObjStage) : 0;
        component.set('v.simplifiedLeadProcessStage', stage)
    },
    setupSimplifiedLeadProcessStatusEvent: function (component, event, helper) {
        component.set("v.leadRecordId", event.getParam("leadObjId"));
        component.set("v.opptyObjId", event.getParam("opptyObjId"));
        
        // console.log(component.get('v.simplifiedLeadProcessStatus')[event.getParam("simplifiedLeadProcessStage")]);
        if (component.get('v.simplifiedLeadProcessStatus')[event.getParam("simplifiedLeadProcessStage")] == 'Submit to SLS') {
            component.set('v.isDisabledBackward', true);
        }
        
        if (event.getParam("isAllowSimplifiedLeadProcessStage")) {
            var leadRecordId = component.get('v.leadRecordId');
            var action = component.get('c.updateTrackStatus');
            action.setParams({
                "leadId": leadRecordId,
                "stage": event.getParam("simplifiedLeadProcessStage")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                } else {
                    var error = response.getError();
                    helper.displayToast(component, "Error", error[0].message);
                }
            });
            $A.enqueueAction(action);
        }
        
        component.find('simplifiedLeadProcessPath').advanceProgress();
        if(event.getParam("simplifiedLeadProcessStage") == 5) component.set("v.simplifiedLeadProcessStage", event.getParam("simplifiedLeadProcessStage"));
        // component.set("v.simplifiedLeadProcessStage", event.getParam("simplifiedLeadProcessStage"));
    },
    startSpinner: function (component) {
        component.set('v.showSpinnerLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.showSpinnerLoading', false);
    },
    getOpportunityId: function (component, event, helper) {
        var action = component.get('c.getMyOpportunityId');
        action.setParams({
            "leadObjId": component.get('v.leadRecordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValues = response.getReturnValue();
                component.set('v.opptyObjId', returnValues);
            } else {
                var error = response.getError();
                console.log(error[0].message);
            }
        });
        $A.enqueueAction(action);
    },

})