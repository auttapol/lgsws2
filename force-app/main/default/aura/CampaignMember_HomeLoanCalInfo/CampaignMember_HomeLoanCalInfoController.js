({
    onInit : function(component, event, helper) {
        var pageRef = component.get('v.pageReference');
        
        component.set('v.campaignMemberId', pageRef.state.c__campaignMemberId ? pageRef.state.c__campaignMemberId : '');
        component.set('v.leadId', pageRef.state.c__leadId ? pageRef.state.c__leadId : '');
        component.set('v.isLoading', false);
        
        helper.setTabDetail(component, event, helper);
    },
    
    close : function(component){
        var workspaceAPI = component.find('workspace');
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
})