({
    displayToast: function (component, type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    parseObj: function (objFields) {
        return JSON.parse(JSON.stringify(objFields));
    },
    startSpinner: function (component) {
        component.set('v.showSpinnerLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.showSpinnerLoading', false);
    },
    setDefaultValue: function (component) {
        component.set('v.taskObj.WhoId', component.get('v.leadObjId'));
        component.set('v.taskObj.OwnerId', $A.get("$SObjectType.CurrentUser.Id"));
        component.set('v.taskObj.ActivityDate', $A.localizationService.formatDate(new Date(), "yyyy-MM-dd"));
        // component.set('v.taskObj.RTL_Call_Date_Time__c', $A.localizationService.formatDate(new Date(), "yyyy-MM-ddTHH:mm:00.000Z"));
        component.set('v.taskObj.Status', 'Completed');
        component.set('v.taskObj.Priority', 'Normal');
    },
    validateField: function (component, event, helper) {
        var userCmp = component.find('varUser');
        var validUserCmp = false;
        if (userCmp) {
            userCmp.get('v.value') ? userCmp.hideError() : userCmp.showError('Complete this field.');
            validUserCmp = userCmp.get('v.value') ? true : false;
        }

        return validUserCmp && component.find('varLogACall').reduce((validTotal, inputCmp) => {
            inputCmp.showHelpMessageIfInvalid();
            return validTotal && inputCmp.get('v.validity').valid;
        }, true);
    }
})