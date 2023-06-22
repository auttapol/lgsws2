({
	openCXM:function (component, event, helper){
        var workspaceAPI = component.find("workspace");
        var CXM = component.get('v.CXMObj');
        var focustabId;
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            // console.log('tabId: ',response.tabId);
            focustabId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: focustabId,
                url: '/lightning/r/CXM_Survey__c/'+ CXM.Id +'/view',
                focus: true
            });
        }).catch(function (error) {
            console.log(error);
        });
	},
	onInit : function(component, event, helper){
		helper.getCXM(component, event,helper);
	}
})