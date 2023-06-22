({
    onInit: function (component, event, helper) {
        var cmpTarget = component.find('status');
        var action = component.get('c.initAgentId');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log(response.getReturnValue());
                var initData = response.getReturnValue();
                if(initData)
                {
                    var agentId = initData.AgentId;
                    var eventName = initData.EventName;
                    var permission = initData.Permission;
                    if(permission)
                    {
                        component.set('v.agentId', agentId);
                        component.set('v.channel','/topic/'+eventName+'?Employee_ID__c='+agentId+'');
                        helper.subscribeEvent(component, event, helper, agentId);
                    }
                    else
                    {
                        $A.util.addClass(cmpTarget, 'icon-status-offline');
                    }
                }
                else
                {
                
                    $A.util.addClass(cmpTarget, 'icon-status-offline');
                }
                // component.set('v.userId', response.getReturnValue());
                // const empApi = component.find('empApi');

                // empApi.onError($A.getCallback(error => {
                //     // Error can be any type of error (subscribe, unsubscribe...)
                //     console.error('EMP API error: ', error);
                //     if (!error.successful) {
                //         helper.unsubscribe(component, event, helper)
                //             .then($A.getCallback(function () {
                //                 return helper.subscribeEvent(component, event, helper, response.getReturnValue());
                //             }));
                //     }
                // }));

                
            } else {
                console.log(state);
                $A.util.addClass(cmpTarget, 'icon-status-offline');
            }
        });

        $A.enqueueAction(action);

    },

    handleEventccpageProxy: function (component, event, helper) {
        console.log('customPopupUtility:handleEventccpageProxy');
        
        component.set('v.step', component.get('v.step') + '2:');
        var verId = event.getParam('verifycode');
        var recordId = event.getParam('recordId');

        if (verId == 'ready') {
            var popup = component.get('c.PopupCallBack');
            component.set('v.vercode', verId);
            component.set('v.callbackId', recordId);
            $A.enqueueAction(popup);
        }
    },

    PopupCallBack: function (component, event, helper) {
        console.log('customPopupUtility:PopupCallBack');
        component.set('v.step', component.get('v.step') + '3:');
        var serviceName = component.get('v.serviceNametmp');
        var cdata = component.get('v.cdatatmp');
        var callbackId = component.get('v.callbackId');

        var action = component.get('c.service_contactcenterLightning');
        console.log('cdatatmp:', cdata);
        console.log('serviceName:', serviceName);
        var dataJson = {
            "Call_ID__c": cdata.Call_ID__c,
            "Employee_ID__c": cdata.Employee_ID__c,
            "Extension_Number__c": cdata.Agent_Extension_Number__c ? cdata.Agent_Extension_Number__c.toString() : null,
            "TMB_Cust_ID__c": cdata.TMB_Cust_ID__c ? cdata.TMB_Cust_ID__c.toString() : null,
            "Phone_Number__c": cdata.Call_Number__c,
            "Xfer__c": cdata.Xfer__c ? cdata.Xfer__c.toString() : null,
            "Verification_Status__c": cdata.Verification_Status__c ? cdata.Verification_Status__c.toString() : null,
            "Verification_Type__c": cdata.Verification_Type__c ? cdata.Verification_Type__c.toString() : null,
            "Verification_Result__c": cdata.Verification_Result__c ? cdata.Verification_Result__c.toString() : null,
            "Verification_Action__c": cdata.Verification_Action__c ? cdata.Verification_Action__c.toString() : null,
            "Verification_Date_Time__c": cdata.Verification_Date__c ? cdata.Verification_Date__c.toString() : null,
            "Fail_Reason__c": cdata.Fail_Reason__c ? cdata.Fail_Reason__c.toString() : null,
            "Customer_Type__c": cdata.Customer_Type__c ? cdata.Customer_Type__c.toString() : null,
        };

        var call_start;
        var msLogId;
        if (cdata.Call_Start__c != null) {
            call_start = cdata.Call_Start__c.replace('T', ' ');
            call_start = call_start.replace('Z', '');
            msLogId = cdata.Call_ID__c + call_start;
        }

        action.setParams({
            'service': serviceName,
            'dataJson': JSON.stringify(dataJson),
            'taskId': cdata.Task_ID__c ? cdata.Task_ID__c.toString() : null,
            'msLogId': msLogId
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
                        component.set('v.sfidForTab', sfidForTab);
                        var verf_hist_id = response[0].urlret ? response[0].urlret.split('?verf_hist_id=')[1] : '';
                        if (callbackId != '' && callbackId != null && callbackId != undefined && callbackId != sfidForTab) return;
                        workspaceAPI.getAllTabInfo().then(function (response) {
                            var tabInfo = response.find(f => f.pageReference.type == "standard__recordPage" && f.pageReference.attributes.recordId == sfidForTab);
                            console.log('tabInfo :: ' + JSON.stringify(tabInfo));
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
                                        // 'state': {
                                        //     'c__vercode': verf_hist_id
                                        // }
                                    },
                                    focus: true
                                }).then(function (response) {
                                    // component.set('v.serviceNametmp', serviceName);
                                    // component.set('v.cdatatmp', cdata);
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

        if (serviceName && cdata) {
            component.set('v.step', component.get('v.step') + 'X:');
            $A.enqueueAction(action);
        }
        // component.set('v.serviceNametmp', '');
        // component.set('v.cdatatmp', '');
    },

    Popup: function (component, event) {
        console.log('customPopupUtility:Popup');
        var serviceName = component.get('v.serviceName');
        var cdata = component.get('v.cdata');
        component.set('v.serviceNametmp', '');
        component.set('v.cdatatmp', '');
        component.set('v.step', '1:');

        serviceName = serviceName === undefined ? '' : serviceName;
        cdata = cdata === undefined ? '' : cdata;

        console.log('service: ' + serviceName);
        console.log('cdata: ' + cdata);

        var action = component.get('c.service_contactcenterLightning');

        var dataJson = {
            "Call_ID__c": cdata.Call_ID__c,
            "Employee_ID__c": cdata.Employee_ID__c,
            "Extension_Number__c": cdata.Agent_Extension_Number__c ? cdata.Agent_Extension_Number__c.toString() : null,
            "TMB_Cust_ID__c": cdata.TMB_Cust_ID__c ? cdata.TMB_Cust_ID__c.toString() : null,
            "Phone_Number__c": cdata.Call_Number__c,
            "Xfer__c": cdata.Xfer__c ? cdata.Xfer__c.toString() : null,
            "Verification_Status__c": cdata.Verification_Status__c ? cdata.Verification_Status__c.toString() : null,
            "Verification_Type__c": cdata.Verification_Type__c ? cdata.Verification_Type__c.toString() : null,
            "Verification_Result__c": cdata.Verification_Result__c ? cdata.Verification_Result__c.toString() : null,
            "Verification_Action__c": cdata.Verification_Action__c ? cdata.Verification_Action__c.toString() : null,
            "Verification_Date_Time__c": cdata.Verification_Date__c ? cdata.Verification_Date__c.toString() : null,
            "Fail_Reason__c": cdata.Fail_Reason__c ? cdata.Fail_Reason__c.toString() : null,
            "Customer_Type__c": cdata.Customer_Type__c ? cdata.Customer_Type__c.toString() : null,
        };

        var call_start;
        var msLogId;
        if (cdata.Call_Start__c != null) {
            call_start = cdata.Call_Start__c.replace('T', ' ');
            call_start = call_start.replace('Z', '');
            msLogId = cdata.Call_ID__c + call_start;

            console.log(cdata.Task_ID__c.toString());
            console.log(msLogId);
        }



        action.setParams({
            'service': serviceName,
            'dataJson': JSON.stringify(dataJson),
            'taskId': cdata.Task_ID__c ? cdata.Task_ID__c.toString() : null,
            'msLogId': msLogId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var response = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
                console.log('response::', response);
                // console.log(JSON.stringify(response));

                // console.log(response[0].sfidForTab);
                console.log(response);

                if (response) {
                    if (response.length == 1 && response[0].sfidForTab != null && response[0].urlret != null) {
                        console.log('response case1');
                        component.set('v.responseCase', 'case 1');
                        // var sfidForTab = response[0].sfidForTab;
                        // var verf_hist_id = response[0].urlret ? response[0].urlret.split('?verf_hist_id=')[1] : '';
                        // console.log('verf_hist_id:',verf_hist_id);
                        // component.find("navService").navigate({
                        //     'type': 'standard__recordPage',
                        //     'attributes': {
                        //         'recordId': sfidForTab,
                        //         'objectApiName': 'Account',
                        //         'actionName': 'view'
                        //     },
                        //     'state': {
                        //         'c__vercode': verf_hist_id
                        //     }
                        // }, false);
                        var appEvent = $A.get("e.c:ccpageProxyEvent");
                        console.log('appEvent --> ' + appEvent);
                        var sfidForTab = response[0].sfidForTab;
                        component.set('v.sfidForTab', sfidForTab);
                        var verf_hist_id = response[0].urlret ? response[0].urlret.split('?verf_hist_id=')[1] : '';
                        console.log('verf_hist_id:', verf_hist_id);
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
                                        // 'state': {
                                        //             'c__vercode': verf_hist_id
                                        //         }
                                    },
                                    focus: true
                                }).then(function (response) {

                                }).catch(function (error) {
                                    console.log(helper.parseObj(error));
                                });
                            }
                        });
                    } else if (response.length == 1 && response[0].ACCOUNT_SF_ID != null) {
                        console.log('response case2 ACCOUNT');
                        component.set('v.responseCase', 'case 2');
                        var sfidForTab = response[0].ACCOUNT_SF_ID;
                        component.set('v.sfidForTab', sfidForTab);
                        component.find("navService").navigate({
                            'type': 'standard__recordPage',
                            'attributes': {
                                'recordId': sfidForTab,
                                'objectApiName': 'Account',
                                'actionName': 'view'
                            }
                        }, false);

                    } else if (response.length == 1 && response[0].LEAD_SF_ID != null) {
                        console.log('response case3 LEAD');
                        component.set('v.responseCase', 'case 3');
                        var sfidForTab = response[0].LEAD_SF_ID;
                        component.set('v.sfidForTab', sfidForTab);
                        component.find("navService").navigate({
                            'type': 'standard__recordPage',
                            'attributes': {
                                'recordId': sfidForTab,
                                'objectApiName': 'Lead',
                                'actionName': 'view'
                            }
                        }, false);

                    } else if (response.length > 0 && response[0].GLOBAL_SEARCH_VAL != undefined) {
                        console.log('response case4');
                        component.set('v.responseCase', 'case 4');
                        component.set('v.sfidForTab', 'Multi');
                        if (response[0].GLOBAL_SEARCH_OBJ != undefined) {
                            // console.log('response case4 with obj name');
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
                                        // 'type': 'TOP_RESULTS',
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
                            console.log('response case4 without obj name');
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
                        console.log('response case5');
                        component.set('v.responseCase', 'case 5');
                        component.set('v.sfidForTab', 'N/A');
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

                    console.log('response null');
                    var globalSearch = btoa(JSON.stringify({
                        'componentDef': 'forceSearch:searchPage',
                        'attributes': {
                            'term': cdata.TMB_Cust_ID__c,
                            'scopeMap': {
                                'type': 'TOP_RESULTS'
                            },
                            'context': {
                                'disableSpellCorrection': false,
                                'SEARCH_ACTIVITY': {
                                    'term': cdata.TMB_Cust_ID__c
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

        $A.enqueueAction(action);

        // component.set('v.serviceName', '');
        // component.set('v.cdata', '');
    },
    Transfer: function (component, event, helper) {
        // console.log('transfer');
        // console.log(component.get('v.transfer_data'));

        // console.log(component.get('v.transfer_data').Task_ID__c);
        // var taskId = component.get('v.transfer_data').Task_ID__c;

    //     var workspaceAPI = component.find("workspace");
    //     workspaceAPI.getAllTabInfo().then(function(response) {
    //         console.log(response);
    //    })
    //     .catch(function(error) {
    //         console.log(error);
    //     });


        var action = component.get('c.getAccountByTask');
        action.setParams({
            'taskId': component.get('v.transfer_data').Task_ID__c,
            'newTaskId': component.get('v.transfer_data').New_Task_ID__c,
            'callNumber': component.get('v.transfer_data').Call_Number__c,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var workspaceAPI = component.find("workspace");
            if (state === 'SUCCESS') {
                var retLst = response.getReturnValue();
                console.log('retLst in tranfer', retLst);
                var haveAccount = Object.keys(retLst).includes('ACCOUNT_ID');
                // console.log('retLst.ACCOUNT_ID', retLst.ACCOUNT_ID);
                // var verf_hist_id = component.get('v.transfer_data').Verification_History_ID__c ? component.get('v.transfer_data').Verification_History_ID__c.toString() : '';

                if (!haveAccount) {
                    console.log('account not found', retLst.GLOBAL_SEARCH)
                    console.log('transfer without account id');
                    var globalSearch = btoa(JSON.stringify({
                        'componentDef': 'forceSearch:searchPage',
                        'attributes': {
                            'term': retLst.GLOBAL_SEARCH ? retLst.GLOBAL_SEARCH : '',
                            'scopeMap': {
                                'type': 'TOP_RESULTS',
                            },
                            'context': {
                                'disableSpellCorrection': false,
                                'SEARCH_ACTIVITY': {
                                    'term': retLst.GLOBAL_SEARCH ? retLst.GLOBAL_SEARCH : ''
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
                            console.log(helper.parseObj(error));
                        });
                } else if (haveAccount) {
                    if (component.get('v.transfer_data').Verification_History_ID__c) {
                        console.log('verify: ' + component.get('v.transfer_data').Verification_History_ID__c.toString());

                        var appEvent = $A.get("e.c:ccpageProxyEvent");
                        // var sfidForTab = response[0].sfidForTab;
                        // var verf_hist_id = response[0].urlret ? response[0].urlret.split('?verf_hist_id=')[1] : '';
                        var sfidForTab = retLst.ACCOUNT_ID;
                        component.set('v.sfidForTab', sfidForTab);
                        var verf_hist_id = component.get('v.transfer_data').Verification_History_ID__c ? component.get('v.transfer_data').Verification_History_ID__c.toString() : '';
                        // console.log('retLst.ACCOUNT_ID:', retLst.ACCOUNT_ID);
                        // console.log('verf_hist_id transfer:',verf_hist_id);

                        workspaceAPI.getAllTabInfo().then(function (response) {
                            console.log('tab response', response);
                            console.log('f.pageReference.type', response.find(f => f.pageReference.type));
                            console.log('f.pageReference.attributes.recordId', response.find(f => f.pageReference.attributes.recordId));
                            var tabInfo = response.find(f => f.pageReference.type == "standard__recordPage" && f.pageReference.attributes.recordId == sfidForTab);

                            if (tabInfo) {
                                console.log('fire first!');
                                console.log('tabInfo', tabInfo);
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
                                console.log('fire else!');

                                workspaceAPI.openTab({
                                    pageReference: {
                                        "type": "standard__recordPage",
                                        'attributes': {
                                            'recordId': sfidForTab,
                                            'objectApiName': 'Account',
                                            'actionName': 'view'
                                        },
                                        'state': {
                                                    'c__vercode': verf_hist_id
                                                }
                                    },
                                    focus: true
                                }).then(function (response) {
                                    setTimeout(() => {
                                        appEvent.setParams({
                                            'recordId': sfidForTab,
                                            'verifycode': verf_hist_id,
                                        });
                                        appEvent.fire();
                                    }, 2000);
                                    
                                }).catch(function (error) {
                                    console.log(helper.parseObj(error));
                                });
                            }
                        });

                        // component.find("navService").navigate({
                        //     'type': 'standard__recordPage',
                        //     'attributes': {
                        //         'recordId': retLst.ACCOUNT_ID,
                        //         'objectApiName': 'Account',
                        //         'actionName': 'view'
                        //     },
                        //     'state': {
                        //         'c__vercode': component.get('v.transfer_data').Verification_History_ID__c.toString()
                        //     }
                        // }, false);
                    } else {
                        component.find("navService").navigate({
                            'type': 'standard__recordPage',
                            'attributes': {
                                'recordId': retLst.ACCOUNT_ID,
                                'objectApiName': 'Account',
                                'actionName': 'view'
                            }
                        }, false);
                    }
                }
            } else {
                console.log(state);

            }
        });

        $A.enqueueAction(action);
    },
    Outbound: function (component, event, helper) {

        let data = component.get('v.outbound_data');
        console.log('outbound');

        if (data.Popup_Mode__c === 'popup') {
            helper.popupFromUniqueKey(component, event, helper, data.Unique_Key__c, data.Task_ID__c, data.Callback_ID__c);
        } else if (data.Popup_Mode__c === 'transfer') {
            console.log('popup from unique key');
            helper.transferFromUniqueKey(component, event, helper, data.Task_ID__c, data.Unique_Key__c)
        }


    },

    Reconnect : function (component, event, helper) 
    {
        var agentId = component.get('v.agentId');
        var cmpTarget = component.find('status');
        var isSuccess = component.get('v.isSuccess');

        console.log('unsubscribe');
            // Get the empApi component
            const empApi = component.find('empApi');
            // Get the subscription that we saved when subscribing
            const subscription_Inbound = component.get('v.subscription_Inbound');
            // Unsubscribe from event          
            empApi.unsubscribe(subscription_Inbound, $A.getCallback(unsubscribed => {
                // Confirm that we have unsubscribed from the event channel
                console.log('Unsubscribed from channel '+ unsubscribed.subscription);
                component.set('v.subscription_Inbound', null);

                component.set('v.isSuccess',false);

                $A.util.removeClass(cmpTarget, 'icon-status-online');
                $A.util.addClass(cmpTarget, 'icon-status-offline');

                helper.subscribeEvent(component, event, helper, agentId);
            }));

        
        console.log('isSuccess:',isSuccess);
        if(isSuccess)
        {
            component.set('v.reconnectMsg','Reconnect Success');
            setTimeout($A.getCallback(function() {
                component.set('v.reconnectMsg',null);
            }), 5000);
        }
        
    }
})