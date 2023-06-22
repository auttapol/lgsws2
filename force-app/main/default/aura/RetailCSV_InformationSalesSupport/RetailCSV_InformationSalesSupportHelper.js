({
    // loop ไมวะ เอา 3 field มาเช็ค security matrix ของแต่ละอัน
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
        helper.getInstantLendingDetail(component, event, helper);

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
                //เขียน function เพื่อเรียก เฉพาะ section ของ 3 field นี้
                component.set('v.dataFields', objectInfoField);
                helper.getVerifyAPIFeild(component, event, helper, 'regisStateTable', objectInfoField);
                helper.getVerifyAPIFeild(component, event, helper, 'CYC_Campaign_PromoCond_api', objectInfoField);
                helper.getVerifyAPIFeild(component, event, helper, 'e_statement', objectInfoField);

                component.set('v.EStatement.data', [{
                    'Consolidate': component.get('v.dataFields.Consolidate_Status__c.value') == 'Y',
                    'CreditCard': component.get('v.dataFields.RTL_CC_STMT_status__c.value') == 'Y',
                    'RDC': component.get('v.dataFields.RTL_RDC_STMT_status__c.value') == 'Y',
                    'C2G': component.get('v.dataFields.RTL_C2G_STMT_status__c.value') == 'Y',
                }]);
                // Call CycCampaignMapingInq 
                helper.get4ThanaInformation(component, objectInfoField);
                helper.getOnSiteService(component, objectInfoField);
            }
            else if(state === 'ERROR') {
                console.log('getVerifyByField ERROR');
            } else {
                console.log('Unknown problem, state.');
            }
            this.stopRetrySpinner(component,event,helper);
        });
        $A.enqueueAction(action);
    },

    getInstantLendingDetail: function (component, event, helper) {
        var action = component.get('c.getInstantLendingDetail');
        action.setParams({
            "accId": component.get('v.recordId'),
        });
        // action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var lendingDetail = response.getReturnValue();
                //console.log('lendingDetail : '+lendingDetail);
                component.set('v.instantLendingDetail',lendingDetail);
            }
            else if(state === 'ERROR') {
                console.log('getInstantLendingDetail ERROR');
            } else {
                console.log('Unknown problem, state.');
            }
            // this.stopRetrySpinner(component,event,helper);
        });
        $A.enqueueAction(action);
    },

    getVerifyAPIFeild: function (component, event, helper, field, objectInfoField){
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
                if(field == 'regisStateTable'){
                    component.set(`v.dataFields.regisStateTable.isAccessible`, result);
                    if( result == true){
                        helper.getCVSAnalyticsData(component, event, helper);
                    }
                    else{
                        component.set("v.isCallAnalyticsFinish","true");
                    }
                }
                else if(field == 'CYC_Campaign_PromoCond_api'){
                    component.set(`v.dataFields.CYC_Campaign_PromoCond_api.isAccessible`, result);
                    if( result == true ){
                        helper.CallCYCCampaignMapingInq(component,event,helper,objectInfoField);
                    }
                    else{
                        component.set("v.isCallCYCFinish","true");
                    }
                }
                else if(field == 'e_statement'){
                    component.set(`v.dataFields.e_statement.isAccessible`, result);
                }
            }
            else if(state === 'ERROR') {
                console.log('getVerifyByField ERROR');
            } else {
                console.log('Unknown problem, state.');
            }
            this.stopRetrySpinner(component,event,helper);
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
                console.log('getProfileName ERROR');
            } else {
                console.log('Unknown problem, state.');
            }
        });
        $A.enqueueAction(action);
    },

    getCVSAnalyticsData: function (component, event, helper) {
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        var action = component.get('c.getCVSAnalyticsData');
        action.setParams({
            'rmId': component.get('v.dataFields.TMB_Customer_ID_PE__c.value')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.StatusCode == '401'){
                    this.retryGetCVSAnalyticsData(component, event, helper, numOfRetryTime);
                }
                if (result && result.Status == 'SUCCESS') {
                    component.set('v.dataFields.RTL_Entitled_Privilege2__c.value', result.entitledPrivilege2Desc ? result.entitledPrivilege2Desc.split('|').filter(f => f).join('<br />') : '');
                    component.set('v.dataFields.RTL_Privilege2__c.value', result.currentPrivilege2Desc ? (result.currentPrivilege2Desc.includes('|') ? result.currentPrivilege2Desc.split('|').filter(f => f).join('<br />') : result.currentPrivilege2Desc) : '');
                    component.set('v.TouchIBProm.data', [{
                        'TMBTouch': result.touchStatus ? result.touchStatus == 'YES' : false,
                        'InternetBanking': result.ibStatus ? result.ibStatus == 'YES' : false,
                        'PromptPay': result.promptPay ? result.promptPay == 'YES' : false,
                    }]);
                    component.set("v.isCallAnalyticsFinish","true");
                }
                else{
                    component.set("v.isCallAnalyticsFinish","true");
                }
            } else {
                component.set("v.isCallAnalyticsFinish","true");
            }
            this.stopRetrySpinner(component,event,helper);
        });
        if (component.get('v.dataFields.TMB_Customer_ID_PE__c.value'))
            $A.enqueueAction(action);
    },
    retryGetCVSAnalyticsData: function (component, event, helper, numOfRetryTime) {
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        numOfRetryTime -= 1;
        setTimeout(()=>{
            var action = component.get('c.getCVSAnalyticsData');
            action.setParams({
                'rmId': component.get('v.dataFields.TMB_Customer_ID_PE__c.value')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if(result.StatusCode == '401' && numOfRetryTime>0){
                        this.retryGetCVSAnalyticsData(component, event, helper, numOfRetryTime);
                    }
                    else if(result.StatusCode == '401' && numOfRetryTime == 0){
                        component.set("v.isCallAnalyticsFinish","true");
                    }
                    else if (result && result.Status == 'SUCCESS') {
                        component.set('v.dataFields.RTL_Entitled_Privilege2__c.value', result.entitledPrivilege2Desc ? result.entitledPrivilege2Desc.split('|').filter(f => f).join('<br />') : '');
                        component.set('v.dataFields.RTL_Privilege2__c.value', result.currentPrivilege2Desc ? (result.currentPrivilege2Desc.includes('|') ? result.currentPrivilege2Desc.split('|').filter(f => f).join('<br />') : result.currentPrivilege2Desc) : '');
                        component.set('v.TouchIBProm.data', [{
                            'TMBTouch': result.touchStatus ? result.touchStatus == 'YES' : false,
                            'InternetBanking': result.ibStatus ? result.ibStatus == 'YES' : false,
                            'PromptPay': result.promptPay ? result.promptPay == 'YES' : false,
                        }]);
                        component.set("v.isCallAnalyticsFinish","true");
                    }
                    else{
                        component.set("v.isCallAnalyticsFinish","true");
                    }
                } else {
                    component.set("v.isCallAnalyticsFinish","true");
                }
                this.stopRetrySpinner(component,event,helper);
            });
            if (component.get('v.dataFields.TMB_Customer_ID_PE__c.value')){
                $A.enqueueAction(action);
            }
        }, retrySetTimeOut);
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
        else{
            cmp.value = '***********';
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
        else{
            cmp.value = '***********';
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
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            }
            else if(state === 'ERROR') {
                console.log('STATE ERROR');
            } else {
                console.log('Unknown problem, state.');
            }
		});
		$A.enqueueAction(action);
	},
    CallCYCCampaignMapingInq : function(component,event,helper,ObjectField){
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        var recordId = component.get('v.recordId');
        var tmbCustomer_id = ObjectField.TMB_Customer_ID_PE__c.value;
        var accountSegment = ObjectField.Core_Banking_Suggested_Segment__c.value;
        var action = component.get('c.CallCYCCampaignMappingInqAPI');
        //var bodyParam = '{"rmid":"'+ObjectField+'"}';
        var bodyParam = '{"rmid":"'+tmbCustomer_id+'"}';
        var servieLogObject = '{"customerName":"'+ObjectField.Name.value+'","rmId":"'+tmbCustomer_id+'","accId":"'+recordId+'","accSegment":"'+accountSegment+'"}';
        var response_status = JSON.parse('{"code":"XXXX","description":"-","cyc_status":"XXXX"}');
        var response_value = JSON.parse('{"customer_id":"'+tmbCustomer_id+'","promotion_condition":""}');
        
        action.setParams({
            "NameCredentail" : "CYC_CAMPAIGN_MAPPING_INQ",
            "headerParam" : "",
            "bodyParam" :  bodyParam,
            "OnlineServiceLog" : servieLogObject
        });
        action.setCallback(this, function(response){
            var statusCodeSuccess = ["0000","4001"];
            var state = response.getState();
            var returnValue = response.getReturnValue();
            var max_committee_price = 0.00;
            var tmp_committee_price = 0.00;
            var campaign_date_str = "";
            var current_date = new Date();
            var campaign_date;
            var date_ofmaxcomittee_price = new Date(9999,11,31); // set Max date
            var strInitialDate = "01011970";
            var checkNewLine = /\^/g;
            response_status = (returnValue!=undefined && returnValue.status!=undefined)? returnValue.status :  response_status;
            if( component.isValid() && state == "SUCCESS" && returnValue != null){
                if(returnValue.description == 'Unauthorized'){
                    response_status.cyc_status = "SUCCESS";
                    this.retryCallCYCCampaignMapingInq(component, event, helper, ObjectField, 1);
                }
                else if( returnValue != undefined && returnValue.status != undefined && returnValue.status.code != undefined && statusCodeSuccess.indexOf(returnValue.status.code) >=0){
                    response_status.cyc_status = "SUCCESS";
                    component.set("v.isCallCYCFinish","true");
                    if( returnValue.cyc_campaign_mapping_list != undefined){
                        returnValue.cyc_campaign_mapping_list.forEach((element,index,array)=>{
                            tmp_committee_price = element.committee_price == undefined && isNaN( element.committee_price )? 0 : parseFloat(element.committee_price);
                            campaign_date_str = element.campaign_expiry_date == undefined && element.campaign_date.length != 8 ? strInitialDate : element.campaign_expiry_date;
                            campaign_date = new Date(parseInt(campaign_date_str.substr(4,4)),parseInt(campaign_date_str.substr(2,2))-1,parseInt(campaign_date_str.substr(0,2)));
                            current_date.setHours(0,0,0,0);   // Set time equal for same type comparison
                            campaign_date.setHours(0,0,0,0);  // Set time equal for same type comparison
                            if( element.customer_id == tmbCustomer_id ){  // Check TMB Customer Id
                                if( max_committee_price <= tmp_committee_price  && current_date <= campaign_date ){   // Check Commitee Price and Campaign Date 
                                    
                                    if( max_committee_price < tmp_committee_price){
                                        max_committee_price = tmp_committee_price;
                                        date_ofmaxcomittee_price = campaign_date;
                                        // Change Character ^ to newline
                                        element.promotion_condition = element.promotion_condition!=undefined?element.promotion_condition.replace(checkNewLine,"<br/>"):"";                                     
                                        response_value = element;    
                                    }else if( max_committee_price == tmp_committee_price){
                                        if( date_ofmaxcomittee_price >= campaign_date){
                                            max_committee_price = tmp_committee_price;
                                            date_ofmaxcomittee_price = campaign_date;
                                            // Change Character ^ to newline
                                            element.promotion_condition = element.promotion_condition!=undefined?element.promotion_condition.replace(checkNewLine,"<br/>"):"";                                     
                                            response_value = element;                                              
                                        }// else campaign_date > current max not update

                                    } // else max_commitee_price > tmp_committee_price ( using old data )

                                }
                            }
                        });
                    }
                }else{ // Error from API
                    response_status.cyc_status == "API_EXECPTION";
                    component.set("v.isCallCYCFinish","true");
                    // else there are other status code return response_status will send originally to component
                }
            }else{
                response_status.code = "ERROR";
                response_status.cyc_status = "ERROR";
                var err = response.getError();
                response_status.description = err && err[0] && err[0].message && err[0].exceptionType ? err[0].exceptionType + " : "+err[0].message : "Unknown error occur";
                component.set("v.isCallCYCFinish","true");
            }
            component.set("v.CYCCampaignMappingInqStatus",response_status);
            component.set("v.CYCCampaignMappingInq",response_value);
            this.stopRetrySpinner(component,event,helper);
        });
        $A.enqueueAction(action);
    },

    retryCallCYCCampaignMapingInq : function(component,event,helper,ObjectField,round){
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        setTimeout(()=>{
    
            var recordId = component.get('v.recordId');
            var tmbCustomer_id = ObjectField.TMB_Customer_ID_PE__c.value;
            var accountSegment = ObjectField.Core_Banking_Suggested_Segment__c.value;
            var action = component.get('c.CallCYCCampaignMappingInqAPI');
            //var bodyParam = '{"rmid":"'+ObjectField+'"}';
            var bodyParam = '{"rmid":"'+tmbCustomer_id+'"}';
            var servieLogObject = '{"customerName":"'+ObjectField.Name.value+'","rmId":"'+tmbCustomer_id+'","accId":"'+recordId+'","accSegment":"'+accountSegment+'"}';
            var response_status = JSON.parse('{"code":"XXXX","description":"-","cyc_status":"XXXX"}');
            var response_value = JSON.parse('{"customer_id":"'+tmbCustomer_id+'","promotion_condition":""}');
            
            action.setParams({
                "NameCredentail" : "CYC_CAMPAIGN_MAPPING_INQ",
                "headerParam" : "",
                "bodyParam" :  bodyParam,
                "OnlineServiceLog" : servieLogObject
            });
            action.setCallback(this, function(response){
                var statusCodeSuccess = ["0000","4001"];
                var state = response.getState();
                var returnValue = response.getReturnValue();
                var max_committee_price = 0.00;
                var tmp_committee_price = 0.00;
                var campaign_date_str = "";
                var current_date = new Date();
                var campaign_date;
                var date_ofmaxcomittee_price = new Date(9999,11,31); // set Max date
                var strInitialDate = "01011970";
                var checkNewLine = /\^/g;
    
                response_status = (returnValue!=undefined && returnValue.status!=undefined)? returnValue.status :  response_status;
                if( component.isValid() && state == "SUCCESS" && returnValue != null){
                    if(returnValue.description == 'Unauthorized'){
                        if(round < numOfRetryTime){
                            response_value.promotion_condition = "Retry round : " + round;
                            response_status.cyc_status = "SUCCESS";
                            this.retryCallCYCCampaignMapingInq(component, event, helper, ObjectField, round+1);
                        }
                        else{
                            response_status.cyc_status = "ERROR";
                            component.set("v.isCallCYCFinish","true");
                        }
                    }
                    else if( returnValue != undefined && returnValue.status != undefined && returnValue.status.code != undefined && statusCodeSuccess.indexOf(returnValue.status.code) >=0 ){
                        response_status.cyc_status = "SUCCESS";
                        component.set("v.isCallCYCFinish","true");
                        if( returnValue.cyc_campaign_mapping_list != undefined){
                            returnValue.cyc_campaign_mapping_list.forEach((element,index,array)=>{
                                tmp_committee_price = element.committee_price == undefined && isNaN( element.committee_price )? 0 : parseFloat(element.committee_price);
                                campaign_date_str = element.campaign_expiry_date == undefined && element.campaign_date.length != 8 ? strInitialDate : element.campaign_expiry_date;
                                campaign_date = new Date(parseInt(campaign_date_str.substr(4,4)),parseInt(campaign_date_str.substr(2,2))-1,parseInt(campaign_date_str.substr(0,2)));
                                current_date.setHours(0,0,0,0);   // Set time equal for same type comparison
                                campaign_date.setHours(0,0,0,0);  // Set time equal for same type comparison
                                if( element.customer_id == tmbCustomer_id ){  // Check TMB Customer Id
                                    if( max_committee_price <= tmp_committee_price  && current_date <= campaign_date ){   // Check Commitee Price and Campaign Date 
                                        
                                        if( max_committee_price < tmp_committee_price){
                                            max_committee_price = tmp_committee_price;
                                            date_ofmaxcomittee_price = campaign_date;
                                            // Change Character ^ to newline
                                            element.promotion_condition = element.promotion_condition!=undefined?element.promotion_condition.replace(checkNewLine,"<br/>"):"";                                     
                                            response_value = element;    
                                        }else if( max_committee_price == tmp_committee_price){
                                            if( date_ofmaxcomittee_price >= campaign_date){
                                                max_committee_price = tmp_committee_price;
                                                date_ofmaxcomittee_price = campaign_date;
                                                // Change Character ^ to newline
                                                element.promotion_condition = element.promotion_condition!=undefined?element.promotion_condition.replace(checkNewLine,"<br/>"):"";                                     
                                                response_value = element;                                              
                                            }// else campaign_date > current max not update
    
                                        } // else max_commitee_price > tmp_committee_price ( using old data )
    
                                    }
                                }
                            });
                        }
                    }else{ // Error from API
                        response_status.cyc_status == "API_EXECPTION";
                        component.set("v.isCallCYCFinish","true");
                        // else there are other status code return response_status will send originally to component
                    }
                }else{
                    response_status.code = "ERROR";
                    response_status.cyc_status = "ERROR";
                    var err = response.getError();
                    response_status.description = err && err[0] && err[0].message && err[0].exceptionType ? err[0].exceptionType + " : "+err[0].message : "Unknown error occur";
                    component.set("v.isCallCYCFinish","true");
                }
                component.set("v.CYCCampaignMappingInqStatus",response_status);
                component.set("v.CYCCampaignMappingInq",response_value);
                this.stopRetrySpinner(component,event,helper);
            });
            $A.enqueueAction(action);
        }, retrySetTimeOut);
    },

    stopRetrySpinner : function(component,event,helper){
        var cycflag = component.get('v.isCallCYCFinish');
        var analysisflag = component.get('v.isCallAnalyticsFinish');

        if(cycflag == "true" && analysisflag == "true"){
            helper.stopSpinner(component);
        }
    }


})