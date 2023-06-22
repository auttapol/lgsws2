({
    doInit: function (component, event, helper) {
        component.set('v.isInitial', true);
        helper.getRecord(component, event, helper);
    },
    handleCancel: function (component, event, helper) {
        helper.closeSubtab(component, event, helper);
        helper.refreshFocusedTab(component, event, helper);
    },
    handleConfirm: function (component, event, helper) {
        component.set("v.isLoading", true);
        var round = 0;
        helper.sendRequest(component, event, helper, round);
    },
    handleRefresh: function (component, event, helper) {
        component.set("v.isLoading", true);
        helper.getRecord(component, event, helper);
    },
})