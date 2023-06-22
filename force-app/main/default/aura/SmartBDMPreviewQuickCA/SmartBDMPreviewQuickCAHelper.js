({
    displayToast: function (component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
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

    getDeeplink: function (component, event, helper) {
        var action = component.get("c.getDeepLink");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var getDeepLink = response.getReturnValue();
                component.set('v.varDeepLink', getDeepLink);
            }
        });
        $A.enqueueAction(action);
    },

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
})