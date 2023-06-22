({
    Popup: function (component, event, helper) {
        var taskObj = component.get('v.taskObj');
        var phone = component.get('v.phone');

        var action = component.get('c.call_interfaceLightning');
        action.setParams({
            'encpData': phone,
            'taskEncpData': taskObj,
            'rmid': ''
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var response = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
                var navService = component.find("navService");
                if (response) {
                    var recordId = response[0].ACCOUNT_SF_ID ? response[0].ACCOUNT_SF_ID : response[0].LEAD_SF_ID;
                    var globalSearch = response[0].GLOBAL_SEARCH_VAL ? response[0].GLOBAL_SEARCH_VAL : '';
                    if (recordId) {
                        navService.navigate({
                            'type': 'standard__recordPage',
                            'attributes': {
                                'recordId': recordId,
                                'actionName': 'view'
                            }
                        }, false);
                    } else if (globalSearch) {
                        var objName;
                        if (response[0].GLOBAL_SEARCH_OBJ == '001') {
                            objName = 'Account';
                        } else if (response[0].GLOBAL_SEARCH_OBJ == '003') {
                            objName = 'Contact';
                        } else if (response[0].GLOBAL_SEARCH_OBJ == '00Q') {
                            objName = 'Lead';
                        } else {
                            objName = '';
                        }

                        var globalSearchurl = btoa(JSON.stringify({
                            'componentDef': 'forceSearch:searchPage',
                            'attributes': {
                                'term': globalSearch,
                                'scopeMap': objName ? {
                                    'name': objName,
                                } : {
                                    'type': 'TOP_RESULTS',
                                },
                                'context': {
                                    'disableSpellCorrection': false,
                                    'SEARCH_ACTIVITY': {
                                        'term': globalSearch
                                    }
                                },
                            }
                        }));
                        workspaceAPI.getAllTabInfo().then(function (response) {
                                var closeTabInfo = response.find(f => f.pageReference.attributes.name == "forceSearch:search" || f.pageReference.attributes.name == "forceSearch:searchPage");
                                if (closeTabInfo) {
                                    workspaceAPI.closeTab({
                                        tabId: closeTabInfo.tabId
                                    });
                                }
                                setTimeout(() => {
                                    workspaceAPI.openTab({
                                        url: '/one/one.app#' + globalSearchurl,
                                        focus: true
                                    });
                                }, 500);
                            })
                            .catch(function (error) {
                                // console.log(helper.parseObj(error));
                            });
                    }else{
                        var globalSearch = btoa(JSON.stringify({
                            'componentDef': 'forceSearch:searchPage',
                            'attributes': {
                                'term': '',
                                'scopeMap': {
                                    'type': 'TOP_RESULTS'
                                },
                                'context': {
                                    'disableSpellCorrection': false,
                                    'SEARCH_ACTIVITY': {
                                        'term': 'test'
                                    }
                                },
                            }
                        }));
    
                        workspaceAPI.getAllTabInfo().then(function (response) {
                            var closeTabInfo = response.find(f => f.pageReference.attributes.name == "forceSearch:search" || f.pageReference.attributes.name == "forceSearch:searchPage");
                            if (closeTabInfo) {
                                workspaceAPI.closeTab({
                                    tabId: closeTabInfo.tabId
                                });
                            }
                            
                            setTimeout(() => {
                                workspaceAPI.openTab({
                                    url: '/one/one.app#' + globalSearch,
                                    focus: true
                                });
                            }, 500);
                        })
                        .catch(function (error) {
                            // console.log(helper.parseObj(error));
                        });
                    }

                }else{
                    var globalSearch = btoa(JSON.stringify({
                        'componentDef': 'forceSearch:searchPage',
                        'attributes': {
                            'term': '',
                            'scopeMap': {
                                'type': 'TOP_RESULTS'
                            },
                            'context': {
                                'disableSpellCorrection': false,
                                'SEARCH_ACTIVITY': {
                                    'term': 'test'
                                }
                            },
                        }
                    }));

                    workspaceAPI.getAllTabInfo().then(function (response) {
                        var closeTabInfo = response.find(f => f.pageReference.attributes.name == "forceSearch:search" || f.pageReference.attributes.name == "forceSearch:searchPage");
                        if (closeTabInfo) {
                            workspaceAPI.closeTab({
                                tabId: closeTabInfo.tabId
                            });
                        }
                        
                        setTimeout(() => {
                            workspaceAPI.openTab({
                                url: '/one/one.app#' + globalSearch,
                                focus: true
                            });
                        }, 500);
                    })
                    .catch(function (error) {
                        // console.log(helper.parseObj(error));
                    });
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        if (taskObj && phone) {
            $A.enqueueAction(action);
        }
        component.set('v.taskObj', '');
        component.set('v.phone', '');
    }
})