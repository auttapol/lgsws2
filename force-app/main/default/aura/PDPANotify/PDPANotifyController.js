({
	onInit : function(component, event, helper) {
		component.set('v.message', '');
		component.set('v.isNeedUpdate', false);
		component.set('v.isCallServiceError', false);
		var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        component.set("v.retrySetTimeOut", retrySetTimeOut);
        component.set("v.numOfRetryTime", numOfRetryTime);

		
		var tmbCustId = component.get('v.tmbCustId');
		// console.log('tmbCust', tmbCustId);
		var action = component.get('c.getFagPdpa');
		var isShowErrorMsg = false;
        
        action.setParams({
			"tmbCustId": tmbCustId,
            "serviceName" : 'PDPA_GET_CONSENT_FAG_NOTIFY'
		});

		action.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === 'SUCCESS') {
				var result = response.getReturnValue();

				const replacer = str => ({
					'\t': '\\t',
					'\n': '\\n',
					'\b': '\\b',
					'\r': '\\r',
					'\f': '\\f',
					'\\': '\\\\',
					'': '\\\\'
				}[str]);
				
				const regEx = new RegExp('\\\\|\t|\n|\b|\r|\f', 'g');
				
				const replacedText = result.replace(regEx, replacer);
				
				var resultObj = JSON.parse(replacedText);

				// var resultObj = JSON.parse(result);
				var isNeedUpdate = false;
				var isCallServiceError = false;
				var message = '';

				if(resultObj.isSuccess == 'true'){
					isCallServiceError = false;
					
					if(resultObj.MARKETNeedUpdate == 'Y' && resultObj.PDPANeedUpdate == 'Y'){
						message = $A.get('$Label.c.PDPA_Notify_User_PDPA_Market');
						isNeedUpdate = true;
					}else if(resultObj.MARKETNeedUpdate == 'Y'){
						message = $A.get('$Label.c.PDPA_Notify_User_Market')
						isNeedUpdate = true;
					}else if(resultObj.PDPANeedUpdate == 'Y'){
						message = $A.get('$Label.c.PDPA_Notify_User_PDPA')
						isNeedUpdate = true;
					}
				}else if(resultObj.errorMessage == 'invalid_token'){
					var round = 1;
					window.setTimeout(
						$A.getCallback(function () {
							helper.retryCalloutGetFagPdpa(component,event, helper, round);
						}), component.get("v.retrySetTimeOut")
					);
				}else{	
					message = $A.get('$Label.c.PDPA_Error_Response');
					isCallServiceError = true;
					isShowErrorMsg = true;
				}
			}else{
				message = $A.get('$Label.c.PDPA_Error_Response');
				isCallServiceError = true;
				isShowErrorMsg = true;
			}
			component.set('v.message', message);
			component.set('v.isNeedUpdate', isNeedUpdate);
			component.set('v.isShowErrorMsg', isShowErrorMsg);
			component.set('v.isCallServiceError', isCallServiceError);
		});
		if(tmbCustId)$A.enqueueAction(action);
		
	},
	handlerAccount: function (component, event, helper) {
		var tmbCustId = component.get('v.account.TMB_Customer_ID_PE__c');
		component.set('v.tmbCustId', tmbCustId);

		var action = component.get('c.getFagPdpa');
		var isShowErrorMsg = false;
        
        action.setParams({
			"tmbCustId": tmbCustId,
            "serviceName" : 'PDPA_GET_CONSENT_FAG_NOTIFY'
		});

		action.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === 'SUCCESS') {
				var result = response.getReturnValue();

				const replacer = str => ({
					'\t': '\\t',
					'\n': '\\n',
					'\b': '\\b',
					'\r': '\\r',
					'\f': '\\f',
					'\\': '\\\\',
					'': '\\\\'
				}[str]);
				
				const regEx = new RegExp('\\\\|\t|\n|\b|\r|\f', 'g');
				
				const replacedText = result.replace(regEx, replacer);
				
				var resultObj = JSON.parse(replacedText);

				// var resultObj = JSON.parse(result);
				var isNeedUpdate = false;
				var isCallServiceError = false;
				var message = '';

				if(resultObj.isSuccess == 'true'){
					isCallServiceError = false;
					
					if(resultObj.MARKETNeedUpdate == 'Y' && resultObj.PDPANeedUpdate == 'Y'){
						message = $A.get('$Label.c.PDPA_Notify_User_PDPA_Market');
						isNeedUpdate = true;
					}else if(resultObj.MARKETNeedUpdate == 'Y'){
						message = $A.get('$Label.c.PDPA_Notify_User_Market')
						isNeedUpdate = true;
					}else if(resultObj.PDPANeedUpdate == 'Y'){
						message = $A.get('$Label.c.PDPA_Notify_User_PDPA')
						isNeedUpdate = true;
					}
				}else if(resultObj.errorMessage == 'invalid_token' ){
					var round = 1;
					window.setTimeout(
						$A.getCallback(function () {
							helper.retryCalloutGetFagPdpa(component,event, helper, round);
						}), component.get("v.retrySetTimeOut")
					);
				}else{
					message = $A.get('$Label.c.PDPA_Error_Response');
					isCallServiceError = true;
					isShowErrorMsg = true;
				}
			}else{
				message = $A.get('$Label.c.PDPA_Error_Response');
				isCallServiceError = true;
				isShowErrorMsg = true;
			}
			component.set('v.message', message);
			component.set('v.isNeedUpdate', isNeedUpdate);
			component.set('v.isShowErrorMsg', isShowErrorMsg);
			component.set('v.isCallServiceError', isCallServiceError);
		});
		if(tmbCustId)$A.enqueueAction(action);
	},
})