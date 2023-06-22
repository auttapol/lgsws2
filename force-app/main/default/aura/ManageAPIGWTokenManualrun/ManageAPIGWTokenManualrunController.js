({
    onInit: function(component, event, helper) {
        component.set('v.isLoadingButtomSection', true);
        component.set('v.isLoadingScheduleJobSection', true);
        component.set('v.isLoadingPlatformCacheSection', true);
        
        helper.getPlatformCacheData(component, helper);
        helper.getNextScheduleJobData(component, helper);
        
        component.set('v.isLoadingButtomSection', false);
    },

    manualrunGetAPIGWToken : function(component, event, helper) {
        component.set('v.manualGetTokenFag', true);
        component.set('v.isLoadingButtomSection', true);

        var action = component.get('c.runGetAPIGWToken');

        action.setCallback(this, function (response) {
            component.set('v.isLoadingButtomSection', false);
            if (response.getState() === 'SUCCESS' && component.isValid()) {
                helper.displayToast('success', 'EnqueueJob ManageAPIGWTokenQueue successful.');
                component.set('v.isLoadingScheduleJobSection', true);
                component.set('v.isLoadingPlatformCacheSection', true);

                setTimeout(function () {
                    helper.getPlatformCacheData(component, helper);
                    helper.getNextScheduleJobData(component, helper);
                }, 3000);

            }else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', errors[0].message);
                    }
                }
            }else{
                helper.displayToast('error', 'ERROR');
            }
        });

        $A.enqueueAction(action);
    },

    refreshPlatformCacheData : function(component, event, helper){
        component.set('v.isLoadingPlatformCacheSection', true);
        helper.getPlatformCacheData(component, helper);
    },

    refreshNextScheduleJobData : function(component, event, helper){
        component.set('v.isLoadingScheduleJobSection', true);
        helper.getNextScheduleJobData(component, helper);

    }
})