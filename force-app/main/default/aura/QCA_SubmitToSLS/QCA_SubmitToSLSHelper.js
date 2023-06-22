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

    getOppty: function (component, event, helper) {

        var opptyObjId = component.get("v.opptyObjId");
        if (opptyObjId != null) {
            var action = component.get("c.getOppty");

            action.setParams({
                "opptyId": opptyObjId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var oppty = response.getReturnValue();
                    component.set("v.oppty", oppty);

                }
            });
            $A.enqueueAction(action);
        } else {
            helper.displayToast(component, "Error", 'Opportunity Id is null ');
        }
    },

    // getAccount: function (component, event, helper) {
    //     var opptyObjId = component.get("v.opptyObjId");
    //     if (opptyObjId != null) {
    //         var action = component.get("c.getAccount");

    //         action.setParams({
    //             "opptyId": opptyObjId
    //         });
    //         action.setCallback(this, function (response) {
    //             var state = response.getState();
    //             if (state === "SUCCESS") {

    //                 var acc = response.getReturnValue();
    //                 component.set("v.acc", acc);
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     } else {
    //         helper.displayToast(component, "Error", 'Opportunity Id is null ');
    //     }
    // },

    getProduct: function (component, event, helper) {
        var opptyObjId = component.get("v.opptyObjId");
        if (opptyObjId != null) {
            var action = component.get("c.getProductionList");

            action.setParams({
                "opptyId": opptyObjId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.listOpportunityProduct2", result);
                    // console.log('listOpportunityProduct2: ', result);
                  
                }
            });
            $A.enqueueAction(action);
        } else {
            helper.displayToast(component, "Error", 'Opportunity Id is null ');
        }
    },

    getHost: function (component, event, helper) {
        var action = component.get("c.getHost");

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.host", result);

            }
        });
        $A.enqueueAction(action);
    },
    
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },
})