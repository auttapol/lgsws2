({
    getInvitee : function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getInvitee");
        action.setParams({ recordId : recordId});
        action.setCallback(this, function(response) {
            var invitee = response.getReturnValue();
            component.set("v.invitee",invitee);
            component.set("v.old_invitee",invitee);
        });
        $A.enqueueAction(action);
    },
    getOwnerId : function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getOwnerId");
        action.setParams({ recordId : recordId});
        action.setCallback(this, function(response) {
            var invitee = response.getReturnValue();
            component.set("v.invitee",invitee);
        });
        $A.enqueueAction(action);
    },
	navigateToObject : function(component,event,helper,id) {
        var theme = component.get("v.theme");

        var navigateTo = $A.get("e.force:navigateToSObject");
        // console.log(id);
        if( !id ){
            var cancelEvent = $A.get("e.force:navigateToObjectHome");
            cancelEvent.setParams({
                "scope": "Call_Report__c"
            });
            cancelEvent.fire();
        }
        else if(theme == 'Theme4t'){
            navigateTo.setParams({
                "recordId": id,
                "slideDevName": "related"
            });
            navigateTo.fire();
            
        } else {
            // console.log('ELSE');
            navigateTo.setParams({
                "isredirect":true,
                "recordId": id,
                "slideDevName": "detail"
            });
            navigateTo.fire();

        }
        
    },
    
    handleFormSubmit : function(component,event,helper){
        event.preventDefault(); // Prevent default submit
        var invitee = component.get("v.invitee");
        var eventFields = event.getParam("fields");
        helper.findDuplicates(component,event,helper,invitee,eventFields);
        
    },

    findDuplicates : function(component,event,helper,invitee,eventFields){
        var dup = [];
        var isOwner = false;
        var isDuplicate = false;
        var OwnerId = component.get("v.owner");
        var recordId = component.get("v.recordId");

        for(var i = 0; i < invitee.length; i++){
			var subset = invitee[i];
            if(dup.includes(subset.TMB_Person__c)){
                isDuplicate = true;
            } 
            if(subset.TMB_Person__c == OwnerId){
                isOwner = true;
            }

            if(subset.TMB_Person__c){
                dup.push(subset.TMB_Person__c);
            }
        }
        
        if(isDuplicate){
            helper.fireToast(component,event,helper,"TMB Counterparty must be unique.","error");
            helper.hideSpinner(component);
            // throw new Error("TMB Counterparty must be unique.");
        }
        if(isOwner){
            helper.fireToast(component,event,helper,"TMB Counterparty can not be Owner.","error");
            helper.hideSpinner(component);
            // throw new Error("TMB Counterparty can not be Owner.");
        }

        if( !isDuplicate && !isOwner ){

            eventFields["OwnerId"] = OwnerId;
            eventFields["RecordTypeId"] = eventFields["RecordTypeId"] ? eventFields["RecordTypeId"] : component.get("v.recordTypeId");

            if(recordId){
                // console.log(JSON.parse(JSON.stringify(eventFields)));
                component.find('recordCreateForm').submit(eventFields); 
            } else {
                eventFields["Customer_name__c"] = eventFields["Customer_name__c"] ? eventFields["Customer_name__c"] : component.get("v.accid");
                eventFields["Status__c"] = '1 - Open';
                delete eventFields.TMB_Person__c;
                component.find('recordCreateForm').submit();
            }
        }
        
    },
    upsertInvitee : function(component,event,helper){
        var invitee = component.get("v.invitee");
        var oldInvitee = component.get("v.old_invitee");
        var recordId = component.get("v.recordId");
        // console.log('invitee:',invitee);
        var action = component.get("c.updateInvitee");
        action.setParams({ invitee : invitee,
                            old_invitee : oldInvitee,
                        recordId : recordId});
        action.setCallback(this, function(response) {
            helper.fireToast(component,event,helper,"Visit Plan / Report record has been update successfully.","success");
            helper.refreshFocusedTab(component,event,helper);
            helper.navigateToObject(component,event,helper,recordId);    
        });
        $A.enqueueAction(action);
        
    },

    fireToast : function(component,event,helper,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": type+"!",
            "message": message
        });
        toastEvent.fire();
    },
    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            var focusedTabId = JSON.parse(JSON.stringify(response));
            
            for(var i=0;i<focusedTabId.length;i++){
                workspaceAPI.refreshTab({
                    tabId: focusedTabId[i].tabId,
                    includeAllSubtabs: true
                });
            }
        })
        .catch(function(error) {
            // console.log(error);
        });
    },
    showSpinner: function (component) {
        component.set("v.spinner", true);
    },
    hideSpinner: function (component) {
        component.set("v.spinner", false);
    },
    closeSubtab : function(component,event,helper){
        //close subtab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            // console.log(error);
        });
    },
})