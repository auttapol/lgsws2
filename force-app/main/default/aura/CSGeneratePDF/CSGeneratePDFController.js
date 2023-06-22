({
	onInit: function (component, event, helper) {
		var eclientId = component.get("v.recordId");

		var action = component.get("c.getEclient");
		action.setParams({
			"eclientId": eclientId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var ec =  response.getReturnValue();

				component.set("v.eClient",ec);

				var isValidGeneratePDF = false;

				if( ec != null )
				{
					if( ec.CS_Customer_Survey_A__c != null && ec.CS_Customer_Survey_B__c != null )
					{
						if( ec.CS_Customer_Survey_A__r.Status__c == 'Completed' &&  
							(ec.CS_Customer_Survey_B__r.Status__c == 'Completed' || ec.CS_Customer_Survey_B__r.Status__c == 'Ready for Review') )
						{
							isValidGeneratePDF = true;
						}
					}
				}

				component.set("v.isValidGeneratePDF",isValidGeneratePDF);
				
			}

		});

		$A.enqueueAction(action);

	},

	verifyNo : function(component, event, helper) {

		$A.get("e.force:closeQuickAction").fire();
	},

	verifyYes : function(component, event, helper) {

		var eclientId = component.get("v.recordId");

		var action = component.get("c.generatePDFfile");
		action.setParams({
			"eclientId": eclientId
		});

		action.setCallback(this, function (response) {
			console.log(response);
			helper.generatePDF(component,event,helper);
			/*var state = response.getState();
			if (state === "SUCCESS") {
				helper.displayToast(component, "Success", "PDF Generated");

			}
			else 
			{
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

					helper.displayToast(component, "Error", errorTextList.join("<br />"));
				} else {
					helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_GeneratePDF_Generate_Failed_Msg"));
				}
			}
			
			$A.get("e.force:closeQuickAction").fire();
			$A.get('e.force:refreshView').fire(); */
		});

		$A.enqueueAction(action);

	},
	

})