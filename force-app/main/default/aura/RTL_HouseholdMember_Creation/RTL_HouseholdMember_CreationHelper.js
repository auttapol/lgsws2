({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },
    displayToast: function (type, title, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    doWorkspaceAPI: function (component) {
        var tabName = component.get('v.householdMemberId') ? component.get('v.householdMemberId') : `${$A.get('$Label.c.RTL_New_Member')}`;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: tabName,
            });
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "custom:custom1",
                iconAlt: tabName,
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    refreshTab: function (component, flag) {
        var helper = this;
        var {
            isClose,
        } = flag;
        var workspaceAPI = component.find("workspace");
        setTimeout(() => {
            workspaceAPI.refreshTab({
                tabId: component.get('v.tabId'),
                includeAllSubtabs: false
            });
            if (isClose) {
                helper.closeTab(component);
            }
        }, 500);
    },
    closeTab: function (component) {
        if (component.get('v.theme') == 'Theme4t' || component.get('v.theme') == 'Theme4u') {
            var navService = component.find('navService');
            navService.navigate({
                type: 'standard__recordPage',
                attributes: {
                    recordId: component.get('v.householdId'),
                    objectApiName: 'RTL_Household__c',
                    actionName: 'view'
                },
            }, true);
        } else {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                    workspaceAPI.focusTab({
                        tabId: component.get('v.tabId')
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
        }
    },
})