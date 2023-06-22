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
            }, [])
        });
        // action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                objectInfoField.regisStateTable = {
                    isAccessible : false
                };
                objectInfoField.e_statement= {
                    isAccessible : false
                };
                objectInfoField.CYC_Campaign_PromoCond_api= {
                    isAccessible : false
                };
                
                component.set('v.dataFields', objectInfoField);
    
                helper.getAPIFieldsSection(component, event, helper, 'regisStateTable', objectInfoField);
                helper.getAPIFieldsSection(component, event, helper, 'e_statement', objectInfoField);

                component.set('v.EStatement.data', [{
                    'CreditCard': component.get('v.dataFields.RTL_CC_STMT_status__c.value') == 'Y',
                    'RDC': component.get('v.dataFields.RTL_RDC_STMT_status__c.value') == 'Y',
                    'C2G': component.get('v.dataFields.RTL_C2G_STMT_status__c.value') == 'Y',
                }]);

                helper.get4ThanaInformation(component, objectInfoField);
                helper.getOnSiteService(component, objectInfoField);
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

    getAPIFieldsSection: function (component, event, helper, field, objectInfoField){
        var action = component.get('c.getVerifyByField');
        action.setParams({
            "field": field,
            "profileName": component.get('v.profileName'),
            "recordId": component.get('v.recordId'),
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state == 'SUCCESS'){
                const result = response.getReturnValue();
                if( field == 'regisStateTable'){
                    component.set(`v.dataFields.regisStateTable.isAccessible`, result);
                    if(result == true){
                        helper.getCVSAnalyticsData(component, event, helper);
                    }
                }
                else if( field == 'e_statement'){
                    component.set(`v.dataFields.e_statement.isAccessible`, result);
                }
            }
            else if(state === 'ERROR') {
                console.error('error: getVerifyByField');
            } else {
                console.error('Unknown problem, state.');
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
                console.error('error: getProfileName');
            } else {
                console.error('Unknown problem, state.');
            }
        });
        $A.enqueueAction(action);
    },

    getCVSAnalyticsData: function (component, event, helper) {
        var action = component.get('c.getCVSAnalyticsData');
        action.setParams({
            'rmId': component.get('v.dataFields.TMB_Customer_ID_PE__c.value')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result && result.Status == 'SUCCESS') {
                    component.set('v.dataFields.RTL_Entitled_Privilege2__c.value', result.entitledPrivilege2Desc ? result.entitledPrivilege2Desc.split('|').filter(f => f).join('<br />') : '');
                    component.set('v.dataFields.RTL_Privilege2__c.value', result.currentPrivilege2Desc ? (result.currentPrivilege2Desc.includes('|') ? result.currentPrivilege2Desc.split('|').filter(f => f).join('<br />') : result.currentPrivilege2Desc) : '');
                    component.set('v.TouchIBProm.data', [{
                        'TMBTouch': result.touchStatus ? result.touchStatus == 'YES' : false,
                        'InternetBanking': result.ibStatus ? result.ibStatus == 'YES' : false,
                        'PromptPay': result.promptPay ? result.promptPay == 'YES' : false,
                    }]);
                }
            }
            else if(state === 'ERROR') {
                console.error('error: getCVSAnalyticsData');
            } else {
                console.error('Unknown problem, state.');
            }
        });
        if (component.get('v.dataFields.TMB_Customer_ID_PE__c.value'))
            $A.enqueueAction(action);
    },
    get4ThanaInformation: function (component, objectInfoField) {
        var cmp = component.get('v.dataFields.RTL_4THANA_Info__c');
        if(cmp.isAccessible == true){
            var RTL_4THANA_Fund_AMT__c = objectInfoField['RTL_4THANA_Fund_AMT__c'].value ? objectInfoField['RTL_4THANA_Fund_AMT__c'].value : '0';
            var RTL_4THANA_Aggregate_Bond_AMT__c = objectInfoField['RTL_4THANA_Aggregate_Bond_AMT__c'].value ? objectInfoField['RTL_4THANA_Aggregate_Bond_AMT__c'].value : '0';
            var RTL_4THANA_Bond_AMT__c = objectInfoField['RTL_4THANA_Bond_AMT__c'].value ? objectInfoField['RTL_4THANA_Bond_AMT__c'].value : '0';
            var RTL_4THANA_Short_Bond_AMT__c = objectInfoField['RTL_4THANA_Short_Bond_AMT__c'].value ? objectInfoField['RTL_4THANA_Short_Bond_AMT__c'].value : '0';
            var RTL_4THANA_Total_AMT__c = objectInfoField['RTL_4THANA_Total_AMT__c'].value ? objectInfoField['RTL_4THANA_Total_AMT__c'].value : '0';
            cmp.value = '- ' + objectInfoField['RTL_4THANA_Fund_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Fund_AMT__c) + ' บาท'
                        + '<br/>- ' + objectInfoField['RTL_4THANA_Aggregate_Bond_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Aggregate_Bond_AMT__c) + ' บาท'
                        + '<br/>- ' + objectInfoField['RTL_4THANA_Bond_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Bond_AMT__c) + ' บาท'
                        + '<br/>- ' + objectInfoField['RTL_4THANA_Short_Bond_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Short_Bond_AMT__c) + ' บาท'
                        + '<br/>- ' + objectInfoField['RTL_4THANA_Total_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Total_AMT__c) + ' บาท';
            // component.set('v.dataFields.RTL_4THANA_Info__c.value', component.get('v.fields'));
        }
    },
    getOnSiteService: function (component, objectInfoField) {
        var cmp = component.get('v.dataFields.RTL_OnSite_Service__c');
        if(cmp.isAccessible == true){
            var RTL_OnSite_Service__c = objectInfoField['RTL_OnSite_Service__c'].value ? objectInfoField['RTL_OnSite_Service__c'].value : '';
            var RTL_OnSite_Service_User_Update__c = objectInfoField['RTL_OnSite_Service_User_Update__c'].value ? objectInfoField['RTL_OnSite_Service_User_Update__c'].value : '';
            var RTL_OnSite_Service_Update_Date__c = objectInfoField['RTL_OnSite_Service_Update_Date__c'].value ? objectInfoField['RTL_OnSite_Service_Update_Date__c'].value : '';
            if (RTL_OnSite_Service_Update_Date__c != ''){
                RTL_OnSite_Service_Update_Date__c = $A.localizationService.formatDateTime((objectInfoField['RTL_OnSite_Service_Update_Date__c'].value),'dd/MM/yyyy');
                RTL_OnSite_Service_Update_Date__c = ' [' + RTL_OnSite_Service_Update_Date__c + ']';
            }
            if (RTL_OnSite_Service_User_Update__c != ''){
                RTL_OnSite_Service_User_Update__c = '[' + RTL_OnSite_Service_User_Update__c + ']';
            }
            cmp.value = RTL_OnSite_Service__c + RTL_OnSite_Service_Update_Date__c + RTL_OnSite_Service_User_Update__c;
        }
        // component.set('v.dataFields.RTL_4THANA_Info__c.value', component.get('v.fields'));
    },
    numberWithCommas: function (x) {
        var dec = parseFloat(x).toFixed(2);
        var parts = dec.toString().split(".");
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join(".");
    },
    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                "<text transform='translate(20, 65) rotate(-45)' fill='rgb(240,240,240)' font-size='25' font-family='Helvetica' weight='700'>" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            }
            else if(state === 'ERROR') {
                console.error('error: getWatermarkHTML');
            } else {
                console.error('Unknown problem, state.');
            }
		});
		$A.enqueueAction(action);
	},
})