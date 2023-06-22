({
    calloutService: function (component, event, helper) {
        helper.calloutService(component, event, helper);
    },
    calloutGuarantorService: function (component, event, helper) {
        helper.calloutGuarantorService(component, event, helper);
    },
    getProducts: function (component, event, helper) {
        return component.get('v.product');
    },
    getGuarantor: function (component, event, helper) {
        return component.get('v.guarantor');
    },
    getError: function (component, event, helper) {
        var params = event.getParam('arguments');
        var type = params ? params.type : null;
        return type ? component.get(`v.error.${type}`) : null;
    },
})