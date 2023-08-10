({	
	doInit : function(component, event, helper) {
		// console.log(component.get("v.fieldType"));
		var fieldType = component.get("v.fieldType");
		var operation = [];
		operation.push('=')
        if(fieldType == "Text"){
			operation.push('Contain')
		}else if(fieldType == "Number"){
			operation.push('<')
			operation.push('>')
			operation.push('Range')
		} 
		component.set("v.operation", operation);
		
		var list = component.get("v.LeadScoringList")
		if(list.Operator == 'Range'){
			component.set("v.readonly",false);
		}
		if(!list.hasOwnProperty("rowIndex")){
			list.rowIndex = component.get("v.rowIndex") - 1;
			// console.log('list.rowIndex ' +list.rowIndex )
		}

		// console.log('list ' + JSON.stringify(list));
    },
	AddNewRow: function (component, event, helper) {
		// fire the AddNewRowEvt Lightning Event
		component.set("v.rowIndex", component.get("v.rowIndex")+1)
		component.getEvent("leadSettingAddNewRowEvt").fire();
	},

	removeRow: function (component, event, helper) {
		// fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
		// component.set("v.rowIndex", component.get("v.rowIndex")-1)
		component.getEvent("leadSettingDeleteRowEvt").setParams({ "indexVar": component.get("v.rowIndex") }).fire();
	},
    openScoreSettingModal: function (component, event, helper){
        component.set("v.showModal",true);
    },
    closeModal: function (component, event, helper){
        component.set("v.showModal",false);
    },
	onchangeOperation: function (component, event, helper){
		component.set("v.readonly",true);
		component.set("v.LeadScoringList.Value2", null)
		if(component.get("v.LeadScoringList.Operator") == 'Range'){
			component.set("v.readonly",false);
		}
	}
})