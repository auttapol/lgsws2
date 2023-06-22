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
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    runInitialize: function (component, event, helper) {
        helper.getDescribeFieldResult(component, event, helper);
    },
    getDescribeFieldResult: function (component, event, helper) {
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.fields').reduce((l, i) => {
                if (i.fieldName && !l.includes(i.fieldName))
                    l.push(i.fieldName);
                return l;
            }, []),
            "fields_translate": component.get('v.fields_translate')
        });
        // action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                component.set('v.dataFields', objectInfoField);

                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    helper.displayToast('error', error.message);
                });
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    getProfileName: function (component, event, helper) {
        var action = component.get('c.getProfileName');
        action.setParams({
            "userId": component.get('v.userId'),
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.profileName', result);
            }
            else if(state === 'ERROR') {
                console.log('error : getProfileName');
            } else {
                console.log('Unknown problem, state.');
            }
        });
        $A.enqueueAction(action);
    },
    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();
                
                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                document.documentElement.style.setProperty('--backgroundImage', bg);
            }
            else if(state === 'ERROR') {
                console.log('error : getWatermarkHTML');
            } else {
                console.log('Unknown problem, state.');
            }
		});
		$A.enqueueAction(action);
	},
})