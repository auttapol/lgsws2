({	
	updateSelectboxChoice : function(component, event, helper) {
		var choiceSelect = component.get("v.choiceSelect");
		var selectedOptionValue = event.getParam("value");
		var isScore = choiceSelect.choice.Score__c;
		var isChecked;
		var answerObj = component.get("v.answerObj");
		var answerId;
		if(selectedOptionValue != "")
		{
			isChecked = true;
		}
		else
		{
			isChecked = false;
		}

		if(selectedOptionValue == undefined)
		{
			selectedOptionValue = "";
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
				'choiceValue' : { 'choiceValue' : selectedOptionValue,
								  'choiceChecked' : isChecked,
								  'choiceVerified' : true,
								  'choiceScore' : isScore,
								  'choiceType': choiceSelect.choice.Option_Type__c, 
								  'answerId' : answerId,
								},
				
        	});

        choiceUpdateEvent.fire();

	},

	init: function (component,event) {
		var choiceSelect = component.get("v.choiceSelect");
		var surveyAwnser = component.get("v.surveyAwnser");
		var result = choiceSelect.choice.List_Values__c;

		result = result.split('\r\n');
		var items = [];
        for (var i = 0; i < result.length; i++) {
            var item = {
                "label": result[i].replace(/\n\r/gi, ''),
                "value": result[i].replace(/\n\r/gi, ''),
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

			}
			else
			{
				component.set("v.AnswerValue",choiceObj.choiceValue);
			}
		}


	},
	
})