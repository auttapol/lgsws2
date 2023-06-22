({
    onInit : function(component, event, helper) {
        var encTMBID = component.get("v.pageReference").state.c__key;
        var encPhoneNo = component.get("v.pageReference").state.c__val;
        var queueNo = component.get("v.pageReference").state.c__val2;
        var branchCode = component.get("v.pageReference").state.c__val3;

        encTMBID = encTMBID === undefined ? '' : encTMBID;
        encPhoneNo = encPhoneNo === undefined ? '' : encPhoneNo;
        queueNo = queueNo === undefined ? '' : queueNo;
        branchCode = branchCode === undefined ? '' : branchCode;

        component.set('v.encTMBID', encTMBID);
        component.set('v.encPhoneNo', encPhoneNo);
        component.set('v.queueNo', queueNo);
        component.set('v.branchCode', branchCode);

        console.log('encTMBID: ' + encTMBID);
        console.log('encPhoneNo: ' + encPhoneNo);

        var action = component.get('c.getKeyValueForNewVersionLightning');

        action.setParams({
            'encTMBID': encTMBID,
            'encPhoneNo': encPhoneNo,
            'queueNo': queueNo,
            'branchCode': branchCode
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var response = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
                console.log('response::');
                console.log(response);

                if(response){
                    // if (response.length == 1 && response.sfidForTab != null && response.urlret != null) {
                    //     console.log('response case1');
                    //     var sfidForTab = response.sfidForTab;
                    //     var verf_hist_id = response.urlret ? response.urlret.split('?verf_hist_id=')[1] : '';
                    //     component.find("navService").navigate({
                    //         'type': 'standard__recordPage',
                    //         'attributes': {
                    //             'recordId': sfidForTab,
                    //             'objectApiName': 'Account',
                    //             'actionName': 'view'
                    //         },
                    //         'state': {
                    //             'c__vercode': verf_hist_id
                    //         }
                    //     }, false);
                    // }else if 
                    if (response.ACCOUNT_SF_ID != null) {
                        var sfidForTab = response.ACCOUNT_SF_ID;
                        component.find("navService").navigate({
                            'type': 'standard__recordPage',
                            'attributes': {
                                'recordId': sfidForTab,
                                'objectApiName': 'Account',
                                'actionName': 'view'
                            }
                        }, false);
                    }else if (response.LEAD_SF_ID != null) {
                        var sfidForTab = response.LEAD_SF_ID;
                        component.find("navService").navigate({
                            'type': 'standard__recordPage',
                            'attributes': {
                                'recordId': sfidForTab,
                                'objectApiName': 'Lead',
                                'actionName': 'view'
                            }
                        }, false);
                    }else if (response.GLOBAL_SEARCH_VAL != undefined) {
                        if (response.GLOBAL_SEARCH_OBJ != undefined) {
                            var objName;

                            if(response.GLOBAL_SEARCH_OBJ == '001'){
                                objName = 'Account';
                            }
                            // else if(response.GLOBAL_SEARCH_OBJ == '003'){
                            //     objName = 'Contact';
                            // }
                            else if(response.GLOBAL_SEARCH_OBJ == '00Q'){
                                objName = 'Lead';
                            }else{
                                objName = '';
                            }

                            var globalSearch = btoa(JSON.stringify({
                                'componentDef': 'forceSearch:searchPage',
                                'attributes': {
                                    'term': response ? response.GLOBAL_SEARCH_VAL : '',
                                    'scopeMap': {
                                        'name': objName,
                                    },
                                    'context': {
                                        'disableSpellCorrection': false,
                                        'SEARCH_ACTIVITY': {
                                            'term': response ? response.GLOBAL_SEARCH_VAL : ''
                                        }
                                    },
                                }
                            }));

                            workspaceAPI.getAllTabInfo().then(function (res) {
                                var closeTabInfo = res.find(f => f.pageReference.attributes.name == "forceSearch:search" || f.pageReference.attributes.name == "forceSearch:searchPage");
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
                        }else {
                            // console.log('response case4 without obj name');
                            var globalSearch = btoa(JSON.stringify({
                                'componentDef': 'forceSearch:searchPage',
                                'attributes': {
                                    'term': response ? response.GLOBAL_SEARCH_VAL : '',
                                    'scopeMap': {
                                        'type': 'TOP_RESULTS',
                                    },
                                    'context': {
                                        'disableSpellCorrection': false,
                                        'SEARCH_ACTIVITY': {
                                            'term': response ? response.GLOBAL_SEARCH_VAL : ''
                                        }
                                    },
                                }
                            }));

                            workspaceAPI.getAllTabInfo().then(function (res) {
                                var closeTabInfo = res.find(f => f.pageReference.attributes.name == "forceSearch:search" || f.pageReference.attributes.name == "forceSearch:searchPage");
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
                    }else {
                        // console.log('response case5');
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
                        workspaceAPI.getAllTabInfo().then(function (res) {
                            var closeTabInfo = res.find(f => f.pageReference.attributes.name == "forceSearch:search" || f.pageReference.attributes.name == "forceSearch:searchPage");
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
                    // console.log('response null');
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

                    workspaceAPI.getAllTabInfo().then(function (res) {
                        var closeTabInfo = res.find(f => f.pageReference.attributes.name == "forceSearch:search" || f.pageReference.attributes.name == "forceSearch:searchPage");
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

            helper.closeStartTab(component);
        });

        $A.enqueueAction(action);

        component.set('v.encTMBID', '');
        component.set('v.encPhoneNo', '');
        component.set('v.queueNo', '');
        component.set('v.branchCode', '');
    },
})