({
	onInit : function(component, event, helper) {
		
	},
	
	updateChoice : function(component, event, helper) {

		var choiceValue = event.getParam("choiceValue");
		var choiceId = event.getParam("choiceId");
		var questionId = event.getParam("questionId");

		var surveyAwnser = component.get("v.surveyAwnser");

		if( surveyAwnser[questionId] == null)
		{
			surveyAwnser[questionId] = {};
		}

		surveyAwnser[questionId][choiceId] = choiceValue ;

		component.set("v.surveyAwnser",surveyAwnser);

		var choiceUpdateEvent = component.getEvent("scoreUpdate");
        choiceUpdateEvent.setParams({ 
				'choiceValue' : {Id: questionId, value: choiceValue, choiceId: choiceId},
        	});

        choiceUpdateEvent.fire();

	},	


})