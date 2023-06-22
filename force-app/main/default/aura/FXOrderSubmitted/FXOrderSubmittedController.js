({
	onInit: function (component, event, helper) {
		var FXSId = component.get("v.recordId");

		// Get user Current User
		var CurrentUser;
		var actionPromise = new Promise(function (resolve, reject) {
			var action = component.get("c.getUserData");

			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					if (response.getReturnValue()) {
						component.set("v.userCurrentProfile", response.getReturnValue());

						CurrentUser = response.getReturnValue();
						resolve();
					} else {
						reject(Error('Invalid value: Current user'));
					}
				} else {
					reject(Error('Invalid value: Current user'));
				}
			});

			$A.enqueueAction(action);
		});

		actionPromise.then(function () {

			var action = component.get("c.getSubmittedOrderByFXS");
			action.setParams({
				"FXSId": FXSId
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var orderList = response.getReturnValue();

					for (var i = 0; i < orderList.length; i++) {
						if ( (CurrentUser.Segment__c && CurrentUser.Segment__c === orderList[i].Owner_s_Segment__c) || CurrentUser.Id == orderList[i].OwnerId ) {

							if( orderList[i]["FXO_Is_Order_Cloned__c"] == false )
							{
								orderList[i]["Allow_CloneCancel_action"] = true;	
							}
							else
							{
								orderList[i]["Allow_CloneCancel_action"] = false;
							}
							

						} else {
							orderList[i]["Allow_CloneCancel_action"] = false;
						}
					}

					component.set("v.orderList", orderList);

					// helper.clearFill(component);

				} else {
					console.log(response.getError());
				}
			});
			$A.enqueueAction(action);

		}, function (error) {
			console.log(error);
		});

		var action2 = component.get("c.getFXS");
		action2.setParams({
			"FXSId": FXSId
		});

		action2.setCallback(this, function (response) {
			// console.log(response);
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.fxs", response.getReturnValue());
			}
		});

		$A.enqueueAction(action2);

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


	navToRecDetail: function (component, event) {
		// console.log(event.target.id);
		var id = event.target.id;

		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
			"recordId": id
		});
		navEvt.fire();

	},

	clearFill: function (component, event, helper) {

		helper.clearFill(component);
		helper.displayToast(component, 'Info', $A.get("$Label.c.FX_Order_Submit_Display_Toast_Clear_Message"));
	},

	ConfirmFill: function (component, event, helper) {

		var blotterProfile = component.get("v.blotterProfile");


		var orderList = component.get("v.orderList");
		var fxs = component.get("v.fxs");
		var totalFillAmount = 0;

		for (var i in orderList) {
			var order = orderList[i];
			totalFillAmount += parseInt(order.FXO_FillAmount__c);
		}


		if (totalFillAmount == 0) {
			helper.displayToast(component, 'Error', $A.get("$Label.c.FX_Order_Submit_Total_Fill_Amount_Greater_than_Zero_Message"));
		} else if (totalFillAmount != fxs.FXS_TotalAllocateAmount__c) {
			helper.displayToast(component, 'Error', $A.get('$Label.c.FX_Order_Submit_Total_Fill_Amount_Equal_Total_Allocate_Amount_Message'));
		} else {
			if (blotterProfile && blotterProfile.FX_Order_Allow_Allocate__c) {
				// Start filled here
				var action = component.get("c.spreadOrder");
				action.setParams({
					"orderList": orderList,
					"newfxs": fxs,
				});

				action.setCallback(this, function (response) {
					var state = response.getState();
					
					if (state === "SUCCESS") {
						// component.set("v.oscSellList", response.getReturnValue());
						
						
						var result = response.getReturnValue();
						if(result.fxs && result.orderList){
							var fxs = result.fxs;
							var orderList = result.orderList;
	
							component.set("v.fxs", fxs);
							component.set("v.orderList", orderList);
							helper.displayToast(component, "Success", $A.get("$Label.c.FX_Order_Submit_Spread_Order_Success_Message"));
						}
						else
						{
							helper.displayToast(component, "Error", $A.get("$Label.c.FX_Order_Submit_Spread_Order_Failed_Message"));
						}
						
						$A.get('e.force:refreshView').fire();
					} else {
						var error = response.getError();
						var errorTextList = [];

						if( error != null )
						{
							for (var i = 0; i < error.length; i++) {

								if (error[i].message != null) {
									errorTextList.push(error[i].message);
								}

								if( error[i].fieldErrors != null )
								{
									if (error[i].fieldErrors.length > 0) {
										for (var j = 0; j < error[i].fieldErrors.length; j++) {
											errorTextList.push(error[i].message[j].message);
										}
									}
								}

								if( error[i].pageErrors != null )
								{
									if (error[i].pageErrors.length > 0) {
										for (var j = 0; j < error[i].pageErrors.length; j++) {
											errorTextList.push(error[i].pageErrors[j].message);
										}
									}
								}
							}

							helper.displayToast(component, "Error", $A.get("$Label.c.FX_Order_Submit_Spread_Order_Failed_Message") + " " + errorTextList.join("<br />"));
						}
						else
						{
							helper.displayToast(component, "Error", $A.get("$Label.c.FX_Order_Submit_Spread_Order_Failed_Message") );
						}
						$A.get('e.force:refreshView').fire();
					}
				});

				$A.enqueueAction(action);
			}
		}


	},

	changeFillAmount: function (component, event, helper) {

		var target = event.getSource();

		var idx = event.currentTarget.parentNode.dataset.idx;
		var orderList = component.get("v.orderList");
		var orderItem = component.get('v.orderList')[idx];


		var requestAmount = parseInt(orderItem.FXO_RequestAmount__c);
		var fillAmount = parseInt(target.get("v.value"));

		if (isNaN(fillAmount) || fillAmount < 0) {
			fillAmount = 0;
		} else if (fillAmount > requestAmount) {
			helper.displayToast(component, 'Warning', $A.get("$Label.c.FX_Order_Submit_Invalid_Request_Amount_less_than_Fill_Amount_Message"));
			fillAmount = 0;
		}

		orderItem.FXO_RemainingAmount__c = requestAmount - fillAmount;
		target.set("v.value", fillAmount);
		component.set('v.orderList', orderList);

	},

	CloneOrder: function (component, event, helper) {

		var idx = event.currentTarget.dataset.idx;
		var tmpOrderItem = component.get('v.orderList')[idx];

		var action = component.get("c.getFXO");
		action.setParams({
			"fxoId": tmpOrderItem.Id
		});

		action.setCallback(this, function (response) {
			 
			var state = response.getState();
			if (state === "SUCCESS") {
				
				var orderItem = response.getReturnValue();

				if( orderItem.FXO_Is_Order_Cloned__c == false )
				{
					//var orderItem = component.get('v.orderList')[idx];

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
							'FXO_Bypass_InterbankRate__c' : orderItem.FXO_Bypass_InterbankRate__c,
							'FXO_GTC__c' : orderItem.FXO_GTC__c,
							'FXO_Expiration_Date__c' : orderItem.FXO_Expiration_Date__c,
							'FXO_Remark__c' : orderItem.FXO_Remark__c,
							'FXO_OrderStatus__c' : 'New',
							'FX_Order_Clone_Reference__c' : orderItem.Id
						}
					};

					// console.log('clone default value: ',param)

					createFXOrderEvent.setParams(param);
					createFXOrderEvent.fire();
				}
				else
				{
					helper.displayToast(component, "Error",  $A.get("$Label.c.FXO_Clone_Error_Text")  );
					$A.get('e.force:refreshView').fire();
				}
			}
			else
			{
				var error = response.getError();
				var errorTextList = [];

				if( error != null )
				{
					for (var i = 0; i < error.length; i++) {

						if (error[i].message != null) {
							errorTextList.push(error[i].message);
						}

						if( error[i].fieldErrors != null )
						{
							if (error[i].fieldErrors.length > 0) {
								for (var j = 0; j < error[i].fieldErrors.length; j++) {
									errorTextList.push(error[i].message[j].message);
								}
							}
						}

						if( error[i].pageErrors != null )
						{
							if (error[i].pageErrors.length > 0) {
								for (var j = 0; j < error[i].pageErrors.length; j++) {
									errorTextList.push(error[i].pageErrors[j].message);
								}
							}
						}
					}

					helper.displayToast(component, "Error", $A.get("$Label.c.FXO_Clone_Error_Text") + " " + errorTextList.join("<br />"));
				}
				else
				{
					helper.displayToast(component, "Error", $A.get("$Label.c.FXO_Clone_Error_Text") );
				}

				$A.get('e.force:refreshView').fire();
			}
		});

		$A.enqueueAction(action);

	
	},

	showConfirmCancelOrderModal: function (component, event, helper) {
		var idx = event.currentTarget.dataset.idx;
		var orderItem = component.get('v.orderList')[idx];

		component.set('v.FXOrderDataOnModal', orderItem);
		component.set('v.confirmCancelOrderModal', true);
	},

	closeConfirmCancelOrderModal: function (component, event, helper) {
		component.set('v.FXOrderDataOnModal', null);
		component.set('v.confirmCancelOrderModal', false);
	},

	CancelOrder: function (component, event, helper) {

		// var idx =  event.currentTarget.dataset.idx;
		// var orderItem = component.get('v.orderList')[idx];
		var orderItem = component.get('v.FXOrderDataOnModal');

		var action = component.get("c.stampCancelRemain");
		action.setParams({
			"FXOrderItem": orderItem
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				// component.set("v.oscSellList", response.getReturnValue());
				helper.displayToast(component, "Success", $A.get("$Label.c.FX_Order_Submit_Display_Toast_Cancel_remaining_amount_order_success_message"));
				component.set('v.confirmCancelOrderModal', false);
				$A.get('e.force:refreshView').fire();
			} else {
				var error = response.getError();
				var errorTextList = [];

				console.log('error:', error);

				for (var i = 0; i < error.length; i++) {
					console.log('error:', error[i]);
					errorTextList.push(error[i].message);
				}

				helper.displayToast(component, "Error", $A.get("$Label.c.FX_Order_Submit_Display_Toast_Cancel_remaining_amount_order_faild") + " " + errorTextList.join("<br />"))
			}

		});
		$A.enqueueAction(action);
	},
})