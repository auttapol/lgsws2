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
        helper.onCustomSegment(component, objectInfoField);

        // Call for Segment Coloring
        helper.getSegmentCodition(component,event,helper,objectInfoField);

        helper.onCustomPrivilege1(component, objectInfoField);
        helper.onCustomAUM(component, objectInfoField);
        helper.onCustomSBOFlag(component, objectInfoField);
        // Custom color field
        helper.onDynamicAdjustField(component, objectInfoField);
        helper.onCustomWRM(component, objectInfoField);
        // Call service OSC07
        helper.getCVSAnalyticsData(component, event, helper);  
        helper.retryCalloutGetFagPdpa(component,event, helper, 0);   
        helper.getSubDebtTransaction(component,helper);


    },
    getDescribeFieldResult: function (component, event, helper) {

        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.allField').reduce((l, i) => {
                if (i.fieldName && !l.some(f => f.trim() == i.fieldName))
                    l.push(i.fieldName);
                return l;
            }, [])
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                objectInfoField['RTL_Average_AUM__c'].isAccessible = true;
                component.set('v.dataFields',objectInfoField);
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

    // getDescribeFieldResults: function (component, event, helper) {
        // console.log('allField : '+JSON.stringify(component.get('v.allField')));
        // component.get('v.allField').reduce((l, i) => {
        //     if (i.fieldName && !l.some(f => f.trim() == i.fieldName))
        //         console.log('fieldName : '+i.fieldName);
        //         console.log(l.some(f => f.trim() == i.fieldName));
        //         l.push(i.fieldName);
        //     return l;
        // })
        // console.log('dataField : '+JSON.stringify(component.get('v.dataField')));
        // var action = component.get('c.getDescribeFieldResultAndValue');
        // action.setParams({
        //     "recordId": component.get('v.recordId'),
        //     "fields": component.get('v.allField').reduce((l, i) => {
        //         if (i.fieldName && !l.some(f => f.trim() == i.fieldName))
        //             l.push(i.fieldName);
        //         return l;
        //     })
        // });
        // action.setStorable();
        // action.setCallback(this, function (response) {
        //     var state = response.getState();
        //     if (component.isValid() && state === 'SUCCESS') {
        //         var objectInfoField = response.getReturnValue();
        //         console.log('objectInfoField : '+JSON.stringify(objectInfoField));
        //         component.set('v.dataFields',objectInfoField);
        //         // helper.runCallback(component, event, helper, objectInfoField);
        //         helper.stopSpinner(component);
        //     } else {
        //         var errors = response.getError();
        //         errors.forEach(error => console.log(error.message));
        //         helper.stopSpinner(component);
        //     }
        // });
        // $A.enqueueAction(action);
    // },

    onDynamicAdjustField: function (component, objectInfoField) {
        // var customColorField = component.get('v.customColorField');
        // component.get('v.fields').forEach((optCmp, index) => {
        //     if(optCmp.value){
        //         if(optCmp.fieldName == 'FATCA__c' ){
        //             optCmp.class = objectInfoField[optCmp.fieldName].value == 'ทำ FATCA (complete)' ? 'greenColor' : 'redColor';
        //         }else if(optCmp.fieldName == 'KYC_Update__c'){
        //             if(objectInfoField[optCmp.fieldName].value.includes('ใกล้หมดอายุ')){
        //                 optCmp.class = 'yellowColor';
        //             }else if(objectInfoField[optCmp.fieldName].value == 'กรุณาปรับปรุงข้อมูล'){
        //                 optCmp.class = 'redColor';
        //             }
    
        //         }
        //     }
        // });
        // component.set('v.fields', component.get('v.fields'));

        var cmp =  component.get('v.dataFields');
        cmp.FATCA__c.class = objectInfoField['FATCA__c'].value == 'ทำ FATCA (complete)' ? 'greenColor' : 'redColor';
        if(cmp.KYC_Update__c.value.includes('ใกล้หมดอายุ')){
            cmp.KYC_Update__c.class = 'yellowColor';
        }else if(cmp.KYC_Update__c.value == 'กรุณาปรับปรุงข้อมูล'){
            cmp.KYC_Update__c.class = 'redColor';
        }
        component.set('v.dataFields', cmp);

    }, 

    generateField: function (component, objectInfoField, fieldList) {
        // fieldList.forEach(cmp => {
        //     cmp.type = objectInfoField[cmp.fieldName].type;
        //     cmp.label = objectInfoField[cmp.fieldName].label;
        //     cmp.value = objectInfoField[cmp.fieldName] ? objectInfoField[cmp.fieldName].value : '';
        //     cmp.inlineHelpText = objectInfoField[cmp.fieldName].inlineHelpText ? objectInfoField[cmp.fieldName].inlineHelpText : '';
        //     cmp.isAccessible = typeof cmp.isAccessible === "boolean" ? cmp.isAccessible : (objectInfoField[cmp.fieldName].isAccessible ? objectInfoField[cmp.fieldName].isAccessible : false);
        // });
        // component.set('v.fields', component.get('v.fields'));

        var dataField = component.get('v.dataFields');
        dataField.RTL_Customer_Name_TH__c.class = 'blueColor';
        dataField.RTL_Date_Of_Birth__c.class = 'blueColor';
        dataField.RTL_Zodiac__c.class = 'blueColor';
        dataField.Mobile_Number_PE__c.class = 'blueColor';
        dataField.Email_Address_PE__c.class = 'blueColor';
        dataField.RTL_Wealth_RM__c.class = 'blueColor';

    },
    onCustomSegment: function (component, objectInfoField) {
        // var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'Core_Banking_Suggested_Segment__c');
        // cmp.label = objectInfoField['Core_Banking_Suggested_Segment__c'].label + ' / ' + objectInfoField['Sub_segment__c'].label;
        // cmp.value = objectInfoField['Core_Banking_Suggested_Segment__c'].value ? objectInfoField['Core_Banking_Suggested_Segment__c'].value : '';
        // cmp.isAccessible = objectInfoField['Core_Banking_Suggested_Segment__c'] ? true : false;
        // cmp.type = 'STRING';
        // component.set('v.fields', component.get('v.fields'));

        var cmp = component.get('v.dataFields');
        // .find(cmp => cmp.fieldName == 'Core_Banking_Suggested_Segment__c');
        cmp.Core_Banking_Suggested_Segment__c.label = objectInfoField['Core_Banking_Suggested_Segment__c'].label + ' / ' + objectInfoField['Sub_segment__c'].label;
        cmp.Core_Banking_Suggested_Segment__c.value = objectInfoField['Core_Banking_Suggested_Segment__c'].value ? objectInfoField['Core_Banking_Suggested_Segment__c'].value : '';
        cmp.Core_Banking_Suggested_Segment__c.isAccessible = objectInfoField['Core_Banking_Suggested_Segment__c'] ? true : false;
        cmp.Core_Banking_Suggested_Segment__c.type = 'STRING';
        component.set('v.dataFields',cmp);
    },
    onCustomPrivilege1: function (component, objectInfoField) {
        // var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Privilege1__c');
        // cmp.label = objectInfoField['RTL_Privilege1__c'].label;
        // cmp.value = objectInfoField['RTL_Privilege1__c'].value ? objectInfoField['RTL_Privilege1__c'].value : '-';
        // cmp.inlineHelpText = $A.get('$Label.c.Privilege_Start_End_Date');
        // cmp.isAccessible = objectInfoField['RTL_Privilege1__c'] ? true : false;
        // cmp.type = 'STRING';
        // component.set('v.fields', component.get('v.fields'));

        var cmp = component.get('v.dataFields');
        cmp.RTL_Privilege1__c.label = objectInfoField['RTL_Privilege1__c'].label;
        cmp.RTL_Privilege1__c.value = objectInfoField['RTL_Privilege1__c'].value ? objectInfoField['RTL_Privilege1__c'].value : '-';
        cmp.RTL_Privilege1__c.inlineHelpText = $A.get('$Label.c.Privilege_Start_End_Date');
        cmp.RTL_Privilege1__c.isAccessible = objectInfoField['RTL_Privilege1__c'] ? true : false;
        cmp.RTL_Privilege1__c.type = 'STRING';
        component.set('v.dataFields', cmp);
    },
    onCustomAUM: function (component, objectInfoField) {
        // var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_AUM__c');
        // cmp.label = objectInfoField['RTL_AUM__c'].label + ' (' + objectInfoField['RTL_AUM_Last_Calculated_Date__c'].label + ')';
        // cmp.value = $A.get("$Locale.currency") + (objectInfoField['RTL_AUM__c'].value ? objectInfoField['RTL_AUM__c'].value.toLocaleString('en-US') : '0');
        // cmp.value += objectInfoField['RTL_AUM_Last_Calculated_Date__c'].value ? ' [' + $A.localizationService.formatDate(objectInfoField['RTL_AUM_Last_Calculated_Date__c'].value) + ']' : '';
        // cmp.inlineHelpText = objectInfoField['RTL_AUM_Last_Calculated_Date__c'].inlineHelpText;
        // cmp.isAccessible = objectInfoField['RTL_AUM__c'] ? true : false;
        // cmp.type = 'STRING';
        // component.set('v.fields', component.get('v.fields'));

        var cmp = component.get('v.dataFields');
        cmp.RTL_AUM__c.label = objectInfoField['RTL_AUM__c'].label + ' (' + objectInfoField['RTL_AUM_Last_Calculated_Date__c'].label + ')';
        cmp.RTL_AUM__c.value = $A.get("$Locale.currency") + (objectInfoField['RTL_AUM__c'].value ? objectInfoField['RTL_AUM__c'].value.toLocaleString('en-US') : '0');
        cmp.RTL_AUM__c.value += objectInfoField['RTL_AUM_Last_Calculated_Date__c'].value ? ' [' + $A.localizationService.formatDate(objectInfoField['RTL_AUM_Last_Calculated_Date__c'].value) + ']' : '';
        cmp.RTL_AUM__c.inlineHelpText = objectInfoField['RTL_AUM_Last_Calculated_Date__c'].inlineHelpText;
        cmp.RTL_AUM__c.isAccessible = objectInfoField['RTL_AUM__c'] ? true : false;
        cmp.RTL_AUM__c.type = 'STRING';
        component.set('v.dataFields', cmp);
    },
    onCustomSBOFlag: function (component, objectInfoField) {
        // var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_SBO_FLAG__c');
        // cmp.label = objectInfoField['RTL_SBO_FLAG__c'].label + ' / ';
        // cmp.label += objectInfoField['RTL_EXIST_NONJU_FLAG__c'].label;
        // cmp.value = (objectInfoField['RTL_SBO_FLAG__c'].value ? objectInfoField['RTL_SBO_FLAG__c'].value : '-') + ' / ';
        // cmp.value += (objectInfoField['RTL_EXIST_NONJU_FLAG__c'].value ? objectInfoField['RTL_EXIST_NONJU_FLAG__c'].value : '-');
        // cmp.type = 'STRING';
        // component.set('v.fields', component.get('v.fields'));

        var cmp = component.get('v.dataFields');
        cmp.RTL_SBO_FLAG__c.label = objectInfoField['RTL_SBO_FLAG__c'].label + ' / ';
        cmp.RTL_SBO_FLAG__c.label += objectInfoField['RTL_EXIST_NONJU_FLAG__c'].label;
        cmp.RTL_SBO_FLAG__c.value = (objectInfoField['RTL_SBO_FLAG__c'].value ? objectInfoField['RTL_SBO_FLAG__c'].value : '-') + ' / ';
        cmp.RTL_SBO_FLAG__c.value += (objectInfoField['RTL_EXIST_NONJU_FLAG__c'].value ? objectInfoField['RTL_EXIST_NONJU_FLAG__c'].value : '-');
        cmp.RTL_SBO_FLAG__c.type = 'STRING';
        component.set('v.dataFields', cmp);
    },
    onCustomWRM: function (component, objectInfoField) {
        // var cmp = component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Wealth_RM__c');
        // cmp.value_addon = objectInfoField['RTL_Check_WM_RM_as_PWA__c'].value != 'Undefined' ? objectInfoField['RTL_Check_WM_RM_as_PWA__c'].value + ' ' : '';
        // cmp.value_addon += objectInfoField['Wealth_RM_EMP_Code__c'].value != 'Undefined' ? objectInfoField['Wealth_RM_EMP_Code__c'].value : '';
        // cmp.value = objectInfoField['RTL_Wealth_RM__c'].value;
        // cmp.type = 'REFERENCE_ADDON';
        // component.set('v.fields', component.get('v.fields'));

        var cmp = component.get('v.dataFields');
        cmp.RTL_Wealth_RM__c.value_addon = objectInfoField['RTL_Check_WM_RM_as_PWA__c'].value != 'Undefined' ? objectInfoField['RTL_Check_WM_RM_as_PWA__c'].value + ' ' : '';
        cmp.RTL_Wealth_RM__c.value_addon += objectInfoField['Wealth_RM_EMP_Code__c'].value != 'Undefined' ? objectInfoField['Wealth_RM_EMP_Code__c'].value : '';
        cmp.RTL_Wealth_RM__c.value = objectInfoField['RTL_Wealth_RM__c'].value;
        cmp.RTL_Wealth_RM__c.type = 'REFERENCE_ADDON';
        component.set('v.dataFields', cmp);
    },
    retryCalloutGetFagPdpa: function (component, event, helper, round){
        // console.log('Get PDPA');
		var tmbCustId = component.get('v.account.TMB_Customer_ID_PE__c').value;
		var action = component.get('c.getPdpaDetail');

        // var pdpa = component.get('v.fields').find(cmp => cmp.name == 'PDPA');
        // var marketConduct = component.get('v.fields').find(cmp => cmp.name == 'Market Conduct');

        // marketConduct.isAccessible = true;
        // pdpa.isAccessible = true;

		action.setParams({
			"tmbCustId": tmbCustId,
            "serviceName" : 'PDPA_GET_CONSENT_FAG_CSV_CC_PAGE'
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

				var pdpaMessage = '';
				var marketConductMessage = '';
                
				// console.log('retryCalloutGetFagPdpa pdpa: ',resultObj);
				// console.log('retryCalloutGetFagPdpa round: ',round);
				// console.log('retryCalloutGetFagPdpa number of retry: ',component.get("v.numberOfRetry"));

				if(resultObj.isSuccess == 'true'){
                    if (resultObj.PDPAFag == 'Y') {
                        pdpaMessage = $A.get('$Label.c.PDPA_Accept_YES');
                        // pdpa.class = 'greenBackgroundColor';
                        component.set('v.pdpaClass','greenBackgroundColor');
                    } else if (resultObj.PDPAFag == 'N') {
                        pdpaMessage = $A.get('$Label.c.PDPA_Accept_NO') + '<br/>' + $A.get("$Label.c.PDPA_Flag_No_Message");
                        // pdpa.class = 'redBackgroundColor';
                        component.set('v.pdpaClass','redBackgroundColor');

                    }

                    if (resultObj.MARKETFag == 'Y') {
                        marketConductMessage = $A.get('$Label.c.PDPA_Accept_YES');

                    } else if (resultObj.MARKETFag == 'N') {
                        marketConductMessage = $A.get('$Label.c.PDPA_Accept_NO');

                    }
                    // component.set('v.fields', component.get('v.fields'));
					
				}else if(resultObj.errorMessage == 'invalid_token' && round < component.get("v.numberOfRetry")){
					round++;
                    pdpaMessage = 'Error getting data, retrying... ('+round+')';
                    marketConductMessage = 'Error getting data, retrying... ('+round+')';
					window.setTimeout(
						$A.getCallback(function () {
							helper.retryCalloutGetFagPdpa(component,event, helper, round);
						}), component.get("v.retrySetTimeOut")
					);
				}else{
					pdpaMessage = 'Error getting data';
					marketConductMessage = 'Error getting data';
                    // pdpa.class = 'redErrorFontColor';
                    component.set('v.pdpaClass','redErrorFontColor');
                    // marketConduct.class = 'redErrorFontColor';
                    component.set('v.marketConductValue','redErrorFontColor');
				}
			}else{
				pdpaMessage = 'Error getting data';
				marketConductMessage = 'Error getting data';
                // pdpa.class = 'redErrorFontColor';
                component.set('v.pdpaClass','redErrorFontColor');
                // marketConduct.class = 'redErrorFontColor';
                component.set('v.marketConductValue','redErrorFontColor');
			}
            // pdpa.value = pdpaMessage;
            component.set('v.pdpaValue',pdpaMessage);
            // marketConduct.value = marketConductMessage;
            component.set('v.marketConductValue',marketConductMessage);

            // console.log('pdpa Name : ',pdpa.name);
            // console.log('marketConduct name : ',marketConduct.name);
            // component.set('v.fields', component.get('v.fields'));
		});
		if(tmbCustId)$A.enqueueAction(action);
	},
    getCVSAnalyticsData: function (component, event, helper) {
        var numberOfRetry = component.get('v.numberOfRetry');
        var round = component.get('v.round');
        var retrySetTimeOut = component.get('v.retrySetTimeOut');

        var action = component.get('c.getCVSAnalyticsData');
        action.setParams({
            "rmId": component.get('v.account.TMB_Customer_ID_PE__c').value
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // var touchCmp = component.get('v.fields').find(cmp => cmp.name == 'ttb touch');
                var dataField = component.get('v.dataFields');
                // touchCmp.isAccessible = true;
                if (result && result.Status == 'SUCCESS') {
                    dataField.Core_Banking_Suggested_Segment__c.value +=  (result.csProfSubsegment ? '/ ' + result.csProfSubsegment : '');
                    dataField.RTL_Privilege1__c.value +=  (result.csProfWealthExpDt ? '[' + result.csProfWealthExpDt + ']' : '');
                    dataField.RTL_Average_AUM__c.value =  result.csProfAvgaum12m ? parseFloat(result.csProfAvgaum12m) : 0;

                    // component.get('v.fields').find(cmp => cmp.fieldName == 'Core_Banking_Suggested_Segment__c').value += (result.csProfSubsegment ? '/ ' + result.csProfSubsegment : '');
                    // component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Privilege1__c').value += (result.csProfWealthExpDt ? '[' + result.csProfWealthExpDt + ']' : '');
                    // component.get('v.fields').find(cmp => cmp.fieldName == 'RTL_Average_AUM__c').value = result.csProfAvgaum12m ? parseFloat(result.csProfAvgaum12m) : 0;

                    if(result.touchStatus == 'YES' && result.LastLoginSuccessDate){
                        const date = new Date(result.LastLoginSuccessDate);
                        var date_format = date.toLocaleDateString('th-TH', {
                            year: '2-digit',
                            month: 'short',
                            day: 'numeric',
                        })
                        // touchCmp.value = 'มี (เข้าใช้งานล่าสุด '+ date_format + ')';
                        component.set('v.touchValue','มี (เข้าใช้งานล่าสุด '+ date_format + ')');
                    }else{
                        // touchCmp.value = 'ไม่มี';
                        component.set('v.touchValue','ไม่มี');
                        // touchCmp.class = 'redColor';
                        component.set('v.touchClass','redColor');
                    }
                    component.set('v.dataFields', dataField);
                }else if(result.StatusCode == '401' && round < numberOfRetry ){
                    round += 1;
                    // touchCmp.value = 'Error getting data, retrying... ('+round+')';
                    component.set('v.touchValue','Error getting data, retrying... ('+round+')');
                    component.set('v.round', round);
                    window.setTimeout(
                        $A.getCallback(function() {
                            helper.getCVSAnalyticsData(component,event,helper);
                        }), retrySetTimeOut
                    );
                }else{
                    // touchCmp.value = 'Error getting data';
                    component.set('v.touchValue','Error getting data');
                    // touchCmp.class = 'redErrorFontColor';
                    component.set('v.touchClass','redErrorFontColor');
                }
                component.set('v.dataFields', dataField);

            } else {
                var errors = response.getError();
                console.log('Result errors : ',errors);
                errors.forEach(error => console.log(error.message));
            }
        });
        if (component.get('v.account.TMB_Customer_ID_PE__c').value)
            $A.enqueueAction(action);
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
    getSegmentCodition : function(component,event,helper,objectInfoField){
        //get from custom metadata type
        var action = component.get("c.getSetUpFormat");
        action.setParams({"formatName":"segment_coloring"});
        action.setCallback(this,function(response){
            // console.log('getSetUpFormat: '+JSON.stringify(response.getReturnValue())  );
            var retReult = JSON.parse( response.getReturnValue() );
            // var vField = component.get('v.fields');
            var dataField = component.get('v.dataFields');
            var param2 = objectInfoField.Segment_crm__c != undefined && objectInfoField.Segment_crm__c.value != ""? objectInfoField.Segment_crm__c.value : "";
            var param3 = objectInfoField.RTL_Privilege1__c != undefined && objectInfoField.RTL_Privilege1__c.value != "" ? objectInfoField.RTL_Privilege1__c.value.substr(0,2) :  "";
            var cssClass = '';
            // console.log( 'Param 2 : '+param2 + ', Param 3 : '+param3);
            var state = response.getState();
            // if( state === "SUCESSS"){
            //     // do                
            // }else if(state === "ERROR"){
            //     console.log(" STATE ERROR");
            //     console.log("error : ",response.error);
            // }

            for(var i in retReult.Condition){
                if( retReult.Condition[i].Segment_crm__c == param2 ){
                    if( retReult.Condition[i].RTL_Privilege1__c.length > 0 ){
                        if( retReult.Condition[i].RTL_Privilege1__c.indexOf( param3) >= 0 ){
                            cssClass = retReult.Condition[i].class;
                            break;
                        }
                        // else do notting
                    }else{ // there are not check Privilege1
                         cssClass = retReult.Condition[i].class;
                        break;
                    }
                }
            }
            // console.log( 'cssClass: ', cssClass );

            // vField.forEach(cmp=>{
            //     if(cmp.fieldName === 'Core_Banking_Suggested_Segment__c'){
            //         cmp.class = cssClass;
            //     }
            // });
            // component.set('v.fields', vField);            
            // console.log(vField);

            dataField.Core_Banking_Suggested_Segment__c.class = cssClass;
            component.set('v.dataFields', dataField);            

        });
        $A.enqueueAction(action);
    },

    getSubDebtTransaction : function(component,helper){
        // console.log('getSubDebtTransaction');

        var action = component.get('c.getSubDebtTransaction');
        action.setParams({
            "accId": component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                // var subDeptFlag = component.get('v.fields').find(cmp => cmp.name == 'Sub Debt Flag');
                // subDeptFlag.isAccessible = true;
                // subDeptFlag.value = response.getReturnValue();
                component.set('v.subDebtValue',response.getReturnValue());
                // component.set('v.fields', component.get('v.fields'));
                
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    }
})