({
	onInit : function(component, event, helper) {

		var choiceSelect = component.get("v.choiceSelect");
		var surveyAwnser = component.get("v.surveyAwnser");
		var value;

		if(surveyAwnser != null)
		{
			var choiceSelect = component.get("v.choiceSelect");
			var surveyAwnser = component.get("v.surveyAwnser");

			for(var question in surveyAwnser)
			{
				if(question == choiceSelect.mainQuestionId){
					for(var choice in surveyAwnser[question])
					{
						if(choice == choiceSelect.choice.Id)
						{
							value = surveyAwnser[question][choice];
							component.set("v.answerObj",value);

							component.set("v.isValue", value[0]);	
				
						}
					}
				}	
			}		
		}
		else
		{
			value = "";
			component.set("v.isValue", value);
		}

	},

	
	itemsChange: function(component, event, helper) {
		console.log('------Text-itemsChange------');
        var AnswerValue = component.get("v.AnswerValue");
        var choiceVerified = component.get("v.choiceVerified");
        var isInput = component.get("v.isInput");
		var selectType = component.get("v.selectType");
   
		if(AnswerValue == undefined || AnswerValue == "" || choiceVerified == false)
		{
			component.set("v.isChecked", false);
		}
		else if (choiceVerified == true && (AnswerValue != undefined || AnswerValue != ""))
		{
			component.set("v.isChecked", true);
		}

		helper.updateData(component); 
        console.log('------Text-itemsChange------');
    },
})