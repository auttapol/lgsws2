({
	createfirst: function (component, event, helper) {
		// get the caseList from component and add(push) New Object to List
		var RowItemList = component.get("v.caseList");
		console.log('RowItemList: ',RowItemList);
		var size = RowItemList.length;
		if (RowItemList != undefined){
			if (size < 10){
				RowItemList.push({
					'sobjectType': 'Case',
					'Status':'Completed',
					'PTA_Segment__c':'RBG',
					'Category__c':'Inquiry',
					'Sub_Category__c':'Contact Center',
				});
			}else {
				helper.displayToast(component, 'Error', 'สามารถสร้างเคสได้สูงสุด 10 เคสเท่านั้น');
			}
			
		}
		// set the updated list to attribute (contactList) again   
		component.set("v.caseList", RowItemList);
		// console.log('v.caseList: ',component.get('v.caseList'));
	}, 
	getServiceTypeMatrix : function (component, event , helper){
		// console.log('GET SVTM');
		var action = component.get('c.getServiceTypeMatrix');
		action.setCallback(this, function (response) {
			var state = response.getState();
            console.log('STATE: ',state);
			if (state === 'SUCCESS'){
				var returnValues = response.getReturnValue();
				// console.log('returnValues: ',returnValues);
				component.set('v.CasePTASegment',returnValues.keyPTASegment);
				component.set('v.MapCaseCateLVL_1',returnValues.mapSVTMlvl1);
				component.set('v.MapCaseCateLVL_2',returnValues.mapSVTMlvl2);
				// console.log('v.MapCaseCateLVL_2',returnValues.mapSVTMlvl2);
				// console.log('v.MapCaseCateLVL_3',returnValues.mapSVTMlvl3);
				component.set('v.MapCaseCateLVL_3',returnValues.mapSVTMlvl3);
				component.set('v.MapCaseCateLVL_4',returnValues.mapSVTMlvl4);
				component.set('v.MapServiceTypeMatrix',returnValues.mapSVTM);
				

			}else if (state ==='ERROR'){
				var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors);
                        
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
			}
			helper.createfirst(component, event, helper);
			helper.stopSpinner(component,event,helper);
		});
		$A.enqueueAction(action);
	},
	displayToast: function (component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
	},
	SaveRecord: function (component, event, helper, saveType){
		var caseList = component.get('v.caseList');
		var isSuccess = false;
		var ContactPhone = component.get('v.ContactPhone');
		var ContactName = component.get('v.ContactName');
		var CallLogId = component.get('v.CallLogId');
		var CallNumber = component.get('v.CallNumber');
		var AccountId = component.get('v.AccountId');
		var mapSVTM = component.get('v.MapServiceTypeMatrix');
		var isValid = true;
		var CallLogObj = component.get('v.CallLogObj');
		var ContactPhone2 = component.get('v.ContactPhone2');
		var ToExt1 = component.get('v.ToExt1');
		var ToExt2 = component.get('v.ToExt2');
		// console.log('AccountId: ',AccountId);
		// console.log('ContactName: ',ContactName);
		
		if ((AccountId == '' || AccountId == undefined) && (ContactName == '' || ContactName == undefined)){
			isValid = false;
		}
		if (!isValid){
			component.set('v.errorMessage','กรุณากรอก Customer Name/Company (TH) Account หรือ Contact Person Name');
			component.set('v.isError',true);
			helper.stopSpinner(component,event,helper);
		}else {
			component.set('v.isError',false);
			caseList.forEach(element => {
				if (element.PTA_Segment__c == ''){
					component.set('v.errorMessage','Please input value in PTA Segment, Category, Problem Channel, Product/Service and Issue. ' 
					+'(กรุณากรอกข้อมูล PTA Segment, Category, Problem Channel, Product/Service, Issue ให้ครบถ้วน)');
					component.set('v.isError',true);
					isValid = false;
					helper.stopSpinner(component,event,helper);
					// break;
					return null;
				}else if (((element.PTA_Segment__c != '' || element.PTA_Segment__c != undefined) && (element.Category__c != undefined || element.Category__c != '') 
				&& (element.Sub_Category__c != undefined || element.Sub_Category__c != '')) && ((element.Product_Category__c == undefined || element.Product_Category__c == '')
				|| (element.Issue__c == undefined || element.Issue__c == ''))){
					component.set('v.errorMessage','Please input value in Product/Service and Issue. (กรุณาระบุค่า Product/Service และ Issue ให้ครบถ้วน)');
					component.set('v.isError',true);
					isValid = false;
					helper.stopSpinner(component,event,helper);
					// break;
					return null;
				}
				else {
					var keyWord;
					if (CallLogObj != undefined){
						element.Call_Start_Datetime__c = CallLogObj.Call_Start_Datetime__c;
						element.Call_Log_ID__c = CallLogId;
						element.Call_Number__c = CallNumber;
					}
					element.AccountId = AccountId;
					element.Contact_Person_Name__c = ContactName;
					element.Contact_Person_Phone__c = ContactPhone;
					element.Contact_Person_Phone_2__c = ContactPhone2;
					element.To_Ext_1__c = ToExt1;
					element.To_Ext_2__c = ToExt2;
					element.Subject = element.Issue__c;
					
					if (element.Issue__c != '' && element.Issue__c != undefined){
						element.FCR__c = true;
						keyWord = element.Issue__c + ':' + element.Product_Category__c +':'+ element.Sub_Category__c +':'+ element.Category__c +':'+ element.PTA_Segment__c;
						var SVTM = mapSVTM[keyWord];
						if (SVTM != null){
							// console.log('HAVE SVTM');
							element.Problem_Type__c = SVTM.Problem_Type__c;
							element.Journey__c = SVTM.Journey__c;
							element.Service_Type_Matrix_Code__c = SVTM.Validate_Code__c;
							element.Origin = 'ลูกค้าสัมพันธ์';
						}
					}
				}
				

				// console.log('element: ',element);
			});
			if (isValid){
				var action = component.get('c.saveRecord');
				action.setParams({
					'caseList': caseList,
                    'taskObj' : component.get('v.taskObj')
				});
				action.setCallback(this, function (response) {
					var state = response.getState();
					var returnValues;
					if (state === 'SUCCESS'){
						returnValues = response.getReturnValue();
						isSuccess = true;
						// console.log('returnValues v1: ',returnValues);
						
					}else if (state === 'ERROR'){
						var errors = response.getError();
						if (errors) {
							if (errors[0] && errors[0].message) {
								console.log(errors);
								console.log("Error message: " + errors[0].message);
							}
						} else {
							console.log("Unknown error");
						}
					}
					helper.stopSpinner(component,event,helper);
					if (isSuccess && saveType == 'SaveOnly'){
						helper.displayToast(component, 'Success', 'Create Inquiry Cases Success.');
						helper.closeFocusedTabwithRefreshView(component, event, helper);
					}else if (isSuccess && saveType == 'SaveAndCreate'){
						helper.displayToast(component, 'Success', 'Create Inquiry Cases Success.');
						helper.closeFocusedTabwithRefreshView(component, event, helper);
						helper.openTab(component,event,helper);
					}
				});
				$A.enqueueAction(action);	
			}
		}
	},
	closeFocusedTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
        .catch(function (error) {
            console.log(error);
        });
	},
	closeFocusedTabwithRefreshView: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            $A.get('e.force:refreshView').fire();
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
        .catch(function (error) {
            console.log(error);
        });
    },
	openTab: function (component, event, helper) {
		var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
		var ContactPhone = component.get('v.ContactPhone');
		var ContactName = component.get('v.ContactName');
		var AccountId = component.get('v.AccountId');
		var ContactPhone2 = component.get('v.ContactPhone2');
		var ToExt1 = component.get('v.ToExt1');
		var ToExt2 = component.get('v.ToExt2');
		if (AccountId != undefined){
			workspaceAPI.openTab({
				url: '/apex/CaseUpdateStd?type='+ 'Inquiry_Case' +'&def_account_id='+AccountId+'&ContactPersonName='+ContactName+'&ContactPersonPhone='+ContactPhone+'&ContactPersonPhone2='+ContactPhone2+
				'&Toxt1='+ToExt1 +'&ToExt2='+ToExt2 ,
				focus: true
			});
		}else {
            workspaceAPI.openTab({
				url: '/apex/CaseUpdateStd?type='+ 'Inquiry_Case' +'&ContactPersonName='+ContactName+'&ContactPersonPhone='+ContactPhone+'&ContactPersonPhone2='+ContactPhone2+
				'&Toxt1='+ToExt1 +'&ToExt2='+ToExt2 ,
                focus: true
				});
			}
        })
        .catch(function (error) {
            console.log(error);
		});
		
		
	},
	mappingCallLog: function(component, event, helper){
		var action = component.get('c.mappingCallLog');
		action.setCallback(this, function(response){
			var state = response.getState();
			// console.log('CALL LOG STATE: ',state);
			if (state === 'SUCCESS'){
				var returnValues = response.getReturnValue();
				// console.log('CALL LOG :',returnValues);
				if (returnValues != null){
					console.log('CALL LOG :',returnValues);
					component.set('v.CallLogId',returnValues.Call_Log_ID__c);
					component.set('v.CallNumber',returnValues.Call_Number__c);
					component.set('v.CallLogObj',returnValues);
                    //  <!-- Inbound Popup -->
					component.set('v.taskObj',returnValues);
					console.log('taskObj :',component.get('v.taskObj'));
				}
			}else if (state === 'ERROR'){
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log(errors);
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	},
	startSpinner: function(component, event, helper){
		component.set('v.loading',true);
	},
	stopSpinner: function(component, event, helper){
		component.set('v.loading',false);
	},
})