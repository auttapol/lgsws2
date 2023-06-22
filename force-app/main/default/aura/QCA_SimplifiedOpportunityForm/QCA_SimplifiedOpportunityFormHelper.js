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
    setupStage: function (component) {
        var opptyObjStage = component.get('v.opptyObj.SmartBDM_QuickCA_ProcessStatus__c');
        var tmpStage = ['NewOpportunity', 'Contact', 'AddProduct', 'SubmitSLS'];
        var stage = tmpStage.indexOf(opptyObjStage) != -1 ? tmpStage.indexOf(opptyObjStage) : 0;
        component.set('v.simplifiedOpportunityProcessStage', stage)
        // console.log(opptyObjStage, stage);
    },
    setupSimplifiedOpportunityProcessStatusEvent: function (component, event, helper) {
        component.set("v.opptyId", event.getParam("opptyObjId"));
        
        // console.log(component.get('v.simplifiedOpportunityProcessStatus')[event.getParam("simplifiedOpportunityProcessStage")]);
        if (component.get('v.simplifiedOpportunityProcessStatus')[event.getParam("simplifiedOpportunityProcessStage")] == 'Submit to SLS') {
            component.set('v.isDisabledBackward', true);
        }

        if (event.getParam("isAllowSimplifiedOpportunityProcessStage")) {
            var opptyId = component.get('v.opptyId');
            var action = component.get('c.updateTrackStatus');
            action.setParams({
                "opptyObjId": opptyId,
                "stage": event.getParam("simplifiedOpportunityProcessStage")
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

        component.find('simplifiedOpportunityProcessPath').advanceProgress();
        if(event.getParam("simplifiedOpportunityProcessStage") == 4) component.set("v.simplifiedOpportunityProcessStage", event.getParam("simplifiedOpportunityProcessStage"));
    },
    startSpinner: function (component) {
        component.set('v.showSpinnerLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.showSpinnerLoading', false);
    },
})