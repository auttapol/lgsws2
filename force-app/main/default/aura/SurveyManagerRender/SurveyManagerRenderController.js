({
	onInit: function (component, event, helper) {

		helper.fetchSurvey(component,event);
	},

	saveDraftSurvey: function (component, event, helper) {
		var surveySheetId = component.get("v.surveySheetId");
		var finalAwnser = component.get("v.surveyAwnser");
		var surveyManager = component.get("v.surveyManager");

		component.set("v.processSave", true);

		var compEvent = component.getEvent("SaveAnswerEvent");

		compEvent.setParams({"processSave" : true });    

		compEvent.fire();

		var action = component.get("c.saveDraftSurveySheet");
        helper.choiceChecked_False(component,event);
		action.setParams({
			// "surveyAwnser": JSON.stringify(finalAwnser),
			"surveyAwnser": finalAwnser,
			"survey": surveyManager.survey,
			"surveySheetId": surveySheetId,
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.fetchSurvey(component,event);
                //$A.get('e.force:refreshView').fire();
				helper.displayToast(component, "Success", $A.get("$Label.c.SurveyManagerRender_SaveDraft_Success_Msg"));
				
			} else {
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
					helper.displayToast(component, "Error", $A.get("$Label.c.SurveyManagerRender_SaveDraft_Failed_Msg"));
				}
			}

			component.set("v.processSave", false);

			var compEvent = component.getEvent("SaveAnswerEvent");

			compEvent.setParams({"processSave" : false });    

			compEvent.fire();

		});

		$A.enqueueAction(action);
	},

	saveAwnser: function (component, event, helper) {
		var surveySheetId = component.get("v.surveySheetId");
		var finalAwnser = component.get("v.surveyAwnser");
		var surveyManager = component.get("v.surveyManager");
	
		var validateResult = helper.validateAwnser(component, event, helper);   

		var isValidatePass = true;

		var errorQuestion = '';
		var errorMessage = '';

		var questionError = new Map();

		var params = event.getParam('arguments');
		var callback;

		component.set("v.processSave", true);

		var compEvent = component.getEvent("SaveAnswerEvent");

		compEvent.setParams({"processSave" : true });    

		compEvent.fire();

		if (params) {
			callback = params.callback;
		}

		for (var questionId in validateResult) {
			if (validateResult[questionId] != null && validateResult[questionId].status != null) {
				if (!validateResult[questionId].status) {
					isValidatePass = false;

					questionError[questionId] = validateResult[questionId].message;
				}
			}
		}

		var sortOrder = null;
		for (var questionId in questionError) {
			if (validateResult[questionId] != null && validateResult[questionId].status != null) {
				var questionOrder = helper.getSortOrder(questionId, surveyManager);
				if ((sortOrder == null || sortOrder > questionOrder)) {
					sortOrder = questionOrder;
					errorQuestion = questionId;
					errorMessage = validateResult[questionId].message;
				}
			}
		}

		if (!isValidatePass) {
			var question = surveyManager.allQuestionList[errorQuestion];
			var questionLabel = ( question.Question_Title__c != null ? question.Question_Title__c : question.Name )
			component.set("v.processSave", false);

			var compEvent = component.getEvent("SaveAnswerEvent");

			compEvent.setParams({"processSave" : false });    

			compEvent.fire();
			helper.displayToast(component, "Error", $A.get("$Label.c.SurveyManagerRender_Validate_Failed_Msg") + questionLabel + " (" + errorMessage + ")");
		} else {
            
			var action = component.get("c.saveSurveySheet");
			action.setParams({
				// "surveyAwnser": JSON.stringify(finalAwnser),
				"surveyAwnser": finalAwnser,
				"survey": surveyManager.survey,
				"surveySheetId": surveySheetId,
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
			
					helper.displayToast(component, "Success", $A.get("$Label.c.SurveyManagerRender_SaveAnswer_Success_Msg"));
					
					var updateCSLevel = component.getEvent("updateCSLevelHandler");
					updateCSLevel.setParams({
						'isSuccess': true
					});
					updateCSLevel.fire();

					if (callback) callback(response.getReturnValue());
					// helper.redirectToDetail(component);

				} else {
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
						helper.displayToast(component, "Error", $A.get("$Label.c.SurveyManagerRender_SaveAnswer_Failed_Msg"));
					}
				}
				component.set("v.processSave", false);

				var compEvent = component.getEvent("SaveAnswerEvent");

				compEvent.setParams({"processSave" : false });    
	
				compEvent.fire();
			});

			$A.enqueueAction(action);

		}
	},

})