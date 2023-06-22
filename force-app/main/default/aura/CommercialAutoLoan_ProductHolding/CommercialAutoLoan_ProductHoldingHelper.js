({
    parseObj: function (obj) {
        return obj ? JSON.parse(JSON.stringify(obj)) : null;
    },
    doWorkspaceAPI: function (component, event, helper) {
        var tabName = 'Auto Loan';
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: tabName,
            });
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "standard:product",
                iconAlt: tabName,
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    checkDulplicatePage: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
                var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
                workspaceAPI.getTabInfo({
                    tabId: primaryTab
                }).then(function (response) {
                    var subTab = response.subtabs.filter(function (f) {
                        return f.pageReference.attributes.componentName == "c__CommercialAutoLoan_ProductHolding";
                    });
                    if (subTab.length > 1) {
                        workspaceAPI.focusTab({
                            tabId: subTab.find(function (f) {
                                return f;
                            }).tabId
                        });
                        workspaceAPI.closeTab({
                            tabId: tabId
                        });
                    }
                });
            })
            .catch(function (error) {
                console.log(helper.parseObj(error));
            });
    },
    getAccessibleCusHold: function (component, event, helper) {
        var action = component.get('c.getAccessibleCusHold');
        action.setParams({
            'accountId': component.get('v.recordId')
        });
        // action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (
                    result.isAccessibleCusHoldLow ||
                    result.isAccessibleCusHoldMid ||
                    result.isAccessibleCusHoldHig
                ) {
                    component.set('v.accessibleCusHold', result);
                } else {
                    component.set('v.error.message', $A.get('$Label.c.Data_Condition_NotAuthorizedMsg'));
                    component.set('v.error.state', true);
                }
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message)
                });
            }
        });
        $A.enqueueAction(action);
    },

})