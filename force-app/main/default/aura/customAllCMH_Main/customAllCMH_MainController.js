({
    onInit : function(component, event ,helper)
    {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:campaign_members",
                iconAlt: "Campaign_Members",
            });
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: $A.get('$Label.c.RTL_CampaignMemberHistory_TabTitle')
            });                      
       })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    handleViewUser : function(component, event, helper){
        console.log('viewUser', event.getParam('message'));
        
        let navService = component.find('navigation');
        navService.navigate({
            "type" : "standard__recordPage",
            "attributes": {
                "recordId"      : event.getParam('message'),
                "actionName"    : "view"
            }
        });
    }
})