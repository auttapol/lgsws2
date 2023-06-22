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
    doWorkspaceAPI: function (component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            component.set('v.tabId', tabId);
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
    closeTab: function (component) {
        if (component.get('v.theme') == 'Theme4t') {
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
        } else {
            var navService = component.find('navService');
            navService.navigate({
                type: 'standard__recordPage',
                attributes: {
                    recordId: component.get('v.accountId'),
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            }, true);
        }
    },
    updateRecord: function (component, section, list) {
        component.set(`v.householdSectionInfoes.${section}.isLoading`, true);
        component.set(`v.householdSectionInfoes.${section}.items`, list);
        component.set(`v.householdSectionInfoes.${section}.isLoading`, false);
    },
    getDescribeFieldResult: function (component, objInfoes, section) {
        var {
            sObjectName,
            fields
        } = objInfoes;
        var helper = this;
        var action = component.get('c.getDescribeFieldResult');
        action.setParams({
            "sObjectName": sObjectName,
            "fields": fields
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                component.set(`v.householdSectionInfoes.${section}.columns`, component.get(`v.householdSectionInfoes.${section}.columns`).map(m => {
                    var obj = helper.getValueReference(m.fieldName, objectInfoField);
                    m.label = m.label ? m.label : obj.label;
                    m.type = m.type ? m.type : obj.type;
                    return m;
                }, []));
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
    getDescribeFieldResultAndValue: function (component, objInfoes, section) {
        component.set(`v.householdSectionInfoes.${section}.isLoading`, true);
        var {
            recordId,
            sObjectName,
            fields
        } = objInfoes;
        var helper = this;
        var action = component.get('c.getDescribeFieldResultAndValue');
        action.setParams({
            "recordId": recordId,
            "sObjectName": sObjectName,
            "fields": fields
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set(`v.householdSectionInfoes.${section}.datas`, result);
                component.set(`v.householdSectionInfoes.${section}.isLoading`, false);
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message);
                });
                helper.closeTab(component);
            }
        });
        $A.enqueueAction(action);
    },
    getQueryDatabase: function (component, paramters, section) {
        component.set(`v.householdSectionInfoes.${section}.isLoading`, true);
        var {
            fields,
            sObjectName,
            filter,
        } = paramters;

        var helper = this;
        var action = component.get('c.getQueryDatabase');
        action.setParams({
            "fields": fields,
            "sObjectName": sObjectName,
            "filter": filter
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set(`v.householdSectionInfoes.${section}.datas`, result);
                component.set(`v.householdSectionInfoes.${section}.isLoading`, false);
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
    getRecordPerPage: function (component) {
        var action = component.get('c.getRecordPerPage');
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.householdSectionInfoes.RTL_History.offset', result);
            }
        });
        $A.enqueueAction(action);
    },
    getIsHouseholdRecordLocked: function (component, householdId) {
        var helper = this;
        var action = component.get('c.getIsHouseholdRecordLocked');
        action.setParams({
            "householdId": householdId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set(`v.householdSectionInfoes.isHouseholdRecordLocked`, result);
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
    getIsHouseholdEditable: function (component, household, approvalList) {
        var helper = this;
        var userId = component.get('v.userId');
        if (userId == household.RTL_RM__r.ManagerId) {
            return false;
        }
        if (household.RTL_Status__c == 'Deleted') {
            return false;
        }
        if (approvalList.length > 0) {
            if (userId == approvalList[0].CreatedById || userId == household.RTL_RM__c) {
                return true;
            }
            return false;
        }
        return userId == household.RTL_RM__c;
    },
    changeRecordModify: function (component, event, helper) {
        var isHouseholdRecordLocked = component.get(`v.householdSectionInfoes.isHouseholdRecordLocked`);
        var isHouseholdEditable = component.get(`v.householdSectionInfoes.isHouseholdEditable`);
        var househouseInfo = component.get(`v.householdSectionInfoes.RTL_Household_Information.datas`);
        var householdStatus = component.get(`v.householdSectionInfoes.RTL_Household_Information.householdStatus`);
        var approvalList = component.get(`v.householdSectionInfoes.RTL_Approval.items`);
        var historyList = component.get(`v.householdSectionInfoes.RTL_History.items`);
        var userId = component.get(`v.userId`);

        component.set(`v.householdButtonAccess`, {
            'isModifyHousehold': !isHouseholdRecordLocked && isHouseholdEditable,
            'isRequestDeleteHousehold': !isHouseholdRecordLocked && isHouseholdEditable && householdStatus != 'New',
            'isSubmitForApproval': !isHouseholdRecordLocked && isHouseholdEditable && approvalList.length > 0,
            'isApproveAll': (househouseInfo.RTL_RM__r && userId == househouseInfo.RTL_RM__r.ManagerId.value) && approvalList.length > 0 &&
                isHouseholdRecordLocked && householdStatus != 'Deleted',
            'isRejectAll': (househouseInfo.RTL_RM__r && userId == househouseInfo.RTL_RM__r.ManagerId.value) && approvalList.length > 0 &&
                isHouseholdRecordLocked && householdStatus != 'Deleted',
            'isNotifyRequestor': (househouseInfo.RTL_RM__r && userId == househouseInfo.RTL_RM__r.ManagerId.value) && approvalList.length == 0 &&
                historyList.filter(f => f.RTL_Sent_to_Requestor__c == false && f.RTL_Outcome__c != 'Pending' && f.RTL_Outcome__c != 'New').length > 0,
        });

        if (component.get(`v.householdSectionInfoes.RTL_Household_Member.items`).length > 0) {
            component.set(`v.householdSectionInfoes.RTL_Household_Member.isLoading`, true);
            component.set(`v.householdSectionInfoes.RTL_Household_Member.items`,
                component.get(`v.householdSectionInfoes.RTL_Household_Member.items`)
                .map(e => {
                    // null is not display
                    e.action = {
                        edit: isHouseholdRecordLocked == true || isHouseholdEditable == false || e.RTL_Primary__c == true ? null : $A.get('$Label.c.Edit'),
                        delete: isHouseholdRecordLocked == true || isHouseholdEditable == false || e.RTL_Primary__c == true ? null : $A.get('$Label.c.Delete')
                    };
                    return e;
                })
            );
            component.set(`v.householdSectionInfoes.RTL_Household_Member.isLoading`, false);
        }

        if (component.get(`v.householdSectionInfoes.RTL_Approval.items`).length > 0) {
            component.set(`v.householdSectionInfoes.RTL_Approval.isLoading`, true);
            component.set(`v.householdSectionInfoes.RTL_Approval.items`,
                component.get(`v.householdSectionInfoes.RTL_Approval.items`)
                .map(m => {
                    m.action = {
                        // null is not display
                        edit: isHouseholdRecordLocked == false ||
                            userId != househouseInfo.RTL_RM__r.ManagerId.value ||
                            househouseInfo.RTL_Status__c.value == 'Deleted' ?
                            null : $A.get('$Label.c.Edit'),
                        delete: isHouseholdRecordLocked == true || isHouseholdEditable == false ?
                            null : $A.get('$Label.c.Delete'),
                    };
                    return m;
                })
            );
            component.set(`v.householdSectionInfoes.RTL_Approval.isLoading`, false);
        }
    }
})