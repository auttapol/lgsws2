({
    onInit: function (component, event, helper) {

    },
    handleEventccpageProxy: function (component, event, helper) {
        var verId = event.getParam('verifycode');
        var recordId = event.getParam('recordId');

        if(verId == 'ready'){
           	var popup = component.get('c.PopupCallBack');
            component.set('v.cceventmsg', verId);
            component.set('v.callbackId', recordId);
			$A.enqueueAction(popup);
    	}
    },
    PopupCallBack: function(component, event, helper){
        var serviceName = component.get('v.serviceNametmp');
        var cdata = component.get('v.cdatatmp');
		var callbackId = component.get('v.callbackId');
        
        var action = component.get('c.service_contactcenterLightning');

        action.setParams({
            'encpData': '',
            'taskEncpData': '',
            'rmid': '',
            'service': serviceName,
            'dataJson': cdata
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var response = response.getReturnValue();
                var workspaceAPI = component.find("workspace");

                if (response) {
                    if (response.length == 1 && response[0].sfidForTab != null && response[0].urlret != null) {
                        var appEvent = $A.get("e.c:ccpageProxyEvent");
                        var sfidForTab = response[0].sfidForTab;
                        var verf_hist_id = response[0].urlret ? response[0].urlret.split('?verf_hist_id=')[1] : '';
                        if(callbackId != '' && callbackId  != null && callbackId  != undefined && callbackId != sfidForTab) return;
                        workspaceAPI.getAllTabInfo().then(function (response) {
                            var tabInfo = response.find(f => f.pageReference.type == "standard__recordPage" && f.pageReference.attributes.recordId == sfidForTab);

                            if (tabInfo) {
                                workspaceAPI.focusTab({
                                    tabId: tabInfo.tabId
                                }).then(function (response) {
                                    appEvent.setParams({
                                        'recordId': sfidForTab,
                                        'verifycode': verf_hist_id,
                                    });
                                    appEvent.fire();
                                });
                                
                                
                            } else {
                                workspaceAPI.openTab({
                                    pageReference: {
                                        "type": "standard__recordPage",
                                        'attributes': {
                                            'recordId': sfidForTab,
                                            'objectApiName': 'Account',
                                            'actionName': 'view'
                                        },
                                    },
                                    focus: true
                                }).then(function (response) {
                                    component.set('v.serviceNametmp', serviceName);
                                    component.set('v.cdatatmp', cdata);
                                }).catch(function (error) {
                                    console.log(helper.parseObj(error));
                                });
                            }
                        });
                    }
                }
            } else {
                console.log('ERROR');
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });

        if(serviceName && cdata){
           $A.enqueueAction(action); 
        }
        component.set('v.serviceNametmp', '');
        component.set('v.cdatatmp', '');
    },
    Popup: function (component, event, helper) {
        var serviceName = component.get('v.serviceName');
        var cdata = component.get('v.cdata');
        component.set('v.serviceNametmp', '');
        component.set('v.cdatatmp', '');
        
        serviceName = serviceName === undefined ? '' : serviceName;
        cdata = cdata === undefined ? '' : cdata;

        var action = component.get('c.service_contactcenterLightning');

        action.setParams({
            'encpData': '',
            'taskEncpData': '',
            'rmid': '',
            'service': serviceName,
            'dataJson': cdata
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var response = response.getReturnValue();
                var workspaceAPI = component.find("workspace");

                if (response) {
                    if (response.length == 1 && response[0].sfidForTab != null && response[0].urlret != null) {
                        var appEvent = $A.get("e.c:ccpageProxyEvent");
                        var sfidForTab = response[0].sfidForTab;
                        var verf_hist_id = response[0].urlret ? response[0].urlret.split('?verf_hist_id=')[1] : '';
                        workspaceAPI.getAllTabInfo().then(function (response) {
                            var tabInfo = response.find(f => f.pageReference.type == "standard__recordPage" && f.pageReference.attributes.recordId == sfidForTab);

                            if (tabInfo) {
                                workspaceAPI.focusTab({
                                    tabId: tabInfo.tabId
                                }).then(function (response) {
                                    appEvent.setParams({
                                        'recordId': sfidForTab,
                                        'verifycode': verf_hist_id,
                                    });
                                    appEvent.fire();
                                });                                
                            } else {
                                component.set('v.serviceNametmp', serviceName);
                                component.set('v.cdatatmp', cdata);
                                workspaceAPI.openTab({
                                    pageReference: {
                                        "type": "standard__recordPage",
                                        'attributes': {
                                            'recordId': sfidForTab,
                                            'objectApiName': 'Account',
                                            'actionName': 'view'
                                        },
                                    },
                                    focus: true
                                }).then(function (response) {
                                    
                                }).catch(function (error) {
                                    console.log(helper.parseObj(error));
                                });
                            }
                        });
                    } else if (response.length == 1 && response[0].ACCOUNT_SF_ID != null) {
                        var sfidForTab = response[0].ACCOUNT_SF_ID;

                        component.find("navService").navigate({
                            'type': 'standard__recordPage',
                            'attributes': {
                                'recordId': sfidForTab,
                                'objectApiName': 'Account',
                                'actionName': 'view'
                            }
                        }, false);

                    } else if (response.length == 1 && response[0].LEAD_SF_ID != null) {
                        var sfidForTab = response[0].LEAD_SF_ID;
                        
                        component.find("navService").navigate({
                            'type': 'standard__recordPage',
                            'attributes': {
                                'recordId': sfidForTab,
                                'objectApiName': 'Lead',
                                'actionName': 'view'
                            }
                        }, false);
                    } else if (response.length > 0 && response[0].GLOBAL_SEARCH_VAL != undefined) {
                        if (response[0].GLOBAL_SEARCH_OBJ != undefined) {
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

                            var globalSearch = btoa(JSON.stringify({
                                'componentDef': 'forceSearch:searchPage',
                                'attributes': {
                                    'term': response ? response[0].GLOBAL_SEARCH_VAL : '',
                                    'scopeMap': {
                                        'name': objName,
                                    },
                                    'context': {
                                        'disableSpellCorrection': false,
                                        'SEARCH_ACTIVITY': {
                                            'term': response ? response[0].GLOBAL_SEARCH_VAL : ''
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


                        } else {
                            var globalSearch = btoa(JSON.stringify({
                                'componentDef': 'forceSearch:searchPage',
                                'attributes': {
                                    'term': response ? response[0].GLOBAL_SEARCH_VAL : '',
                                    'scopeMap': {
                                        'type': 'TOP_RESULTS',
                                    },
                                    'context': {
                                        'disableSpellCorrection': false,
                                        'SEARCH_ACTIVITY': {
                                            'term': response ? response[0].GLOBAL_SEARCH_VAL : ''
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
                                        'term': ''
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
                                    'term': ''
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
                console.log('ERROR');
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });

        if(serviceName && cdata){
           $A.enqueueAction(action); 
        }

        component.set('v.serviceName', '');
        component.set('v.cdata', '');
    }
})