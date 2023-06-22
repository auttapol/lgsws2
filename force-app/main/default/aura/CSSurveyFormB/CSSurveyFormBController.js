({
	onInit: function (component, event, helper) {
		var recordId = component.get("v.surveySheetId");
		var action = component.get('c.getSurveySheet');
	
		var workspaceAPI = component.find("workspace");

		action.setParams({
			"recordId": recordId,
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var sh = response.getReturnValue();
				component.set("v.surveySheetStatus", sh.Status__c);
				component.set("v.saveButtonText", "Save " + sh.Survey_Type__c);

				workspaceAPI.getFocusedTabInfo().then(function (response) {
					workspaceAPI.getTabInfo({
						tabId: response.tabId
					}).then(function (response) {
						console.log(response);
						if(response.isSubtab){
							workspaceAPI.setTabLabel({
								tabId: response.tabId,
								label: sh.Info_1__c
							});
							workspaceAPI.setTabIcon({
								tabId: response.tabId,
								icon: "standard:document",
								iconAlt: sh.Info_1__c
							});
						}
						else if(response.subtabs && response.subtabs.length > 0){
							workspaceAPI.setTabLabel({
								tabId: response.subtabs[response.subtabs.length - 1].tabId,
								label: sh.Info_1__c
							});
							workspaceAPI.setTabIcon({
								tabId: response.subtabs[response.subtabs.length - 1].tabId,
								icon: "standard:document",
								iconAlt: sh.Info_1__c
							});
						}
						// response.pageReference.attributes.name
						// workspaceAPI.setTabLabel({
						// 	tabId: response.tabId,
						// 	label: "TEST TITLE 1",
						// });
					});
				})
				.catch(function (error) {
					console.log(error);
				});

				helper.getRecordAccess(component);
			}
		});
		$A.enqueueAction(action);
		helper.getRecordId(component);

	},

	saveSurvey: function (component, event, helper) {
		var surveyCmp = component.find("surveyCmp");

		surveyCmp.saveAwnser(function (result) {
			console.log("callback for aura:method was executed");
			console.log("result: " + result);
			helper.redirectToDetail(component);
		});
		//helper.redirectToDetail(component);

	},
	saveDraftSurvey: function (component, event, helper) {
		var surveyCmp = component.find("surveyCmp");

		surveyCmp.saveDraftSurvey();
	},

	updateCSLevel: function (component, event, helper) {
		var eClientRecordId = component.get("v.recordIdEClient");
		var surveySheetId = component.get("v.surveySheetId");
		var isCSlevelHandler = event.getParam("isSuccess");

		if (isCSlevelHandler) {

			var action = component.get('c.updateEClientCSLevel');
			action.setParams({
				"eClientRecoredId": eClientRecordId,
				"surveySheetId": surveySheetId,
			});

			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var res = response.getReturnValue();

					$A.get('e.force:refreshView').fire();

				} else {
					console.log(state);
				}
			});
			$A.enqueueAction(action);
		}

	},

	SaveAnswerEvent : function(component, event, helper) {
	   
		var GetFromEvent = event.getParam("processSave");
		component.set("v.isDisable" , GetFromEvent); 	   
	 },


})