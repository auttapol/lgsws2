({
	displayToast : function(component, type, message) {
	    var toastEvent = $A.get('e.force:showToast');
	    toastEvent.setParams({
	      type: type,
	      message: message
	    });
	    toastEvent.fire();
		},

	setSharingEdit: function (component, event, helper) {

		var eClient = component.get("v.eClientObj");
		var action = component.get("c.setManualShareEdit");

		if(eClient == null)
		{
			this.displayToast(component, "Error", $A.get("$Label.c.E_Client_VerifyCustomer_Invalid_E_Client") );
		}
		else
		{
			action.setParams({
				"recId" : eClient.Id, 
				"userId" : eClient.CS_RM__c,
			});

			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {

				}
			});
	
			$A.enqueueAction(action);
		}
	},

	fireErrorEvent: function (message)
	{
		var CSReviewEClientEvent = $A.get("e.c:CSReviewEClientEvent");
		CSReviewEClientEvent.setParams({'confirmSuccess': false });
		CSReviewEClientEvent.setParams({'action': 'error' });
		CSReviewEClientEvent.setParams({'message': message });
		CSReviewEClientEvent.fire();
	}
})