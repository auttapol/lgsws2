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
    runCallback: function (component, event, helper, objectInfoField) {
        component.set('v.account', objectInfoField);
        // GenerateField defualt field
        helper.generateField(component, objectInfoField, component.get('v.fields').filter(f => f.fieldName));
        // Special replace field

        helper.onCustomCustomerType(component, objectInfoField);
        helper.onCustomPrivilege1(component, objectInfoField);
        helper.onCustomBRNName(component, objectInfoField);
        helper.onCustomBRNDate(component, objectInfoField);
        helper.onCustomAUM(component, objectInfoField);
        // Kuong
        // helper.onCustomWA(component, objectInfoField);
        helper.onCustomWRM(component, objectInfoField);
        helper.onCustomCRM(component, objectInfoField);
        helper.onCustomRD(component, objectInfoField);
        // Kuong
        // helper.onCustomCalculatedWBPBAmount(component, objectInfoField);
        // helper.onCustomA_WBPB(component, objectInfoField);
        // Call service OSC07
        helper.getCVSAnalyticsData(component, event, helper);
    },
    getDescribeFieldResult: function (component, event, helper) {
        
        var action = component.get('c.getDescribeFieldResultAndValue');
        // console.log(component.get('v.fields').filter(f => f.trim()))
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.fields').reduce((l, i) => {
                if (i.fieldName && !l.some(f => f.trim() == i.fieldName))
                    l.push(i.fieldName);
                return l;
            }, component.get('v.dataFields').map(m => m.trim()))
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                // console.log(objectInfoField);
                helper.runCallback(component, event, helper, objectInfoField);
                // helper.stopSpinner(component);
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
            cmp.type = cmp.type ? cmp.type : objectInfoField[cmp.fieldName].type;
            cmp.label = objectInfoField[cmp.fieldName].label;
            cmp.value = objectInfoField[cmp.fieldName] ? objectInfoField[cmp.fieldName].value : '';
            cmp.inlineHelpText = objectInfoField[cmp.fieldName].inlineHelpText ? objectInfoField[cmp.fieldName].inlineHelpText : '';
            cmp.isAccessible = typeof cmp.isAccessible === "boolean" ? cmp.isAccessible : (objectInfoField[cmp.fieldName].isAccessible ? objectInfoField[cmp.fieldName].isAccessible : false);
        });
        component.set('v.fields', component.get('v.fields'));
    },
    onCustomCustomerType: function (component, objectInfoField) {
        var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'Customer_Type__c');
        cmp.label = objectInfoField['Customer_Type__c'].label + ' / ';
        cmp.label += objectInfoField['Core_Banking_Suggested_Segment__c'].label + ' (' + objectInfoField['Sub_segment__c'].label + ')' ;
        cmp.value = (objectInfoField['Customer_Type__c'].value ? objectInfoField['Customer_Type__c'].value : '-') + ' / ';
        cmp.value += (objectInfoField['Core_Banking_Suggested_Segment__c'].value ? objectInfoField['Core_Banking_Suggested_Segment__c'].value : '-');
        // cmp.isAccessible = objectInfoField['Core_Banking_Suggested_Segment__c'] ? true : false;
        cmp.type = 'STRING';
        component.set('v.fields', component.get('v.fields'));
    },
    onCustomPrivilege1: function (component, objectInfoField) {
        var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Privilege1__c');
        cmp.label = objectInfoField['RTL_Privilege1__c'].label + ' / ' + objectInfoField['RTL_Benefit_Status__c'].label;
        cmp.value = objectInfoField['RTL_Privilege1__c'].value ? objectInfoField['RTL_Privilege1__c'].value : '-';
        cmp.value += ' / ' + (objectInfoField['RTL_Benefit_Status__c'].value ? objectInfoField['RTL_Benefit_Status__c'].value : (objectInfoField['RTL_Privilege1__c'].value ? 'ไม่ได้รับสิทธิประโยชน์' : '-'));
        // cmp.isAccessible = objectInfoField['RTL_Privilege1__c'] ? true : false;
        cmp.type = 'STRING';
        component.set('v.fields', component.get('v.fields'));
    },
    onCustomBRNName: function (component, objectInfoField) {
        var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Most_Operating_Branch__c');
        cmp.label = objectInfoField['RTL_Most_Operating_Branch__c'].label + ' (' + objectInfoField['RTL_BRC_Type__c'].label + ')';
        cmp.value = objectInfoField['RTL_Most_Operating_Branch__c'].value ? objectInfoField['RTL_Most_Operating_Branch__c'].value : '';
        cmp.value_addon = objectInfoField['RTL_BRC_Type__c'].value ? objectInfoField['RTL_BRC_Type__c'].value : '-';
        cmp.inlineHelpText = objectInfoField['RTL_BRC_Type__c'].inlineHelpText;
        cmp.isAccessible = objectInfoField['RTL_Most_Operating_Branch__c'] ? true : false;
        cmp.type = 'REFERENCE_ADDON';
        component.set('v.fields', component.get('v.fields'));
    },
    onCustomBRNDate: function (component, objectInfoField) {
        var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Assigned_BRC__c');
        cmp.label = objectInfoField['RTL_Assigned_BRC__c'].label + ' (' + objectInfoField['RTL_BRC_Updated_Date__c'].label + ')';
        cmp.value = objectInfoField['RTL_Assigned_BRC__c'].value ? objectInfoField['RTL_Assigned_BRC__c'].value : '';
        cmp.value_addon = objectInfoField['RTL_BRC_Updated_Date__c'].value ? $A.localizationService.formatDateTime((objectInfoField['RTL_BRC_Updated_Date__c'].value),'dd/MM/yyyy') : '-';
        cmp.inlineHelpText = objectInfoField['RTL_BRC_Updated_Date__c'].inlineHelpText;
        cmp.isAccessible = objectInfoField['RTL_Assigned_BRC__c'] ? true : false;
        cmp.type = 'REFERENCE_ADDON';
        component.set('v.fields', component.get('v.fields'));
    },
    onCustomAUM: function (component, objectInfoField) {
        var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_AUM__c');
        cmp.label = objectInfoField['RTL_AUM__c'].label + ' (' + objectInfoField['RTL_AUM_Last_Calculated_Date__c'].label + ')';
        cmp.value = $A.get("$Locale.currency") + (objectInfoField['RTL_AUM__c'].value ? objectInfoField['RTL_AUM__c'].value.toLocaleString('en-US', {
            style: 'decimal',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }) : '0.00');
        cmp.value += objectInfoField['RTL_AUM_Last_Calculated_Date__c'].value ? ' [' + $A.localizationService.formatDateTime((objectInfoField['RTL_AUM_Last_Calculated_Date__c'].value),'dd/MM/yyyy') + ']' : '';
        // cmp.isAccessible = objectInfoField['RTL_AUM__c'] ? true : false;
        cmp.type = 'STRING';
        component.set('v.fields', component.get('v.fields'));
    },
    onCustomRD: function (component, objectInfoField) {
        var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Relationship_Duration_Years__c');
        cmp.label = objectInfoField['RTL_Relationship_Duration_Years__c'].label;
        cmp.value = objectInfoField['RTL_Relationship_Duration_Years__c'].value ? objectInfoField['RTL_Relationship_Duration_Years__c'].value : '';
        // cmp.isAccessible = objectInfoField['RTL_WA_Name__c'] ? true : false;
        cmp.type = 'DOUBLE';
        component.set('v.fields', component.get('v.fields'));
    },

    // Kuong
    // onCustomCalculatedWBPBAmount: function(component, objectInfoField){
    //         var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Calculated_WB_PB_Amount__c');
    //         cmp.label = objectInfoField['RTL_Calculated_WB_PB_Amount__c'].label;
    //         var WBPBAmount = objectInfoField['RTL_Calculated_WB_PB_Amount__c'].value

    //         var num1 = WBPBAmount.substring(1, WBPBAmount.length-1).split("/")[0];
    //         var num2 = WBPBAmount.substring(1, WBPBAmount.length-1).split("/")[1];

    //         var num_parts = num1.toString().split(".");
    //         var num_parts2 = num2.toString().split(".");

    //         num_parts[0] = num_parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    //         num_parts2[0] = num_parts2[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");

    //         if(num_parts[1]) num_parts[1] = parseFloat('0.' + num_parts[1]).toFixed(2).toString().split(".")[1];
    //         else num_parts[1] = '00';

    //         if(num_parts2[1]) num_parts2[1] = parseFloat('0.' + num_parts2[1]).toFixed(2).toString().split(".")[1];
    //         else num_parts2[1] = '00';

    //         cmp.value = '(' + num_parts.join(".") + '/' + num_parts2.join(".") + ')';
    //         cmp.type = 'STRING';
    //         component.set('v.fields', component.get('v.fields'));
    // },
    // onCustomA_WBPB: function (component, objectInfoField) {
    //     var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Calculated_WB_PB_Amount__c');
    //     cmp.label = objectInfoField['RTL_Calculated_WB_PB_Amount__c'].label;
    //     cmp.value = '(';
    //     cmp.value += objectInfoField['RTL_PB_Customer__c'].value ? objectInfoField['RTL_PB_Customer__c'].value : '-';
    //     cmp.value += '/';
    //     cmp.value += objectInfoField['RTL_WB_Customer__c'].value ? objectInfoField['RTL_WB_Customer__c'].value : '-';
    //     cmp.value += ')';
    //     // cmp.isAccessible = objectInfoField['RTL_WA_Name__c'] ? true : false;
    //     cmp.type = 'DOUBLE';
    //     component.set('v.fields', component.get('v.fields'));
    // },

    // Kuong
    // onCustomWA: function (component, objectInfoField) {
    //     var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_WA_Name__c');
    //     cmp.label = objectInfoField['RTL_WA_Name__c'].label;
    //     cmp.value = (objectInfoField['RTL_WA_Name__c'].value ? objectInfoField['RTL_WA_Name__c'].value + (objectInfoField['RTL_WA_Emp_ID__c'].value ? ' (' + objectInfoField['RTL_WA_Emp_ID__c'].value + ')' : '') : '');
    //     // cmp.isAccessible = objectInfoField['RTL_WA_Name__c'] ? true : false;
    //     cmp.type = 'STRING';
    //     component.set('v.fields', component.get('v.fields'));
    // },
    onCustomWRM: function (component, objectInfoField) {
        var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Wealth_RM__c');
        cmp.value_addon = objectInfoField['RTL_Check_WM_RM_as_PWA__c'].value != 'Undefined' ? objectInfoField['RTL_Check_WM_RM_as_PWA__c'].value + ' ' : '';
        cmp.value_addon += objectInfoField['Wealth_RM_EMP_Code__c'].value != 'Undefined' ? objectInfoField['Wealth_RM_EMP_Code__c'].value : '';
        cmp.value = objectInfoField['RTL_Wealth_RM__c'].value;
        cmp.type = 'REFERENCE_ADDON';
        component.set('v.fields', component.get('v.fields'));
    },
    onCustomCRM: function (component, objectInfoField) {
        var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Commercial_RM__c');
        cmp.value_addon = objectInfoField['RTL_Commercial_RM_Emp_ID__c'].value;
        cmp.value = objectInfoField['RTL_Commercial_RM__c'].value;
        cmp.type = 'REFERENCE_ADDON';
        component.set('v.fields', component.get('v.fields'));
    },
    getCVSAnalyticsData: function (component, event, helper) {
        var numberOfRetry = component.get('v.numberOfRetry');
        var round = component.get('v.round');
        var retrySetTimeOut = component.get('v.retrySetTimeOut');
        var action = component.get('c.getCVSAnalyticsData');
        // console.log('action : ',action);
        // console.log('account value : ',component.get('v.account.TMB_Customer_ID_PE__c').value);
        action.setParams({
            "rmId": component.get('v.account.TMB_Customer_ID_PE__c').value
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // console.log('state : ',state);
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // console.log('result here >>' , result);
                if (result && result.Status == 'SUCCESS') {
                    // console.log('csProfSubsegment : ',result.csProfSubsegment);
                    // console.log('component ::: ',component.get('v.fields').find(cmp => cmp.fieldName == 'Customer_Type__c'))
                    component.get('v.fields').find(cmp => cmp.fieldName == 'Customer_Type__c').value += (result.csProfSubsegment ? ' (' + result.csProfSubsegment + ')' : '');
                    component.set('v.fields', component.get('v.fields'));
                    helper.stopSpinner(component);

                }else if(result.StatusCode == '401' && round < numberOfRetry ){
                    round += 1;
                    component.set('v.round', round);
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.getCVSAnalyticsData(component,event,helper);
                        }), retrySetTimeOut
                    );
                }else{
                    helper.stopSpinner(component);
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        if (component.get('v.account.TMB_Customer_ID_PE__c').value){
            $A.enqueueAction(action);
        }else{
            helper.stopSpinner(component);
        }
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