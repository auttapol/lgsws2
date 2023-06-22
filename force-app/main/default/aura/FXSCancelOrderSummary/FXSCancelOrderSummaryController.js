({
	onInit : function(component, event, helper) {
		var FXSId = component.get("v.recordId");

		var action = component.get("c.getFXS");
		action.setParams({
			"FXSId": FXSId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var resObj = response.getReturnValue();
				
				if (resObj.FXS_Status__c == "Fully Completed" || resObj.FXS_Status__c == "Partially Completed") {
					component.set("v.confirmDialogShow", true);
					component.set("v.cancelFXSItem", resObj);
				}
			}
		});

		$A.enqueueAction(action);

		var action3 = component.get("c.getBlotterProfile");
		action3.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				var getBlotterProfile = response.getReturnValue();
				component.set('v.blotterProfile', getBlotterProfile);
			} else {
				console.error(response);
			}
		});

		$A.enqueueAction(action3);
	},

	confirmCancel : function(component, event, helper) {
		
		var cancelFXSItem = component.get("v.cancelFXSItem");
		
		var action = component.get('c.cancelOrderSummaryFromPartialAndFull');
		
		action.setParams({ 
			"newFXS": cancelFXSItem,
		  });
		
		action.setCallback(this, function(response) {
			// console.log(response.getReturnValue());
			var state = response.getState();
			if (state === "SUCCESS") {
				$A.get("e.force:closeQuickAction").fire()
				$A.get('e.force:refreshView').fire();

				helper.displayToast(component, "Success", $A.get("$Label.c.FXS_Cancel_Success") )
			}
			else 
			{
				var error = response.getError();
				var errorTextList = [];

				console.log('error:', error);

				for (var i = 0; i < error.length; i++) {
					console.log('error:', error[i]);
					errorTextList.push(error[i].message);
				}

				helper.displayToast(component, "Error", $A.get("$Label.c.FXS_Cancel_Fail") + "\n" + errorTextList.join("\n"))
			}
		});

		$A.enqueueAction(action);
	},
})