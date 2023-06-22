({
    onInit: function (component, event, helper) {
        component.set(`v.householdHistoryInfoes`, {
            RTL_Household_Information: {
                isRender: false,
                fields: [{
                        fieldName: 'RTL_Household__c',
                    },
                    {
                        fieldName: 'RTL_HH_RM_BM__c',
                        hover: true,
                    },
                    {
                        fieldName: 'RTL_HH_Req_Benefit_Package__c',
                    },
                    {
                        fieldName: 'RTL_HH_Req_Remarks__c',
                    },
                ],
            },
            RTL_Household_And_Member_Information: {
                isRender: false,
                fields: [{
                        fieldName: 'RTL_Household__c',
                    },
                    {
                        fieldName: 'RTL_HH_RM_BM__c',
                        hover: true,
                    },
                    {
                        fieldName: 'RTL_Member_Lookup_Account__c',
                        hover: true,
                    },
                    {
                        fieldName: 'RTL_HHM_Relationship__c',
                    },
                    {
                        fieldName: 'RTL_HHM_Benefit__c',
                    },
                ],
            },
            RTL_Request_Details: {
                fields: [{
                        fieldName: 'RTL_Field_Label_Display__c',
                    },
                    {
                        fieldName: 'RTL_User_Requesting__c',
                        hover: true,
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
                ]
            },
            // RTL_Approval_Details: {
            //     fields: [
            //         'RTL_Outcome__c',
            //     ]
            // },
        });

        helper.getDescribeFieldResultAndValue(component, {
            recordId: component.get(`v.householdHistoryId`),
            sObjectAPIName: 'RTL_Household_History_and_Approval__c',
            fields: component.get(`v.householdHistoryInfoes.RTL_Household_Information.fields`).map(m => m.fieldName),
            section: 'RTL_Household_Information'
        });
        helper.getDescribeFieldResultAndValue(component, {
            recordId: component.get(`v.householdHistoryId`),
            sObjectAPIName: 'RTL_Household_History_and_Approval__c',
            fields: component.get(`v.householdHistoryInfoes.RTL_Household_And_Member_Information.fields`).map(m => m.fieldName),
            section: 'RTL_Household_And_Member_Information'
        });
        helper.getDescribeFieldResultAndValue(component, {
            recordId: component.get(`v.householdHistoryId`),
            sObjectAPIName: 'RTL_Household_History_and_Approval__c',
            fields: component.get(`v.householdHistoryInfoes.RTL_Request_Details.fields`).map(m => m.fieldName)
                .concat('RTL_Field_Changed__c'),
            section: 'RTL_Request_Details'
        });
    },
    handleActiveSections: function (component, event, helper) {
        component.set(`v.activeSections`, ['A', 'B', 'C', 'D']);
    },
    handleClose: function (component, event, helper) {
        helper.closeTab(component);
    },
    onLoad: function (component, event, helper) {
        helper.stopSpinner(component);
        var paramenters = event.getParams();
        if (component.get('v.householdHistoryId')) {
            var section = paramenters.recordUi.record.fields.RTL_Section__c.value === $A.get('$Label.c.RTL_Member');

            component.set(`v.householdHistoryInfoes.RTL_Household_Information.isRender`, section ? false : true);
            component.set(`v.householdHistoryInfoes.RTL_Household_And_Member_Information.isRender`, section ? true : false);

            component.set(`v.oldOutcome`, paramenters.recordUi.record.fields.RTL_Outcome__c.value);
            component.set(`v.householdHistoryRcordTypeId`, paramenters.recordUi.record.recordTypeId);
            component.set(`v.householdHistoryInfoes.title`, paramenters.recordUi.record.fields.Name.value);
            helper.doWorkspaceAPI(component, component.get(`v.householdHistoryInfoes.title`));

            component.set(`v.activeSections`, ['A', 'B', 'C', 'D']);
            component.set(`v.isRerended`, true);
            component.set(`v.isModify`, component.get(`v.oldOutcome`) == 'Pending');
        }
    },
    onSubmit: function (component, event, helper) {
        event.preventDefault();
        helper.startSpinner(component);

        var paramenters = event.getParams();
        var action = component.get(`c.saveHouseholdhistory`);
        action.setParams({
            oldOutcome: component.get('v.oldOutcome'),
            newOutcome: paramenters.fields.RTL_Outcome__c,
            historyRecordId: component.get('v.householdHistoryId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                helper.displayToast('success', result);
                helper.refreshTab(component, {
                    isClose: true,
                });
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message, error.message);
                });
            }
            helper.stopSpinner(component);
        });
        if (paramenters.fields.RTL_Outcome__c)
            $A.enqueueAction(action);
    },
    onSuccess: function (component, event, helper) {

    },
    onError: function (component, event, helper) {
        helper.stopSpinner(component);
        var params = event.getParams();
        component.set(`v.isShowOldNew`, false);
        component.set('v.isModify', !params.output.errors.some(s => ["INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY", "INSUFFICIENT_ACCESS"].includes(s.errorCode)));
        // helper.displayToast('error', params.message, params.detail);
    },

})