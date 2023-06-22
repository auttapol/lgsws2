({
	updateCurrencyData: function (component) {
		console.log('-----updateCurrencyData-----');
        var isInput = component.get("v.isInput");
		var selectType = component.get("v.selectType");
		var choiceValue = component.get("v.isValue");
		
		var finalChoiceValue;
		var type = "";
        
		if (isInput == undefined) {
			isInput = "";			  
		}
        if (choiceValue == undefined) {
			choiceValue = "";			  
		}

		if (selectType == 'Other') {
			if (choiceValue == undefined || choiceValue == "") {
				type = "";  
			}
			else {
				type = choiceValue;   
			}
 
		}
        else if(selectType == undefined)
        {
            choiceValue = "";	
        }
		else {
			type = selectType;
		}
        
		if (isInput != "" && type != "" && isInput != undefined && type != undefined) {
			component.set("v.choiceVerified", true);
		}
		else {
			component.set("v.choiceVerified", false);
		}

		if (isInput.match(/^\-?.[0-9]+$/g)) {

			var array = isInput.split('.');

			if (!array[0].match(/[0-9]/g)) {
				if (array[1] != undefined) {
					isInput = array[0] + '0.' + array[1];
				}				
				else {
					isInput = array[0] + '0.';
				}
			}
			else
			{
				if(parseInt(array[1]) == 0) {
					isInput = array[0];
				}
			}

			if(!(isInput.includes('-0')) && parseInt(isInput) == 0) {
				isInput = '0';
			}
			finalChoiceValue = isInput + " " + type;
		}
		else {
			if(!(isInput.includes('0.')) && parseInt(isInput) == 0) {
				isInput = '0';
			}
			finalChoiceValue = isInput + " " + type;
		}
        
        if (isInput.match(/^\-?[0][0-9]+.?(\.\d{1,2})?$/g))
        {
            var firstOccuranceIndex = isInput.search(/[1-9]/);
            isInput = isInput.substr(0, firstOccuranceIndex).replace(/0/g, '')+isInput.slice(firstOccuranceIndex);	
            finalChoiceValue = isInput + " " + type;
        }
		finalChoiceValue = isInput + " " + type;
        
        console.log("Input Helper choiceVerified:",component.get("v.choiceVerified"),"'")

        component.set("v.isInput", isInput);
        if(selectType != 'Other'){
            component.set("v.selectType", type);
        }
        
		component.set("v.AnswerValue", finalChoiceValue);
        console.log("Input Helper isChecked:",component.get("v.isChecked"),"'")
        console.log(component.get("v.AnswerValue"));
        console.log('-----updateCurrencyData-----');
	},

})