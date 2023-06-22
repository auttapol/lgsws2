({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    startSpinner: function (component) {
        component.set('v.isRerender', true);
    },
    stopSpinner: function (component) {
        component.set('v.isRerender', false);
    },
    getDescribeFieldResult: function (component, event, helper) {
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.fields').filter(f => f),
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                helper.generateField(component, objectInfoField, component.get('v.fields').filter(f => f).map(m => {
                    return {
                        "fieldName": m
                    };
                }));
                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    generateField: function (component, objectInfoField, fieldList) {
        fieldList.forEach(cmp => {
            cmp.type = objectInfoField[cmp.fieldName].type;
            cmp.label = objectInfoField[cmp.fieldName].label;
            cmp.value = objectInfoField[cmp.fieldName].value ? objectInfoField[cmp.fieldName].value : '';
            cmp.inlineHelpText = objectInfoField[cmp.fieldName].inlineHelpText ? objectInfoField[cmp.fieldName].inlineHelpText : '';
            cmp.isAccessible = objectInfoField[cmp.fieldName].isAccessible ? objectInfoField[cmp.fieldName].isAccessible : false;
        });
        component.set('v.fields', component.get('v.fields').map(m => m ? fieldList.find(f => f.fieldName == m) : m));
    },
    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();
                // console.log('watermarkHTML: ', watermarkHTML);

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('STATE ERROR');
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
		});
		$A.enqueueAction(action);
	},
})