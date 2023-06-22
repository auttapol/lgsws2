({
	// submitSummary: function (component, event, helper) {
	// 	var surveySheetId = component.get("v.objSurveySheet");
	// 	var SumScore = 0;

	// 	var action = component.get("c.getSurveyAnswer");
	// 	action.setParams({
	// 		"surveySheetId": surveySheetId.Id,
	// 	});
	// 	action.setCallback(this, function (response) {
	// 		if (component.isValid() && response.getState() === 'SUCCESS') {
	// 			var result = response.getReturnValue();

	// 			for (var key in result) {

	// 				SumScore = SumScore + result[key].Score__c;
	// 			}
	// 			component.set("v.SumScore", SumScore);
	// 			this.saveSumScore(component);
	// 		} else {
	// 			console.error(response);
	// 		}
	// 	});
	// 	$A.enqueueAction(action);

	// },

	// saveSumScore: function (component, event, helper) {
	// 	var recordIdEClient = component.get("v.recordIdEClient");
	// 	var result = component.get("v.SumScore");

	// 	var actionAnswer = component.get('c.saveScore');
	// 	actionAnswer.setParams({
	// 		"recordIdEClient": recordIdEClient,
	// 		"result": result,
	// 	});

	// 	actionAnswer.setCallback(this, function (response) {
	// 		if (component.isValid() && response.getState() === 'SUCCESS') {

	// 			this.closeFocusedTab(component);
	// 		} else {
	// 			console.error(response);
	// 		}
	// 	});
	// 	$A.enqueueAction(actionAnswer);
	// },

	closeFocusedTab: function (component, event, helper) {
		var workspaceAPI = component.find("workspace");
		workspaceAPI.getFocusedTabInfo().then(function (response) {
				var focusedTabId = response.tabId;
				workspaceAPI.closeTab({
					tabId: focusedTabId
				});
			})
			.catch(function (error) {
				console.log(error);
			});
	},

	getRecordAccess: function (component) {
		var recordId = component.get("v.surveySheetId");
		var action = component.get("c.getUserRecordAccess");
		var status = component.get("v.surveySheetStatus");

		action.setParams({
			"recordId": recordId,
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var result = response.getReturnValue();

				if (status != "Completed" && status != "Pending Approval" && status != "Cancelled") {
                    if (result.HasEditAccess == true) {
                        component.set("v.showSaveButton", true);
                        // Save Draft Button
                        switch (status) {
                            case "New":
                                this.updateSurveyStatus(component);
                                component.set("v.showSaveDraftButton", true);
                                break;
                            case "In Progress":
                                component.set("v.showSaveDraftButton", true);
                                break;
                            default:
                                // component.set("v.showSaveDraftButton", false);
                                break;
                        }
                    } 
                }
			}
		});

		$A.enqueueAction(action);
		
	},
	updateSurveyStatus: function (component) {
		var recordId = component.get("v.surveySheetId");
		var action = component.get("c.updateSurveyStatus");

		action.setParams({
			"idSurveySheet": recordId,
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

			}
		});

		$A.enqueueAction(action);

	},
	
	getRecordId: function (component, helper, event) {
		var surveySheetId = component.get("v.surveySheetId");
		var action = component.get('c.getEClientId');

		action.setParams({
			"surveySheetId": surveySheetId,
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var sh = response.getReturnValue();

				component.set("v.eclientId", sh.Id);
			}
		});
		$A.enqueueAction(action);
	},
    redirectToDetail: function (component) {
		var eclientId = component.get("v.eclientId")
		var workspaceAPI = component.find("workspace");
		workspaceAPI.getFocusedTabInfo().then(function (response) {
				var focusedTabId = response.tabId;
				workspaceAPI.closeTab({
					tabId: focusedTabId
				});

			})
			.then(function () {
				
				var navigationSObject = $A.get("e.force:navigateToSObject");
				navigationSObject.setParams({
					"recordId": eclientId,
					"slideDevName": "detail",
					"isredirect": true,
				});
				navigationSObject.fire();
				
			})
			.then(function () {
				$A.get('e.force:refreshView').fire();
			})
			.catch(function (error) {
				console.log(error);
			});
	},


})