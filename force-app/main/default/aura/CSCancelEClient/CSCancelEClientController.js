({
	doInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");

		var action = component.get('c.getEclient');
		action.setParams({
			"recordId": recordId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var eClient =  response.getReturnValue();

				component.set("v.eClientObj",eClient);

				console.log('eClient ',eClient)

			}
		});

		$A.enqueueAction(action);
	},

	cancelConfirm : function(component, event, helper) {

		var eClient = component.get("v.eClientObj");

		if(eClient == null)
		{
			
		}
		else
		{
			if(eClient.CS_Status__c == 'Pending RM TH' ||  eClient.CS_Status__c == 'Pending Sales TH')
			{
				helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_Cancel_Invalid_Msg"));
				$A.get("e.force:closeQuickAction").fire();
			}
			else
			{
				eClient.CS_Status__c = 'Completed';

				var action = component.get("c.updateCurrentEclient");
				action.setParams({
					"eClient": eClient
				});

				action.setCallback(this, function (response) {
					var state = response.getState();
					if (state === "SUCCESS") {

						helper.displayToast(component, "Success", $A.get("$Label.c.E_Client_Cancel_Success_Msg"));
						$A.get('e.force:refreshView').fire();
						$A.get("e.force:closeQuickAction").fire();
					}
					else
					{
						helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_Cancel_Failed_Msg"));
					}
				});

				$A.enqueueAction(action);
			}
		}
		
	},

	cancelAction : function(component, event, helper) {

		$A.get("e.force:closeQuickAction").fire();
		
	},
})