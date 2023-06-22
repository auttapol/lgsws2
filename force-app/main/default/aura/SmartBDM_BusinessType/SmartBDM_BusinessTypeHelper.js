({
	parseObj: function (obj) {
		return JSON.parse(JSON.stringify(obj));
	},
	startSpinner: function (component) {
		component.set("v.showSpinnerLoading", true);
	},
	stopSpinner: function (component) {
		component.set("v.showSpinnerLoading", false);
	},
	searchHelper: function (component, event, getInputkeyWord) {
		// call the apex class method 
		var action = component.get("c.fetchIndustryMaster");
		// set param to method  
		action.setParams({
			'searchKeyWord': getInputkeyWord
		});
		// set a callBack    
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				// if storeResponse size is equal 0 ,display No Result Found... message on screen.
				if (storeResponse.length == 0) {
					component.set("v.Message", 'No Result Found');
				} else {
					component.set("v.Message", 'Search Result');
				}

				// set searchResult list with return value from server.
				component.set("v.listOfSearchRecords", storeResponse);
			} else {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
				
				component.set("v.Message", 'No Result Found...');
				component.set("v.listOfSearchRecords", []);
			}
		});
		// enqueue the Action  
		$A.enqueueAction(action);
	},

	getDataSelectedHelper: function (component, event, helper, IndustryMasterID) {
		// helper.startSpinner(component);
		var action = component.get("c.getIndustryMaster");
		action.setParams({
			'IndustryMasterID': IndustryMasterID
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();

				component.set("v.IndustrySelected", storeResponse);
				component.set("v.isSelected", true);
			}
			// helper.stopSpinner(component);
		});
		$A.enqueueAction(action);
	},
    getDeepLink: function (component, event, helper){
    	var action = component.get("c.getDeepLink");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var getDeepLink = response.getReturnValue();
                component.set('v.varDeepLink', getDeepLink);
            }
        });
        $A.enqueueAction(action);
	}
})