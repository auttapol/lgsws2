({
    doInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");

		var action = component.get('c.getEclient');
		action.setParams({
			"recordId": recordId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var eClient =  response.getReturnValue();

                component.set("v.eClientObj",eClient);

			}
		});

		$A.enqueueAction(action);
	},

	updateCommentText : function(component, event, helper)
	{
		var commentText = component.find('commentText').get('v.value');
	
		component.set("v.commentText",commentText);
	},

	confirmAction : function(component, event, helper) {

		var eClient = component.get("v.eClientObj");
		var commentText = component.get("v.commentText");
		
		if(eClient != null)
		{
			if(eClient.CS_Status__c == 'Pending Sales' ||  eClient.CS_Status__c == 'Sales TH Rejected')
			{
				var action = component.get("c.revertFormA");
				action.setParams({
					"ecId": eClient.Id,
					"comment" : commentText
				});

				action.setCallback(this, function (response) {
					var state = response.getState();
					if (state === "SUCCESS") {

						helper.displayToast(component, "Success", $A.get("$Label.c.E_Client_Reverse_Success_Msg"));
						$A.get('e.force:refreshView').fire();
						$A.get("e.force:closeQuickAction").fire();
					}
					else
					{
						helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_Reverse_Fail_Msg"));
						$A.get('e.force:refreshView').fire();
						$A.get("e.force:closeQuickAction").fire();
					}
				});

				$A.enqueueAction(action);
            }
            else
            {
                $A.get("e.force:closeQuickAction").fire();
                helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_Reverse_CannotReverse_Msg"));
            }
		}
		
	},

	cancelAction : function(component, event, helper) {

		$A.get("e.force:closeQuickAction").fire();
		
	},
})