({
    runLongtermBactch : function(component, event, helper) {
        component.set('v.LongtermBatchDisable', true);
        var action = component.get('c.runForecastPipelineBatch');

        action.setParams({
            batchName: 'Longterm'
        });

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && component.isValid()) {
            }else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', errors[0].message);
                    }
                }
            }
        });

        $A.enqueueAction(action);
    },
    runExistingFeeBactch : function(component, event, helper) {
        component.set('v.ExistingBatchDisable', true);
        var action = component.get('c.runForecastPipelineBatch');

        action.setParams({
            batchName: 'ExistingFee'
        });

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && component.isValid()) {
            }else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', errors[0].message);
                    }
                }
            }
        });

        $A.enqueueAction(action);
    },
    runExpireDrawdownBactch : function(component, event, helper) {
        component.set('v.ExpireDrawdownBatchDisable', true);
        var action = component.get('c.runForecastPipelineBatch');

        action.setParams({
            batchName: 'ExpireDrawdown'
        });

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && component.isValid()) {
            }else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', errors[0].message);
                    }
                }
            }
        });

        $A.enqueueAction(action);
    }
})