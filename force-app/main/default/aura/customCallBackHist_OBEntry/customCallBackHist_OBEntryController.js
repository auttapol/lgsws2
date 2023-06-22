({
    
    toggleAcitivity : function(component, event, helper) {
        if(component.get('v.iconName') === 'utility:chevronright'){
            component.set('v.iconName', 'utility:chevrondown')
        }
        else{
            component.set('v.iconName', 'utility:chevronright')
        }
        // toggle 'slds-is-open' class to expand/collapse activity section
        $A.util.toggleClass(component.find('taskItemID'), 'slds-is-open');
    },
    goToTask : function(component, event, helper){

        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": component.get('v.activity.Id'),
                        "actionName": "view"
                    }
                }
            }).then(function(subtabId) {
                console.log("The new subtab ID is:" + subtabId);
            }).catch(function(error) {
                console.log("error");
            });
        });
    },
    goToUser : function(component, event, helper){

        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": component.get('v.activity.Owner.Id'),
                        "actionName": "view"
                    }
                }
            }).then(function(subtabId) {
                console.log("The new subtab ID is:" + subtabId);
            }).catch(function(error) {
                console.log("error");
            });
        });

    },
    handleMenuSelect : function(component, event, helper){
        var selectedMenu = event.detail.menuItem.get("v.value");

        switch(selectedMenu){
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": component.get("v.activity.Id")
                });
                editRecordEvent.fire();
        }

    }
})