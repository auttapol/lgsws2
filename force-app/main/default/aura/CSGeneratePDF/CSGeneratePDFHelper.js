({
	displayToast : function(component, type, message) {
	    var toastEvent = $A.get('e.force:showToast');
	    toastEvent.setParams({
	      type: type,
	      message: message
	    });
	    toastEvent.fire();
	},
	generatePDF : function(component, event,helper) {

		var eclientId = component.get("v.recordId");

		var action = component.get("c.createPDFfile");
		action.setParams({
			"eclientId": eclientId,
		
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				this.displayToast(component, "Success", "PDF Generated Success");

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
			$A.get('e.force:refreshView').fire();
		});

		$A.enqueueAction(action);
	},
})