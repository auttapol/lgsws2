({	
	updateCheckboxChoice : function(component, event, helper) {
		console.log('-----updateCheckboxChoice-----');
        var isChecked = event.target.checked;
        var AnswerValue = component.get("v.AnswerValue");
        var isInput = component.get("v.isInput")
		var selectType = component.get("v.selectType")        
		component.set("v.isChecked", isChecked);
        
        if(isChecked == false )
		{
			component.set("v.choiceVerified", false);
        } else if (isChecked == true && isInput != '' && selectType != '' ){
            
            component.set("v.choiceVerified", true);
        }
        
		helper.updateData(component);
	}, 


	init: function (component) {

		var choiceSelect = component.get("v.choiceSelect");
		var surveyAwnser = component.get("v.surveyAwnser");       
		if( surveyAwnser[choiceSelect.mainQuestionId] != undefined )
		{
			var choiceObj = surveyAwnser[choiceSelect.mainQuestionId][choiceSelect.choice.Id];
            
			component.set("v.answerObj",choiceObj);
			
			if( choiceObj == undefined || (choiceObj.choiceChecked == false && choiceObj.choiceValue == undefined))
			{
				component.set("v.isChecked", false);
            } 
			else
			{        

                if(choiceObj.choiceValue == undefined){
                    component.set("v.AnswerValue", ' ');
                } else if(choiceObj.choiceValue != undefined && choiceObj.choiceChecked == false){
                    component.set("v.AnswerValue", choiceObj.choiceValue);
                } else {
                    component.set("v.AnswerValue", choiceObj.choiceValue + ' ');
                }     
                
                if(choiceObj.choiceChecked == false)
                {
                    component.set("v.isChecked", false);
                    component.set("v.choiceVerified", false);
                   
                } else if(choiceObj.choiceChecked == true)
                {
                    component.set("v.isChecked", true);
                    component.set("v.choiceVerified", true);
                    
                    if(choiceObj.choiceValue == undefined){
                        component.set("v.AnswerValue", ' ');
                    } else {
                        component.set("v.AnswerValue", choiceObj.choiceValue);
                    }
                }
                              
			}
		}
		else
		{
			component.set("v.isChecked", false);
		}
		
	},

	itemsChange: function(component, event, helper) {
		var AnswerValue = component.get("v.AnswerValue");
        var isInput = component.get("v.isInput")
		var selectType = component.get("v.selectType")  
        var choiceVerified = component.get("v.choiceVerified");
        
		if(AnswerValue == " " + undefined ) 
		{	
			component.set("v.isChecked", false);
            component.set("v.choiceVerified", false);
		}
		else if(AnswerValue == "" || AnswerValue == undefined)
		{
			component.set("v.isChecked", false);
            component.set("v.choiceVerified", false);
		}
        else if(isInput == '' || selectType == '')
        {
        	component.set("v.choiceVerified", false);
        }
		else if (choiceVerified != false)
		{
            component.set("v.isChecked", true);
		}
        else
        {
            component.set("v.isChecked", true);
        }
		helper.updateData(component);
    }

})