({
    init: function (component, event, helper) {
		var result;
		var recordId = component.get('v.recordId');
		var action = component.get('c.getQuestionList');
		action.setParams({
		      "recordId": recordId,
			});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS"){
				result =  response.getReturnValue();
				component.set('v.QuestionList',result);
			}
		});
		$A.enqueueAction(action);

	},
	
	navToRecDetail: function (component, event) {
		var id = event.target.id;

		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
			"recordId": id
		});
		navEvt.fire();

	},

	navToCreate: function (component, event, helper) {
		var recordId = component.get('v.recordId');
		var createQuestionEvent = $A.get("e.force:createRecord");
		var param = {
			"entityApiName": "Survey_Question__c",
			"defaultFieldValues": {
				'Survey_Version__c': recordId
			}	
		};
		createQuestionEvent.setParams(param);
		createQuestionEvent.fire();
	},
})