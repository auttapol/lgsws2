({
    showToast: function (type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    refreshFocusedTab: function (component, event, helper) {
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function (response) {
        //         var focusedTabId = response.tabId;
        //         workspaceAPI.refreshTab({
        //             tabId: focusedTabId,
        //             includeAllSubtabs: true
        //         });
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire()
            // })
            // .catch(function (error) {
            //     console.log(error);
            // });
    }
})