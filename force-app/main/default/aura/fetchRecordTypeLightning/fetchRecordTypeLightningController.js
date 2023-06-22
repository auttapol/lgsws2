({
    onInit: function (component, event, helper) {
        helper.setOnInit(component, event, helper);
    },
    onPageReferenceChange: function (component, event, helper) {
        helper.setOnInit(component, event, helper);
    },
    onChangeRadioRecordType: function (component, event, helper) {
        var cmp = event.getSource();
        component.set('v.recordTypeId', cmp.get('v.value'));
    },
    closeTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var navService = component.find('navService');

        if ((component.get('v.theme') != 'Theme4t') && ((component.get('v.theme') == 'Theme4u' && $A.get("$Browser").isDesktop))) {
            //Close tab for desktop.
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                })
                .catch(function (error) {
                    // console.log(error);
                });
        } else {
            //Close tab for salesforce app.
            event.preventDefault();
            helper.clearCache(component);
            navService.navigate({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/PreviousPage'
                }
            }, true);
        }
    },
    onFireCreateRecord: function (component, event, helper) {
        event.preventDefault();
        helper.fireCreateRecord(component);
    },

})