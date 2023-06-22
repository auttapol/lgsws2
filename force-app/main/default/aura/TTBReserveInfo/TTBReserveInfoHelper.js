({
    runInitialize: function (component, event, helper) {
       
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.fields'),
            "fields_translate": null
        });
        // action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                objectInfoField.CYC_Campaign_PromoCond_api= {
                    isAccessible : false
                };
                component.set('v.dataFields', objectInfoField);
             
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message);
                });
              
            }
        });
        $A.enqueueAction(action);
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    }
})