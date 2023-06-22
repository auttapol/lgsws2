({
    doInit: function (component, event, helper) {
        helper.getOppty(component, event, helper);
        // helper.getAccount(component, event, helper);
        helper.getProduct(component, event, helper);
        helper.getHost(component, event, helper);
    },

    submitToHostButton: function (component, event, helper) {
        helper.startSpinner(component);
        var opptyObjId = component.get("v.opptyObjId");
        if (opptyObjId != null) {
            helper.startSpinner(component);
            var action = component.get("c.submitToHost");

            action.setParams({
                "opptyId": opptyObjId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.stopSpinner(component);
                    var result = response.getReturnValue();
                    helper.getOppty(component, event, helper);
                                        
                    var flowType = component.get("v.flowType");
                    if (flowType == 'QCALeadType') {
                        var compEvent = component.getEvent("varSimplifiedLeadProcessStatus");
                        compEvent.setParams({
                            "opptyObjId": component.get('v.opptyObjId'),
                            "simplifiedLeadProcessStage": 5,
                            "isAllowSimplifiedLeadProcessStage": false,
                        });
                        compEvent.fire();
                    } else if (flowType == 'QCAOpptyType') {
                        var compEvent = component.getEvent("varSimplifiedOpportunityProcessStatus");
                        compEvent.setParams({
                            "opptyObjId": component.get('v.opptyObjId'),
                            "simplifiedOpportunityProcessStage": 4,
                            "isAllowSimplifiedOpportunityProcessStage": false,
                        });
                        compEvent.fire();
                    }
                } else {
                    helper.stopSpinner(component);
                    var error = response.getError();
                    helper.displayToast(component, "Error", error[0].message);
                }
            });
            $A.enqueueAction(action);
        } else {
            helper.stopSpinner(component);
            helper.displayToast(component, "Error", 'Opportunity Id is null ');
        }
    },

    handleShowNotice: function (component, event, helper) {
        var element = component.find("notify");
        $A.util.toggleClass(element, "slds-hide")
    }
})