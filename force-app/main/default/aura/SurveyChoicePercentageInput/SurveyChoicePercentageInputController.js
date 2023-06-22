({
	init : function(component) {

		var choiceSelect = component.get("v.choiceSelect");
		var surveyAwnser = component.get("v.surveyAwnser");

		if( surveyAwnser[choiceSelect.mainQuestionId] != undefined )
		{
			var choiceObj = surveyAwnser[choiceSelect.mainQuestionId][choiceSelect.choice.Id];
			component.set("v.answerObj",choiceObj);
			if( choiceObj == undefined || choiceObj.choiceChecked == false)
			{
				component.set("v.AnswerValueBoolean",false);
				component.set("v.AnswerValue", "");
			}
			else
			{
				component.set("v.AnswerValueBoolean",true);
				component.set("v.AnswerValue", choiceObj.choiceValue );
			}
		}
		else
		{
			component.set("v.AnswerValueBoolean",false);
			component.set("v.AnswerValue", "");
		}

	},

	updateChoice : function(component, event, helper) {
		var choiceSelect = component.get("v.choiceSelect");
		var isScore = choiceSelect.choice.Score__c;
		var surveyAwnser = component.get("v.surveyAwnser");
		var answerObj = component.get("v.answerObj");
		var answerId;
		if(isScore == undefined)
		{
			isScore = 0;
		}

		if( component.get("v.AnswerValue") != '' && component.get("v.AnswerValue") != null )
		{
			component.set("v.AnswerValueBoolean",true);
		}
		else
		{
			component.set("v.AnswerValueBoolean",false);
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
					'choiceValue':  component.get("v.AnswerValue") ,
					'choiceChecked' : component.get("v.AnswerValueBoolean") ,
					'choiceVerified' : true,
					'answerId' : answerId,
				},
				 
        	});

		choiceUpdateEvent.fire();
	}, 
	
})