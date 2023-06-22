({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.fields', {
            'RTL_Household_Information': [{
                    fieldName: 'Name',
                    readonly: true,
                },
                {
                    fieldName: 'RTL_RM__c',
                    readonly: true,
                    hover: true,
                },
                {
                    fieldName: 'RTL_Benefit_Package__c',
                    readonly: false,
                    // required: true,
                },
                {
                    fieldName: 'RTL_Approver_UserName__c',
                    readonly: true,
                    type: "REFERENCE",
                    replace: 'RTL_RM__r.ManagerId',
                    hover: true,
                },
                {
                    fieldName: 'RTL_Remarks__c',
                    readonly: false,
                },
            ],
            'RTL_Household_Member': [{
                    fieldName: 'RTL_Household_Member_Name__c',
                    readonly: true,
                    hover: true,
                },
                {
                    fieldName: 'RTL_Primary__c',
                    readonly: true,
                },
                {
                    fieldName: 'RTL_Benefit__c',
                    readonly: true,
                },
            ]
        });
        if (component.get('v.isEdit')) {
            component.set('v.fieldInfoes', component.get('v.fields'));
            helper.getDescribeFieldResultAndValue(component,
                component.get('v.householdId'), 'RTL_HouseHold__c',
                component.get('v.fields.RTL_Household_Information')
                .map(m => m.fieldName).concat(component.get('v.fields.RTL_Household_Information').reduce((l, i) => {
                    if (i.replace) {
                        l.push(i.replace)
                    }
                    return l;
                }, [])),
                'RTL_Household_Information');
            helper.getDescribeFieldResultAndValue(component,
                component.get('v.householdMemberId'), 'RTL_HouseHold_Member__c',
                component.get('v.fields.RTL_Household_Member').map(m => m.fieldName),
                'RTL_Household_Member');
        } else {
            helper.getInitialHousehold(component, event, helper);
        }
    },
    handleHousehold: function (component, event, helper) {
        helper.getModifyHousehold(component);
    },
    handleClose: function (component, event, helper) {
        helper.closeTab(component);
    },
    handleSectionToggle: function (component, event, helper) {
        component.set('v.activeSections', ['A', 'B']);
    },
    onLoad: function (component, event, helper) {
        helper.stopSpinner(component);
        if (component.get('v.isEdit')) {
            var recordUi = event.getParams().recordUi;
            helper.doWorkspaceAPI(component, recordUi.record.fields.Name.value);
            component.set(`v.householdReference.RTL_HouseHold__c`, {
                Name: recordUi.record.fields.Name.value,
                RTL_RM__c: recordUi.record.fields.RTL_RM__c.value,
            });
        }
    },
    onSubmit: function (component, event, helper) {
        helper.startSpinner(component);
        event.preventDefault();
        var eventFields = event.getParam("fields");

        if (component.get('v.isEdit')) {
            component.find('recordEditForm').submit(eventFields);
        } else {
            helper.saveHousehold(component, event, helper);
        }
    },
    onSuccess: function (component, event, helper) {
        helper.stopSpinner(component);
        helper.displayToast('success', `${$A.get('$Label.c.PDPA_Update_Success')}`, '');
        if (component.get('v.isEdit')) {
            helper.refreshTab(component, {
                isClose: true
            });
        } else {
            helper.openTab(component);
        }
    },
    onError: function (component, event, helper) {
        helper.stopSpinner(component);
        var params = event.getParams();
        console.log(helper.parseObj(params));
        component.set('v.isModify', !params.output.errors.some(s => ["INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY", "INSUFFICIENT_ACCESS"].includes(s.errorCode)));
    },
})