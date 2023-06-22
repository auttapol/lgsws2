({

	doInit: function (component, event, helper) {
		var eclientId = component.get("v.recordId");
		var action = component.get("c.getCurrentEclient");

		action.setParams({
			"eclientId": eclientId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var eClient =  response.getReturnValue();

				component.set("v.eClientObj",eClient);
				component.set("v.hasEclient",true);
				component.set("v.stepName","VerifyCustomer");

				var eClient = component.get("v.eClientObj");
				if(eClient == null)
				{
					component.set("v.stepName","GetError");
					helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_VerifyCustomer_Invalid_E_Client"));
					helper.fireErrorEvent($A.get("$Label.c.E_Client_VerifyCustomer_Invalid_E_Client"));	
					
				}
				if(eClient.CS_Status__c == null)
				{
					component.set("v.stepName","GetError");
					helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_VerifyCustomer_Not_Pending"));		
					helper.fireErrorEvent($A.get("$Label.c.E_Client_VerifyCustomer_Not_Pending"));	
							
				}
				if(eClient.CS_Status__c == 'Overdue' || eClient.CS_Status__c == 'Pending Review')
				{
					component.set("v.stepName","VerifyCustomer");
					if(eClient.CS_New_Customer_flag__c == true)
					{
						component.set("v.isChecked", true);
					}
				}
				else
				{
					component.set("v.stepName","GetError");
					helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_VerifyCustomer_Not_Pending"));
					helper.fireErrorEvent($A.get("$Label.c.E_Client_VerifyCustomer_Not_Pending"));	
					
				}
				
			}
		});
		$A.enqueueAction(action);

	},

	verifyYes : function(component, event, helper) {

		var eClient = component.get("v.eClientObj");
		var isChecked = component.get("v.isChecked");

		if(eClient == null)
		{
			
		}
		else
		{
			eClient.CS_Basic_Flag__c = true;
			eClient.CS_Status__c = 'Completed';

			if(isChecked == true)
			{
				eClient.CS_New_Customer_flag__c = true;
			}
			else
			{
				eClient.CS_New_Customer_flag__c = false;
			}

			var action = component.get("c.updateCurrentEclientToBasic");
			action.setParams({
				"eClient": eClient
			});

			action.setCallback(this, function (response) {
				var state = response.getState();
				var message = '';
				if (state == "SUCCESS") {

					var eClient =  response.getReturnValue();

					if( eClient != null )
					{

						component.set("v.eClientObj",eClient);
						component.set("v.hasEclient",true);

						helper.displayToast(component, "Success",$A.get("$Label.c.E_Client_VerifyCustomer_Update_To_Basic"));

						$A.get('e.force:refreshView').fire();
						$A.get("e.force:closeQuickAction").fire();

						var CSReviewEClientEvent = $A.get("e.c:CSReviewEClientEvent");
						CSReviewEClientEvent.setParams({'confirmSuccess': false });
						CSReviewEClientEvent.setParams({'action': 'verifyYes' });
						CSReviewEClientEvent.setParams({'message': $A.get("$Label.c.E_Client_VerifyCustomer_Update_To_Basic") });
						CSReviewEClientEvent.fire();
					}
					else
					{
						helper.displayToast(component, "Error",$A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Failed"));
						helper.fireErrorEvent($A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Failed"));

					}

				}
				else
				{
					helper.displayToast(component, "Error",$A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Failed"));
					helper.fireErrorEvent($A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Failed"));
				}


			});

			$A.enqueueAction(action);

		}
		
	},

	verifyNo : function(component, event, helper) {

		var eClient = component.get("v.eClientObj");
		var isChecked = component.get("v.isChecked");

		if(isChecked == true)
		{
			eClient.CS_New_Customer_flag__c = true;
		}
		else
		{
			eClient.CS_New_Customer_flag__c = false;
		}

		component.set("v.stepName","ConfirmReviewer");
		
	},

	reviewerConfirm : function(component, event, helper) {

		var eClient = component.get("v.eClientObj");

		var getRM = component.get("v.selectedRm");
		var getFX = component.get("v.selectedFx");

		if(eClient == null)
		{
			
		}
		else
		{
			eClient.CS_Basic_Flag__c = false;
			eClient.CS_Status__c = 'Reviewing';
				
			eClient.CS_RM__c = getRM.Id;
			eClient.CS_Sales_Owner__c = getFX.Id;
			eClient.OwnerId = getFX.Id;

			var action = component.get("c.confirmEclient");
			action.setParams({
				"eClient": eClient,
			});
		
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state == "SUCCESS") {
						
					if(eClient == null)
					{
						helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Data_Invalid"));	
						helper.fireErrorEvent($A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Data_Invalid"));	

					}
					else
					{
						helper.displayToast(component, "Success", $A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Success"));

						var CSReviewEClientEvent = $A.get("e.c:CSReviewEClientEvent");
						CSReviewEClientEvent.setParams({'confirmSuccess': true });
						CSReviewEClientEvent.setParams({'action': 'confirm' });
						CSReviewEClientEvent.setParams({'message': $A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Success") });
     					CSReviewEClientEvent.fire();
					}	
					
					$A.get('e.force:refreshView').fire();
					$A.get("e.force:closeQuickAction").fire();

				}
				else
				{
					helper.displayToast(component, "Error",$A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Failed"));
					helper.fireErrorEvent($A.get("$Label.c.E_Client_VerifyCustomer_E_Client_Review_Failed"));	

				}
			});
		
			$A.enqueueAction(action);
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

	updateCheckboxChoice : function(component, event, helper) {
		var isChecked = event.target.checked;
		component.set("v.isChecked", isChecked);
	}, 
})