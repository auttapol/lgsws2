({

    doInit: function(component, event, helper){
        var editId = component.get("v.editId")
        //console.log(editId);
        //console.log(component.get("v.planId"));
        if(editId!=''){
            helper.getEditRecord(component, event, helper,editId);
            component.set("v.isEdit",true);
            component.set("v.subtitleText",'Edit');
        }else{
            helper.setFocusedTabLabel(component,event,helper);
            component.set("v.subtitleText",'New');
        }
        
        
    },

    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },

    
    handleCancel : function(component, event, helper) {
        var editMode = component.get("v.isEdit");
        var cancelEvent;
        //Create mode
        var theme = component.get("v.theme")
        
        if(theme=='Theme4u'){
            helper.closeSubtab(component,event,helper);
        }else{
            /*cancelEvent = $A.get("e.force:navigateToRelatedList");
            cancelEvent.setParams({
                "relatedListId": "Visit_Reports__r",
                "parentRecordId": component.get("v.planId")
            }); */
            var cancelEvent = $A.get("e.force:navigateToSObject");
            cancelEvent.setParams({
                "recordId": component.get("v.planId"),
                "slideDevName": "related"
                });
            cancelEvent.fire();
        }
            
        helper.closeSubtab(component,event,helper);
        
    },	

    handleSubmit : function(component, event, helper) {
        event.preventDefault(); // Prevent default submit
        helper.handleFormSubmit(component,event,helper);
        //console.log('handleSubmit');
     
        
    },

    handleSuccess: function(component, event, helper) {
        // Show toast
        var toastEvent = $A.get("e.force:showToast");
        if(component.get("v.isEdit")== true){
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": "Visit Report has been update successfully."
            });
            toastEvent.fire();
        }else{
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": "Visit Report has been create successfully."
            });
            toastEvent.fire();
        ""
        }
        //console.log('before refresh');
        helper.refreshFocusedTab(component, event, helper);
        var id = component.get("v.planId")
        var theme = component.get("v.theme")
        var navigateTo = $A.get("e.force:navigateToSObject");
		var payload = event.getParams().response;
        //navigate to recently update of created
        
        component.set('v.recordId', event.getParam("response").id);
        //helper.closeAndrefreshTab(component,event,helper)
        helper.navigateToObject(component,event,helper,component.get('v.recordId'))

        if(theme =='Theme4u'){
            helper.refreshFocusedTab(component, event, helper);
            navigateTo.setParams({
                "recordId": payload.id,
                "slideDevName": "detail"
                });
            navigateTo.fire();
           
        }else{
            //console.log("hello");
            helper.refreshFocusedTab(component, event, helper);
            navigateTo.setParams({
                "recordId": payload.id,
                "slideDevName": "related"
                });
                
            navigateTo.fire();
        }
        helper.refreshFocusedTab(component, event, helper);
        //helper.closeSubtab(component,event,helper);
    },

})