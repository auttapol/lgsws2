({
	updateData : function(component) {
        console.log('-----helper-----');
		var choiceSelect = component.get("v.choiceSelect");

		var isChecked = component.get("v.isChecked");
		var AnswerValue = component.get("v.AnswerValue");
		var isScore = choiceSelect.choice.Score__c;
		var choiceVerified = component.get("v.choiceVerified");
		var answerObj = component.get("v.answerObj");

		var requireType = choiceSelect.choice.Require_Type__c;
		var requireList = [];
		if( requireType != null )
		{
			requireList = requireType.split(";");
		}

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
		
        console.log('choiceVerified ' + choiceVerified);
        console.log('AnswerValue:'+ component.get("v.AnswerValue") + "'");
		if( choiceVerified == true )
		{
			if( requireList.includes("Required only when check") )
			{
                console.log("Required only when check",AnswerValue.length);
				var isRequireWhenCheck = true;

				if( isChecked && ( AnswerValue == '' || AnswerValue == ' ' ) )
				{
                    console.log("GET IN");
					isRequireWhenCheck = false;					
				}

				component.set("v.choiceVerified", isRequireWhenCheck );   

			}
			else
			{
				component.set("v.choiceVerified",true);   
			}
        } 
       
        choiceVerified = component.get("v.choiceVerified");
        console.log('choiceVerified after IF : ' + choiceVerified);
		var choiceUpdateEvent = component.getEvent("choiceUpdate");
        choiceUpdateEvent.setParams({ 
        		'choiceId' :  choiceSelect.choice.Id ,
				'questionId' :  choiceSelect.mainQuestionId ,
        		'choiceValue' : { 				
        			'choiceValue' : AnswerValue,
					'choiceChecked' : isChecked,
					'choiceVerified' : choiceVerified,
					'choiceScore' : isScore,
					'choiceType': choiceSelect.choice.Option_Type__c ,
					'answerId' : answerId,
				},
				
        	});

		choiceUpdateEvent.fire();
        console.log('-----helper-----');
	},

})