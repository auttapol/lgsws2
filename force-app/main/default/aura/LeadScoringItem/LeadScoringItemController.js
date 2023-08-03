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
		
		// console.log('fieldlength' + fieldlength);
		var newMapAPiNameLabel = component.get("v.mapWrapperLabel");
		
		var FIELDAPINAME = newMapAPiNameLabel[component.get("v.LeadScoringList").LObject];
		// console.log('FIELDAPINAME '+ JSON.stringify(FIELDAPINAME))
		// console.log('hahah' + FIELDAPINAME.API[component.get("v.LeadScoringList").FieldName]);
		var index = component.get("v.LeadScoringList").FieldName;
		// var mapfieldLabellist = component.get("v.mapfieldLabel");
		// var fieldLabellist = mapfieldLabellist[component.get("v.LeadScoringList").LObject];
		// console.log('FieldName' + component.get("v.LeadScoringList").FieldName);
		// console.log('hehe' + JSON.stringify(fieldLabellist));
		// var fieldlabel = fieldLabellist[component.get("v.LeadScoringList").FieldName];
		var LeadList = component.get("v.LeadScoringList");
		console.log('index -- > '+index)
		var LabelList = component.get("v.LeadScoringList").FieldList;
		var label = LabelList[index];
		var mapfieldtypelist = component.get("v.mapfieldtype");
		var fieldtypelist = mapfieldtypelist[component.get("v.LeadScoringList").LObject];
		var fieldtype = fieldtypelist[FIELDAPINAME.API[index]];
		// var clickedIndex = event.getSource().getElement().dataset.index;
    	console.log('fieldname label:', label);
		var mapfieldlengthlist = component.get("v.mapfieldLength");
		var fieldlengthlist = mapfieldlengthlist[component.get("v.LeadScoringList").LObject];
		var fieldlength = fieldlengthlist[FIELDAPINAME.API[index]];

		LeadList.Label = label;
		LeadList.FieldType = fieldtype;
		LeadList.Length = fieldlength;
		LeadList.APIName = FIELDAPINAME.API[index];
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
    },

	handleItemClick: function(component, event, helper) {
		var selectedValue = component.get("v.LeadScoringList.FieldName");
        // var selectedIndex = event.target["data-index"];
        // var selectedIndex1 = event.getSource().get("v.id");
		// var selectedIndex2 = event.getSource().get("v.data-index");
        console.log("Selected Value: " + selectedValue);
		// console.log("Selected Index1: " + selectedIndex1);
        // console.log("Selected Index2: " + selectedIndex2);
		

		// var selectedIndex123 = event.getSource().get("v.value");
		// var selectedOption = event.getSource().find("option[value='" + selectedIndex123 + "']");
		// var index = selectedOption.get("v.data-index");
		// console.log("Index value: " + index);
	  }
})