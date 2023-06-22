({
    onInit: function (component, event, helper) {
        component.set('v.calculateRequest', {
            'businessGroupCode': '',
            'salePerYear': null,
            'tmbWcLimit': null,
            'wcLimit': 0,
        });
        helper.getBussinessGroup(component, event, helper);
        // helper.getVFBaseURL(component, event, helper);
        helper.getDeepLink(component, event, helper);
    },
    onSubmitToWC: function (component, event, helper) {
        // Do something on evnet ....
        var validInputField = component.find('inputWorkingCapital').reduce((validSoFar, inputCmp) => {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (!component.get('v.calculateRequest.businessGroupCode')) return;
        if (!component.get('v.calculateRequest.salePerYear')) return;
        if (validInputField) helper.getWorkingCapital(component, event, helper);
    },
    onValidInput: function (component, event, helper) {
        var inputCmp = event.getSource();
        var value = inputCmp.get("v.value");
        if (value < 0) {
            inputCmp.setCustomValidity("จำนวนตัวเลขห้ามน้อยกว่า 0");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity();
    },
    redirectToSmartBDM: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get('v.varDeepLink')
        });
        urlEvent.fire();
    }
})