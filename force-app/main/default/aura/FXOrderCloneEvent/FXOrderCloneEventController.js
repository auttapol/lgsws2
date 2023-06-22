({
	onInit: function (component, event, helper) {
		var FXOId = component.get("v.recordId");

		var action = component.get("c.getFXO");
		action.setParams({
			"fxoId": FXOId
		});

		component.set("v.processSave", true);

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var orderItem = response.getReturnValue();
				component.set("v.fxoObject", orderItem);

				var createFXOrderEvent = $A.get("e.force:createRecord");
				var param = {
					"entityApiName": "FX_Order__c",
					"defaultFieldValues": {
						'FXO_RequestAmount__c': orderItem.FXO_RemainingAmount__c,
						'FXO_BuySell__c': orderItem.FXO_BuySell__c,
						'FXO_Customer__c': orderItem.FXO_Customer__c,
						'FXO_Currency__c': orderItem.FXO_Currency__c,
						'FXO_CurrencyPair__c': orderItem.FXO_CurrencyPair__c,
						'FXO_CustomerRate__c': orderItem.FXO_CustomerRate__c,
						'FXO_InterbankRate__c': orderItem.FXO_InterbankRate__c,
						'FXO_Bypass_InterbankRate__c': orderItem.FXO_Bypass_InterbankRate__c,
						'FXO_GTC__c': orderItem.FXO_GTC__c,
						'FXO_Expiration_Date__c': orderItem.FXO_Expiration_Date__c,
						'FXO_Remark__c': orderItem.FXO_Remark__c,
						'FXO_OrderStatus__c': 'New',
					}
				};

				// console.log('gade',param)
				component.set("v.processSave", false);
				createFXOrderEvent.setParams(param);
				createFXOrderEvent.fire();

			} else {
				console.log(response.getError());
			}
		});

		$A.enqueueAction(action);
	},
})