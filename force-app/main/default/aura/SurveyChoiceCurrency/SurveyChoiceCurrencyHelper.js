({
	updateData : function(component) {
		var choiceSelect = component.get("v.choiceSelect");

		var isInput = component.get("v.isInput");
		var selectType = component.get("v.selectType");
		var isValue = component.get("v.isValue");
		
		var isScore = choiceSelect.choice.Score__c;
		var isSumValue;
		var type;		
		var isChecked;

		if(selectType == 'Other')
		{
			type = isValue;
		}
		else
		{
			type = selectType;
		}

		if(isInput != "" && type != "")
		{
			isChecked = true;
		}
		else
		{
			isChecked = false;
		}

		if(isInput == undefined || type == undefined)
		{
			isSumValue = "";
			isChecked = false;
		}
		else
		{
			isSumValue = isInput + " " + type; 
		}

		if(isScore == undefined)
		{
			isScore = 0;
		}
		var choiceUpdateEvent = component.getEvent("choiceUpdate");
        choiceUpdateEvent.setParams({ 
        		'choiceId' :  choiceSelect.choice.Id ,
				'questionId' :  choiceSelect.mainQuestionId ,
				'choiceValue' : { 'choiceValue' :  isSumValue,
								'choiceChecked' : isChecked,
								'choiceScore' : isScore,
								'choiceType': choiceSelect.choice.Option_Type__c  }
        	});

		choiceUpdateEvent.fire();
	}
})