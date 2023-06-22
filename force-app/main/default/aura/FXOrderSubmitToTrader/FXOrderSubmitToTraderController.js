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

				if(resObj){
					var isNotExpired = true;

					if(  resObj.FXO_Expiration_Date__c )
					{
						if( new Date(resObj.FXO_Expiration_Date__c).getTime() < Date.now() )
						{
							isNotExpired = false;
						}
					}

					if( resObj.FXO_OrderStatus__c == "New" && isNotExpired )
					{
						component.set("v.SubmitToTraderDialogValidateShow", true);
					}
					else
					{
						component.set("v.MessageValidateShow", true );
					}
				}
				else
				{
					component.set("v.MessageValidateShow",true );
				}
			}
			else
			{
				console.log(response.getError());
			}
		});

		$A.enqueueAction(action);
	},

	confirm : function(component, event, helper) {
		var fxoitem = component.get("v.fxoObject");

		var action = component.get("c.submitFromQuickAction");
		action.setParams({
			"fxo": fxoitem
		});

		action.setCallback(this, function (response) {

			var state = response.getState();
			
			if (state === "SUCCESS") {
				
				helper.displayToast(component, "Success", $A.get("$Label.c.FXO_Submit_Success_Text") );				

			} 
			else 
			{
				var error = response.getError();
				var errorTextList = [];

				// console.log('error:', error);

				for (var i = 0; i < error.length; i++) {
					console.log('error:', error[i]);

					var msg = error[i].message;
					if( msg.indexOf( $A.get("$Label.c.FXO_Submit_Fail_Traffic_Text") ) !== -1 )
					{
						msg = $A.get("$Label.c.FXO_Submit_Fail_Traffic_Text");
					}

					errorTextList.push(msg);

				}

				helper.displayToast(component, "Error", $A.get("$Label.c.FXO_Submit_Fail_Text") + "\n" + errorTextList.join("\n"))
			}

			$A.get("e.force:closeQuickAction").fire()
			$A.get('e.force:refreshView').fire();
		});

		// component.set("v.processSave", true);
		$A.enqueueAction(action);
	}
})