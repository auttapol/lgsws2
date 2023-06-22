({
	onInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");
		console.log("recordId: ",recordId); 
		var action = component.get('c.getFormList'); 
		action.setParams({
		      "recordId": recordId ,
		    });

			action.setCallback(this, function(response) { 
		    if (component.isValid() && response.getState() === 'SUCCESS') 
		    { 
					if(response.getReturnValue() != null)
					{
						component.set("v.isShowtable", true);
						var EClientSuit = response.getReturnValue().EClient;
						var FormA = response.getReturnValue().FormA;
						var FormB = response.getReturnValue().FormB;
							

						component.set("v.OwnerA", response.getReturnValue().OwnerA);
						component.set("v.OwnerB", response.getReturnValue().OwnerB);
						component.set("v.EClient", EClientSuit);
						component.set("v.FormA", FormA);
						component.set("v.FormB", FormB);

						EClientSuit.LastModifiedDate = new Date (EClientSuit.LastModifiedDate).toLocaleString('en');
						EClientSuit.CreatedDate = new Date (EClientSuit.CreatedDate).toLocaleString('en');

						FormA.LastModifiedDate = new Date (FormA.LastModifiedDate).toLocaleString('en');
						FormA.CreatedDate = new Date (FormA.CreatedDate).toLocaleString('en');

						FormB.LastModifiedDate = new Date (FormB.LastModifiedDate).toLocaleString('en');
						FormB.CreatedDate = new Date (FormB.CreatedDate).toLocaleString('en');
						if(FormA == null) {
							component.set("v.isSurveySheet1",true);
						} else {
							component.set("v.isSurveySheet1",false);
						}	

						if(FormB == null) {
							component.set("v.isSurveySheet2",true);
						} else {
							component.set("v.isSurveySheet2",false);
						}
					}
		    }
		    else
		    {
		    	console.error(response);
		    }
		});
		 $A.enqueueAction(action);
	},

	navigateToFormEDIT : function(component, event, helper){
		var formType =  event.target.value;
		var recordId = component.get("v.recordId");
		var ComponentName;
		var surveySheetId;

		var action = component.get('c.SurveyEClient');
		action.setParams({
			"recordId": recordId ,
			"formType": formType,
		});

		action.setCallback(this, function(response) {
		    if (component.isValid() && response.getState() === 'SUCCESS')  
		    {
				var surveyEClient = response.getReturnValue();
				console.log('surveyEClient:::',surveyEClient);
				if(formType == 'FormA') {
					ComponentName = "c:CSSurveyFormA";
					surveySheetId = surveyEClient.CS_Customer_Survey_A__c;
				} else if (formType == 'FormB') {
					ComponentName = "c:CSSurveyFormB";
					surveySheetId = surveyEClient.CS_Customer_Survey_B__c;
				}
				
				var evt = $A.get("e.force:navigateToComponent");
				evt.setParams({
					componentDef : ComponentName,
					componentAttributes : {
						recordIdEClient : recordId,
						surveySheetId : surveySheetId,
					}
				});
				evt.fire();
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
					helper.displayToast(component, "Error", $A.get("$Label.c.E_Client_FormList_NavigateToEdit_Failed_Msg"));
				}
		    }
		});
		 $A.enqueueAction(action);
	},


	navigateToView : function(component, event, helper){

		var formType =  event.target.value;

		var recordId = component.get("v.recordId");
		var url;



		if(formType == 'FormA') {
			url = "/apex/CSGeneratePDFMain?surveySheet=formA&id=" + recordId;
		} else if (formType == 'FormB') {
			url = "/apex/CSGeneratePDFMain?surveySheet=formB&id=" + recordId;
		}
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	        "url": url
	    });

	    urlEvent.fire();



	},
	



})