({
    onInit: function (component, event, helper) {
        var action = component.get("c.getContactDetail");
        action.setParams({
            conId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // console.log(state);
            if (state === "SUCCESS") {
                var contact = response.getReturnValue();
                component.set('v.isVerified', contact.IsVerified__c);
                component.set('v.isTBankData', contact.IsTBankData__c);
                component.set('v.contact', contact);
            } else {
                var errors = response.getError();
                // console.log("Verify failed: ", errors);
                helper.showToast('Verify failed.', 'Error');
            }
        });
        $A.enqueueAction(action);
    },

    activeClick: function (component, event, helper) {
        var action = component.get("c.UpdateContact");
        action.setParams({
            conId: component.get("v.recordId"),
            isActive: true
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // console.log(state);
            if (state === "SUCCESS") {
                // console.log('Active success!');
                helper.refreshFocusedTab(component, event, helper);
            } else {
                var errors = response.getError();
                console.log("Active failed: ", errors);
                helper.showToast('Active failed.', 'Error');
            }
        });
        $A.enqueueAction(action);

    },

    inactiveClick: function (component, event, helper) {
        var action = component.get("c.UpdateContact");
        action.setParams({
            conId: component.get("v.recordId"),
            isActive: false
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // console.log(state);
            if (state === "SUCCESS") {
                // console.log('InActive success!');
                helper.refreshFocusedTab(component, event, helper);
            } else {
                var errors = response.getError();
                // console.log("InActive failed: ", errors);
                helper.showToast('InActive failed.', 'Error');
            }
        });
        $A.enqueueAction(action);

    },

    closeClick: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
    },
})