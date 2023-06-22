({
	onInit : function(component, event, helper) {
		helper.showSpinner(component);
		var recordId = component.get("v.recordId");
		var cancelId = component.get("v.cancelId")
		var isEdit = component.get("v.isEdit");
		var opptyId = component.get("v.opptyid");
		var theme = component.get("v.theme");
		var accId = component.get("v.accid"); 
		var leadId = component.get("v.leadid");
		let width = screen.width;
		//alert('width :: '+ width);

		if(recordId){
			helper.getInvitee(component, event, helper);
			isEdit = true;
			component.set("v.isEdit",isEdit);
			component.set("v.Title","Edit Visit Plan / Report");
		}

		if( cancelId == '' && !isEdit && opptyId != ''){
			cancelId = opptyId;
			component.set("v.cancelId",cancelId);
		} else if (theme = 'Theme4t' && cancelId == '') {
			if(leadId){
				cancelId = leadId;
			} else if(accId){
				cancelId = accId;
			} 
			component.set("v.cancelId",cancelId);
		}
		// console.log('isEdit:',isEdit);
		// console.log('isLead:',component.get("v.isLead"));
	},
	addInvitee : function(component, event, helper) {
		var invitee = component.get("v.invitee");
		var recordId = component.get("v.recordId");
	
		invitee.push({'sobjectType':'Visit_Plan_Invitee__c','SEQ__c': invitee.length});

		component.set("v.invitee",invitee);
	}, 
	removeInvitee : function(component, event, helper) {
		var invitee = component.get("v.invitee");
		var index = event.getSource().get("v.value");
		invitee.splice(index, 1);
		for(var i = 0; i < invitee.length; i++){
			invitee[i].SEQ__c = i;
		}
		component.set("v.invitee",invitee);
	}, 
	handleSubmit : function(component, event, helper) {
		helper.showSpinner(component);

		event.preventDefault(); // Prevent default submit
		helper.handleFormSubmit(component,event,helper)


	},
	handleCancel : function(component, event, helper) {
		var idEdit = component.get("v.isEdit");
		var cancelId = component.get("v.cancelId")
		var recordId = component.get("v.recordId");
		var theme = component.get("v.theme");

		if(idEdit){
			helper.navigateToObject(component, event, helper,recordId);
		} else if( theme=="Theme4t" ){
            var navService = component.find('navService');
            navService.navigate({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/PreviousPage'
                }
            }, true);
        } else {
			helper.closeSubtab(component,event,helper);
		}
	},	
	handleSuccess: function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        if(recordId){
			helper.upsertInvitee(component,event,helper);
        }else{

			var payload = event.getParams().response;
			// console.log('Visit Plan Id:',payload.id);
			var oppid = component.get("v.opptyid");
			var action = component.get("c.insertVisitPlan");
			if(oppid){
				action.setParams({ visitplan : payload.id,
					invitee : component.get("v.invitee"),
					oppid : oppid});
			} else {
				action.setParams({ visitplan : payload.id,
					invitee : component.get("v.invitee")});
			} 
			
			action.setCallback(this, function(response) {
				helper.hideSpinner(component);
				helper.fireToast(component,event,helper,"Visit Plan / Report record has been create successfully.","success");
				// helper.refreshFocusedTab(component,event,helper);
				helper.navigateToObject(component,event,helper,payload.id);
			});
			$A.enqueueAction(action);

        }	
	},
	
    handleError: function (component, event, helper){
        component.set('v.spinner', false);
        var error = event.getParam("error");
        
        if((error != null ||error != '') && JSON.stringify(error) != '{}' && typeof(error) !='undefined'){
            var errorMap = error.body.output;
            // console.log(JSON.stringify(errorMap));
            var errorMessage = '';
            if(errorMap.errors.length>0){
                errorMessage=errorMap.errors[0].message;
            }else{
                for (var k in errorMap.fieldErrors) {
                    errorMessage=errorMap.fieldErrors[k][0].message;
                    break;
                }
            }
            
            errorMessage = errorMessage.replace('"', '').replace('"', '');
            // console.log(errorMessage);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: errorMessage,
                type: "error"
            });
            toastEvent.fire();
        }        
    },
	
	handleLoad: function (component, event, helper){
		helper.hideSpinner(component);
	},
	handleDateFormat: function (component, event, helper){
		// console.log("date change");
	},

})