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
    displayErrorMsg: function (component, status, message) {
        component.set('v.error', {
            status: status,
            message: message
        });
    },
    getValueReference: function (path, obj) {
        var key = path.split('.')[0];
        if (path.includes('.') && obj[key]) {
            return this.getValueReference(path.split('.')[1], obj[key]);
        }
        return obj[key];
    },
    doWorkspaceAPI: function (component, tabName) {
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
    openTab: function (component) {
        var navService = component.find('navService');
        navService.navigate({
            type: 'standard__recordPage',
            attributes: {
                recordId: component.get('v.householdId'),
                objectApiName: 'RTL_HouseHold__c',
                actionName: 'view'
            },
        }, true);
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
                    recordId: component.get('v.householdId') ? component.get('v.householdId') : component.get('v.accountId'),
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
    getModifyHousehold: function (component) {
        component.set('v.isModify', component.get('v.householdReference.RTL_HouseHold__c.RTL_RM__c') == component.get('v.userId'));
        if (!component.get('v.isModify')) {
            component.find('errorMessage').setError($A.get('$Label.c.RTL_Household_ERR09'));
        }
        return component.get('v.isModify');
    },
    getInitialHousehold: function (component, event, helper) {
        var helper = this;
        var action = component.get('c.initialCreateHouseHold');
        action.setParams({
            "householdId": component.get('v.householdId'),
            "accountId": component.get('v.accountId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // console.log(result);
                result.RTL_HouseHold__c.RTL_Approver_UserName__c = result.User.ManagerId;
                component.set('v.householdReference', result);
                component.set('v.isManager', result.User.ManagerId == component.get('v.userId'));
                if (component.get('v.isManager')) {
                    component.find('errorMessage').setError($A.get('$Label.c.RTL_Household_ERR05'))
                } else if (!helper.getModifyHousehold(component)) {
                    // Don't nothing
                }

                helper.doWorkspaceAPI(component, component.get('v.householdReference.RTL_HouseHold__c.Name'));
                helper.getDescribeFieldResult(component, 'RTL_HouseHold__c', component.get('v.fields.RTL_Household_Information').map(m => m.fieldName), 'RTL_Household_Information');
                helper.getDescribeFieldResult(component, 'RTL_HouseHold_Member__c', component.get('v.fields.RTL_Household_Member').map(m => m.fieldName), 'RTL_Household_Member');
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message);
                });
            }

        });
        $A.enqueueAction(action);
    },
    saveHousehold: function (component, event, helper) {
        helper.startSpinner(component);
        helper.displayErrorMsg(component, false, '');

        // Default value
        var eventFields = event.getParam("fields");
        var householdReference = component.get('v.householdReference');
        delete householdReference.RTL_HouseHold__c.RTL_Approver_UserName__c;
        householdReference.RTL_HouseHold__c.RTL_Benefit_Package__c = eventFields.RTL_Benefit_Package__c;
        householdReference.RTL_HouseHold__c.RTL_Remarks__c = eventFields.RTL_Remarks__c;

        var action = component.get('c.saveHousehold');
        action.setParams({
            "householdObject": householdReference,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result.success) {
                    component.set('v.householdId', result.RTL_HouseHold__c.Id);
                    component.find('recordEditForm').submit(eventFields);
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    // helper.displayToast('error', error.message);
                    helper.displayErrorMsg(component, true, error.message);
                });
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
    getDescribeFieldResult: function (component, sObjectAPIName, fields, section) {
        var helper = this;
        var action = component.get('c.getDescribeFieldResult');
        action.setParams({
            "sObjectName": sObjectAPIName,
            "fields": fields
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                component.set(`v.fieldInfoes.${section}`, fields.map(m => {
                    var fieldInfo = component.get(`v.fields.${section}`).find(f => f.fieldName == m);
                    return {
                        name: m,
                        readonly: fieldInfo.readonly,
                        hover: fieldInfo.hover ? true : false,
                        required: fieldInfo.required ? true : false,
                        label: objectInfoField[m].label,
                        type: fieldInfo.type ? fieldInfo.type : objectInfoField[m].type,
                        value: component.get(`v.householdReference.${sObjectAPIName}.${m}`),
                    }
                }));

            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message);
                });
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
    getDescribeFieldResultAndValue: function (component, recordId, sObjectAPIName, fields, section) {
        var helper = this;
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
                component.set(`v.fieldInfoes.${section}`, fields.map(m => {
                    var fieldInfo = component.get(`v.fields.${section}`).find(f => f.fieldName == m);
                    fieldInfo = fieldInfo ? fieldInfo : {};
                    return {
                        name: m,
                        readonly: fieldInfo.readonly,
                        hover: fieldInfo.hover ? true : false,
                        required: fieldInfo.required ? true : false,
                        value: fieldInfo.replace ? helper.getValueReference(fieldInfo.replace, objectInfoField).value : helper.getValueReference(m, objectInfoField).value,
                        label: helper.getValueReference(m, objectInfoField).label,
                        type: fieldInfo.type ? fieldInfo.type : helper.getValueReference(m, objectInfoField).type,
                    }
                }));
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message);
                });
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
})