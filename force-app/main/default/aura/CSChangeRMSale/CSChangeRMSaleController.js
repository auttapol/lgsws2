({
	doInit: function (component, event, helper) {

		helper.getCurrentUser(component);
		helper.getEclient(component, event, helper);

	},

	reviewerConfirm : function(component, event, helper) {

		var eClient = component.get("v.eClientCanChange");
		var getRM = component.get("v.selectedRm");
		var getFX = component.get("v.selectedFx");
		
		if(eClient == null || getRM == null || getFX == null )
		{
			helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_ChangeRM_Invalid_ChangeRM_Msg"));
		}
		else
		{
			helper.ChangeOnListView(component);
		}
	},

	reviewerCancel : function(component, event, helper) {

		$A.get("e.force:closeQuickAction").fire();

		var CSReviewEClientEvent = $A.get("e.c:CSReviewEClientEvent");
		CSReviewEClientEvent.setParams({'confirmSuccess': false });
		CSReviewEClientEvent.setParams({'action': 'cancel' });
		CSReviewEClientEvent.fire();
	},
	

	handleComponentEvent : function(component, event, helper) {
      
			var selectedAccountGetFromEvent = event.getParam("accountByEvent");
			var getNameLookup = event.getParam("lookupName");

			if(getNameLookup == "RM")
			{
				component.set("v.selectedRm" , selectedAccountGetFromEvent); 
			}
			else if(getNameLookup == "FX")
			{
				component.set("v.selectedFx" , selectedAccountGetFromEvent); 
			}
		},
})