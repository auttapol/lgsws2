({
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