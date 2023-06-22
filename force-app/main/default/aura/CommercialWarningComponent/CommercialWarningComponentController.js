({
    onInit : function(component, event, helper) {
        var action = component.get("c.getContactDetail");
        action.setParams({
            conId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var contact = response.getReturnValue();
                component.set('v.isVerified', contact.IsVerified__c);
                component.set('v.isTBankData', contact.IsTBankData__c);
            } else {
                var errors = response.getError();
                // console.log("Verify failed: ", errors);
                helper.showToast('Verify failed.', 'Error');
            }
        });
        $A.enqueueAction(action);
    }
})