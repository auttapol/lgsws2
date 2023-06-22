({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.HistoryTyoMappingTranslate', {
            'Edit Household : Remarks': $A.get(`$Label.c.RTL_Edit_HH_Remarks`),
            'Delete Household': $A.get(`$Label.c.RTL_Del_HH`),
            'New Member': $A.get(`$Label.c.RTL_New_HHM`),
            'Household': $A.get(`$Label.c.RTL_Household`),
            'Delete Member': $A.get(`$Label.c.RTL_Del_HHM`),
            'Edit Member : Relationship': $A.get(`$Label.c.RTL_Edit_HHM_Relationship`),
            'Edit Household : Benefit': $A.get(`$Label.c.RTL_Edit_HH_Benefit`),
            'Edit Member : Benefit': $A.get(`$Label.c.RTL_Edit_HHM_Benefit`),
            'New Household': $A.get(`$Label.c.RTL_New_HH`),
            'Member': $A.get(`$Label.c.RTL_Member`),
        });

        component.set('v.householdSectionInfoes', {
            'title': '',
            'isHouseholdRecordLocked': false,
            'isHouseholdEditable': false,
            'RTL_Household_Information': {
                'sObjectName': 'RTL_Household__c',
                'fields': [
                    'Name',
                    'RTL_RM__c',
                    'RTL_Benefit_Package__c',
                    'RTL_Approver_UserName__c',
                    'RTL_Status__c',
                    'RTL_Number_of_Members__c',
                    'RTL_Remarks__c',
                ],
                'fieldsAddon': [
                    'RTL_RM__r.ManagerId',
                ],
                'filter': `Id = '${component.get('v.householdId')}'`,
                'datas': {},
                'items': [],
                'householdStatus': '',
                'isLoading': false,
            },
            'RTL_Household_Member': {
                'isLoading': true,
                'sObjectName': 'RTL_Household_Member__c',
                'fields': [
                    'Id', 'Name', 'RTL_Household_Member_Name__c', 'RTL_TMB_Customer_ID_PE__c',
                    'RTL_Primary__c', 'RTL_Benefit__c', 'RTL_Relationship__c', 'RTL_Status__c', 'RTL_Is_Approved__c',
                    'RTL_To_Delete__c', 'RTL_Household_Member_Name__r.Name'
                ],
                'filter': `RTL_Household__c = '${component.get('v.householdId')}' ORDER BY RTL_Primary__c DESC`,
                'datas': [],
                'items': [],
                'columns': [{
                        fieldName: 'Action',
                        type: 'Action',
                        label: $A.get('$Label.c.Action'),
                    },
                    {
                        fieldName: 'RTL_Household_Member_Name__c',
                        type: 'PARSE',
                        format: '{0}',
                        valueAddon: ['RTL_Household_Member_Name__r.Name'],
                    },
                    {
                        fieldName: 'RTL_Primary__c',
                    },
                    {
                        fieldName: 'RTL_Benefit__c',
                    },
                    {
                        fieldName: 'RTL_Relationship__c',
                    },
                    {
                        fieldName: 'RTL_Status__c',
                    },
                ],

            },
            'RTL_Approval': {
                'isLoading': true,
                'sObjectName': 'RTL_Household_History_and_Approval__c',
                'fields': [
                    'Id', 'Name', 'RTL_Field_Changed__c', 'RTL_Field_Label__c', 'RTL_User_Requesting__c', 'RTL_Prev_Value__c',
                    'RTL_New_Value__c', 'RTL_Outcome__c', 'RTL_Date_Requested__c', 'RTL_Date_Approved__c', 'RTL_Household_Member__c',
                    'RTL_Household__c', 'RTL_Household__r.Name', 'RTL_Household_Member__r.Name', 'RTL_Sent_To_Approval__c',
                    'RTL_Section__c', 'RTL_Sent_to_Requestor__c', 'RTL_User_Requesting__r.Name', 'RTL_Approver_Link__c',
                    'CreatedById', 'RTL_Member_Lookup_Account__c', 'RTL_Member_Lookup_Account__r.Name'
                ],
                'filter': `RTL_Outcome__c != 'Approved' AND RTL_Outcome__c != 'Rejected' AND RTL_Household__c = '${component.get('v.householdId')}'`,
                'datas': [],
                'items': [],
                'columns': [{
                        fieldName: 'Action',
                        type: 'Action',
                        label: $A.get('$Label.c.Action'),
                    },
                    {
                        fieldName: 'Id',
                        type: 'PARSE',
                        label: $A.get('$Label.c.RTL_Request'),
                        format: '{0}',
                        valueAddon: ['Name'],
                    },
                    {
                        fieldName: 'RTL_Section__c',
                    },
                    {
                        fieldName: 'RTL_Field_Label__c',
                        label: $A.get('$Label.c.RTL_Household_Requested_Type'),
                    },
                    {
                        fieldName: 'RTL_Member_Lookup_Account__c',
                        label: $A.get('$Label.c.RTL_Related_Record'),
                    },
                    {
                        fieldName: 'RTL_Prev_Value__c',
                    },
                    {
                        fieldName: 'RTL_New_Value__c',
                    },
                    {
                        fieldName: 'RTL_Date_Requested__c',
                    },
                    {
                        fieldName: 'RTL_Outcome__c',
                    },
                ],
            },
            'RTL_History': {
                'isLoading': true,
                'sObjectName': 'RTL_Household_History_and_Approval__c',
                'fields': [
                    'Id', 'Name', 'RTL_Field_Changed__c', 'RTL_Field_Label__c', 'RTL_User_Requesting__c', 'RTL_Prev_Value__c',
                    'RTL_New_Value__c', 'RTL_Outcome__c', 'RTL_Date_Requested__c', 'RTL_Date_Approved__c', 'RTL_Household_Member__c',
                    'RTL_Household__c', 'RTL_Household__r.Name', 'RTL_Household_Member__r.Name', 'RTL_Sent_To_Approval__c',
                    'RTL_Section__c', 'RTL_Sent_to_Requestor__c', 'RTL_User_Requesting__r.Name',
                    'RTL_Approver_Link__c', 'RTL_Approver_Link__r.Name', 'RTL_Member_Lookup_Account__c', 'RTL_Member_Lookup_Account__r.Name'
                ],
                'filter': `RTL_Household__c = '${component.get('v.householdId')}'`,
                'datas': [],
                'items': [],
                'columns': [{
                        fieldName: 'Id',
                        type: 'PARSE',
                        label: $A.get('$Label.c.RTL_Request'),
                        format: '{0}',
                        valueAddon: ['Name'],
                    },
                    {
                        fieldName: 'RTL_Section__c',
                    },
                    {
                        fieldName: 'RTL_Field_Label__c',
                        label: $A.get('$Label.c.RTL_Household_Requested_Type'),
                    },
                    {
                        fieldName: 'RTL_Member_Lookup_Account__c',
                        label: $A.get('$Label.c.RTL_Related_Record'),
                    },
                    {
                        fieldName: 'RTL_Prev_Value__c',
                    },
                    {
                        fieldName: 'RTL_New_Value__c',
                    },
                    {
                        fieldName: 'RTL_Outcome__c',
                        label: $A.get('$Label.c.RTL_Result'),
                    },
                    {
                        fieldName: 'RTL_Date_Approved__c',
                    },
                ],
                'paginationLabel': `${$A.get('$Label.c.RTL_Page')} 1 of 1`,
                'offset': 5,
                'isDisabledPrevious': true,
                'isDisabledNext': true,
            }
        });

        helper.doWorkspaceAPI(component);
        helper.getRecordPerPage(component);

        // House hold information
        helper.getDescribeFieldResultAndValue(component, {
            recordId: component.get('v.householdId'),
            sObjectName: component.get('v.householdSectionInfoes.RTL_Household_Information.sObjectName'),
            fields: component.get('v.householdSectionInfoes.RTL_Household_Information.fields')
                .concat(component.get('v.householdSectionInfoes.RTL_Household_Information.fieldsAddon')),
        }, 'RTL_Household_Information');

        // House hold member
        helper.getDescribeFieldResult(component, {
            sObjectName: component.get('v.householdSectionInfoes.RTL_Household_Member.sObjectName'),
            fields: component.get('v.householdSectionInfoes.RTL_Household_Member.fields'),
        }, 'RTL_Household_Member');
        helper.getQueryDatabase(component, {
            sObjectName: component.get('v.householdSectionInfoes.RTL_Household_Member.sObjectName'),
            fields: component.get('v.householdSectionInfoes.RTL_Household_Member.fields'),
            filter: component.get('v.householdSectionInfoes.RTL_Household_Member.filter'),
        }, 'RTL_Household_Member');

        // Approval
        helper.getDescribeFieldResult(component, {
            sObjectName: component.get('v.householdSectionInfoes.RTL_Approval.sObjectName'),
            fields: component.get('v.householdSectionInfoes.RTL_Approval.fields'),
        }, 'RTL_Approval');
        helper.getQueryDatabase(component, {
            sObjectName: component.get('v.householdSectionInfoes.RTL_Approval.sObjectName'),
            fields: component.get('v.householdSectionInfoes.RTL_Approval.fields'),
            filter: component.get('v.householdSectionInfoes.RTL_Approval.filter'),
        }, 'RTL_Approval');

        // Histroy approval
        helper.getDescribeFieldResult(component, {
            sObjectName: component.get('v.householdSectionInfoes.RTL_History.sObjectName'),
            fields: component.get('v.householdSectionInfoes.RTL_History.fields'),
        }, 'RTL_History');
        helper.getQueryDatabase(component, {
            sObjectName: component.get('v.householdSectionInfoes.RTL_History.sObjectName'),
            fields: component.get('v.householdSectionInfoes.RTL_History.fields'),
            filter: component.get('v.householdSectionInfoes.RTL_History.filter'),
        }, 'RTL_History');

        // Is Household record Locked? => defaulf to be false
        helper.getIsHouseholdRecordLocked(component, component.get(`v.householdId`));
        component.set(`v.householdButtonAccess`, {
            'isModifyHousehold': false,
            'isRequestDeleteHousehold': false,
            'isSubmitForApproval': false,
            'isApproveAll': false,
            'isRejectAll': false,
            'isNotifyRequestor': false,
        });
    },
    handleHouseholdRecordModify: function (component, event, helper) {
        helper.changeRecordModify(component, event, helper);
    },
    handleHouseholdInfo: function (component, event, helper) {
        if (component.get('v.householdSectionInfoes.RTL_Household_Information.isOnce')) {
            return;
        }

        var househouseInfo = component.get(`v.householdSectionInfoes.RTL_Household_Information.datas`);
        if (Object.keys(househouseInfo).length > 0) {
            // Set once
            component.set('v.householdSectionInfoes.RTL_Household_Information.isOnce', true);

            // Set Title
            var Name = househouseInfo.Name;
            component.set('v.householdSectionInfoes.title', Name.value);
            helper.setTabName(component, component.get('v.tabId'), Name.value);

            // Household status
            var RTL_Status__c = househouseInfo.RTL_Status__c;
            component.set('v.householdSectionInfoes.RTL_Household_Information.householdStatus', RTL_Status__c.value);

            // Set User Approver 
            var ManagerId = househouseInfo.RTL_RM__r.ManagerId;
            househouseInfo.RTL_Approver_UserName__c.value = ManagerId ? ManagerId.value : househouseInfo.RTL_Approver_UserName__c.value;
            househouseInfo.RTL_Approver_UserName__c.type = ManagerId ? ManagerId.type : househouseInfo.RTL_Approver_UserName__c.type;

            // Setup hover
            househouseInfo.RTL_RM__c.hover = true;
            househouseInfo.RTL_Approver_UserName__c.hover = true;

            // Set up items
            // Display form element
            component.set(`v.householdSectionInfoes.RTL_Household_Information.items`,
                component.get(`v.householdSectionInfoes.RTL_Household_Information.fields`).reduce((l, fieldName) => {
                    l.push(helper.getValueReference(fieldName, househouseInfo));
                    return l;
                }, []));

            helper.stopSpinner(component);
        }
    },
    handleHouseholdMember: function (component, event, helper) {
        // Household member
        if (component.get(`v.householdSectionInfoes.RTL_Household_Member.datas`).length > 0) {
            // filter was approved
            component.set(`v.householdSectionInfoes.RTL_Household_Member.items`,
                helper.parseObj(component.get(`v.householdSectionInfoes.RTL_Household_Member.datas`))
                .filter(f => f.RTL_Is_Approved__c == true)
            );

            // Set accountId
            component.set(`v.accountId`,
                component.get(`v.householdSectionInfoes.RTL_Household_Member.datas`).find(f => f.RTL_Primary__c).RTL_Household_Member_Name__c);
            component.set(`v.householdMemberId`,
                component.get(`v.householdSectionInfoes.RTL_Household_Member.datas`).find(f => f.RTL_Primary__c).Id);

            helper.changeRecordModify(component, event, helper);
            helper.updateRecord(component, 'RTL_Household_Member', component.get(`v.householdSectionInfoes.RTL_Household_Member.items`));
        }
    },
    handleHouseholdApproval: function (component, event, helper) {
        var household = component.get(`v.householdSectionInfoes.RTL_Household_Information.datas`);
        component.set(`v.householdSectionInfoes.isHouseholdEditable`, helper.getIsHouseholdEditable(component, {
                'RTL_RM__r': {
                    'ManagerId': household.RTL_RM__r ? household.RTL_RM__r.ManagerId.value : ''
                },
                'RTL_Status__c': household.RTL_Status__c ? household.RTL_Status__c.value : '',
                'RTL_RM__c': household.RTL_RM__c ? household.RTL_RM__c.value : '',
            },
            component.get(`v.householdSectionInfoes.RTL_Approval.datas`)));

        // Household approval
        if (component.get(`v.householdSectionInfoes.RTL_Approval.datas`).length > 0) {

            // Mapping field to be dispaly table
            component.set(`v.householdSectionInfoes.RTL_Approval.items`,
                helper.parseObj(component.get(`v.householdSectionInfoes.RTL_Approval.datas`))
                .map(m => {
                    m.RTL_Field_Label__c = component.get(`v.HistoryTyoMappingTranslate.${m.RTL_Field_Label__c}`);
                    m.RTL_Member_Lookup_Account__c = m.RTL_Member_Lookup_Account__c ? m.RTL_Member_Lookup_Account__c : m.RTL_Household__r.Name;
                    // Old Value
                    if (m.RTL_Field_Changed__c != 'RTL_Benefit__c') {
                        m.RTL_Prev_Value__c = m.RTL_Field_Changed__c == 'RTL_To_Delete__c' ? '' : m.RTL_Prev_Value__c;
                    } else if (m.RTL_Field_Changed__c == 'RTL_Benefit__c') {
                        m.RTL_Prev_Value__c = m.RTL_Prev_Value__c == 'true' ? 'Yes' : 'No';
                    } else {
                        m.RTL_Prev_Value__c = '';
                    }
                    // New Value
                    if (m.RTL_Field_Changed__c != 'RTL_Benefit__c') {
                        m.RTL_New_Value__c = m.RTL_Field_Changed__c == 'RTL_To_Delete__c' || m.RTL_Field_Changed__c == 'New Household' || m.RTL_Field_Changed__c == 'New Member' ?
                            '' : m.RTL_New_Value__c;
                    } else if (m.RTL_Field_Changed__c == 'RTL_Benefit__c') {
                        m.RTL_New_Value__c = m.RTL_New_Value__c == 'true' ? 'Yes' : 'No';
                    } else {
                        m.RTL_New_Value__c = '';
                    }

                    return m;
                }).sort((a, b) => a.Id > b.Id ? 1 : (a.Id < b.Id ? -1 : 0))
            );

            helper.changeRecordModify(component, event, helper);
            helper.updateRecord(component, 'RTL_Approval', component.get(`v.householdSectionInfoes.RTL_Approval.items`));
        }
    },
    handleHouseholdHistory: function (component, event, helper) {
        // Household history
        if (component.get(`v.householdSectionInfoes.RTL_History.datas`).length > 0) {
            component.set(`v.householdSectionInfoes.RTL_History.items`,
                helper.parseObj(component.get(`v.householdSectionInfoes.RTL_History.datas`))
                .map(m => {
                    m.RTL_Field_Label__c = component.get(`v.HistoryTyoMappingTranslate.${m.RTL_Field_Label__c}`);
                    m.RTL_Member_Lookup_Account__c = m.RTL_Member_Lookup_Account__c ? m.RTL_Member_Lookup_Account__c : m.RTL_Household__r.Name;
                    // Old Value
                    if (m.RTL_Field_Changed__c != 'RTL_Benefit__c') {
                        m.RTL_Prev_Value__c = m.RTL_Field_Changed__c == 'RTL_To_Delete__c' ? '' : m.RTL_Prev_Value__c;
                    } else if (m.RTL_Field_Changed__c == 'RTL_Benefit__c') {
                        m.RTL_Prev_Value__c = m.RTL_Prev_Value__c == 'true' ? 'Yes' : 'No';
                    } else {
                        m.RTL_Prev_Value__c = '';
                    }
                    // New Value
                    if (m.RTL_Field_Changed__c != 'RTL_Benefit__c') {
                        m.RTL_New_Value__c = m.RTL_Field_Changed__c == 'RTL_To_Delete__c' || m.RTL_Field_Changed__c == 'New Household' || m.RTL_Field_Changed__c == 'New Member' ?
                            '' : m.RTL_New_Value__c;
                    } else if (m.RTL_Field_Changed__c == 'RTL_Benefit__c') {
                        m.RTL_New_Value__c = m.RTL_New_Value__c == 'true' ? 'Yes' : 'No';
                    } else {
                        m.RTL_New_Value__c = '';
                    }
                    return m;
                }).sort((a, b) => a.Id > b.Id ? 1 : (a.Id < b.Id ? -1 : 0))
            );

            helper.changeRecordModify(component, event, helper);
            helper.updateRecord(component, 'RTL_History', component.get(`v.householdSectionInfoes.RTL_History.items`));
            var RTL_History = component.get(`v.householdSectionInfoes.RTL_History`);
            component.set(`v.householdSectionInfoes.RTL_History.paginationLabel`,
                `${$A.get('$Label.c.RTL_Page')} 1 of ${Math.ceil(RTL_History.items.length/RTL_History.offset)}`);
            component.set(`v.householdSectionInfoes.RTL_History.isDisabledNext`, Math.ceil(RTL_History.items.length / RTL_History.offset) == 1);
        }
    },
    handleHouseholdEdit: function (component, event, helper) {
        var navService = component.find('navService');
        navService.navigate({
            type: "standard__webPage",
            attributes: {
                url: `/one/one.app#${btoa(JSON.stringify({
                    "componentDef": `c:RTL_HouseHold_Creation`,
                    "attributes": {
                        "householdId": component.get('v.householdId'),
                        "householdMemberId": component.get('v.householdMemberId'),
                        "accountId": component.get('v.accountId'),
                        "tabId": component.get('v.tabId'),
                        "isEdit": true,
                        "uuid": component.get('v.theme') == 'Theme4t' ? 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                            let r = Math.random() * 16 | 0,
                                v = c == 'x' ? r : (r & 0x3 | 0x8);
                            return v.toString(16);
                        }) : '',     // Salesforce one app for replace page
                    }  
                }))}`
            }
        }, false);
    },
    handleNewHouseholdMember: function (component, event, helper) {
        var navService = component.find('navService');
        navService.navigate({
            type: "standard__webPage",
            attributes: {
                url: `/one/one.app#${btoa(JSON.stringify({
                    "componentDef": `c:RTL_HouseholdMember_Creation`,
                    "attributes": {
                        "householdId": component.get('v.householdId'),
                        "tabId": component.get('v.tabId'),
                        "uuid": 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
                            return v.toString(16);
                        }),
                    }
                }))}`
            }
        }, false);
    },
    handleEditHouseholdMember: function (component, event, helper) {
        var parameters = event.getParams();
        var householdMemberId = parameters.recordId;
        var navService = component.find('navService');
        navService.navigate({
            type: "standard__webPage",
            attributes: {
                url: `/one/one.app#${btoa(JSON.stringify({
                    "componentDef": `c:RTL_HouseholdMember_Creation`,
                    "attributes": {
                        "householdMemberId": householdMemberId,
                        "householdId": component.get(`v.householdId`),
                        "tabId": component.get('v.tabId'),
                    }
                }))}`
            }
        }, false);
    },
    handleHouseholdRequestDelete: function (component, event, helper) {
        var householdInfo = component.get('v.householdSectionInfoes.RTL_Household_Information');
        var memberListInfo = component.get('v.householdSectionInfoes.RTL_Household_Member');
        var approvalListInfo = component.get('v.householdSectionInfoes.RTL_Approval');

        var action = component.get('c.householdAction');
        action.setParams({
            "householdInfo": householdInfo,
            "memberListInfo": memberListInfo,
            "approvalListInfo": approvalListInfo,
            "actionType": 'RequestDelete'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                helper.displayToast('success', result);
                $A.get('e.force:refreshView').fire();
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, error.message);
                });
            }
            helper.stopSpinner(component);
        });

        if (confirm($A.get(`$Label.c.RTL_Confirm_Request_Delete_Household`))) {
            helper.startSpinner(component);
            $A.enqueueAction(action);
        }
    },
    handleSubmitForApproval: function (component, event, helper) {
        var householdInfo = component.get('v.householdSectionInfoes.RTL_Household_Information');
        var memberListInfo = component.get('v.householdSectionInfoes.RTL_Household_Member');
        var approvalListInfo = component.get('v.householdSectionInfoes.RTL_Approval');

        var action = component.get('c.householdAction');
        action.setParams({
            "householdInfo": householdInfo,
            "memberListInfo": memberListInfo,
            "approvalListInfo": approvalListInfo,
            "actionType": 'SubmitForApproval'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                helper.displayToast('success', result);
                $A.get('e.force:refreshView').fire();
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, error.message);
                });
            }
            helper.stopSpinner(component);
        });

        if (confirm($A.get(`$Label.c.RTL_Confirm_Submit_For_Approval`))) {
            helper.startSpinner(component);
            $A.enqueueAction(action);
        }
    },
    handleDeleteHouseholdMember: function (component, event, helper) {
        var parameters = event.getParams();
        var action = component.get('c.requestDeleteMember');
        action.setParams({
            "householdMemberId": parameters.recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                helper.displayToast('success', result);

                // Rerender data for RTL_Approval, RTL_History
                helper.getQueryDatabase(component, {
                    sObjectName: component.get('v.householdSectionInfoes.RTL_Approval.sObjectName'),
                    fields: component.get('v.householdSectionInfoes.RTL_Approval.fields'),
                    filter: component.get('v.householdSectionInfoes.RTL_Approval.filter'),
                }, 'RTL_Approval');
                helper.getQueryDatabase(component, {
                    sObjectName: component.get('v.householdSectionInfoes.RTL_History.sObjectName'),
                    fields: component.get('v.householdSectionInfoes.RTL_History.fields'),
                    filter: component.get('v.householdSectionInfoes.RTL_History.filter'),
                }, 'RTL_History');

            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, error.message);
                });
            }
            helper.stopSpinner(component);
        });

        if (confirm($A.get(`$Label.c.RTL_Confirm_Request_Delete_Household_Member`))) {
            helper.startSpinner(component);
            $A.enqueueAction(action);
        }
    },
    handleEditHouseholdApproval: function (component, event, helper) {
        var parameters = event.getParams();
        var navService = component.find('navService');
        navService.navigate({
            type: "standard__webPage",
            attributes: {
                url: `/one/one.app#${btoa(JSON.stringify({
                    "componentDef": `c:RTL_HouseHoldHistory_Edit`,
                    "attributes": {
                        "householdHistoryId": parameters.recordId,
                        "householdId": component.get(`v.householdId`),
                        "tabId": component.get('v.tabId'),
                    }  
                }))}`
            }
        }, false);

    },
    handleDeleteHouseholdApproval: function (component, event, helper) {
        var memberList = component.get(`v.householdSectionInfoes.RTL_Household_Member.items`);
        var approvalList = component.get(`v.householdSectionInfoes.RTL_Approval.items`);
        var historyList = component.get(`v.householdSectionInfoes.RTL_History.items`);

        var paramter = event.getParams();
        var thisRTLApproval = approvalList.find(f => f.Id == paramter.recordId);
        var cfLabel = thisRTLApproval.RTL_Field_Label__c == 'New Household' ? $A.get('$Label.c.RTL_Confirm_Delete') : $A.get('$Label.c.RTL_Confirm_Cancel_Create_Household');

        var action = component.get('c.deleteHouseholdHistoryApproval');
        action.setParams({
            "householdHistoryApprovalId": thisRTLApproval.Id,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();

                // Remove this history and approval 
                approvalList.splice(approvalList.findIndex(f => f.Id == paramter.recordId), 1);
                helper.updateRecord(component, 'RTL_Approval', approvalList);
                historyList.splice(historyList.findIndex(f => f.Id == paramter.recordId), 1);
                helper.updateRecord(component, 'RTL_History', historyList);

                if (!approvalList.some(s => s.RTL_Section__c == 'Household') && !memberList.some(s => s.RTL_Primary__c)) {
                    helper.closeTab(component);
                } else {
                    helper.displayToast('success', result);
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, error.message);
                });
            }
            helper.stopSpinner(component);
        });

        if (confirm(cfLabel)) {
            helper.startSpinner(component);
            $A.enqueueAction(action);
        }
    },
    handleApproveAll: function (component, event, helper) {
        var householdInfo = component.get('v.householdSectionInfoes.RTL_Household_Information');
        var memberListInfo = component.get('v.householdSectionInfoes.RTL_Household_Member');
        var approvalListInfo = component.get('v.householdSectionInfoes.RTL_Approval');

        var action = component.get('c.householdAction');
        action.setParams({
            "householdInfo": householdInfo,
            "memberListInfo": memberListInfo,
            "approvalListInfo": approvalListInfo,
            "actionType": 'approveAll'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                helper.displayToast('success', result);

                // Rerender data for RTL_Household_Member, RTL_Approval, RTL_History
                $A.get('e.force:refreshView').fire();

            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, error.message);
                });
            }
            helper.stopSpinner(component);
        });

        if (confirm($A.get(`$Label.c.RTL_Confirm_Approve_All`))) {
            helper.startSpinner(component);
            $A.enqueueAction(action);
        }
    },
    handleRejectAll: function (component, event, helper) {
        var householdInfo = component.get('v.householdSectionInfoes.RTL_Household_Information');
        var memberListInfo = component.get('v.householdSectionInfoes.RTL_Household_Member');
        var approvalListInfo = component.get('v.householdSectionInfoes.RTL_Approval');

        var action = component.get('c.householdAction');
        action.setParams({
            "householdInfo": householdInfo,
            "memberListInfo": memberListInfo,
            "approvalListInfo": approvalListInfo,
            "actionType": 'rejectAll'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                helper.displayToast('success', result);

                // Rerender data for RTL_Approval, RTL_History
                $A.get('e.force:refreshView').fire();
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, error.message);
                });
            }
            helper.stopSpinner(component);
        });

        if (confirm($A.get(`$Label.c.RTL_Confirm_Reject_All`))) {
            helper.startSpinner(component);
            $A.enqueueAction(action);
        }
    },
    handleSentEmail: function (component, event, helper) {
        var action = component.get('c.notifyRequestor');
        action.setParams({
            "householdId": component.get('v.householdId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                component.set(`v.householdButtonAccess.isNotifyRequestor`, false);
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, error.message);
                });
            }
            helper.stopSpinner(component);
        });
        if (confirm($A.get(`$Label.c.RTL_Confirm_Send_Email`))) {
            helper.startSpinner(component);
            $A.enqueueAction(action);
        }
    },
    onPaginator: function (component, event, helper) {
        var historyTable = component.find('historyTable');
        var btn = event.getSource();
        switch (btn.get('v.name')) {
            case 'first':
                historyTable.first();
                break;
            case 'previous':
                historyTable.previous();
                break;
            case 'next':
                historyTable.next();
                break;
            case 'last':
                historyTable.last();
                break;
            default:
                historyTable.reload();
                break;
        }
        component.set(`v.householdSectionInfoes.RTL_History.paginationLabel`,
            `${$A.get('$Label.c.RTL_Page')} ${historyTable.get('v.currentPage')} of ${historyTable.get('v.totalPage')}`);
        component.set(`v.householdSectionInfoes.RTL_History.isDisabledPrevious`, historyTable.get('v.isDisabledPrevious'));
        component.set(`v.householdSectionInfoes.RTL_History.isDisabledNext`, historyTable.get('v.isDisabledNext'));
    },

})