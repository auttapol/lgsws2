({
	onInit: function (component, event, helper) {
		// console.log(JSON.stringify(component.get("v.LeadScoringList")))

	},
	onchangeObject: function (component, event, helper){
		component.set("v.loaded",true);

		// console.log(component.get("v.rowIndex") + 1);
		// console.log(component.get("v.LeadScoringList").LObject);

		var LeadList = component.get("v.LeadScoringList");
		LeadList.FieldName = '--None--';
		LeadList.APIName = '';
		LeadList.FieldType = '';
		LeadList.Length = '';

		component.set("v.LeadScoringList",LeadList);

		if(component.get("v.LeadScoringList").LObject == 'CampaignMember' || component.get("v.LeadScoringList").LObject == 'Lead'){
			var mapfieldList = component.get("v.mapfieldList");
			var mapWrapperLabel = component.get("v.mapWrapperLabel");

			// console.log('Object : ' + component.get("v.LeadScoringList").LObject);
			var fieldList = mapfieldList[component.get("v.LeadScoringList").LObject];
			var LabelAPIMap = mapWrapperLabel[component.get("v.LeadScoringList").LObject];
			var LabelList = LabelAPIMap["Label"];
			var ApiList = LabelAPIMap["API"];
			component.set("v.APILabelListWrapper",LabelAPIMap);
			var LeadfieldList = component.get("v.LeadScoringList");
			LeadfieldList.FieldList = fieldList;
			component.set("v.LeadScoringList",LeadfieldList);
			// console.log('test '+ JSON.stringify(fieldList.length));
			component.set("v.readonly",false);
			component.set("v.loaded",false);

		}else{
			component.set("v.readonly",true);
			var LeadfieldList = component.get("v.LeadScoringList");
			LeadfieldList.FieldList = [];
			component.set("v.LeadScoringList", LeadfieldList);
			component.set("v.")
			component.set("v.loaded",false);

		}
	},
	onchangeFieldName : function (component, event, helper) {
		// console.log(component.get("v.LeadScoringList").FieldName);
		var mapfieldtypelist = component.get("v.mapfieldtype");
		var fieldtypelist = mapfieldtypelist[component.get("v.LeadScoringList").LObject];
		var fieldtype = fieldtypelist[component.get("v.LeadScoringList").FieldName];

		var mapfieldlengthlist = component.get("v.mapfieldLength");
		var fieldlengthlist = mapfieldlengthlist[component.get("v.LeadScoringList").LObject];
		var fieldlength = fieldlengthlist[component.get("v.LeadScoringList").FieldName];
		// console.log('fieldlength' + fieldlength);

		var mapfieldLabellist = component.get("v.mapfieldLabel");
		var fieldLabellist = mapfieldLabellist[component.get("v.LeadScoringList").LObject];
		var fieldlabel = fieldLabellist[component.get("v.LeadScoringList").FieldName];
		var LeadList = component.get("v.LeadScoringList");
		LeadList.FieldType = fieldtype;
		LeadList.Length = fieldlength;
		LeadList.APIName = fieldlabel;

		component.set("v.LeadScoringList",LeadList);
	},

	AddNewRow: function (component, event, helper) {
		// fire the AddNewRowEvt Lightning Event 
		// console.log('event : ' + JSON.stringify(component.getEvent("LeadScoringAddNewRowEvt")))
		component.getEvent("LeadScoringAddNewRowEvt").fire();
	},

	removeRow: function (component, event, helper) {
		// fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
		component.getEvent("InquiryDeleteRowEvt").setParams({ "indexVar": component.get("v.rowIndex") }).fire();
	},
    openScoreSettingModal: function (component, event, helper){
        component.set("v.showModal",true);
    },
    closeModal: function (component, event, helper){
        component.set("v.showModal",false);
    }
})