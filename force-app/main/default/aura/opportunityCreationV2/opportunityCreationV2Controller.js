({
    doInit: function(cmp, event, helper) {
        // console.log(cmp.get("v.recordTypeId"));
        var recordId = cmp.get("v.recordId");
        var theme = cmp.get("v.theme");
        helper.getOpptyRecord(cmp, event, helper);
        // console.log("oppRec.AccountId "+cmp.get("v.oppRec.AccountId"));
    },


    handleSubmit : function(cmp, event, helper) {
        event.preventDefault(); // Prevent default submit
        helper.handleFormSubmit(cmp,event,helper)
    },

    handleCancel : function(cmp, event, helper) {
		var idEdit = cmp.get("v.isEdit");
		var cancelId = cmp.get("v.visitplanID")
        helper.navigateToObject(cmp, event, helper,cancelId);
    },	

    handleSuccess: function(cmp, event, helper) {
        //helper.closeSubtab(cmp,event,helper);
        // Show toast
        var recordId = cmp.get("v.recordId");
        if(recordId){
			helper.upsertInvitee(cmp,event,helper);
			// console.log('update success ja');
        }else{

			var payload = event.getParams().response;
            // console.log('Oppty Id:',payload.id);
			// console.log('Visit Plan Id2:',cmp.get("v.visitplanID"));
            var VisitPlanID = cmp.get("v.visitplanID");
			var action = cmp.get("c.insertToVisitPlan");
			if(VisitPlanID){
				action.setParams({ 
                    oppRecID : payload.id,
                    VisitPlanID : VisitPlanID});
			} else {
				action.setParams({ VisitPlanID : VisitPlanID});
			} 
			
			action.setCallback(this, function(response) {
				helper.fireToast(cmp,event,helper,"Opportunity record has been create successfully.","success");
				helper.refreshFocusedTab(cmp,event,helper);
				helper.navigateToObject(cmp,event,helper,payload.id);
			});
			$A.enqueueAction(action);
        }
   		
    },

    showSpinner: function(cmp, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        cmp.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(cmp,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        cmp.set("v.spinner", false);
    },
})