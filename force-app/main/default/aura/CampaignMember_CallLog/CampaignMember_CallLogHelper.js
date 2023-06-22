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

                component.set("v.display" , response.getReturnValue().task); 
                component.set('v.marketingCode', response.getReturnValue().marketing_code)
                component.set('v.isViewMore', isViewMore);              

                component.set('v.loaded',false);               
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
                component.set('v.loaded',false);
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
                component.set('v.loaded',false);
            }
        });
        $A.enqueueAction(action);
    }
})