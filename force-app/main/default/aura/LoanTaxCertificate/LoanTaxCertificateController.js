({
    onInit: function(component, event, helper) {
        helper.startSpinner(component);
        helper.setTabDetail(component, event, helper);

        var pageRef = component.get('v.pageReference');

        // component.set('v.passRMID', pageRef.state.c__rmId ? pageRef.state.c__rmId : '');
        component.set('v.passAccountType', pageRef.state.c__accountType ? pageRef.state.c__accountType : 'com.fnis.xes.AL');

        // var passAcctNo = pageRef.state.c__accountNo ? pageRef.state.c__accountNo : null;

        if (component.get('v.accountNo')) {
            component.set('v.isSearchAble', false);
            helper.getOSC04Data(component, helper);
        } else {
            helper.getSearchPermission(component, helper);
        }

        helper.getWatermarkHTML(component);

    },

    searchAccountNo: function(component, event, helper) {
        component.set('v.isViewForm', true);
        helper.resetForm(component);
        helper.startSpinner(component);

        if (!component.get('v.accountNo')) component.set('v.accountNo', component.get('v.displayAccountNo'));

        var action = component.get('c.getSearchBtnPermission');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (result == true) {
                    if (component.get('v.accountNo')) {
                        helper.getOSC04Data(component, helper);
                    } else {
                        helper.stopSpinner(component);
                        helper.displayToast('error', 'Please input Account Number.');
                    }
                } else if (result == false) {
                    helper.stopSpinner(component);
                    component.set('v.isSearchAble', false);
                    component.set('v.isError.noData', true);
                } else {
                    helper.stopSpinner(component);
                    component.set('v.isError.noData', true);
                }

            } else if (response.getState() === "ERROR") {
                helper.stopSpinner(component);
                component.set('v.isError.noData', true);
            }
        });

        $A.enqueueAction(action);
    },

    editForm: function(component, event, helper) {
        component.set('v.isViewForm', false);
    },

    saveForm: function(component, event, helper) {
        component.set('v.isSaveSuccess', {});
        for (var i = 0; i <= 5; i++) {
            var coborrower = helper.parseObj(component.get(`v.taxForm.coborrower${i}`));
            coborrower.currentFlag = component.get(`v.taxForm.coborrower${i}.currentFlag`);
            if (coborrower.editable && coborrower.currentFlag) {
                if (coborrower.oldFlag != coborrower.currentFlag) {
                    component.set(`v.isError.saveForm.co${i}`, false);
                    helper.startSpinner(component);
                    helper.saveConsent(component, helper, coborrower, i);
                }
            }
        }
        component.set('v.isViewForm', true);
    },

    cancelEditForm: function(component, event, helper) {
        for (var i = 0; i <= 5; i++) {
            var curFlag = component.get(`v.taxForm.coborrower${i}.currentFlag`);
            var oldFlag = component.get(`v.taxForm.coborrower${i}.oldFlag`);

            if (oldFlag == 'Y') { oldFlag = 'Yes'; } else if (oldFlag == 'N') { oldFlag = 'No'; }

            if (curFlag != oldFlag) {
                component.set(`v.taxForm.coborrower${i}.currentFlag`, oldFlag)
            }
        }
        component.set('v.isViewForm', true);
    },
})