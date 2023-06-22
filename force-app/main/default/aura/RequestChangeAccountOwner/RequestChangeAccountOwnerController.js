({
    onInit : function(component, event, helper) {
        helper.showSpinner(component);
        helper.checkRequestPermission(component, helper);
        component.set('v.message', $A.get('$Label.c.RequestChangeOwnerMessage1'));
    },

    handlesubmit : function(component, event, helper){
        helper.submitRequest(component, helper);
    },

    handleCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})