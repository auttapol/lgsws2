({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
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
    },

    getPlatformCacheData: function(component, helper){
        var action = component.get('c.getTokenDataInPlatformCache');

        action.setCallback(this, function (response) {
            component.set('v.isLoadingPlatformCacheSection', false);
            if (response.getState() === 'SUCCESS' && component.isValid()) {
                console.log(response.getReturnValue());
                component.set('v.platformCacheWrapper',response.getReturnValue());
                helper.displayToast('success', 'Get getPlatformCacheData successful.');
            }else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', 'getPlatformCacheData: ' + errors[0].message);
                    }
                }
            }else{
                helper.displayToast('error', 'ERROR');
            }
        });

        $A.enqueueAction(action);
    },

    getNextScheduleJobData: function(component, helper){
        var action = component.get('c.getAsyncQueueAPIGWTokenCrontrigger');

        action.setCallback(this, function (response) {
            component.set('v.isLoadingScheduleJobSection', false);
            if (response.getState() === 'SUCCESS' && component.isValid()) {
                console.log(response.getReturnValue());
                component.set('v.cronTriggerObj',response.getReturnValue());
                console.log(component.get('v.cronTriggerObj'));

                helper.displayToast('success', 'Get getAsyncQueueAPIGWTokenCrontrigger successful.');
            }else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', 'getNextScheduleJobData :' + errors[0].message);
                    }
                }
            }else{
                helper.displayToast('error', 'ERROR');
            }
        });

        $A.enqueueAction(action);
    },

})