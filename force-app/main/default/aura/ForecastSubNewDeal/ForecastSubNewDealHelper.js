({
	setEditData : function(component, helper) {
		var myData = component.get("v.mydata");

		var incomeTypeOpts = [
			{ label: "--- None ---" , text: "" },
			{ label: "NIIc", text: "NIIc" },
			{ label: "NIId", text: "NIId" },
			// { label: "Fee", text: "Fee" },
			{ label: "AS Fee", text: "AS Fee" },
			{ label: "BA Fee", text: "BA Fee" },
			{ label: "Credit Fee", text: "Credit Fee" },
			{ label: "Derivative Fee", text: "Derivative Fee" },
			{ label: "FX Fee", text: "FX Fee" },
			{ label: "IB Fee", text: "IB Fee" },
			{ label: "L/G Fee", text: "L/G Fee" },
			{ label: "TF Fee", text: "TF Fee" },
			{ label: "Supply Chain", text: "Supply Chain" },
			{ label: "AL Fee", text: "AL Fee" },
			{ label: "MF Fee", text: "MF Fee" },
			{ label: "Front End Fee", text: "Front End Fee" },
			{ label: "Direct CM Fee", text: "Direct CM Fee" },
			{ label: "Other CM Fee", text: "Other CM Fee" },
			{ label: "Fleet Fee", text: "Fleet Fee" },
			{ label: "EDC Fee", text: "EDC Fee" },
			{ label: "Cash Fee", text: "Cash Fee" },
		];
	
		var recurringTypeOpts = [
			{ label: "--- None ---" , text: "" },
			{ label: "Recurring", text: "Recurring" },
			{ label: "One-off", text: "One-off" }
		];
	
		var frequencyOpts = [
			{ label: "--- None ---" , text: "" },
			{ label: "Monthly", text: "Monthly" },
			{ label: "Quarterly", text: "Quarterly" },
			{ label: "Biyearly", text: "Biyearly" },
			{ label: "Yearly", text: "Yearly" }
		];
	
		var expectedStartYearOpts = [
			{ label: "--- None ---" , text: "" },
			{ label: "2020", text: "2020" },
			{ label: "2021", text: "2021" },
			{ label: "2022", text: "2022" },
			{ label: "2023", text: "2023" },
			{ label: "2024", text: "2024" },
		];
	
		var expectedStartMonthOpts = [
			{ label: "--- None ---" , text: "" },
			{ label: "January", text: "Jan" },
			{ label: "February", text: "Feb" },
			{ label: "March", text: "Mar" },
			{ label: "April", text: "Apr" },
			{ label: "May", text: "May" },
			{ label: "June", text: "Jun" },
			{ label: "July", text: "Jul" },
			{ label: "August", text: "Aug" },
			{ label: "September", text: "Sep" },
			{ label: "October", text: "Oct" },
			{ label: "November", text: "Nov" },
			{ label: "December", text: "Dec" }
		];
	
		var incomeTypeSelected = component.get("v.mydata.incomeType");
		incomeTypeOpts.filter(incomeTypeOpt => {
		(incomeTypeOpt.text == incomeTypeSelected) ? incomeTypeOpt.value = true : incomeTypeOpt.value = false
		})
		var recurringTypeSelected = component.get("v.mydata.recurringType");
		recurringTypeOpts.filter(recurringTypeOpt => {
		(recurringTypeOpt.text == recurringTypeSelected) ? recurringTypeOpt.value = true : recurringTypeOpt.value = false
		})
		var frequencySelected = component.get("v.mydata.frequency");
		frequencyOpts.filter(frequencyOpt => {
		(frequencyOpt.text == frequencySelected) ? frequencyOpt.value = true : frequencyOpt.value = false
		})
		var expectedStartYearSelected = component.get("v.mydata.expectedStartYear");
		expectedStartYearOpts.filter(expectedStartYearOpt => {
		(expectedStartYearOpt.text == expectedStartYearSelected) ? expectedStartYearOpt.value = true : expectedStartYearOpt.value = false
		})
		var expectedStartMonthSelected = component.get("v.mydata.expectedStartMonth");
		expectedStartMonthOpts.filter(expectedStartMonthOpt => {
		(expectedStartMonthOpt.text == expectedStartMonthSelected) ? expectedStartMonthOpt.value = true : expectedStartMonthOpt.value = false
		})
		
		var utilizationEdited = component.get("v.mydata.utilization");
		var NIMfeeRateEdited = component.get("v.mydata.NIMfeeRate");
		var startingVolumeEdited = component.get("v.mydata.startingVolume") == 0 ? 0 : component.get("v.mydata.startingVolume");
		var remarkEdited = component.get("v.mydata.remark");
		var expectedStartMonthFullName = helper.getMonthFullName(component.get("v.mydata.expectedStartMonth"));

		if(myData.Id == undefined || myData.Id == null) {
			component.set("v.isSave",false);
			component.set("v.incomeTypeEditMode",true);
			// component.set("v.recurringTypeEditMode",true);
			// component.set("v.frequencyEditMode",true);
			component.set("v.expectedStartYearEditMode",true);
			component.set("v.expectedStartMonthEditMode",true);
			component.set("v.utilizationEditMode",true);
			component.set("v.NIMfeeRateEditMode",true);
			component.set("v.startingVolumeEditMode",true);
			component.set("v.remarkEditMode",true);

			incomeTypeSelected = '';
			recurringTypeSelected = '';
			frequencySelected = '';
			expectedStartYearSelected = '';
			expectedStartMonthSelected = '';
			utilizationEdited = null;
			NIMfeeRateEdited = '';
			startingVolumeEdited = 0;
			remarkEdited = '';
		} else {
			component.set("v.isSave",true);
		}

		component.set("v.mydata.ThisYearExpectedBalanceWCommas", helper.numberWithCommas(component.get("v.mydata.ThisYearExpectedBalance")));
		component.set("v.mydata.startingVolumeWCommas", helper.numberWithCommas(component.get("v.mydata.startingVolume")));

		component.set("v.dumpData.incomeType",incomeTypeSelected);
		component.set("v.dumpData.recurringType",recurringTypeSelected);
		component.set("v.dumpData.frequency",frequencySelected);
		component.set("v.dumpData.expectedStartYear",expectedStartYearSelected);
		component.set("v.dumpData.expectedStartMonth",expectedStartMonthSelected);
		component.set("v.dumpData.utilization",utilizationEdited);
		component.set("v.dumpData.NIMfeeRate",NIMfeeRateEdited);
		component.set("v.dumpData.startingVolume",startingVolumeEdited);
		component.set("v.dumpData.remark",remarkEdited);

		// console.log('expectedStartMonth: ', component.get("v.mydata.expectedStartMonth"));
		// console.log('expectedStartMonthFullName: ', expectedStartMonthFullName);
		// console.log('dumpData: ', component.get("v.dumpData"));
		
		component.set("v.expectedStartMonthFullName", expectedStartMonthFullName);
	
		component.set("v.InputList.incomeTypeOptions", incomeTypeOpts);
		component.set("v.InputList.recurringTypeOptions", recurringTypeOpts);
		component.set("v.InputList.frequencyOptions", frequencyOpts);
		component.set("v.InputList.expectedStartYearOptions", expectedStartYearOpts);
		component.set("v.InputList.expectedStartMonthOptions", expectedStartMonthOpts);
		component.set("v.InputNumber.utilizationEdited",utilizationEdited);
		component.set("v.InputNumber.NIMfeeRateEdited",NIMfeeRateEdited);
		component.set("v.InputNumber.startingVolumeEdited",startingVolumeEdited);
		component.set("v.remarkEdited",remarkEdited);
	},
	setDealForecastData : function(component) {
		var id = component.get("v.mydata.Id");
		var incomeTypeSelected = (component.find("incomeTypeid") == null ? 
			component.get("v.mydata.incomeType") : component.find("incomeTypeid").get("v.value"));
		var recurringTypeSelected = (component.find("recurringTypeid") == null ? 
			component.get("v.mydata.recurringType") : component.find("recurringTypeid").get("v.value"));
		var frequencySelected = (component.find("frequencyid") == null ? 
			component.get("v.mydata.frequency") : component.find("frequencyid").get("v.value"));
		var expectedStartYearSelected = (component.find("expectedStartYearid") == null ? 
			component.get("v.mydata.expectedStartYear") : component.find("expectedStartYearid").get("v.value"));
		var expectedStartMonthSelected = (component.find("expectedStartMonthid") == null ?
			component.get("v.mydata.expectedStartMonth") : component.find("expectedStartMonthid").get("v.value"));
		var utilizationEdited = (component.get("v.InputNumber.utilizationEdited") == null ? 
			component.get("v.mydata.utilization") : component.get("v.InputNumber.utilizationEdited"));
		var NIMfeeRateEdited = (component.get("v.InputNumber.NIMfeeRateEdited") == null ? 
			component.get("v.mydata.NIMfeeRate") : component.get("v.InputNumber.NIMfeeRateEdited"));
		var startingVolumeEdited = (component.get("v.InputNumber.startingVolumeEdited") == null ? 
			component.get("v.mydata.startingVolume") : component.get("v.InputNumber.startingVolumeEdited"));
		var remarkEdited = (component.get("v.remarkEdited") == null ? 
			component.get("v.mydata.remark") : component.get("v.remarkEdited"));

		// if (utilizationEdited == '') {
		// 	component.set("v.InputNumber.utilizationEdited", null)
		// 	component.set("v.mydata.utilization", null)
		// }
		// if (startingVolumeEdited == '') {
		// 	component.set("v.InputNumber.startingVolumeEdited", 0)
		// 	component.set("v.mydata.startingVolume", 0)
		// }
		
		var DealForecastData = new Object();

		if(id == undefined || id == null) {
			DealForecastData.Probability__c = component.get("v.mydata.prop");
			DealForecastData.OpportunityLineItem_Limit_Volume__c = component.get("v.mydata.limitVolume");
			DealForecastData.Income_Type__c = incomeTypeSelected;
			DealForecastData.Recurring_Type__c = recurringTypeSelected;
			DealForecastData.Frequency__c = frequencySelected;
			DealForecastData.Expected_Start_Year__c = (expectedStartYearSelected == '') ? null : expectedStartYearSelected;
			DealForecastData.Expected_Start_Month__c = (expectedStartMonthSelected == '') ? null : expectedStartMonthSelected;
			DealForecastData.Utilization_Percent__c = utilizationEdited;
			DealForecastData.NIM_Fee_rate__c = NIMfeeRateEdited;
			DealForecastData.Volume__c = startingVolumeEdited;
			DealForecastData.Remark__c = remarkEdited;
			DealForecastData.Customer__c = component.get("v.mydata.customerId");
			DealForecastData.Opportunity__c = component.get("v.mydata.opportunityId");
			DealForecastData.Product__c = component.get("v.mydata.productId");
			DealForecastData.Opportunity_Product_Id__c = component.get("v.mydata.opportunityProductId");
			DealForecastData.Main_Deal_forecast__c = component.get("v.mydata.mainDealForecast");
		} else {
			DealForecastData.Id = id;
			DealForecastData.OpportunityLineItem_Limit_Volume__c = component.get("v.mydata.limitVolume");
			DealForecastData.Probability__c = component.get("v.mydata.prop");
			DealForecastData.Customer__c = component.get("v.mydata.customerId");
			DealForecastData.Opportunity__c = component.get("v.mydata.opportunityId");
			DealForecastData.Product__c = component.get("v.mydata.productId");
			DealForecastData.Opportunity_Product_Id__c = component.get("v.mydata.opportunityProductId");
			DealForecastData.Main_Deal_forecast__c = component.get("v.mydata.mainDealForecast");
			DealForecastData.Income_Type__c = incomeTypeSelected;
			DealForecastData.Recurring_Type__c = recurringTypeSelected;
			DealForecastData.Frequency__c = frequencySelected;
			DealForecastData.Expected_Start_Year__c = (expectedStartYearSelected == '') ? null : expectedStartYearSelected;
			DealForecastData.Expected_Start_Month__c = (expectedStartMonthSelected == '') ? null : expectedStartMonthSelected;
			DealForecastData.Utilization_Percent__c = utilizationEdited;
			DealForecastData.NIM_Fee_rate__c = NIMfeeRateEdited;
			DealForecastData.Volume__c = startingVolumeEdited;
			DealForecastData.Remark__c = remarkEdited;
		}

		return DealForecastData;
	},
	setDataAfterChange : function(component, helper) {
		var isSave = component.get("v.isSave");
		var limitVolume = component.get("v.mydata.limitVolume");
		var recordType = component.get("v.mydata.opportunityRecordType");
		var isSE = recordType.includes('SE')
		var incomeTypeInputSelected = (component.find("incomeTypeid") == null ? 
			component.get("v.mydata.incomeType") : component.find("incomeTypeid").get("v.value"));
		var recurringTypeInputSelected = (component.find("recurringTypeid") == null ? 
			component.get("v.mydata.recurringType") : component.find("recurringTypeid").get("v.value"));
		var frequencyInputSelected = (component.find("frequencyid") == null ? 
			component.get("v.mydata.frequency") : component.find("frequencyid").get("v.value"));
		var expectedStartYearInputSelected = (component.find("expectedStartYearid") == null ? 
			component.get("v.mydata.expectedStartYear") : component.find("expectedStartYearid").get("v.value"));
		var expectedStartMonthInputSelected = (component.find("expectedStartMonthid") == null ?
			component.get("v.mydata.expectedStartMonth") : component.find("expectedStartMonthid").get("v.value"));
		var utilizationEdited = component.get("v.InputNumber.utilizationEdited");
		var NIMfeeRateEdited = component.get("v.InputNumber.NIMfeeRateEdited");
		var startingVolumeEdited = component.get("v.InputNumber.startingVolumeEdited");
		var remarkEdited = component.get("v.remarkEdited");
		if (incomeTypeInputSelected != null && incomeTypeInputSelected.includes('NI') && utilizationEdited == null) {
			if(incomeTypeInputSelected.includes('NIIc')) {
				utilizationEdited = isSE ? 35 : 100;
			} else {
				utilizationEdited = 100;
			}
			component.set("v.InputNumber.utilizationEdited", utilizationEdited);
			var isDaft = component.get('v.isDaft');
			if (!isDaft) {
				var target = component.find('isDaft');
				component.set('v.showSaveChildeBtn', true);
				component.set('v.isDaft', true);
				$A.util.addClass(target, 'slds-is-edited');
    		}
		}
		if (incomeTypeInputSelected != null &&  (incomeTypeInputSelected.includes('Fee') || incomeTypeInputSelected.includes('Supply Chain'))) {
			recurringTypeInputSelected = recurringTypeInputSelected;
			if (!isSave) component.set("v.recurringTypeEditMode",true);
		} else {
			recurringTypeInputSelected = '';
			if (!isSave) {
				component.set("v.recurringTypeEditMode",false);
			};
		}
		if (recurringTypeInputSelected != 'Recurring') {
			frequencyInputSelected = '';
			if (!isSave) {
				component.set("v.frequencyEditMode",false);
			} 
		} else {
			frequencyInputSelected = frequencyInputSelected;
			if (!isSave) component.set("v.frequencyEditMode",true);
		}
		if (startingVolumeEdited == null || startingVolumeEdited == '' || utilizationEdited != component.get("v.mydata.utilization")) {
				startingVolumeEdited = limitVolume * (utilizationEdited / 100);
				component.set("v.InputNumber.startingVolumeEdited", startingVolumeEdited);
		}
		var expectedStartMonthFullName = helper.getMonthFullName(expectedStartMonthInputSelected);
		
		component.set("v.expectedStartMonthFullName", expectedStartMonthFullName);
		component.set("v.mydata.incomeType",incomeTypeInputSelected);
		component.set("v.mydata.recurringType",recurringTypeInputSelected);
		component.set("v.mydata.frequency",frequencyInputSelected);
		component.set("v.mydata.expectedStartYear",expectedStartYearInputSelected);
		component.set("v.mydata.expectedStartMonth",expectedStartMonthInputSelected);
		component.set("v.mydata.utilization",utilizationEdited);
		component.set("v.mydata.NIMfeeRate",NIMfeeRateEdited);
		component.set("v.mydata.startingVolume",startingVolumeEdited);
		component.set("v.mydata.remark",remarkEdited);

		// console.log('data after changed: ', component.get("v.mydata"));
	},
	getMonthFullName: function (month) {
        var monthFullNames = {
            'Jan': 'January',
            'Feb': 'February',
            'Mar': 'March',
            'Apr': 'April',
            'May': 'May',
            'Jun': 'June',
            'Jul': 'July',
            'Aug': 'August',
            'Sep': 'September',
            'Oct': 'October',
            'Nov': 'November',
            'Dec': 'December'
		}

		return monthFullNames[month];
	},
	setDataAfterCancel: function(component) {
		component.set("v.mydata.incomeType",component.get("v.dumpData.incomeType"));
		component.set("v.mydata.recurringType",component.get("v.dumpData.recurringType"));
		component.set("v.mydata.frequency",component.get("v.dumpData.frequency"));
		component.set("v.mydata.expectedStartYear",component.get("v.dumpData.expectedStartYear"));
		component.set("v.mydata.expectedStartMonth",component.get("v.dumpData.expectedStartMonth"));
		component.set("v.mydata.utilization",component.get("v.dumpData.utilization"));
		component.set("v.mydata.NIMfeeRate",component.get("v.dumpData.NIMfeeRate"));
		component.set("v.mydata.startingVolume",component.get("v.dumpData.startingVolume"));
		component.set("v.mydata.remark",component.get("v.dumpData.remark"));
	},
	setDataAfterSave: function(component,helper , DealForecastData) {
		var id = DealForecastData.Id;
		var lastUpdatedBy = DealForecastData.Last_Adjustment_By__r.Name;
		var lastUpdated = DealForecastData.Last_Update_Adjustment__c;

		component.set('v.mydata.Id', id);
		component.set('v.mydata.lastUpdatedBy', lastUpdatedBy);
		component.set('v.mydata.lastUpdated', lastUpdated);
		
        if(parseInt(component.get("v.mydata.expectedStartYear")) > (new Date()).getFullYear()){
        	component.set("v.mydata.ThisYearExpectedBalance", 0);
        }
        else{
            component.set("v.mydata.ThisYearExpectedBalance", component.get("v.mydata.startingVolume"));
        }
		component.set("v.mydata.ThisYearExpectedBalanceWCommas", helper.numberWithCommas(component.get("v.mydata.ThisYearExpectedBalance")));
		component.set("v.mydata.startingVolumeWCommas", helper.numberWithCommas(component.get("v.mydata.startingVolume")));

		component.set("v.dumpData.prop",component.get("v.mydata.prop"));
		component.set("v.dumpData.incomeType",component.get("v.mydata.incomeType"));
		component.set("v.dumpData.recurringType",component.get("v.mydata.recurringType"));
		component.set("v.dumpData.frequency",component.get("v.mydata.frequency"));
		component.set("v.dumpData.expectedStartYear",component.get("v.mydata.expectedStartYear"));
		component.set("v.dumpData.expectedStartMonth",component.get("v.mydata.expectedStartMonth"));
		component.set("v.dumpData.limitVolume",component.get("v.mydata.limitVolume"));
		component.set("v.dumpData.utilization",component.get("v.mydata.utilization"));
		component.set("v.dumpData.NIMfeeRate",component.get("v.mydata.NIMfeeRate"));
		component.set("v.dumpData.startingVolume",component.get("v.mydata.startingVolume"));
		component.set("v.dumpData.remark",component.get("v.mydata.remark"));

		component.set("v.incomeTypeEditMode",false);
		component.set("v.recurringTypeEditMode",false);
		component.set("v.frequencyEditMode",false);
		component.set("v.expectedStartYearEditMode",false);
		component.set("v.expectedStartMonthEditMode",false);
		component.set("v.utilizationEditMode",false);
		component.set("v.NIMfeeRateEditMode",false);
		component.set("v.startingVolumeEditMode",false);
		component.set("v.remarkEditMode",false);
	},

	displayToast: function (type, message) {
        var duration = 5000;
		var toastEvent = $A.get('e.force:showToast');
		
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
		});
		
        toastEvent.fire();
    },
	
	numberWithCommas : function (x) {
		if(x == null) return ''
		var parts = x.toString().split(".");
		parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		parts[1] = (parts[1] == '' || parts[1] == null) ? '00': parts[1];
		return parts.join(".");
	},
})