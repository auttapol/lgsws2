({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    splitData: function (defaultData) {
        if (!defaultData) return {};
        return typeof defaultData === 'string' ? (defaultData.includes('=') ? defaultData.split(/[,{}]/g).map(e => e.trim()).filter(f => f).reduce((l, i) => {
            l[i.split('=')[0]] = i.split('=')[1];
            return l;
        }, {}) : JSON.parse(defaultData)) : Object.entries(defaultData).reduce((l, i) => {
            l[i[0]] = decodeURIComponent(i[1]);
            return l;
        }, {});
    },
    setOnInit: function (component, event, helper) {
        var sObjectName = component.get('v.sObjectName') ? component.get('v.sObjectName') : component.get("v.pageReference").state.c__sObjectName;
        var recordId = component.get('v.recordId') ? component.get('v.recordId') : component.get("v.pageReference").state.c__recordId;
        var recordTypeId = component.get('v.recordTypeId') ? component.get('v.recordTypeId') : component.get("v.pageReference").state.c__recordTypeId;
        var theme = component.get('v.theme') ? component.get('v.theme') : (
            component.get("v.pageReference").state.c__theme ?
            component.get("v.pageReference").state.c__theme : ($A.get('$Browser.formFactor') == 'PHONE' ? 'Theme4t' : 'Theme4u')
        );
        var header = component.get('v.header') ? component.get('v.header') : component.get("v.pageReference").state.c__header;
        var detail = component.get('v.detail') ? component.get('v.detail') : component.get("v.pageReference").state.c__detail;
        var defaultValue = component.get('v.defaultValue') ? component.get('v.defaultValue') : component.get("v.pageReference").state.c__defaultVaule;
        var url = component.get('v.url') ? component.get('v.url') : component.get("v.pageReference").state.c__url;
        var isCustom = component.get('v.isCustom') ? component.get('v.isCustom') : component.get("v.pageReference").state.c__isCustom;

        component.set('v.sObjectName', sObjectName);
        component.set('v.recordId', recordId);
        component.set('v.recordTypeId', recordTypeId);
        component.set('v.theme', theme);
        component.set('v.url', url);
        component.set('v.isCustom', isCustom);
        component.set('v.labelDisplay', {
            header: header,
            detail: detail,
        });
        component.set('v.defaultValue', helper.splitData(defaultValue));

        // Get label Display
        helper.doWorkspaceAPI(component, component.get('v.labelDisplay.header'));
        helper.getSObjectLabel(component, event, helper);

        // For support android environment 
        if (component.get('v.isAndroidRedirect')) {
            component.set('v.isAndroidRedirect', false);
            helper.clearCache(component);
            var navService = component.find('navService');
            navService.navigate({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/PreviousPage'
                }
            }, true);
        }

        helper.fetchRecordType(component, event, helper);
        // if (component.get('v.recordTypeId')) {
        //     helper.fireCreateRecord(component);
        // } else {
        //     helper.fetchRecordType(component, event, helper);
        // }
    },
    doWorkspaceAPI: function (component, tabName) {
        tabName = tabName ? tabName : 'Loading...';
        var iconName = component.get('v.sObjectName') ? `standard:${component.get('v.sObjectName')}`.toLowerCase() : 'custom:custom1';
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.getTabInfo({
                tabId: tabId
            }).then(function (response) {
                if (response.isSubtab) {
                    workspaceAPI.setTabLabel({
                        tabId: response.tabId,
                        label: tabName,
                    });
                    workspaceAPI.setTabIcon({
                        tabId: response.tabId,
                        icon: iconName,
                        iconAlt: tabName,
                    });
                }
            });
        }).catch(function (error) {
            // console.log(error);
        });
    },
    closeThisTabWorkspaceAPI: function (component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.closeTab({
                tabId: tabId
            });
        }).catch(function (error) {
            // console.log(error);
        });
    },
    fetchRecordType: function (component, event, helper) {
        var action = component.get('c.fetchRecordType');
        action.setParams({
            'sObjectName': component.get('v.sObjectName')
        })
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result.length == 1) {
                    component.set('v.recordTypeId', result.find(i => i).Id);
                    helper.fireCreateRecord(component);
                } else {
                    // component.set('v.recordTypeId', result.find(i => i.isDefault).Id);
                    component.set('v.recordTypeId', component.get('v.recordTypeId') ? component.get('v.recordTypeId') : result.find(i => i.isDefault).Id);
                    component.set('v.recordTypes', result.sort((a, b) => a.Name < b.Name ? -1 : (a.Name > b.Name ? 1 : 0)));
                }
            } else {
                var errors = response.getError();
                // errors.forEach(error => console.log(error.message));
                helper.displayToast('error', 'No record type to available');
                helper.closeThisTabWorkspaceAPI(component);
            }
        });
        $A.enqueueAction(action);
    },
    getSObjectLabel: function (component, event, helper) {
        var userLocaleLang = $A.get("$Locale.userLocaleLang")
        var action = component.get('c.getSObjectLabel');
        action.setParams({
            'sObjectName': component.get('v.sObjectName')
        })
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var label = response.getReturnValue();
                var header = {
                    'en': `New ${label}`,
                    'th': `สร้าง ${label}`
                };
                component.set('v.labelDisplay.header', header[userLocaleLang] ? header[userLocaleLang] : header['en']);
                helper.doWorkspaceAPI(component, component.get('v.labelDisplay.header'));
            } else {
                var errors = response.getError();
                // errors.forEach(error => console.log(error.message));
            }
        });
        if (!component.get('v.labelDisplay.header'))
            $A.enqueueAction(action);
    },
    fireCreateRecord: function (component) {
        var helper = this;
        var navService = component.find('navService');
        var pageRefUtils = component.find('pageReferenceUtils');

        var defaultValue = component.get('v.defaultValue');
        var sObjectName = component.get('v.sObjectName');
        var recordId = component.get('v.recordId');
        var recordTypeId = component.get('v.recordTypeId');
        var url = component.get('v.url');
        var theme = component.get('v.theme');

        helper.clearCache(component);
        if (recordTypeId) {
            if (component.get('v.isCustom')) {
                // for visualforce page only
                navService.navigate({
                    type: "standard__webPage",
                    attributes: {
                        url: `${url}&recordTypeId=${recordTypeId}`,
                    }
                }, true);
            } else {
                //alert('Case Else Theme: ' +theme + ' | IsAndroid: '+ $A.get("$Browser").isAndroid + ' | IsIPad: '+ $A.get("$Browser").isIOS);
                if (theme == 'Theme4t' || (theme == 'Theme4u' && !$A.get("$Browser").isDesktop)) {
                    if (!$A.get("$Browser").isAndroid) {
                        navService.navigate({
                            type: 'standard__webPage',
                            attributes: {
                                url: '/apex/PreviousPage'
                            }
                        }, true);
                    } else if ($A.get("$Browser").isAndroid) {
                        component.set('v.isAndroidRedirect', true);
                    }
                    // Clear default value to be null out
                    Object.keys(defaultValue).forEach(e => {
                        if (!defaultValue[e] || defaultValue[e] == "null") {
                            delete defaultValue[e];
                        }
                    });
                    // Salesforce one to action new record 
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": sObjectName,
                        "recordTypeId": recordTypeId,
                        "defaultFieldValues": defaultValue,
                    });
                    createRecordEvent.fire();
                } else {
                    defaultValue.RecordTypeId = recordTypeId;
                    navService.navigate({
                        type: "standard__objectPage",
                        attributes: {
                            objectApiName: sObjectName,
                            actionName: "new"
                        },
                        state: {
                            defaultFieldValues: pageRefUtils.encodeDefaultFieldValues(defaultValue),
                            recordTypeId: recordTypeId,
                            nooverride: "1"
                        }
                    }, true);
                }
            }

        }
    },
    clearCache: function (component) {
        // Clear cahce
        component.set('v.recordId', null);
        component.set('v.recordTypeId', null);
        component.set('v.defaultValue', null);
    }
})