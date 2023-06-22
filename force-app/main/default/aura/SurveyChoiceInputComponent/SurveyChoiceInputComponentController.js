({
	updateinputChoice: function (component, event, helper) {
		console.log('Child---updateinputChoice---');
        var isValue = event.target.value;
		var ListOfValues = component.get("v.choiceSelect");
		var requireType = ListOfValues.choice.Require_Type__c;

		var requireList = [];
		if (requireType != null) {
			requireList = requireType.split(";");
		}
		
        isValue = isValue.replace(/^\s+/g, '');
		component.set("v.isValue", isValue);

		if (requireList.includes("Not allow -")) {
			var isNotDashVerify = true;

			if (requireList.includes("Not allow -")) {
				if (isValue == "" || isValue.indexOf('-') == 0) {
					isNotDashVerify = false;
				}

			}

			component.set("v.choiceVerified", isNotDashVerify);

		} else {
			component.set("v.choiceVerified", true);
		}
        component.set("v.AnswerValue", isValue);
        console.log('choiceVerified: ' + component.get("v.choiceVerified"));
		console.log('Child---updateinputChoice---');
	},


	updateCurrencyNumberChoice: function (component, event, helper) {
		console.log('Child---updateCurrencyNumberChoice---');
        var isInput = event.target.value;
		var firstOccuranceIndex = isInput.search(/\./) + 1; // Index of first occurance of (.)

		if(!isInput.match(/^(\-)?\d*(\.\d{1,2})?$/g) )
		{
			isInput = isInput.substr(0, 1) + isInput.slice(1).replace(/\-/g, '');
			isInput = isInput.substr(0, firstOccuranceIndex) + isInput.slice(firstOccuranceIndex).replace(/\./g, '');	
		}
		isInput = isInput.replace(/[^\.\-0-9]/gi, '');
       
		component.set("v.isInput", isInput);
		
		helper.updateCurrencyData(component);
        console.log('isChecked:'+component.get("v.isChecked"));
        console.log('Child---updateCurrencyNumberChoice---');

	},

	updateCurrencyChoice: function (component, event, helper) {
        console.log('Child---updateCurrencyChoice---');

		var selectedOptionValue = event.getParam("value");

		component.set("v.selectType", selectedOptionValue);

		helper.updateCurrencyData(component);
	},


	updateCurrencyinputChoice: function (component, event, helper) {
        console.log('Child---updateCurrencyinputChoice---');

        var isValue = event.target.value;
		component.set("v.isValue", isValue);

		helper.updateCurrencyData(component);
	},

	updateSelectboxChoice: function (component, event, helper) {
		var selectedOptionValue = event.getParam("value");
        if (selectedOptionValue != '') {
			component.set("v.choiceVerified", true);
			component.set("v.isChecked", true);
			component.set("v.AnswerValue", selectedOptionValue);
		}


	},
	updateTelephoneChoice: function (component, event, helper) {
		var TelephoneValue = event.target.value;
		var TelephoneValidity = component.find("tel_input").get("v.validity");
		component.set("v.choiceVerified", false);

		if (TelephoneValidity.valid) {
			component.set("v.choiceVerified", true);
			component.set("v.AnswerValue", TelephoneValue);
		}
	},
	updateEmaiChoice: function (component, event, helper) {
		var EmailValue = event.target.value;
		var EmailValidity = component.find("email_input").get("v.validity");
		component.set("v.choiceVerified", false);
		if (EmailValidity.valid) {
			component.set("v.choiceVerified", true);
			component.set("v.AnswerValue", EmailValue);
		}
        else
        {
            EmailValue = '';
            component.set("v.AnswerValue", EmailValue);
        }
	},

	init: function (component,helper) {
		var surveyAwnser = component.get("v.surveyAwnser");
		var choiceSelected = component.get("v.choiceSelect");
		var allChoiceListString = choiceSelected.choice.List_Values__c;
       
		if (allChoiceListString) {

			allChoiceListString = allChoiceListString.split('\n');
			var items = [];
			for (var i = 0; i < allChoiceListString.length; i++) {
				var item = {
					"label": allChoiceListString[i] ? allChoiceListString[i].replace(/\n\r/gi, '').trim() : "",
					"value": allChoiceListString[i] ? allChoiceListString[i].replace(/\n\r/gi, '').trim() : "",
				};
				items.push(item);
			}

			if (choiceSelected.choice.Input_Text_Type__c == 'currency') {
				var item1 = {
					"label": 'Other',
					"value": 'Other',
				};
				items.push(item1);
			}
			component.set("v.options", items);

			if (choiceSelected.choice.Input_Text_Type__c == 'currency') {
				var num = 0;
				if (surveyAwnser[choiceSelected.mainQuestionId]) {
					var choiceObj = surveyAwnser[choiceSelected.mainQuestionId][choiceSelected.choice.Id];
					
                    var type;
					if (choiceObj) {
                        console.log('Input choiceObj:',choiceObj);
						if (choiceObj.choiceValue) {
							choiceObj = choiceObj.choiceValue.split(' ');
							if (choiceObj.length > 1) {
								component.set("v.isInput", choiceObj[0]);                               
								for (var key in items) {
									if (items[key].value.trim() != choiceObj[1].trim()) {
										num++;
									} else {
										type = items[key].value;
									}
								}
								if (items.length == num) {
									component.set("v.isValue", choiceObj[1]);
									component.set("v.selectType", 'Other');
								} else {
									component.set("v.selectType", type);
								}
							} else {
                                if(choiceObj[0].match(/^[0-9]*$/)){
                                    component.set("v.isInput", choiceObj[0]);
                                    component.set("v.selectType", '');
                                } else {
                                    component.set("v.isInput", '');
                                    component.set("v.selectType", choiceObj[0]);
                                }
                                component.set("v.AnswerValue", choiceObj[0]);
                                console.log('---------------------------here---------------------------');
                            }
                        } else {
                            component.set("v.isInput", '');
                            component.set("v.selectType", '');
                        }
					}
                    console.log('choiceChecked:'+component.get("v.choiceChecked")+"'");
                    console.log('choiceVerified:'+component.get("v.choiceVerified")+"'");
                    console.log('isValue:'+component.get("v.isValue")+"'");
                    console.log('isInput:'+component.get("v.isInput")+"'");
                    console.log('selectType:'+component.get("v.selectType")+"'");
				} else {
					component.set("v.AnswerValue", "");
				}
			} else if (choiceSelected.choice.Input_Text_Type__c == 'select box') {
				var choiceObj = surveyAwnser[choiceSelected.mainQuestionId][choiceSelected.choice.Id];
                if (choiceObj) {
					component.set("v.AnswerValue", choiceObj.choiceValue ? choiceObj.choiceValue.trim() : "");
				}
			}
		} else {
			if (surveyAwnser[choiceSelected.mainQuestionId]) {
				var choiceObj = surveyAwnser[choiceSelected.mainQuestionId][choiceSelected.choice.Id];
				if (choiceObj) {
                    component.set("v.isValue", choiceObj.choiceValue);
                }
                    
                else {
					component.set("v.isValue", "");
				}
			} else {
				component.set("v.AnswerValue", "");
			}
		}
	},

})