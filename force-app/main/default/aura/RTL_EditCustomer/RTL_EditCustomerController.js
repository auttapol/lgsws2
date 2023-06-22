({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        helper.getProfileName(component, event, helper);
    },
    onSuccess: function (component, event, helper) {
        helper.stopSpinner(component);
        var appEvent = $A.get("e.c:RetailCSV_Event");
        appEvent.setParams({
            isRefresh: true,
            recordId: component.get(`v.recordId`),
            fieldUpdate: component.get(`v.fieldUpdate`)
        });
        appEvent.fire();

        helper.displayToast('success', `${$A.get('$Label.c.PDPA_Update_Success')}`);
        helper.closeTab(component);
    },
    handleSectionToggle: function (component, event, helper) {
        component.set('v.activeSections', ['A', 'B', 'C', 'D']);
    },
    onClose: function (component, event, helper) {
        helper.closeTab(component);
    },

    parentAction: function(component, event, helper){
        var params = event.getParam('arguments');
        component.set('v.fieldUpdate', params.fieldValueMap);
        var a = component.get('c.onSuccess');
        $A.enqueueAction(a);
    }
})