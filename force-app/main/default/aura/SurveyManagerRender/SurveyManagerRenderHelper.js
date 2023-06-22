({
	displayToast: function (component, type, message) {
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			type: type,
			message: message,
			mode: 'sticky'
		});
		toastEvent.fire();
	},

	getSortOrder: function (questionId, surveyManager) {

		var allQuestionMap = surveyManager.allQuestionList;

		var question = allQuestionMap[questionId];

		if (question != null) {
			if (question.Parent_Question__c == null) {
				return question.Question_Number__c;
			} else {
				return this.getSortOrder(question.Parent_Question__c, surveyManager);
			}
		}
	},

	validateAwnser: function (component, event, helper) {
		console.log('start validate answer');
		var isPass = false;
		var questionValidateMap = new Map();


		var finalAwnser = component.get("v.surveyAwnser");
		var surveyManager = component.get("v.surveyManager");

		var allQuestion = surveyManager.allQuestionList;
		var allQuestionChoice = surveyManager.questionIdChoiceMap;

		
		var ValidateSubQuestionRequired = new Map();
		var dependentQuestionInvalid = new Array();
        console.log('allQuestion:',allQuestion);
		for (var questionId in allQuestion) {
            
			var awnserMap = finalAwnser[questionId];
			var choiceList = allQuestionChoice[questionId];

			if (choiceList == null) {
				break;
			}

			var choiceMap = new Map();

			for (var i = 0; i < choiceList.length; i++) {

				var choiceObj = choiceList[i];

				choiceMap.set(choiceObj.Id, choiceObj);

				// ===== Add validation check for dependent question check but parent question unchecked ====
				
				if( choiceObj.Dependent_Question__c != null )
				{
                    console.log("===== Add validation check for dependent question check but parent question unchecked ====",choiceObj);
					var choiceId = choiceObj.Id;
					var awnserObj =  awnserMap[choiceId];
					var dependentQuestionId = choiceObj.Dependent_Question__c;

					// If this choice has awnser and checked
					if( dependentQuestionId != null && ( awnserObj == null || awnserObj.choiceChecked == false ) ) 
					{

							var isDepeQuestionHasAwnser = false;
							var depQuestionChoiceList = allQuestionChoice[dependentQuestionId];
							for (var j = 0; j < depQuestionChoiceList.length; j++) {
								var depChoiceObj = depQuestionChoiceList[j];
								var depChoiceId = depChoiceObj.Id;
								var depAwnserObj =  finalAwnser[dependentQuestionId][depChoiceId];

								if( depAwnserObj != null) 
								{
									if( depAwnserObj.choiceChecked == true )
									{
										isDepeQuestionHasAwnser= true;
										break;
									}
								}

							}

							if( isDepeQuestionHasAwnser == true )
							{
								dependentQuestionInvalid.push( questionId );
                                console.log('dependentQuestionInvalid');
							}
					}
				}
			}



			for (var choiceId in awnserMap) {
				if (awnserMap[choiceId] != null) {
       
					if (awnserMap[choiceId].choiceChecked == true) {

						var choiceData = choiceMap.get(choiceId);

						if (choiceData != null && choiceData.Dependent_Question__c != null) {
							var dependentType = choiceData.Dependent_Type__c;
							ValidateSubQuestionRequired.set(choiceData.Dependent_Question__c, dependentType);
						}

					}
				}
			}

		}

		for (var questionId in allQuestion) {

			var requireInputType = allQuestion[questionId].Require_Input__c;
			var awnserMap = finalAwnser[questionId];

			var allSubQuestionAwnser = helper.getAllChildAwnser(questionId, allQuestion, allQuestionChoice, finalAwnser);

			var choiceList = allQuestionChoice[questionId];

			if (choiceList == null) {
				choiceList = new Array();
			}
			var countAllChoice = choiceList.length;

			var count = 0;

			var choiceVerified = true;

			for (var choiceId in awnserMap) {

				var awnserObbj = awnserMap[choiceId];
				if (awnserObbj != null) {
                    console.log(choiceId + ' ' + awnserObbj.choiceChecked + ' ' + awnserObbj.choiceVerified + ' ' + awnserObbj.choiceValue )
                    
                    if (awnserObbj.choiceVerified == undefined && awnserObbj.choiceValue == 'true') {
                        awnserObbj.choiceVerified = true ;
                        
                    } else if (awnserObbj.choiceVerified == undefined && awnserObbj.choiceValue == undefined) {
                        awnserObbj.choiceVerified = false ;
                    } 
                    /*if ( awnserObbj.choiceChecked == false ) {
                        awnserObbj.choiceValue = undefined ;
                    }*/
                    
                    console.log(awnserObbj.choiceChecked + ' ' + awnserObbj.choiceVerified)
                    
					if (awnserObbj.choiceChecked == true) {
						count++;
					}

					if (awnserObbj.choiceChecked && awnserObbj.choiceVerified == false) {
						choiceVerified = false;

						questionValidateMap[questionId] = {
							"status": false,
							"message": $A.get("$Label.c.SurveyManagerRender_ChoiceValidate_Failed_Msg")
						};
						break;
					}

				}
			}



			if (choiceVerified != false) {
				var errorMessage = "";
				
				var isQuestionValidatePass = helper.validateInput(count, countAllChoice, requireInputType, awnserMap, allSubQuestionAwnser);

				if (!isQuestionValidatePass) {
                    
					errorMessage = $A.get("$Label.c.SurveyManagerRender_QuestionValidate_Failed_Msg") + helper.generateAwnserInputErrorMessage(requireInputType);
				}

				var isDependentQuestionValidatePass = true;

				if (ValidateSubQuestionRequired.get(questionId) != null) {
					var dependetValidate = ValidateSubQuestionRequired.get(questionId);
					
					isDependentQuestionValidatePass = helper.validateInput(count, countAllChoice, dependetValidate, awnserMap, allSubQuestionAwnser);

					if (!isDependentQuestionValidatePass) {
						errorMessage = $A.get("$Label.c.SurveyManagerRender_DependentQuestionValidate_Failed_Msg") + helper.generateAwnserInputErrorMessage(dependetValidate);
						isQuestionValidatePass = false;
					}

				}
				questionValidateMap[questionId] = {
					"status": isQuestionValidatePass,
					"message": errorMessage
				};
			}
		}

		if( dependentQuestionInvalid.length > 0 )
		{
			for (var i = 0; i < dependentQuestionInvalid.length; i++) 
			{
				var questionId = dependentQuestionInvalid[0];
				questionValidateMap[questionId] = {
					"status": false,
					"message": $A.get("$Label.c.SurveyManagerRender_ChoiceValidate_Failed_Msg")
				};
			}
		}

		return questionValidateMap;
	},

	generateAwnserInputErrorMessage: function (requireInputType) {
        
		var error = '';
		switch (requireInputType) {
			case "Require One":
				error = $A.get("$Label.c.SurveyManager_Choice_Validate_Require_One");
				break;
			case "Require All":
				error = $A.get("$Label.c.SurveyManager_Choice_Validate_Require_All");
				break;
			case "Require All or None":
				error = $A.get("$Label.c.SurveyManager_Choice_Validate_Require_All_Or_None");
				break;
			case "Require One or more":
				error = $A.get("$Label.c.SurveyManager_Choice_Validate_Require_One_Or_More");
				break;
			case "Percentage":
				error = $A.get("$Label.c.SurveyManager_Choice_Validate_Percentage");
				break;
			case "Require One on Sub Question":
				error = $A.get("$Label.c.SurveyManager_Choice_Validate_Require_One_Sub");
				break;
			case "Require One or More on Sub Question":
				error = $A.get("$Label.c.SurveyManager_Choice_Validate_Require_One_Or_More_Sub");
				break;
			case "Not Require":
			default:

		}

		return error;

	},

	validateInput: function (count, countAllChoice, requireInputType, awnserMap, allSubQuestionAwnser) {

		var isQuestionValidatePass = false;
		switch (requireInputType) {
			case "Require One":
				if (count == 1) {
					isQuestionValidatePass = true;

				}
				break;
			case "Require All":
				if (count == countAllChoice) {
					isQuestionValidatePass = true;

				}

				break;
			case "Require All or None":
				if ((count > 0 && count == countAllChoice) || (count == 0)) {
					isQuestionValidatePass = true;

				}
				break;
			case "Require One or more":
				if (count > 0) {
					isQuestionValidatePass = true;
				}
				break;
			case "Percentage":
				var totalValue = 0;
				for (var awnser in awnserMap) {
					if (awnserMap[awnser] != null) {
						if (awnserMap[awnser].choiceChecked == true) {
							totalValue += Number(awnserMap[awnser].choiceValue);
						}
					}
				}

				if (totalValue == 100) {
					isQuestionValidatePass = true;
				}
				break;
			case "Require One on Sub Question":
				if (allSubQuestionAwnser.length == 1) {
					isQuestionValidatePass = true;
				}
				break;
			case "Require One or More on Sub Question":
				if (allSubQuestionAwnser.length > 0) {
					isQuestionValidatePass = true;
				}
				break;
			case "Not Require":
			default:
				isQuestionValidatePass = true;
		}

		return isQuestionValidatePass;
	},

	getAllChildAwnser: function (mainQuestionId, allQuestion, allQuestionChoice, finalAwnser) {


		var allSubQuestion = new Array();;

		for (var qId in allQuestion) {
			if (allQuestion[qId].Parent_Question__c != null && allQuestion[qId].Parent_Question__c == mainQuestionId) {

				allSubQuestion.push(qId);
			}
		}

		var allSubQuestionAwnser = new Array();

		for (var i = 0; i < allSubQuestion.length; i++) {
			var subQuestionId = allSubQuestion[i];
			var awnserMap = finalAwnser[subQuestionId];

			for (var choiceId in awnserMap) {
				var awnserObbj = awnserMap[choiceId];
				if (awnserObbj != null && awnserObbj.choiceChecked == true) {
					allSubQuestionAwnser.push(awnserObbj);
				}
			}
		}

		return allSubQuestionAwnser;

	},
    fetchSurvey : function(component, event){
        var surveySheetId = component.get("v.surveySheetId");
		var actionPromise = new Promise(function (resolve, reject) {
			var action = component.get('c.getSurveyAnswer');
			action.setParams({
				"recordId": surveySheetId,
			});
			action.setCallback(this, function (response) {
                  
				if (component.isValid() && response.getState() === 'SUCCESS') {
					var result = response.getReturnValue();
					component.set('v.finishRenderAwnser', false);
					component.set("v.surveyManager", result.survey);

					var surveyWrapper = result.survey.allQuestionList;
					var objSurveyAnswer = result.awnser;
	
					var surveyAwnserData = {};
					for (var questionId in surveyWrapper) {
						var temMap = {};
						for (var key in objSurveyAnswer) {
							if (objSurveyAnswer[key].Survey_Question__c == questionId) {

								if (objSurveyAnswer[key].Score__c == undefined) {
									objSurveyAnswer[key].Score__c = 0;
								}
								surveyAwnserData[questionId] = temMap;
								surveyAwnserData[questionId][objSurveyAnswer[key].Survey_Choice__c] = {
									'choiceScore': objSurveyAnswer[key].Score__c,

									'choiceValue': objSurveyAnswer[key].Choice_Value__c,
									'choiceChecked': objSurveyAnswer[key].Choice_Checked__c,
									'choiceScore': objSurveyAnswer[key].Score__c,
									'answerId': objSurveyAnswer[key].Id,
								}
							} else {
								surveyAwnserData[questionId] = temMap;
							}
						}
						surveyAwnserData[questionId] = temMap;

					}
                    console.log('surveyAwnserData:',surveyAwnserData);
					component.set("v.surveyAwnser", surveyAwnserData);
					resolve();
				} else {
					console.error(response);
					reject(response);
				}
			});
			$A.enqueueAction(action);
			// helper.getRecordId(component);
		});

		actionPromise.then(
			function () {
				component.set('v.finishRenderAwnser', true);

			},
			function (error) {

			}
		);
    },
    choiceChecked_False : function(component, event){
        var finalAwnser = component.get("v.surveyAwnser");
		var surveyManager = component.get("v.surveyManager");
        var allQuestion = surveyManager.allQuestionList;
            
        for (var questionId in allQuestion) {
            
            var awnserMap = finalAwnser[questionId];
            
            for (var choiceId in awnserMap) {
                var awnserObbj = awnserMap[choiceId];
                if (awnserObbj != null) {
                    console.log(choiceId + ' ' + awnserObbj.choiceChecked + ' ' + awnserObbj.choiceVerified + ' ' + awnserObbj.choiceValue);
                    
                    if ( awnserObbj.choiceChecked == true && awnserObbj.choiceValue == '-' && awnserObbj.choiceVerified == false) {
                        awnserObbj.choiceValue = undefined ;
                    }
                    /*if ( awnserObbj.choiceChecked == false ) {
                        awnserObbj.choiceValue = undefined ;
                    }*/
                    
                }
            }
        }
    }

})