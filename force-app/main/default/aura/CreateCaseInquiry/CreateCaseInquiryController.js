({
	doInit : function(component, event, helper) {
		helper.startSpinner(component,event,helper);
		var pageRef = JSON.parse(JSON.stringify(component.get("v.pageReference").state));
		var recordId = pageRef.c__recordId;
		var workspaceAPI = component.find("workspace");
		var isCustomTab = component.get('v.isCustomTab');
		var isCustom = component.get('v.isCustomTab');
        workspaceAPI.getFocusedTabInfo().then(function (response) {
			var focusedTabId = response.tabId;
			// console.log('focusedTabId: ',focusedTabId);
			if (focusedTabId == undefined){
				component.set('v.isCustomTab',true);
				component.set('v.isCustom',true);
				isCustomTab = true;
				isCustom = true;
			}
			if (!isCustomTab && !isCustom){
				component.set('v.caseList',[]);
				helper.getServiceTypeMatrix(component, event, helper);
				helper.mappingCallLog(component, event, helper);
				// console.log('CHECK SVTM v2');
			}
        })
        .catch(function (error) {
            console.log(error);
		});
		component.set('v.recordId',recordId);
		component.set('v.AccountId',recordId);
		
		
	},
	customTabInquiry : function(component, event, helper){
		component.set('v.isCustomTab',false);
		helper.startSpinner(component,event,helper);
		helper.getServiceTypeMatrix(component, event, helper);
		helper.mappingCallLog(component, event, helper);
	},
	removeDeletedRow: function (component, event, helper) {
		// get the selected row Index for delete, from Lightning Event Attribute  
		var index = event.getParam("indexVar");
		
		// get the all List (caseList attribute) and remove the Object Element Using splice method    
		var AllRowsList = component.get("v.caseList");
		AllRowsList.splice(index, 1);
		// set the caseList after remove selected row element  
		component.set("v.caseList", AllRowsList);
	},
	addNewRow: function (component, event, helper) {
		helper.createfirst(component, event, helper);
	},
	onSave: function (component, event, helper){
		helper.startSpinner(component,event,helper);
		helper.SaveRecord(component,event,helper,'SaveOnly');
	},
	onSaveAndCreate: function(component, event, helper){
		helper.startSpinner(component,event,helper);
		helper.SaveRecord(component,event,helper,'SaveAndCreate');
	},
	Cancel : function(component, event, helper) {
		var isCustom = component.get('v.isCustom');
		if (isCustom){
			component.set('v.isCustomTab',true);
			var caseList = [];
			component.set('v.caseList',caseList);
		}else {
			helper.closeFocusedTab(component, event, helper);
		}
	},
})