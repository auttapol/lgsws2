({
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },

    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },

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
    toNextStage: function (component) {
        var compEvent = component.getEvent("varSimplifiedLeadProcessStatus");
        compEvent.setParams({
            "leadObjId": component.get('v.leadRecordId'),
            "opptyObjId": component.get('v.opptyObjId'),
            "simplifiedLeadProcessStage": 4,
            "isAllowSimplifiedLeadProcessStage": true
        });
        compEvent.fire();
    }
})