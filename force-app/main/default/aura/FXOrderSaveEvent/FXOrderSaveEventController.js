({
	save : function(component, event, helper) {
        component.find("edit").get("e.recordSave").fire();

        var id = component.get("v.recordId");

		var navEvt = $A.get("e.force:navigateToSObject");

        navEvt.setParams({
            "recordId": id
        });
        navEvt.fire();
    },

    handleSaveSuccess : function(component, event) {

        var toastEvent = $A.get('e.force:showToast');
	    toastEvent.setParams({
	      type: "success",
	      message: "The record has been updated successfully."
	    });
	    toastEvent.fire();
    },

})