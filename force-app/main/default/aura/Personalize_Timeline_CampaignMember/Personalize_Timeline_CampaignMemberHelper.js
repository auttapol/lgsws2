({
    helperMethod: function () {

    },
    checkProfileAssign: function (component, event, helper) {
        var action = component.get('c.checkProfileAssign');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('currentUser:',result); 
                component.set('v.checkProfileAssign', result);
            }
        });

        $A.enqueueAction(action);
    },

})