({
    onInit: function (component, event, helper) {
        // console.log(component.get('v.recordId'), component.get('v.userId'));
        helper.startSpinner(component);
    },
    referralHandler: function (component, event, helper) {
        helper.runInit(component, event, helper);
    },
    userHandler: function (component, event, helper) {
        helper.runInit(component, event, helper);
    },

})