({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);

        var action = component.get('c.getAppHPAPStatus');
        action.setParams({
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.hostHPAP', result.length > 0 ? result[0] : component.get('v.hostHPAP'));
                component.set('v.isInitial', true);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
    onSubmit: function (component, event, helper) {
        helper.startSpinner(component);
        var action = component.get('c.submitAppHPAP');
        action.setParams({
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result.isSuccess == false) {
                    component.set('v.iconName', 'action:close');
                    component.set('v.isError', true);
                    component.set('v.errorMessage', result.errorMsg);
                    // helper.displayToast('error', result.errorMsg);
                } else {
                    component.set('v.hostHPAP.RTL_AL_Refer_No__c', result.RTL_AL_Refer_No__c);
                    component.set('v.hostHPAP.RTL_Is_Send_To_HPAP__c', result.RTL_Is_Send_To_HPAP__c);
                    component.set('v.isSubmitted', true);
                    component.set('v.isError', false);
                }
            } else {
                var errors = response.getError();
                errors[0] ? errors[0].pageErrors.forEach(error => {
                    helper.displayToast('error', error.message);
                }) : console.log(errors);
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
    onClose: function (component, event, helper) {
        if (component.get('v.isSubmitted')) {
            $A.get('e.force:refreshView').fire();
        }
        helper.closeModal();
    },
    handleCheckAppHPAPStatus: function (component, event, helper) {
        component.set('v.iconName', component.get('v.hostHPAP.RTL_Is_Send_To_HPAP__c') ? 'action:approval' : 'action:preview');
    },
})