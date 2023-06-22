({
    doInit: function (component, event, helper) {
        component.set("v.onInit", true);
        helper.getRecord(component, event, helper);
    },
    handleConfirm: function (component, event, helper) {
        helper.createSLLGroupHistory(component, event, helper);
    },
    handleCancel: function (component, event, helper) {
        helper.closeSubtab(component, event, helper);
    },
})