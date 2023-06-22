({
	clearFill : function(component) {
		var orderList = component.get("v.orderList");
		var newOrderList = [];

		for( var i in orderList)
		{
			var order = orderList[i];
			order.FXO_FillAmount__c = 0;
			order.FXO_RemainingAmount__c = order.FXO_RequestAmount__c;
			newOrderList.push(order);
		}

		component.set("v.orderList",newOrderList);
	},

	displayToast : function(component, type, message) {
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
		  type: type,
		  message: message
		});
		toastEvent.fire();
	},

})