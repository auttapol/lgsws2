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
                helper.getAPIFieldsSection(component, event, helper, 'regisStateTable', objectInfoField);
                helper.getAPIFieldsSection(component, event, helper, 'CYC_Campaign_PromoCond_api', objectInfoField);
                helper.getAPIFieldsSection(component, event, helper, 'e_statement', objectInfoField);

                component.set('v.dataFields', objectInfoField);
                component.set('v.EStatement.data', [{
                    'Consolidate': component.get('v.dataFields.Consolidate_Status__c.value') == 'Y',
                    'CreditCard': component.get('v.dataFields.RTL_CC_STMT_status__c.value') == 'Y',
                    'RDC': component.get('v.dataFields.RTL_RDC_STMT_status__c.value') == 'Y',
                    'C2G': component.get('v.dataFields.RTL_C2G_STMT_status__c.value') == 'Y',
                }]);
                helper.stopSpinner(component);
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.error(error.message);
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
                else if( field == 'CYC_Campaign_PromoCond_api'){
                    component.set(`v.dataFields.CYC_Campaign_PromoCond_api.isAccessible`, result);
                    if(result == true){
                        helper.CallCYCCampaignMapingInq(component,event,helper,objectInfoField);
                    }
                }
                else if( field == 'e_statement'){
                    component.set(`v.dataFields.e_statement.isAccessible`, result);
                }
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
            } else {
                var errors = response.getError();
                errors.forEach(error => console.error(error.message));
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
            } else {
                var errors = response.getError();
                errors.forEach(error => console.error(error.message));
            }
        });
        if (component.get('v.dataFields.TMB_Customer_ID_PE__c.value'))
            $A.enqueueAction(action);
    },

    numberWithCommas: function (x) {
        var dec = parseFloat(x).toFixed(2);
        var parts = dec.toString().split(".");
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join(".");
    },
   
	
    CallCYCCampaignMapingInq : function(component,event,helper,ObjectField){

        var recordId = component.get('v.recordId');
        var tmbCustomer_id = ObjectField.TMB_Customer_ID_PE__c.value;
        var accountSegment = ObjectField.Core_Banking_Suggested_Segment__c.value;
        var action = component.get('c.CallCYCCampaignMappingInqAPI');
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
            //returnValue = JSON.parse('{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"001100000000000000000007189785","marketing_code":"DCCAQ0999F1245319023","campaign_name":"ฟรีประกันโควิด เมื่ออนุมัติภายในก.ค.64","campaign_expiry_date":"30042021","contract_period":"72","car_product_group":"NEW CAR","car_register_no":"","car_year":"2017","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"Navara","car_type":"นั่งสองตอนท้ายบรรทุก","committee_price":"580000.00","normal_price":"580000.00","installment_amount":"10700.00","remaining_installment_month":"46","offer_installment_amount":"15000.00","offer_installment_month":"60","offer_interest_rate":"4.75","promotion_detail":"TestA 580000.00","remark":"","lead_owner":"272","owner_type":"BRANCH"},{"customer_id":"001100000000000000000007189785","marketing_code":"DCCAQ0999F1243021070","campaign_name":"ฟรีประกันโควิด เมื่ออนุมัติภายในก.ค.64","campaign_expiry_date":"30042021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"","car_year":"2017","car_brand":"MITSUBISHI","car_gear_type":"","car_group":"","car_model":"Triton","car_type":"นั่งสองตอนท้ายบรรทุก","committee_price":"720000.00","normal_price":"","installment_amount":"14481.00","remaining_installment_month":"38","offer_installment_amount":"17388.00","offer_installment_month":"60","offer_interest_rate":"4.75","promotion_detail":"testB 720000.00","remark":"","lead_owner":"272","owner_type":"BRANCH"},{"customer_id":"001100000000000000000007189785","marketing_code":"DCCAQ0999F1243364903","campaign_name":"ฟรีประกันโควิด เมื่ออนุมัติภายในก.ค.64","campaign_expiry_date":"30042021","contract_period":"84","car_product_group":"NEW CAR","car_register_no":"","car_year":"2018","car_brand":"MITSUBISHI","car_gear_type":"MANUAL","car_group":"","car_model":"Triton","car_type":"นั่งสองตอนท้ายบรรทุก","committee_price":"980000.00","normal_price":"580000.00","installment_amount":"15386.00","remaining_installment_month":"10","offer_installment_amount":"56252.00","offer_installment_month":"60","offer_interest_rate":"4.75","promotion_detail":"ฟรีประกันโควิด เมื่ออนุมัติภายในก.ค.64","promotion_condition":"testC 980000.00","remark":"","lead_owner":"272","owner_type":"BRANCH"},{"customer_id":"001100000000000000000007189785","marketing_code":"DCCAQ0999F1242995461","campaign_name":"ฟรีประกันโควิด เมื่ออนุมัติภายในก.ค.64","campaign_expiry_date":"30042021","contract_period":"84","car_product_group":"NEW CAR","car_register_no":"1ทส 0007","car_year":"2019","car_brand":"TOYOTA","car_gear_type":"AUTO","car_group":"Hilux Revo","car_model":"Hilux Revo","car_type":"บรรทุกส่วนบุคคล (รย 3)","committee_price":"720000.00","normal_price":"720000.00","installment_amount":"16050.00","remaining_installment_month":"30","offer_installment_amount":"7240.00","offer_installment_month":"60","offer_interest_rate":"4.75","promotion_detail":"ฟรีประกันโควิด เมื่ออนุมัติภายในก.ค.64","promotion_condition":"testD 720000.00","remark":"","lead_owner":"272","owner_type":"BRANCH"}]}');
            //returnValue = JSON.parse('{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50001.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 1","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 2","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"24082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 3","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"001100000000000000000000674673","marketing_code":"DTDAL210911106214861","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"29082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 4","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"}]}');

            response_status = (returnValue!=undefined && returnValue.status!=undefined)? returnValue.status :  response_status;
            if( component.isValid() && state == "SUCCESS"){
                if( returnValue != undefined && returnValue.status != undefined && returnValue.status.code != undefined && statusCodeSuccess.indexOf(returnValue.status.code) >=0 ){
                    response_status.cyc_status = "SUCCESS";
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
                                            element.promotion_condition = element.promotion_condition!=undefined?element.promotion_condition.replace(checkNewLine,"<br/>"):"";                                     
                                            response_value = element;                                              
                                        }

                                    } 

                                }
                            }
                        });
                    }
                }else{
                    response_status.cyc_status == "API_EXECPTION";
                }
            }else{
                response_status.code = "ERROR";
                response_status.cyc_status = "ERROR";
                var err = response.getError();
                response_status.description = err && err[0] && err[0].message && err[0].exceptionType ? err[0].exceptionType + " : "+err[0].message : "Unknown error occur";
            }
            component.set("v.CYCCampaignMappingInqStatus",response_status);
            component.set("v.CYCCampaignMappingInq",response_value);
        });
        $A.enqueueAction(action);
    }

})