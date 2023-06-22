({
    onInit: function (component, event, helper) {
        var device = helper.getDevice();

        if(device == "DESKTOP"){
            let workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                let focusedTabId = response.tabId;
                workspaceAPI
                    .setTabLabel({
                        tabId: focusedTabId,
                        label: "ผู้ดูแลลูกค้า BRC"
                    })
                    .then(function (response) {
                        workspaceAPI.setTabIcon({
                            icon: "standard:report",
                        });
                    })
            });
        }
        
    	
        helper.getReportId(component, event, helper);
        helper.getCurrentUser(component, event, helper);
			
    }
})