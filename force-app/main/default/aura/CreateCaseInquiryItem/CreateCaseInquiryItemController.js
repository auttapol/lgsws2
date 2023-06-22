({
	AddNewRow: function (component, event, helper) {
		// fire the AddNewRowEvt Lightning Event 
		component.getEvent("InquiryAddNewRowEvt").fire();
	},

	removeRow: function (component, event, helper) {
		// fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
		component.getEvent("InquiryDeleteRowEvt").setParams({ "indexVar": component.get("v.rowIndex") }).fire();
	},
	doInit: function (component, event, helper){
		var thisCase = component.get('v.CaseInstance');
		if (thisCase.PTA_Segment__c != null && thisCase.PTA_Segment__c != undefined && thisCase.PTA_Segment__c != ''){
				console.log('thisCase: ',thisCase);
				var getSegment = component.get('v.CaseInstance.PTA_Segment__c');
				var getCateLvl1 = component.get('v.CaseInstance.Category__c');
				var getCateLvl2 = component.get('v.CaseInstance.Sub_Category__c');
				console.log('getSegment:',getSegment);
				console.log('getCateLvl1:',getCateLvl1);
				console.log('getCateLvl2:',getCateLvl2);
				var keyWord1 = getSegment;
				var keyWord2 = getCateLvl1+':'+getSegment;
				var keyWord3 = getCateLvl2 + ':' + getCateLvl1+':'+getSegment;
				var mapLvl1 = component.get('v.MapCaseCateLVL_1');
				var mapLvl2 = component.get('v.MapCaseCateLVL_2');
				var mapLvl3 = component.get('v.MapCaseCateLVL_3');
				console.log('mapLvl1[keyWord1]: ',mapLvl1[keyWord1]);
				console.log('mapLvl2[keyWord2]: ',mapLvl2[keyWord2]);
				console.log('mapLvl3[keyWord3]: ',mapLvl3[keyWord3]);
				
				component.set('v.CaseCateLVL_1',mapLvl1[keyWord1]);
				component.set('v.CaseCateLVL_2',mapLvl2[keyWord2]);
				component.set('v.CaseCateLVL_3',mapLvl3[keyWord3]);
				thisCase.PTA_Segment__c = getSegment;
				thisCase.Category__c = getCateLvl1;
				thisCase.Sub_Category__c = getCateLvl2;
				component.set('v.CaseInstance',thisCase);
				console.log('FINISH');
		}
		
	},
	onChangeSegment: function (component, event, helper){
		var main = event.getSource().get("v.value");
		console.log('main: ',main);
		var thisCase = component.get('v.CaseInstance');
		var getSegment = thisCase.PTA_Segment__c;
		console.log('getSegment: ',getSegment);
		var mapLvl1 = component.get('v.MapCaseCateLVL_1');
		console.log('mapLvl1[getSegment]: ',mapLvl1[getSegment]);
		component.set('v.CaseCateLVL_1',mapLvl1[getSegment]);
		thisCase.Category__c = '';
		thisCase.Sub_Category__c = '';
		thisCase.Product_Category__c = '';
		thisCase.Issue__c = '';
		component.set('v.CaseInstance',thisCase);
	},
	onChangeLvl1: function (component, event, helper){
		var thisCase = component.get('v.CaseInstance');
		var getSegment = thisCase.PTA_Segment__c;
		var getCateLvl1 = thisCase.Category__c;
		var keyWord = getCateLvl1+':'+getSegment;
		var mapLvl2 = component.get('v.MapCaseCateLVL_2');
		component.set('v.CaseCateLVL_2',mapLvl2[keyWord]);
		thisCase.Sub_Category__c = '';
		thisCase.Product_Category__c = '';
		thisCase.Issue__c = '';
		component.set('v.CaseInstance',thisCase);
	},
	onChangeLvl2: function (component, event, helper){
		var thisCase = component.get('v.CaseInstance');
		var getSegment = thisCase.PTA_Segment__c;
		var getCateLvl1 = thisCase.Category__c;
		var getCateLvl2 = thisCase.Sub_Category__c;
		var keyWord = getCateLvl2 + ':' + getCateLvl1+':'+getSegment;
		var mapLvl3 = component.get('v.MapCaseCateLVL_3');
		component.set('v.CaseCateLVL_3',mapLvl3[keyWord]);
		thisCase.Product_Category__c = '';
		thisCase.Issue__c = '';
		component.set('v.CaseInstance',thisCase);
	},
	onChangeLvl3: function (component, event, helper){
		var thisCase = component.get('v.CaseInstance');
		var getSegment = thisCase.PTA_Segment__c;
		var getCateLvl1 = thisCase.Category__c;
		var getCateLvl2 = thisCase.Sub_Category__c;
		var getCateLvl3 = thisCase.Product_Category__c;
		var keyWord = getCateLvl3 + ':' + getCateLvl2 + ':' + getCateLvl1+':'+getSegment;
		var mapLvl4 = component.get('v.MapCaseCateLVL_4');
		component.set('v.CaseCateLVL_4',mapLvl4[keyWord]);
		thisCase.Issue__c = '';
		component.set('v.CaseInstance',thisCase);
	},
	onChangeLvl4: function (component, event, helper){
		var thisCase = component.get('v.CaseInstance');
	},
})