({
	onInit: function (component, event, helper) {
		var FXOId = component.get("v.recordId");

		var action = component.get("c.getFXO");
		action.setParams({
			"fxoId": FXOId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var resObj = response.getReturnValue();

				component.set("v.fxoObject", resObj);

				// If check respone value not equal to be null
				if (resObj) {
					if (resObj.FXO_OrderStatus__c === 'New' || resObj.FXO_OrderStatus__c === 'Submitted') {
						component.set("v.ValidateDialogShow", true);
					}
				} else {
					component.set("v.NotAllowToCancelText", true);
				}
			} else {

				console.log(response.getError());
			}
		});

		$A.enqueueAction(action);
	},

	confirmCancel: function (component, event, helper) {

		var fxoitem = component.get("v.fxoObject");
		var action = component.get("c.cancelFromQuickAction");
		action.setParams({
			"fxo": fxoitem
		});

		action.setCallback(this, function (response) {

			var state = response.getState();

			if (state === "SUCCESS") {

				helper.displayToast(component, "Success", $A.get('$Lable.c.FXO_Cancel_Success_Text'));

			} else {
				var error = response.getError();
				var errorTextList = [];

				console.log('error:', error);

				for (var i = 0; i < error.length; i++) {
					console.log('error:', error[i]);
					errorTextList.push(error[i].message);
				}

				helper.displayToast(component, "Error", $A.get('$Lable.c.FXO_Cancel_Failed_Text') + "\n" + errorTextList.join("\n"))
			}

			$A.get("e.force:closeQuickAction").fire()
			$A.get('e.force:refreshView').fire();
		});

		// component.set("v.processSave", true);
		$A.enqueueAction(action);

	}
})