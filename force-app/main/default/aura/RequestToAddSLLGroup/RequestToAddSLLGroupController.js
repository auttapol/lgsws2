({
    doInit: function (component, event, helper) {
        component.set("v.onInit", true);
        component.find("cbutton").focus();
        helper.getRecord(component, event, helper);
    },

    selectGroup: function (component, event, helper) {
        var isAccount = component.get("v.isAccount");
        if (isAccount == true) {
            var selectedGroup = component.get("v.searchGroupId")[0];
            component.set("v.PAM_Name", "-");
            component.set("v.SLL_Group", null);
            component.set("v.approverlst1", null);
            // component.set("v.approverlst2", null);
            component.set("v.hasApprover", false);
            component.set("v.errMsg", $A.get("$Label.c.SLLGroupMessage8"));
            component.set("v.isError", false);
            if (selectedGroup) {
                helper.getPAM(component, event, helper);
            }
        }
    },

    selectCustomer: function (component, event, helper) {
        component.set("v.isError", false);
    },

    selectReason: function (component, event, helper) {
        component.set("v.isError", false);
    },

    handleConfirm: function (component, event, helper) {
        if (component.get("v.SLL_Group") != null) {
            var IsActive = component.get("v.SLL_Group").Is_Active__c;
            var hasAppr = component.get("v.hasApprover");
            if (IsActive) {
                if (hasAppr) {
                    helper.createSLLGroupHistory(component, event, helper);
                } else {
                    component.set("v.errHeaderMsg", $A.get("$Label.c.SLLGroupMessage3"));
                    component.set("v.isError", true);
                }
            } else {
                component.set("v.errHeaderMsg", $A.get("$Label.c.SLLGroupMessage15"));
                component.set("v.isError", true);
            }
        } else {
            component.set("v.errHeaderMsg", $A.get("$Label.c.SLLGroupMessage7"));
            component.set("v.isError", true);
        }
    },

    handleCancel: function (component, event, helper) {
        helper.closeSubtab(component, event, helper);
    },
})