({
	onInit : function(component, event, helper) {
		var FXOId = component.get("v.recordId");

		var action = component.get("c.getFXO");
		action.setParams({
			"fxoId": FXOId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var resObj = response.getReturnValue();
				
				component.set("v.fxoObject", resObj );
				if( resObj ){
					component.set("v.confirmDialogShow", resObj.FXO_OrderStatus__c === 'Done');
					component.set("v.ValidateDialogShow", resObj.FXO_OrderStatus__c === 'Acknowledge');
					component.set("v.afterAcknowledgeValidateDialogShow", resObj.FXO_OrderStatus__c === 'Cancelled');
				}
				else
				{
					component.set("v.confirmDialogShow", false);
					component.set("v.ValidateDialogShow", false);
					component.set("v.afterAcknowledgeValidateDialogShow", true);
				}
				
			}
		});

		$A.enqueueAction(action);
	},

	confirmAcknowledge : function(component, event, helper){
		var fxoitem = component.get("v.fxoObject");
		var action = component.get("c.acknowledgeFromQuickAction");
		action.setParams({
			"fxo": fxoitem
		});

		action.setCallback(this, function (response) {

			var state = response.getState();
			
			if (state === "SUCCESS") {
				
				helper.displayToast(component, "Success", $A.get("$Label.c.FXO_Acknowledge_Success_Text") );				

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

				helper.displayToast(component, "Error", $A.get("$Label.c.FXO_Acknowledge_Failed_Text") + "\n" + errorTextList.join("\n"))
			}

			$A.get("e.force:closeQuickAction").fire()
			$A.get('e.force:refreshView').fire();
		});

		// component.set("v.processSave", true);
		$A.enqueueAction(action);
	}
})