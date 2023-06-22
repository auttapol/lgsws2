({
    setTabDetail : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            var focusedTabId = tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Home Loan Information"
            });

            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:campaign_members",
                iconAlt: "campaign_members"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})