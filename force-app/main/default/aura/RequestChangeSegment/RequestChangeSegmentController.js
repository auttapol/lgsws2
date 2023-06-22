({
    doInit: function(component, event, helper){
        component.set("v.onInit",true);
        if(component.get("v.recordId")){
            var recordId = component.get("v.recordId");
            component.set("v.accountId",recordId);
        }
        helper.getRecord(component,event,helper);
    },
    
    handleSubmit : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        helper.handleFormSubmit(component,event,helper);
    },

    handleCancel : function(component, event, helper) {
        helper.closeSubtab(component,event,helper);
    },
})