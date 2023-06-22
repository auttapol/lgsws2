({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    doWorkspaceAPIforVF: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var navService = component.find("navService");
        var navigationItemAPI = component.find("navigationItemAPI");

        var pageReference = component.get('v.pageReference');
        var _action = component.get('v.action') ? component.get('v.action') : pageReference.state.c__action;
        var _recordId = component.get('v.recordId') ? component.get('v.recordId') : pageReference.state.c__recordId;
        var _url = component.get('v.url') ? component.get('v.url') : pageReference.state.c__url;
        var _replace = component.get('v.replace') ? component.get('v.replace') : pageReference.state.c__replace;
        var _force = component.get('v.force') ? component.get('v.force') : pageReference.state.c__force;
        var _parentTabId = component.get('v.tabId') ? component.get('v.tabId') : pageReference.state.c__tabId;
        var _pageRef = component.get('v.pageRef') ? component.get('v.pageRef') : pageReference.state.c__pageRef;

        workspaceAPI.getEnclosingTabId().then(function (tabId) {
                var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
                workspaceAPI.getTabInfo({
                    tabId: primaryTab
                }).then(function (response) {

                    if (_action == 'openTabUrl') {
                        navService.navigate({
                            type: "standard__webPage",
                            attributes: {
                                url: _url
                            }
                        }, _replace);
                    } else if (_action == 'openTabPageRef') {
                        navService.navigate(_pageRef, _replace);
                    } else if (_action == 'openTabPrimaryUrl') {
                        workspaceAPI.openConsoleURL({
                                url: _url,
                                focus: true
                            }).then(function (response) {
                                workspaceAPI.closeTab({
                                    tabId: _replace ? primaryTab : tabId
                                });
                            })
                            .catch(function (error) {
                                console.log(error);
                            });
                    } else if (_action == 'openSubTabUrl') {
                        workspaceAPI.openSubtab({
                            parentTabId: primaryTab,
                            url: _url,
                            focus: true
                        });
                    } else if (_action == 'closeAndRefresh') {
                        if (response.recordId == _recordId && !response.isSubtab) {
                            workspaceAPI.refreshTab({
                                tabId: primaryTab,
                                includeAllSubtabs: false
                            });
                        }

                        var subtabs = response.subtabs.filter(f => f.pageReference.attributes.recordId == _recordId);
                        subtabs.forEach(e => {
                            workspaceAPI.refreshTab({
                                tabId: e.tabId,
                                includeAllSubtabs: false
                            });
                        })

                        setTimeout(() => {
                            workspaceAPI.closeTab({
                                tabId: tabId
                            });
                            if (_force) {
                                $A.get('e.force:refreshView').fire();
                            }
                        }, 250);
                    } else if (_action == 'openTabUrlWithTabId') {
                        workspaceAPI.openSubtab({
                            parentTabId: _parentTabId,
                            url: _url,
                            focus: true
                        });
                        workspaceAPI.closeTab({
                            tabId: tabId
                        });
                    } else if (_action == 'focusTabByUrl') {
                        workspaceAPI.getAllTabInfo().then(function (response) {
                                var focusInfo = response.find(f => f.url.includes(_url));
                                if (focusInfo) {
                                    workspaceAPI.focusTab({
                                        tabId: focusInfo.tabId
                                    });
                                }
                                setTimeout(() => {
                                    workspaceAPI.closeTab({
                                        tabId: tabId
                                    });
                                }, 250);
                            })
                            .catch(function (error) {
                                console.log(error);
                            });
                    } else if (_action == 'closeAndFocusNavigationItem') {
                        navigationItemAPI.focusNavigationItem().then(function (response) {
                                setTimeout(() => {
                                    workspaceAPI.closeTab({
                                        tabId: tabId
                                    });
                                }, 250);
                            })
                            .catch(function (error) {
                                console.log(error);
                            });
                    } else if (_action == 'refreshNavigationItemAndFocusItem') {
                        setTimeout(() => {
                            if (navigationItemAPI) {
                                navigationItemAPI.refreshNavigationItem().then(function (response) {
                                        navigationItemAPI.focusNavigationItem().then(function (response) {
                                            setTimeout(() => {
                                                workspaceAPI.closeTab({
                                                    tabId: tabId
                                                });
                                            }, 250);
                                        }).catch(function (error) {
                                            console.log(error);
                                        })
                                    })
                                    .catch(function (error) {
                                        console.log(error);
                                    });
                            }
                        }, 250);
                    } else {
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
})