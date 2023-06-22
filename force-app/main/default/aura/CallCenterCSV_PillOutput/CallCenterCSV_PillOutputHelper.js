({
    getReference: function (component, event, helper) {
        var value = component.get('v.value');
        if (value) {
            var action = component.get('c.getReference');
            action.setParams({
                "recordId": value
            });
            action.setStorable();
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    component.set('v.label', result);
                } else {
                    component.set('v.isLookup', true);
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(value, error.message)
                    });
                }
            });
            $A.enqueueAction(action);
        }
    },
    getReferenceAddon: function (component, event, helper) {
        var value = component.get('v.value');
        if (value) {
            var action = component.get('c.getReference');
            action.setParams({
                "recordId": value
            });
            action.setStorable();
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    component.set('v.label', result + ' (' + component.get('v.value_addon') + ')');
                } else {
                    component.set('v.isLookup', true);
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(value, error.message)
                    });
                }
            });
            $A.enqueueAction(action);
        }
    }
})