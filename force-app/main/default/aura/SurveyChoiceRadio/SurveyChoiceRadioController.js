({
	onInit : function(component, event, helper) {
		var choiceSelect = component.get("v.choiceSelect");
		var surveyAwnser = component.get("v.surveyAwnser");
		var choiceValue = choiceSelect.choice.List_Values__c;

		choiceValue = choiceValue.split('\n');
		var items = [];
        for (var i = 0; i < choiceValue.length; i++) {
            var item = {
                "label": choiceValue[i].replace(/\n\r/gi, ''),
                "value": choiceValue[i].replace(/\n\r/gi, ''),
			};
			items.push(item);
		}
		component.set("v.options", items);

		if( surveyAwnser[choiceSelect.mainQuestionId] != undefined )
		{
			var choiceObj = surveyAwnser[choiceSelect.mainQuestionId][choiceSelect.choice.Id];
			component.set("v.answerObj",choiceObj);

			if( choiceObj == undefined || choiceObj.choiceChecked == false)
			{
				component.set("v.AnswerValueBoolean",false);
			}
			else
			{
				component.set("v.AnswerValueBoolean",true);
			}
		}
		else
		{
			component.set("v.AnswerValueBoolean",false);
		}

	},

	updateRadioChoice : function(component, event, helper) {

		var choiceSelect = component.get("v.choiceSelect");
		var isEve = event.target.id;
		var isScore = choiceSelect.choice.Score__c;
		var isChecked;
		var answerObj = component.get("v.answerObj");
		var answerId;
		if(isScore == undefined) {
			isScore = 0;
		} 

		if(isEve != " ") {
			isChecked = true;
		} else {
			isChecked = false;
		}

		if(isChecked == undefined) {
			isChecked = false;
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
			'choiceValue' : { 'choiceValue' : isEve,
							'choiceChecked' : isChecked,
							'choiceVerified' : true,
							'choiceScore' : isScore,
							'choiceType': choiceSelect.choice.Option_Type__c,  
							'answerId' : answerObj.answerId,
						},

        	});

        choiceUpdateEvent.fire();

	},
})