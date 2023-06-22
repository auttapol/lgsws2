({	
	updateNumberChoice : function(component, event, helper) {

		var isInput  = event.target.value;
		// console.log('isInput123',isInput);
		component.set("v.isInput",isInput);

	   helper.updateData(component);
   },

	updateCurrencyChoice : function(component, event, helper) {

	//////////////////Other/////////////////////
		var selectedOptionValue = event.getParam("value");
		component.set("v.selectType",selectedOptionValue);
		//  console.log('isSelect',selectedOptionValue);

		helper.updateData(component);
	},


	updateinputChoice : function(component, event, helper) {
		var isValue = event.target.value;
		component.set("v.isValue", isValue);
		//  console.log('isValue',isValue);
		
		helper.updateData(component);
	},


	init: function (component,event) {
		var ListOfValues = component.get("v.choiceSelect");
		// console.log(ListOfValues + ' 44');
		// console.log(ListOfValues.List_Values__c);

		var selectedOptionValue = event.getParam("value");

		var result = ListOfValues.choice.List_Values__c;
		result = result.split('\r\n');
		var items = [];
        for (var i = 0; i < result.length; i++) {
            var item = {
                "label": result[i].replace(/\n\r/gi, ''),
                "value": result[i].replace(/\n\r/gi, ''),
			};
            items.push(item);
		}

		 var item1 = {
                "label": 'Other',
                "value": 'Other',
            };
            items.push(item1);
		//console.log(items);
		// console.log(items);
		component.set("v.options", items);
		
		var choiceSelect = component.get("v.choiceSelect");
		var mapAnswer = component.get("v.mapAnswer");
		var value;
		var num=0;


		if(JSON.stringify(mapAnswer) != "{}")
		{
			//component.set("v.AnswerValue", mapAnswer);
			for(var question in mapAnswer)
			{
				if(question == choiceSelect.mainQuestionId){
					for(var choice in mapAnswer[question])
					{
						if(choice == choiceSelect.choice.Id)
						{
							value = mapAnswer[question][choice];
							value = value.split(' ');
				
							for(var key in items)
							{
								if(items[key].value != value[1])
								{
									num++;
								}
							}

							if(items.length == num) {
								component.set("v.AnswerNumber", value[0]);
								component.set("v.AnswerValue", 'Other');
								component.set("v.OtherValue", value[1]);
								component.set("v.selectType", 'Other');
							} else {
								component.set("v.AnswerNumber", value[0]);
								component.set("v.AnswerValue", value[1].replace(/\n\r/gi, ''));
							}
						}
					}
				}
			
			}
		}
		else
		{
			value = "";
			component.set("v.AnswerValue", value);
		}

	},
	
	// handleChange: function (cmp, event) {
    //     // This will contain the string of the "value" attribute of the selected option
    //     var selectedOptionValue = event.getParam("value");
    //     alert("Option selected with value: '" + selectedOptionValue + "'");
    // },
	
})