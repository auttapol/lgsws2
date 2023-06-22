({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    getValueReference: function (path, obj) {
        var key = path.split('.')[0];
        if (path.includes('.') && obj[key]) {
            return this.getValueReference(path.split('.')[1], obj[key]);
        }
        return obj[key];
    },
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    doWorkspaceAPI: function (component, tabName) {
        var helper = this;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            helper.setTabName(component, tabId, tabName)
        }).catch(function (error) {
            console.log(error);
        });
    },
    setTabName: function (component, tabId, tabName) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.setTabLabel({
            tabId: tabId,
            label: tabName,
        });
        workspaceAPI.setTabIcon({
            tabId: tabId,
            icon: "custom:custom1",
            iconAlt: tabName,
        });
    },
    closeTab: function (component) {
        //if (component.get('v.theme') == 'Theme4u') {
        if($A.get("$Browser").isDesktop){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.focusTab({
                        tabId: component.get('v.tabId')
                    });
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
        } else {
            var navService = component.find('navService');
            navService.navigate({
                type: 'standard__recordPage',
                attributes: {
                    recordId: component.get('v.householdId'),
                    objectApiName: 'RTL_HouseHold__c',
                    actionName: 'view'
                },
            }, true);
        }
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

    getDescribeFieldResultAndValue: function (component, paramters) {
        var helper = this;
        var {
            recordId,
            sObjectAPIName,
            fields,
            section
        } = paramters;
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": recordId,
            "sObjectName": sObjectAPIName,
            "fields": fields
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                // console.log(objectInfoField);
                var RTL_Field_Changed__c = section == 'RTL_Request_Details' ? objectInfoField['RTL_Field_Changed__c'].value : '';

                component.set(`v.householdHistoryInfoes.${section}.fields`, component.get(`v.householdHistoryInfoes.${section}.fields`).map(m => {
                    if (section == 'RTL_Request_Details') {
                        var thisValue = helper.getValueReference(m.fieldName, objectInfoField).value;
                        // Old Value
                        if (m.fieldName == 'RTL_Prev_Value__c') {
                            if (RTL_Field_Changed__c != 'RTL_Benefit__c') {
                                thisValue = RTL_Field_Changed__c == 'RTL_To_Delete__c' ? '' : thisValue;
                            } else if (RTL_Field_Changed__c == 'RTL_Benefit__c') {
                                thisValue = thisValue == 'true' ? 'Yes' : 'No';
                            } else {
                                thisValue = '';
                            }
                            objectInfoField.RTL_Prev_Value__c.value = thisValue;
                        }

                        // New Value
                        if (m.fieldName == 'RTL_New_Value__c') {
                            if (RTL_Field_Changed__c != 'RTL_Benefit__c') {
                                thisValue = RTL_Field_Changed__c == 'RTL_To_Delete__c' || RTL_Field_Changed__c == 'New Household' || RTL_Field_Changed__c == 'New Member' ?
                                    '' : thisValue;
                            } else if (RTL_Field_Changed__c == 'RTL_Benefit__c') {
                                thisValue = thisValue == 'true' ? 'Yes' : 'No';
                            } else {
                                thisValue = '';
                            }
                            objectInfoField.RTL_New_Value__c.value = thisValue;
                        }
                    }

                    var obj = {
                        fieldName: m.fieldName,
                        value: helper.getValueReference(m.fieldName, objectInfoField).value,
                        label: helper.getValueReference(m.fieldName, objectInfoField).label,
                        type: helper.getValueReference(m.fieldName, objectInfoField).type,
                        inlineHelpText: helper.getValueReference(m.fieldName, objectInfoField).inlineHelpText,
                    };
                    Object.keys(obj).forEach(e => {
                        m[e] = obj[e];
                    });

                    return m;
                }));
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, '');
                });
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
})