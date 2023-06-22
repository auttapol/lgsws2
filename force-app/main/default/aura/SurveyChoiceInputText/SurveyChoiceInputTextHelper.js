({
	updateData : function(component) {
		var choiceSelect = component.get("v.choiceSelect");

		var isChecked = component.get("v.isChecked");
		var AnswerValue = component.get("v.AnswerValue");
		var choiceVerified = component.get("v.choiceVerified");
		var isScore = choiceSelect.choice.Score__c;

		var answerObj = component.get("v.answerObj");
		var answerId;
		if(isChecked == undefined)
		{
			isChecked = false;
		}
		if(AnswerValue == undefined)
		{
			AnswerValue = "";
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
		var ch
		var choiceUpdateEvent = component.getEvent("choiceUpdate");
        choiceUpdateEvent.setParams({ 
        		'choiceId' :  choiceSelect.choice.Id ,
				'questionId' :  choiceSelect.mainQuestionId ,
        		'choiceValue' : { 				
        			'choiceValue' : AnswerValue,
					'choiceChecked' : isChecked,
					'choiceVerified' : choiceVerified,
					'choiceScore' : isScore,
					'choiceType': choiceSelect.choice.Option_Type__c,
					'answerId' : answerId,
				},
				
        	});

		choiceUpdateEvent.fire();
	},
})