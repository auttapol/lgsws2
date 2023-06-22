({
	displayToast: function (component, type, message) {
		var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			type: type,
			message: message,
			duration: duration
		});
		toastEvent.fire();
	},
	parseObj: function (obj) {
		return JSON.parse(JSON.stringify(obj));
	},
	startSpinner: function (component) {
		component.set("v.showSpinnerLoading", true);
	},
	stopSpinner: function (component) {
		component.set("v.showSpinnerLoading", false);
	},
	displayErrorMeassge: function (component, event, errors, isDisplay) {
		if (isDisplay) {
			component.set('v.errorMessageList', errors.reduce((listError, error) => {
				listError.push({
					'errorHeader': error.header,
					'errorMessage': error.message,
				});
				return listError;
			}, []));
		}
		component.set('v.showErrorMessage', isDisplay);
	},
	getBussinessGroup: function (component, event, helper) {
		var action = component.get('c.getBusinessGroup');
		action.setStorable();
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
				component.set('v.businessGroupCodeList', result.reduce((list, i) => {
					list.push({
						'label': i.BusinessGroupNameTH__c,
						'value': i.BusinessGroupCode__c
					});
					return list;
				}, []));
				// console.log(component.get('v.businessGroupCodeList'));
			} else {
				component.set('v.businessGroupCodeList', []);
			}
		});
		$A.enqueueAction(action);
	},
	getVFBaseURL: function (component, event, helper) {
		var action = component.get('c.getVFBaseURL');
		// action.setStorable();
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
				component.set('v.vfHost', result[1]);
				helper.addEventListenerWorkingCapital(component, event, helper);
			}
		});
		$A.enqueueAction(action);
	},
	addEventListenerWorkingCapital: function (component, event, helper) {
		// set defualt result no response
		var result = {
			'isSuccess': false,
			'wcLimit': 0,
			'errorMessage': $A.get("$Label.c.Timeout_message")
		};
		window.addEventListener("message", function (event) {
			helper.stopSpinner(component);
			var vfHost = component.get('v.vfHost') ? component.get('v.vfHost') : '';
			if (event.origin.toLowerCase() !== vfHost.toLowerCase()) {
				// Not the expected origin: reject message
				return;
			}
			// Only handle messages we are interested in
			if (event.data.topic === "smartbdm.com.tmbbank.message") {
				var workingCapital = event.data.result ? event.data.result : result;
				component.set('v.calculateRequest.wcLimit', workingCapital.isSuccess ? workingCapital.wcLimit : 0);
				helper.displayErrorMeassge(component, event, [{
					'header': '',
					'message': workingCapital.errorMessage
				}], !workingCapital.isSuccess);
			}
		}, false);
	},
	getWorkingCapital: function (component, event, helper) {
		helper.startSpinner(component);
		var calculateRequest = component.get('v.calculateRequest');

		var action = component.get('c.getWorkingCapitalContinuation');
		// action.setStorable();
		action.setParams({
			'businessGroupCode': calculateRequest.businessGroupCode,
			'salePerYear': Number(calculateRequest.salePerYear),
			'tmbWcLimit': Number(calculateRequest.tmbWcLimit)
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var workingCapital = response.getReturnValue();
				// console.log(workingCapital);

				component.set('v.calculateRequest.wcLimit', workingCapital.isSuccess ? workingCapital.wcLimit : 0);
				helper.displayErrorMeassge(component, event, [{
					'header': '',
					'message': workingCapital.errorMessage
				}], !workingCapital.isSuccess);

			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
						helper.displayToast(component, "Error", "Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
			helper.stopSpinner(component);
		});
		$A.enqueueAction(action);

		// var vf = component.find("vfFrame").getElement().contentWindow;
		// vf.postMessage({
		// 	topic: "smartbdm.com.tmbbank.message",
		// 	'businessGroupCode': calculateRequest.businessGroupCode,
		// 	'salePerYear': Number(calculateRequest.salePerYear),
		// 	'tmbWcLimit': Number(calculateRequest.tmbWcLimit)
		// }, component.get("v.vfHost"));
	},
	getDeepLink: function (component, event, helper) {
		var action = component.get("c.getDeepLink");
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var getDeepLink = response.getReturnValue();
				component.set('v.varDeepLink', getDeepLink);
			}
		});
		$A.enqueueAction(action);
	}
})