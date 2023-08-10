({
	createfirst: function (component, event, helper) {
		// get the caseList from component and add(push) New Object to List
		var RowItemList = component.get("v.OrderList");
		// console.log('RowItemList: ',RowItemList);
		var size = RowItemList.length;
		if (RowItemList != undefined){
			if (size < 10){
				RowItemList.push({
					'Operator': '=',
                    'Value1':'',
                    'Value2':'',
                    'Score':''
				});
			}else {
				helper.displayToast(component, 'Error', 'สามารถสร้าง Lead Scoring ได้สูงสุด 10 เคสเท่านั้น');
			}
			
		}
		// set the updated list to attribute (contactList) again   
		component.set("v.OrderList", RowItemList);
		// console.log('v.caseList: ',component.get('v.caseList'));
	}, 
    displayToast: function (component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
	},
	getScoringDetail: function (component, event, helper) {
		var recordId = component.get("v.scoringConId")
		
		if(recordId){
			var action = component.get("c.getConDetail");
			action.setParams({
				"recordId" : recordId
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if(state === 'SUCCESS')
				{	
					var result = response.getReturnValue();
					if(result.length > 0 ){
						component.set("v.OrderList", []);
					}
					var OrderList = component.get("v.OrderList");
					for(var i=0; i < result.length;i++){
						if(result[i].Priority__c == '998' ||result[i].Priority__c == '999'){
							OrderList.push({
							'rowIndex' : result[i].Priority__c,
							'inputrowIndex': result[i].Priority__c,
							'Operator': result[i].Operation__c,
							'Value1': result[i].Value1__c,
							'Value2': result[i].Value2__c,
							'Score': result[i].Score__c,
							'Id' : result[i].Id
							});
						}else{
							OrderList.push({
							'inputrowIndex': result[i].Priority__c,
							'Operator': result[i].Operation__c,
							'Value1': result[i].Value1__c,
							'Value2': result[i].Value2__c,
							'Score': result[i].Score__c,
							'Id' : result[i].Id
							});
						}
						
						
					}
					if((OrderList.length < 10) && (component.get("v.isEdit")) == false){
						OrderList.push({
						'Operator': '=',
						'Value1':'',
						'Value2':'',
						'Score':'',
						});
					}
					
					component.set("v.OrderList", OrderList);
					// console.log('state ' + state);
					component.set("v.loaded",false);
				}else{
					console.log('err ' + JSON.stringify(response.getError()));
					component.set("v.loaded",false);
				}
			});
			$A.enqueueAction(action);
		}else{
			// component.set("v.level1Rec.Total_Weight__c", 100);
		}
	},
})