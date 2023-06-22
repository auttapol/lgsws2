({
	save: function (component, event, helper) {
		var fxsitem = component.get("v.fxsObject");
		var blotterProfile = component.get("v.blotterProfile");
		// change Total Allocate Amount
		var floatDigit = 2;
		var Million = 1000000;
		var precision = Math.pow(10, floatDigit);
		var getFillAmount = component.get("v.shortfillAmount");
		var roundUp_shortFXS_TotalRequestAmount__c = (Math.ceil((fxsitem.FXS_TotalRequestAmount__c / Million) * precision) / precision);

		if (getFillAmount == roundUp_shortFXS_TotalRequestAmount__c) {
			fxsitem.FXS_TotalAllocateAmount__c = fxsitem.FXS_TotalRequestAmount__c;
		} else {
			fxsitem.FXS_TotalAllocateAmount__c = getFillAmount * Million;
		}

		if (blotterProfile.FX_Dashboard_Allow_Edit__c) {
			if (fxsitem.FXS_TotalAllocateAmount__c > fxsitem.FXS_TotalRequestAmount__c || fxsitem.FXS_TotalAllocateAmount__c <= 0) {
				var inputAmount = component.find("inputAmount");

				inputAmount.set("v.errors", [{
					message: $A.get("$Label.c.FXS_Fill_Amount_Message_Invalid_Input") + " " + fxsitem.FXS_TotalAllocateAmount__c
				}]);
			} else {

				if (fxsitem.FXS_TotalAllocateAmount__c == fxsitem.FXS_TotalRequestAmount__c) {
					component.set("v.confirmDialogText", $A.get("$Label.c.FX_Dashboard_Full_Fill_Confirm_Text"));
				} else {
					component.set("v.confirmDialogText", $A.get("$Label.c.FX_Dashboard_Partial_Fill_Confirm_Text"));
				}

				component.set("v.fillAllocateAmount", fxsitem.FXS_TotalAllocateAmount__c);
				component.set("v.fillamountDialogShow", false);
				component.set("v.confirmDialogShow", true);
			}
		} else {
			// Not Allow Update Fill Amount
		}


	},

	doInit: function (component, event, helper) {

		var FXSId = component.get("v.recordId");
		var action = component.get("c.getFXS");
		action.setParams({
			"FXSId": FXSId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var fxsObject = response.getReturnValue();
				var shortTotalRequestAmount = Math.ceil(fxsObject.Total_Request_Amount_Million_Unit__c * 100) / 100
				var shortTotalAllocateAmount = fxsObject.FXS_TotalAllocateAmount__c ? fxsObject.FXS_TotalAllocateAmount__c / 1000000 : 0;
				component.set("v.fxsObject", fxsObject);
				component.set("v.shortTotalRequestAmount", shortTotalRequestAmount);
				component.set("v.shortfillAmount", shortTotalAllocateAmount);

				if (fxsObject.FXS_Status__c == "Fully Completed" || fxsObject.FXS_Status__c == "Cancelled") {
					component.set("v.fillamountDialogValidateShow", true);
					component.set("v.fillamountDialogShow", false);
				} else {
					component.set("v.fillamountDialogValidateShow", false);
					component.set("v.fillamountDialogShow", true);
				}

				// console.log(response.getReturnValue());
			}
		});

		$A.enqueueAction(action);

		var action1 = component.get("c.getBlotterProfile");
		action1.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				getBlotterProfile = response.getReturnValue();
				component.set('v.blotterProfile', getBlotterProfile);
				// show users allow can update fill amount
				var isFillUpdate = getBlotterProfile.FX_Dashboard_Allow_Edit__c;
				component.set("v.userAdjustFillAmount", isFillUpdate);
			} else {
				console.error(response);
			}
		});

		$A.enqueueAction(action1);
	},

	confirmFill: function (component, event, helper) {

		var fxsitem = component.get("v.fxsObject");

		var actionPromise = new Promise(function (resolve, reject) {
			var action = component.get("c.validateAndUpdateFXS");
			action.setParams({
				"newFXS": fxsitem
			});

			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					if (response.getReturnValue()) {
						resolve();
					} else {
						reject(Error($A.get("$Label.c.FX_Order_Summary_Invalid_Order")));
					}
				} else {
					reject(Error($A.get("$Label.c.FX_Order_Summary_Invalid_Order")));
				}
			});

			component.set("v.processSave", true);
			$A.enqueueAction(action);

		});

		actionPromise.then(
			function () {
				// get & set full fill amount
				var getFillAmount = component.get("v.fillAllocateAmount");
				fxsitem.FXS_TotalAllocateAmount__c = getFillAmount;

				if (fxsitem.FXS_TotalAllocateAmount__c > fxsitem.FXS_TotalRequestAmount__c || fxsitem.FXS_TotalAllocateAmount__c <= 0) {
					var inputAmount = component.find("inputAmount");

					inputAmount.set("v.errors", [{
						message: $A.get("$Label.c.FXS_Fill_Amount_Message_Invalid_Input") + " " + fxsitem.FXS_TotalAllocateAmount__c
					}]);
				} else {


					var action = component.get("c.adjustOrderSummary");
					action.setParams({
						"newFXS": fxsitem
					});

					action.setCallback(this, function (response) {
						var state = response.getState();
						if (state === "SUCCESS") {
							// component.set("v.oscSellList", response.getReturnValue());
							helper.displayToast(component, "Success", "Update Fill Amount.");
							component.set("v.confirmDialogShow", false);
							$A.get("e.force:closeQuickAction").fire()
							$A.get('e.force:refreshView').fire();
						} else {
							var error = response.getError();
							var errorTextList = [];

							console.log('error:', error);

							for (var i = 0; i < error.length; i++) {
								console.log('error:', error[i]);
								errorTextList.push(error[i].message);
							}

							helper.displayToast(component, "Error", $A.get("$Label.c.FXS_Display_Toast_Fill_Order_Failed") + " \n" + errorTextList.join("\n"))
						}
						component.set("v.processSave", false);

					});

					// component.set("v.processSave" , true);
					$A.enqueueAction(action);
				}

			},
			function (error) {
				helper.displayToast(component, "Error", error.message);
				component.set("v.processSave", false);

				$A.get("e.force:closeQuickAction").fire()
				$A.get('e.force:refreshView').fire();
			}
		);





	},

	backFill: function (component, event, helper) {
		// component.set("v.fillAmount","");

		component.set("v.confirmDialogShow", false);
		component.set("v.fillamountDialogShow", true);
	},
})