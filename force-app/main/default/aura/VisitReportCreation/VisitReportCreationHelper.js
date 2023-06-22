({
    closeSubtab : function(component,event,helper){
        //close subtab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            ////console.log(error);
        });
    },
    getEditRecord: function(component,event,helper,editId){
        var action = component.get("c.getVisitReport");
        action.setParams({ 
            "editId": editId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                 var visitReport = response.getReturnValue();
                 component.set("v.visitReport",visitReport);
                 component.set("v.planId",visitReport.Visit_Plan_Report__c);
                 component.set("v.editId",visitReport.Id);
                 ////console.log(visitReport);
             }
         });
     $A.enqueueAction(action);
    },

    handleFormSubmit : function(component,event,helper,fields){
        var eventFields = event.getParam("fields");
        component.find('recordCreateForm').submit(eventFields);
       
    },
    setFocusedTabLabel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "New Visit Report"
            });
        })
        .catch(function(error) {
            ////console.log(error);
        });
    },

    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            var focusedTabId = JSON.parse(JSON.stringify(response));
            ////console.log(focusedTabId);
            for(var i=0;i<focusedTabId.length;i++){
                workspaceAPI.refreshTab({
                    tabId: focusedTabId[i].tabId,
                    includeAllSubtabs: true
                });
            }
        })
        .catch(function(error) {
            ////console.log(error);
        });
    },
    navigateToObject : function(component,event,helper,id) {
        var theme = component.get("v.theme");

        var navigateTo = $A.get("e.force:navigateToSObject");
        ////console.log(id);
        if( !id ){
            var cancelEvent = $A.get("e.force:navigateToObjectHome");
            cancelEvent.setParams({
                "scope": "Lead"
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
            navigateTo.setParams({
                "isredirect":true,
                "recordId": id,
                "slideDevName": "detail"
            });
            navigateTo.fire();

        }
        
    },
})