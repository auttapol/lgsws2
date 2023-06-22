({
    handleLoadRecord : function(cmp, event, helper) {
        cmp.set('v.isLoading', false);
    },

    clickCancel : function(cmp, event, helper) {
        let dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();

    },

    clickConfirm : function(cmp, event, helper) {
        if(cmp.get("v.curSLLGroup.Is_Active__c") && cmp.get("v.curSLLGroup.RecordType.Name") == 'Available') {
            cmp.set("v.isLoading", true);
            helper.requestToInactiveSLLGroup(cmp, cmp.get("v.recordId"), cmp.get("v.requestComment"));
        } else {
            helper.toastError($A.get("$Label.c.SLLGroupMessage16"));
        }
    },

    onLoadForm : function(cmp, event, helper) {
        cmp.set("v.isLoading",false);
    }
})