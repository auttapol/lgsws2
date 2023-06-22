({
    getOpptyRecord: function (cmp, event, helper) {
        var RecordTypeID=cmp.get("v.recordTypeId");
        var VisitPlanID=cmp.get("v.visitplanID");
        var theme =cmp.get("v.theme");
        // console.log(cmp.get("v.recordTypeId"));
        var action = cmp.get(`c.getOppRec`);
    action.setParams({
        RecordTypeID: RecordTypeID,
        VisitPlanID: VisitPlanID
    });
    action.setCallback(this, function (response) {
        var state = response.getState();
        if (cmp.isValid() && state === 'SUCCESS') {
            var result = response.getReturnValue();
            // console.log(result);
            cmp.set("v.oppRecDefualt",result);
        } else {
            var errors = response.getError();
            errors.forEach(error => {
                // console.log(error.message);
            });
        }
    });
    $A.enqueueAction(action);
},

handleFormSubmit: function (cmp, event, helper) {
    var opportunity = cmp.get('v.oppRec');
    event.preventDefault();
    cmp.find('recordCreateForm').submit(opportunity);
},
navigateToObject : function(component,event,helper,id) {
    var theme = component.get("v.theme");
    var navigateTo = $A.get("e.force:navigateToSObject");
    if(theme == 'Theme4t'){
        navigateTo.setParams({
            "recordId": id,
            "slideDevName": "related"
        });
    } else {
        navigateTo.setParams({
            "recordId": id,
            "slideDevName": "detail"
        });
    }
    helper.closeSubtab(component,event,helper);
    navigateTo.fire();
    
    
},
closeSubtab: function (cmp, event, helper) {
    //close subtab
    var workspaceAPI = cmp.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        })
        .catch(function (error) {
            // console.log(error);
        });
},
fireToast : function(component,event,helper,message,type){
    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": "sticky",
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
        // console.log(focusedTabId[0].tabId);
        workspaceAPI.refreshTab({
                tabId: focusedTabId[0].tabId,
                includeAllSubtabs: true
        });
    })
    .catch(function(error) {
        // console.log(error);
    });
},


})