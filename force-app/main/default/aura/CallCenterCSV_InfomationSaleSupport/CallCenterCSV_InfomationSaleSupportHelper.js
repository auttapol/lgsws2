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
        // Special replace field
        helper.onMessengerCoverArea(component, event, helper);
        helper.onEStatement(component, objectInfoField);
        // helper.onOccupationDesc(component, objectInfoField);
        helper.on4ThanaInfo(component);
        helper.onOnSiteService(component);
        // [2020-09-30]
        helper.onMainBank(component);

        // Call service OSC07
        helper.getCVSAnalyticsData(component, event, helper,0);

    },
    
    getDescribeFieldResults: function (component, event, helper) {
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.allField').reduce((l, i) => {
                if (i.fieldName && !l.some(f => f.trim() == i.fieldName))
                    l.push(i.fieldName);
                return l;
            },[])
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                //Set occupation desc
                component.set('v.occupationDetail',objectInfoField['RTL_Occupation_Details__r.RTL_Occupation_Desc__c'].value);
                
                //Set Risk level color
                if(objectInfoField.RTL_Risk_Level_Details__c.value == 'AC – ลูกค้าปกติ' || objectInfoField.RTL_Risk_Level_Details__c.value == 'A2 – ลูกค้าเสี่ยงระดับ 2'){
                    objectInfoField.RTL_Risk_Level_Details__c.class = 'greenColor';
                }else{
                    objectInfoField.RTL_Risk_Level_Details__c.class = 'redColor';
                }

                component.set('v.dataField', objectInfoField);
                
                helper.runCallback(component, event, helper, objectInfoField);
                
                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    getInstantLendingDetail: function (component, event, helper) {
        var action = component.get('c.getInstantLendingDetail');
        action.setParams({
            "accId": component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var lendingDetail = response.getReturnValue();
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

    onEStatement: function (component, objectInfoField) {
        component.set('v.eStatement.data', [{
            'Consolidate': objectInfoField.Consolidate_Status__c.isAccessible ? objectInfoField.Consolidate_Status__c.value == 'Y' : false,
            'CreditCard': objectInfoField.RTL_CC_STMT_status__c.isAccessible ? objectInfoField.RTL_CC_STMT_status__c.value == 'Y' : false,
            'RDC': objectInfoField.RTL_RDC_STMT_status__c.isAccessible ? objectInfoField.RTL_RDC_STMT_status__c.value == 'Y' : false,
            'C2G': objectInfoField.RTL_C2G_STMT_status__c.isAccessible ? objectInfoField.RTL_C2G_STMT_status__c.value == 'Y' : false,
        }]);
    },

    on4ThanaInfo: function (component) {
        var objectInfoField = component.get('v.dataField');
        var RTL_4THANA_Fund_AMT__c = objectInfoField['RTL_4THANA_Fund_AMT__c'].value ? objectInfoField['RTL_4THANA_Fund_AMT__c'].value : '0';
        var RTL_4THANA_Aggregate_Bond_AMT__c = objectInfoField['RTL_4THANA_Aggregate_Bond_AMT__c'].value ? objectInfoField['RTL_4THANA_Aggregate_Bond_AMT__c'].value : '0';
        var RTL_4THANA_Bond_AMT__c = objectInfoField['RTL_4THANA_Bond_AMT__c'].value ? objectInfoField['RTL_4THANA_Bond_AMT__c'].value : '0';
        var RTL_4THANA_Short_Bond_AMT__c = objectInfoField['RTL_4THANA_Short_Bond_AMT__c'].value ? objectInfoField['RTL_4THANA_Short_Bond_AMT__c'].value : '0';
        var RTL_4THANA_Total_AMT__c = objectInfoField['RTL_4THANA_Total_AMT__c'].value ? objectInfoField['RTL_4THANA_Total_AMT__c'].value : '0';
        objectInfoField.RTL_4THANA_Info__c.value = '- ' + objectInfoField['RTL_4THANA_Fund_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Fund_AMT__c) + ' บาท'
                    + '<br/>- ' + objectInfoField['RTL_4THANA_Aggregate_Bond_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Aggregate_Bond_AMT__c) + ' บาท'
                    + '<br/>- ' + objectInfoField['RTL_4THANA_Bond_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Bond_AMT__c) + ' บาท'
                    + '<br/>- ' + objectInfoField['RTL_4THANA_Short_Bond_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Short_Bond_AMT__c) + ' บาท'
                    + '<br/>- ' + objectInfoField['RTL_4THANA_Total_AMT__c'].label + ' ' + this.numberWithCommas(RTL_4THANA_Total_AMT__c) + ' บาท';

        component.set('v.dataField', objectInfoField);
    },

    onOnSiteService: function (component) {
        var objectInfoField = component.get('v.dataField');

        var RTL_OnSite_Service__c = objectInfoField['RTL_OnSite_Service__c'].value ? objectInfoField['RTL_OnSite_Service__c'].value : '';
        var RTL_OnSite_Service_User_Update__c = objectInfoField['RTL_OnSite_Service_User_Update__c'].value ? objectInfoField['RTL_OnSite_Service_User_Update__c'].value : '';
        var RTL_OnSite_Service_Update_Date__c = objectInfoField['RTL_OnSite_Service_Update_Date__c'].value ? objectInfoField['RTL_OnSite_Service_Update_Date__c'].value : '';
        if (RTL_OnSite_Service_Update_Date__c != ''){
            RTL_OnSite_Service_Update_Date__c = $A.localizationService.formatDateTime((objectInfoField['RTL_OnSite_Service_Update_Date__c'].value),'dd/MM/yyyy');
            RTL_OnSite_Service_Update_Date__c = ' [' + RTL_OnSite_Service_Update_Date__c + ']';
        }
        if (RTL_OnSite_Service_User_Update__c != ''){
            RTL_OnSite_Service_User_Update__c = ' [' + RTL_OnSite_Service_User_Update__c + ']';
        }
        objectInfoField.RTL_OnSite_Service__c.value = RTL_OnSite_Service__c + RTL_OnSite_Service_Update_Date__c + RTL_OnSite_Service_User_Update__c;
        
        component.set('v.dataField', objectInfoField);
    },

    onMainBank: function (component) {
        var objectInfoField = component.get('v.dataField');
        
        var RTL_Primary_Banking_All_Free_Benefit__c = objectInfoField['RTL_Primary_Banking_All_Free_Benefit__c'].value ? 'Yes' : 'No';
        var RTL_Main_Bank_Desc__c = objectInfoField['RTL_Main_Bank_Desc__c'].value ? objectInfoField['RTL_Main_Bank_Desc__c'].value : '';
        if (RTL_Main_Bank_Desc__c != ''){
            RTL_Primary_Banking_All_Free_Benefit__c = RTL_Primary_Banking_All_Free_Benefit__c + ' [' + RTL_Main_Bank_Desc__c + ']';
        }
        objectInfoField.RTL_Primary_Banking_All_Free_Benefit__c.value = RTL_Primary_Banking_All_Free_Benefit__c;
        objectInfoField.RTL_Primary_Banking_All_Free_Benefit__c.type = 'STRING';
        
        component.set('v.dataField', objectInfoField);
    },

    onMessengerCoverArea: function (component, event, helper) {
        var action = component.get('c.getMessengerCoverArea');
        action.setParams({
            "accId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.messageAreaValue',result);
                component.set('v.messageAreaClass',result == 'Cover' ? 'greenColor' : 'redColor');
                // component.set('v.fields.Layout1', component.get('v.fields.Layout1'));
            } else {
                console.error(response);
            }
        });
        $A.enqueueAction(action);
    },
    getCVSAnalyticsData: function (component, event, helper,round) {
        var numberOfRetry = component.get('v.numberOfRetry');
        var retrySetTimeOut = component.get('v.retrySetTimeOut');
        var action = component.get('c.getCVSAnalyticsData');
        action.setParams({
            'rmId': component.get('v.account.TMB_Customer_ID_PE__c').value
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result && result.Status == 'SUCCESS') {
                    helper.generateCVSAnalyticsData(component, result);
                    component.set('v.is07Success',true);
                    helper.checkIsRender(component,helper);
                }else if(result.StatusCode == '401' && round < numberOfRetry ){
                    round += 1;
                    // component.set('v.round', round);
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.getCVSAnalyticsData(component,event,helper, round);
                        }), retrySetTimeOut
                    );
                }else{
                    component.set('v.is07Success',true);
                    helper.checkIsRender(component,helper);
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        if (component.get('v.account.TMB_Customer_ID_PE__c').value){
            $A.enqueueAction(action);
        }else{
            component.set('v.is07Success',true);
            helper.checkIsRender(component,helper);
        }
    },
    generateCVSAnalyticsData: function (component, result) {
        if (result) {
            var dataFieldValue = component.get('v.dataField');
            dataFieldValue.RTL_Most_Visited_Branch__c.value = result.csProfFreqBr ? result.csProfFreqBr : '';
            dataFieldValue.RTL_Suitability__c.value = result.suitability ? result.suitability : '';
            dataFieldValue.RTL_Entitled_Privilege2__c.value = result.entitledPrivilege2Desc ? result.entitledPrivilege2Desc.split('|').filter(f => f).join('<br />') : '';
            dataFieldValue.RTL_Privilege2__c.value = result.currentPrivilege2Desc ? result.currentPrivilege2Desc : '';

            component.set('v.dataField',dataFieldValue);
            // var theader = '<thead><tr>' + $A.get('$Label.c.OTC_ATM_ADM_IB_MIB').split(':').reduce((l, i) => {
            //     l += '<th style="text-align: center;">' + i + '</th>';
            //     return l;
            // }, '') + '</tr></thead>';
            // var tbody = '<tbody><tr>' + result.UsagePercentage.split(':').reduce((l, i) => {
            //     l += '<td style="text-align: center;">' + i + '</td>';
            //     return l;
            // }, '') + '</th></tbody>';
            // var table = '<table class="slds-table">' + theader + tbody + '</table>';
            // component.get('v.fields.Layout1').find(opt => opt.fieldName == 'RTL_OTC_ATM_ADM_IB_MIB__c').value = table;

            // component.set('v.fields', component.get('v.fields'));
            component.set('v.payStatus.data', [{
                'TMBTouch': result.touchStatus ? result.touchStatus == 'YES' : false,
                'InternetBanking': result.ibStatus ? result.ibStatus == 'YES' : false,
                'PromptPay': result.promptPay ? result.promptPay == 'YES' : false,
            }]);
        }
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
            } else if(state === 'ERROR') {
                console.log('STATE ERROR');
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
		});
		$A.enqueueAction(action);
	},
    CYCPrepareDataCustomer : function(component, event, helper){
        // Set Loading Status for display
        var response_status = JSON.parse('{"code":"LOAD","description":"Loading","cyc_status":"LOAD"}');
        component.set("v.CYCCampaignMappingInqStatus",response_status);

        var fields = ["TMB_Customer_ID_PE__c","Name","Core_Banking_Suggested_Segment__c"];
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": fields
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var ObjectField = response.getReturnValue();
                helper.CallCYCCampaignMapingInq(component,event,helper,ObjectField,0);
            } else {
                response_status.code = "ERROR";
                var err = response.getError();
                response_status.description = err && err[0] && err[0].message && err[0].exceptionType ? err[0].exceptionType + " : "+err[0].message : "Unknown error occur";
                component.set("v.CYCCampaignMappingInqStatus",response_status);
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    CallCYCCampaignMapingInq : function(component,event,helper,ObjectField,round){
        var numOfRetryTime = component.get('v.numberOfRetry');
        var retrySetTimeOut = component.get('v.retrySetTimeOut');
        // ObjectField for Test 
        //ObjectField.TMB_Customer_ID_PE__c.value = "001100000000000000000007189785";
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

            //returnValue = JSON.parse('{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"001100000000000000000000674673","marketing_code":"DCCAQ0999F1245319023","campaign_name":"ฟรีประกันโควิด เมื่ออนุมัติภายในก.ค.64","campaign_expiry_date":"30042022","contract_period":"72","car_product_group":"NEW CAR","car_register_no":"","car_year":"2017","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"Navara","car_type":"นั่งสองตอนท้ายบรรทุก","committee_price":"580000.00","normal_price":"580000.00","installment_amount":"10700.00","remaining_installment_month":"46","offer_installment_amount":"15000.00","offer_installment_month":"60","offer_interest_rate":"4.75","promotion_detail":"LINE1 580000.00^LINE2 580000.00^LINE3^^LINE4^LINE5^LINE6^LINE7^LINE8^LINE9^LINE10^LINE11^LINE12^LINE13^","remark":"","promotion_condition":"LINE1 580000.00^LINE2 580000.00^LINE3^^LINE4^LINE5^LINE6^LINE7^LINE8^LINE9^LINE10^LINE11^LINE12^LINE13^","lead_owner":"272","owner_type":"BRANCH"}]}');
            //returnValue = JSON.parse('{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50001.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 1","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 2","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"24082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 3","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"29082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 4","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"}]}');
            //returnValue = JSON.parse('{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50001.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 1^TestLINE^Line^Line^","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 2","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"24082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 3","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"29082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 4","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"}]}');

            response_status = (returnValue!=undefined && returnValue.status!=undefined)? returnValue.status :  response_status;
            if( component.isValid() && state == "SUCCESS"){
                if(returnValue.description == 'Unauthorized' && round < numOfRetryTime){   
                    round += 1;
                    response_value.promotion_condition = 'Error getting data, retrying... ('+round+')';
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.CallCYCCampaignMapingInq(component,event,helper,ObjectField,round);
                        }), retrySetTimeOut
                    );
                }else if( returnValue != undefined && returnValue.status != undefined && returnValue.status.code != undefined && statusCodeSuccess.indexOf(returnValue.status.code) >=0 ){
                    response_status.cyc_status = "SUCCESS";
                    if( returnValue.cyc_campaign_mapping_list != undefined){
                        returnValue.cyc_campaign_mapping_list.forEach((element,index,array)=>{
                            tmp_committee_price = element.committee_price == undefined && isNaN( element.committee_price )? 0 : parseFloat(element.committee_price);
                            campaign_date_str = element.campaign_expiry_date == undefined && element.campaign_date.length != 8 ? strInitialDate : element.campaign_expiry_date;
                            campaign_date = new Date(parseInt(campaign_date_str.substr(4,4)),parseInt(campaign_date_str.substr(2,2))-1,parseInt(campaign_date_str.substr(0,2)));
                            current_date.setHours(0,0,0,0);   // Set time equal for same type comparison
                            campaign_date.setHours(0,0,0,0);  // Set time equal for same type comparison
                            //console.log(campaign_date + " :  price : "+tmp_committee_price+" : current max : "+max_committee_price);
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
                    component.set('v.isCYCSuccess',true);
                    helper.checkIsRender(component,helper);
                }else{ // Error from API
                    response_status.cyc_status == "API_EXECPTION";
                    component.set("v.isCYCSuccess",true);
                    helper.checkIsRender(component,helper);
                    // else there are other status code return response_status will send originally to component
                }
            }else{
                response_status.code = "ERROR";
                response_status.cyc_status = "ERROR";
                var err = response.getError();
                response_status.description = err && err[0] && err[0].message && err[0].exceptionType ? err[0].exceptionType + " : "+err[0].message : "Unknown error occur";
                component.set("v.isCYCSuccess",true);
                helper.checkIsRender(component,helper);
            }
            component.set("v.CYCCampaignMappingInqStatus",response_status);
            component.set("v.CYCCampaignMappingInq",response_value);
        });
        $A.enqueueAction(action);
    },

    checkIsRender: function(component,helper){
        var is07Success = component.get('v.is07Success');
        var isCYCSuccess = component.get('v.isCYCSuccess');
        if(is07Success && isCYCSuccess){
            helper.stopSpinner(component);
        }

    }
})