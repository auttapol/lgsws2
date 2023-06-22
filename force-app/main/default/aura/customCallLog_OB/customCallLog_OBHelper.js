({
    initTimeline : function(component, event, helper, isViewMore) {
        var action = component.get("c.getCallLog");
        action.setParams({
            recordId: component.get('v.recordId'),
            recLimit: component.get('v.recordLimit')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                console.log(JSON.stringify(response.getReturnValue()))

                component.set("v.display" , response.getReturnValue().task); 
                component.set('v.marketingCode', response.getReturnValue().marketing_code)
                component.set('v.isViewMore', isViewMore);

                var spinner = component.find("apexSpinner");
                $A.util.toggleClass(spinner, "slds-hide");
               
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
            }
                else if (state === "ERROR") {
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
        });
        $A.enqueueAction(action);
    }
})