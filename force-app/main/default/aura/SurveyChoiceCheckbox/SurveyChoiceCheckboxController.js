({
	onInit : function(component, event, helper) {

		var choiceSelect = component.get("v.choiceSelect");
		var surveyAwnser = component.get("v.surveyAwnser");

		if( surveyAwnser[choiceSelect.mainQuestionId] != undefined )
		{
			var choiceObj = surveyAwnser[choiceSelect.mainQuestionId][choiceSelect.choice.Id];

			component.set("v.answerObj",choiceObj);
			
			if( choiceObj == undefined || choiceObj.choiceChecked == false)
			{
				component.set("v.AnswerValue", false);
			}
			else
			{
				component.set("v.AnswerValue", true);
				
			}
		}
		else
		{
			component.set("v.AnswerValue", false);
		}

	},

	updateCheckboxChoice : function(component, event, helper) {

		var choiceSelect = component.get("v.choiceSelect");

		var isChecked = event.target.checked;
		var isScore = choiceSelect.choice.Score__c;
		var answerObj = component.get("v.answerObj");
		var answerId; 

		if(isChecked == undefined)
		{
			isChecked = false;
		}
		if(isScore == undefined)
		{
			isScore = 0;
		}
		if(answerObj == undefined)
		{
			answerId = "";
			
		}
		else
		{
			answerId = answerObj.answerId;
		}

		var choiceUpdateEvent = component.getEvent("choiceUpdate");
        choiceUpdateEvent.setParams({ 
        		'choiceId' :  choiceSelect.choice.Id ,
				'questionId' :  choiceSelect.mainQuestionId ,

				'choiceValue' : { 
					'choiceScore' : isScore,
					'choiceType': choiceSelect.choice.Option_Type__c  ,
					'choiceValue': isChecked,
					'choiceChecked' : isChecked,
					'choiceVerified' : true,
					'answerId' : answerId,
				},				
        	});

        choiceUpdateEvent.fire();

	},
})