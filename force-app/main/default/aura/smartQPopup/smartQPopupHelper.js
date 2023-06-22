({
    closeStartTab: function(component, event){
        // Close first open tab.
        var workspaceAPI = component.find("workspace");
        setTimeout(() => {
            workspaceAPI.getAllTabInfo().then(function (res) {
                var closeTabInfo = res.find(f => f.pageReference.attributes.componentName == "c__smartQPopup");
                if (closeTabInfo) {
                    workspaceAPI.closeTab({
                        tabId: closeTabInfo.tabId
                    });
                }
            })}, 3000)
    },
})