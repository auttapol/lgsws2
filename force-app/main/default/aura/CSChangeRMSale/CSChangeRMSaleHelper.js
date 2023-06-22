({
	displayToast: function (component, type, message) {
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			type: type,
			message: message,
			mode: 'sticky'
		});
		toastEvent.fire();
	},

	ChangeOnListView: function (component, type, message) {
		var eClient = component.get("v.eClientObj");
		var getRM = component.get("v.selectedRm");
		var getFX = component.get("v.selectedFx");

		for (i = 0; i < eClient.length; i++) {
			if (getRM != null && getFX != null) {
				eClient[i].CS_RM__c = getRM.Id;
				eClient[i].CS_Sales_Owner__c = getFX.Id;
				eClient[i].OwnerId = getFX.Id;
			}
		}


		var action = component.get("c.confirmEclientListView");
		action.setParams({
			"eClient": eClient,
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				if (eClient == null) {
					this.displayToast(component, "Error", $A.get("$Label.c.E_Client_ChangeRM_Incorrect_ChangeRM_Msg"));
					var CSReviewEClientEvent = $A.get("e.c:CSReviewEClientEvent");
					CSReviewEClientEvent.setParams({
						'confirmSuccess': false
					});
					CSReviewEClientEvent.fire();
				} else {
					
					$A.get('e.force:refreshView').fire();
					
					this.setManualSharing(component,event,helper);
					this.displayToast(component, "Success", $A.get("$Label.c.E_Client_ChangeRM_Succes_ChangeRM_Msg"));
				}
				
				$A.get("e.force:closeQuickAction").fire();

				var CSReviewEClientEvent = $A.get("e.c:CSReviewEClientEvent");
				CSReviewEClientEvent.setParams({
					'confirmSuccess': true
				});
				CSReviewEClientEvent.setParams({
					'action': 'confirm'
				});
				CSReviewEClientEvent.fire();

			} else {
				//this.displayToast(component, "Error", $A.get("$Label.c.E_Client_ChangeRM_Failed_ChangeRM_Msg") );	
				var error = response.getError();
				var errorTextList = [];

				if (error != null) {
					for (var i = 0; i < error.length; i++) {

						if (error[i].message != null) {
							errorTextList.push(error[i].message);
						}

						if (error[i].fieldErrors != null) {
							if (error[i].fieldErrors.length > 0) {
								for (var j = 0; j < error[i].fieldErrors.length; j++) {
									errorTextList.push(error[i].message[j].message);
								}
							}
						}

						if (error[i].pageErrors != null) {
							if (error[i].pageErrors.length > 0) {
								for (var j = 0; j < error[i].pageErrors.length; j++) {
									errorTextList.push(error[i].pageErrors[j].message);
								}
							}
						}
					}

					this.displayToast(component, "Error", errorTextList.join("<br />"));
				} else {
					this.displayToast(component, "Error", $A.get("$Label.c.E_Client_ChangeRM_Failed_ChangeRM_Msg"));
				}
				$A.get("e.force:closeQuickAction").fire();
				var CSReviewEClientEvent = $A.get("e.c:CSReviewEClientEvent");
				CSReviewEClientEvent.setParams({
					'confirmSuccess': false
				});
				CSReviewEClientEvent.setParams({
					'action': 'confirm'
				});
				CSReviewEClientEvent.fire();
			}
		});

		$A.enqueueAction(action);
		

	},

	getCurrentUser: function (component, event, helper) {
		var action = component.get("c.getCurrentUser");
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				component.set("v.currentUser", storeResponse);
			}
		});
		$A.enqueueAction(action);
	},

	getEclient: function (component, event, helper) {

		var eclientId = new Array();
		var action = component.get("c.getCurrentEclient");
		var recordIdList = component.get("v.recordIdList");
		if( recordIdList != null && recordIdList != undefined )
		{
			recordIdList = recordIdList.split(",");
			for (var i = 0; i < recordIdList.length; i++) 
			{
				eclientId[i] = recordIdList[i].replace(/[.*+?^${}()|[\]\\]/gi, '').trim()
			}

		}
		else
		{
			eclientId[0] = component.get("v.recordId");
		}

		action.setParams({
			"eclientId": eclientId,
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var eClient =  response.getReturnValue();
				var currentUser = component.get("v.currentUser");

				if(eClient.length >= 1)
				{
					component.set("v.eClientObj",eClient );
					console.log('eClientObj:',eClient);
					var eClientObj = component.get("v.eClientObj");
					var eClientList = new Array();
					
					for(var i = 0; i < eClientObj.length; i++)
					{
						if(currentUser.Id == eClientObj[i].OwnerId || currentUser.Profile.Name == 'System Administrator')
						{
							eClientList[i] = eClientObj[i];

							component.set("v.eClientCanChange",eClientList);
						}
					}
				}

				var eClientCanChange = component.get("v.eClientCanChange");
				
				if(eClientCanChange.length >= 1 )
				{			
					component.set("v.hasEclient",true);
				}
				else
				{
					component.set("v.hasEclient",false);
					$A.get("e.force:closeQuickAction").fire();

					var CSReviewEClientEvent = $A.get("e.c:CSReviewEClientEvent");
					CSReviewEClientEvent.setParams({'confirmSuccess': false });
					CSReviewEClientEvent.setParams({'action': 'cancel' });
					CSReviewEClientEvent.fire();
					helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_ChangeRM_Invalid_ChangeRM_Msg"));
				}

			}
			else
			{
				helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_ChangeRM_Invalid_ChangeRM_Msg"));
			}

		});
		$A.enqueueAction(action);

    },

	setManualSharing: function(component, event, helper){

		this.getEclient(component, event, helper);
		
		var eClient = component.get("v.eClientObj");
		var action = component.get("c.setManualShareRead");
		
		console.log('eClient:',eClient);
		action.setParams({
			"eClient": eClient,
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log('set sharing success');
			}
		});
		$A.enqueueAction(action);		
	}

})