({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    displayErrorMessage: function (component, isError, message, detail) {
        component.set('v.isError', isError);
        component.set('v.errorDetail', detail ? detail : '');
        component.set('v.errorMessage', message);
    },
    closeTab: function (component) {
        if (component.get('v.theme') == 'Theme4u') {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.openTab({
                        recordId: component.get('v.recordId'),
                        focus: true
                    }).then((res) => {
                        workspaceAPI.closeTab({
                            tabId: focusedTabId
                        });
                    }).catch(err => {
                        console.log(err);
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
        } else {
            var navService = component.find('navService');
            navService.navigate({
                type: 'standard__recordPage',
                attributes: {
                    recordId: component.get('v.recordId'),
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            }, false);
        }
    },

    getProfileName: function (component, event, helper) {
        var action = component.get('c.getProfileName');
        action.setParams({
            "userId": component.get('v.userId'),
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.profileName', result);
                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
})