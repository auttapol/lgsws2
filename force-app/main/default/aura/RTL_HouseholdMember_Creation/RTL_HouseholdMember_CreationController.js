({
    onInit: function (component, event, helper) {
        helper.doWorkspaceAPI(component);
        component.set(`v.householdMemberInfoes`, {
            RTL_Household__c: {
                label: '',
                type: '',
                value: component.get('v.householdId'),
            },
            RTL_Household_Member_Name__c: {
                label: '',
                type: '',
                value: '',
            }
        })
    },
    handleClose: function (component, event, helper) {
        helper.closeTab(component);
    },
    handleSectionToggle: function (component, event, helper) {
        component.set('v.activeSections', ['A']);
    },
    onLoad: function (component, event, helper) {
        helper.stopSpinner(component);
        var recordUi = event.getParams().recordUi;
        var objectInfo = recordUi.objectInfo.fields;
        var record = recordUi.record.fields;

        Object.keys(component.get(`v.householdMemberInfoes`)).forEach((fieldName, i) => {
            var thisField = component.get(`v.householdMemberInfoes.${fieldName}`);
            component.set(`v.householdMemberInfoes.${fieldName}`, {
                label: objectInfo[fieldName].label,
                type: objectInfo[fieldName].dataType,
                value: record[fieldName].value ? record[fieldName].value : thisField.value,
            });
        });
    },
    onSubmit: function (component, event, helper) {
        helper.startSpinner(component);
        event.preventDefault();
        var eventFields = event.getParam("fields");

        var action = component.get('c.getReference');
        action.setParams({
            "recordId": eventFields.RTL_Household_Member_Name__c,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var Name = response.getReturnValue();
                eventFields.Name = Name;
                component.find('recordEditForm').submit(eventFields);
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                });
            }
            helper.stopSpinner(component);
        });

        // is Edit
        if (component.get('v.householdMemberId')) {
            component.find('recordEditForm').submit();
        } else {
            if (eventFields.RTL_Household_Member_Name__c) $A.enqueueAction(action);
        }
    },
    onSuccess: function (component, event, helper) {
        helper.displayToast('success', `${$A.get('$Label.c.PDPA_Update_Success')}`);
        helper.stopSpinner(component);
        if (component.get('v.theme') == 'Theme4u') {
            helper.refreshTab(component, {
                isClose: true,
            });
        } else {
            helper.closeTab(component);
        }
    },
    onError: function (component, event, helper) {
        helper.stopSpinner(component);
        var params = event.getParams();
        // console.log(helper.parseObj(params));
        component.set('v.isModify', params.output.errors.some(s => ["INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY", "INSUFFICIENT_ACCESS"].includes(s.errorCode)));
        // helper.displayToast('error', params.message, params.detail);
    },
})