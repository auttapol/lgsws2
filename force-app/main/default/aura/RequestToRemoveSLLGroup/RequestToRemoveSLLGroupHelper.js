({
    getRecord: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        component.set("v.approver1", null);
        // component.set("v.approver2", null);
        component.set("v.hasApprover", false);
        var initGroupRec = {
            Name: '-',
            SLL_Group__r: { Name: '-' },
            Customer_Name__r: { Name: '-' }
        };
        component.set("v.groupMemRec", initGroupRec);
        var action = component.get("c.getGroupMemRec");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                if (!result.groupMember.SLL_Group__r.Is_Active__c) {
                    component.set("v.errHeaderMsg", "Can't request to add SLL Group due status Inactive.");
                    component.set("v.isError", true);
                    component.set("v.isGroupInActive", true);
                }
                component.set("v.groupMemRec", result.groupMember);
                if (!result.hasOwnProperty('errMsg')) {
                    if (result.hasOwnProperty('approver1')) {
                    // if (result.hasOwnProperty('approver1') && result.hasOwnProperty('approver2')) {
                        const Approver1 = { isActive: result.approver1.IsActive, Id: result.approver1.Id, No: "Approver1", FirstName: result.approver1.FirstName, LastName: result.approver1.LastName, Title: result.approver1.Profile.Name };
                        // const Approver2 = { isActive: result.approver2.IsActive, Id: result.approver2.Id, No: "Approver2", FirstName: result.approver2.FirstName, LastName: result.approver2.LastName, Title: result.approver2.Profile.Name };
                        component.set("v.approver1", Approver1);
                        // component.set("v.approver2", Approver2);
                        component.set("v.hasApprover", true);
                    } else {
                        component.set("v.errMsg", $A.get("$Label.c.SLLGroupMessage2"));
                        component.set("v.hasApprover", false);
                        component.set("v.isError", true);
                    }
                } else {
                    component.set("v.errHeaderMsg", result.errMsg);
                    component.set("v.errMsg", result.errMsg);
                    component.set("v.isError", true);
                }
            } else {
                var errors = response.getError();
                errors.forEach((error) => {
                    component.set("v.errHeaderMsg", error.message);
                });
                component.set("v.isError", true);
                component.set("v.onInit", false);
                component.set("v.isLoading", false);
            }
        });
        component.set("v.onInit", false);
        component.set("v.isLoading", false);
        $A.enqueueAction(action);
    },
    createSLLGroupHistory: function (component, event, helper) {
        if (!component.get("v.isError")) {
            component.set("v.isLoading", true);
            var IsApp1Active = component.get("v.approver1").isActive;
            // var IsApp2Active = component.get("v.approver2").isActive;
            if (IsApp1Active) {
            // if (IsApp1Active && IsApp2Active) {
                var groupmember = component.get("v.groupMemRec");
                if (groupmember.SLL_Group__c != null && groupmember.Customer_Name__c != null) {
                    //create record remove
                    var groupId = groupmember.SLL_Group__c;
                    var cusId = groupmember.Customer_Name__c;
                    var reason = groupmember.Reason__c;
                    var action = component.get("c.createRecord");
                    action.setParams({
                        recordId: component.get("v.recordId"),
                        GroupId: groupId,
                        CustomerId: cusId,
                        Reason: reason,
                        Approver1: component.get("v.approver1").Id
                        // ,Approver2: component.get("v.approver2").Id
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            var result = response.getReturnValue();
                            component.set("v.isLoading", false);
                            if (result === 'SUCCESS') {
                                helper.closeSubtab(component, event, helper);
                                helper.displayToast('success', $A.get("$Label.c.SLLGroupMessage17"));
                                helper.refreshFocusedTab(component, event, helper);
                            }
                            else {
                                component.set("v.errHeaderMsg", result);
                                component.set("v.isError", true);
                            }
                        } else {
                            component.set("v.isLoading", false);
                        }
                    });
                    $A.enqueueAction(action);
                } else {
                    component.set("v.errHeaderMsg", "This Group Member don't have SLL Group or Customer.");
                    component.set("v.isError", true);
                    component.set("v.isLoading", false);
                }
            } else {
                var errormsg;
                if (IsApp1Active == false) {
                    // errormsg = $A.get("$Label.c.SLLGroupMessage4");;
                    errormsg = $A.get("$Label.c.SLLGroupMessage6");;
                } 
                // if (IsApp1Active == false && IsApp2Active == false) {
                //     errormsg = $A.get("$Label.c.SLLGroupMessage5");;
                // } else if (IsApp1Active == false && IsApp2Active == true) {
                //     errormsg = $A.get("$Label.c.SLLGroupMessage6");;
                // } else if (IsApp1Active == true && IsApp2Active == false) {
                //     errormsg = $A.get("$Label.c.SLLGroupMessage2");;
                // }
                component.set("v.errHeaderMsg", errormsg);
                component.set("v.isError", true);
                component.set("v.isLoading", false);
            }
        }
    },
    closeSubtab: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    refreshFocusedTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                tabId: focusedTabId,
                includeAllSubtabs: false
            });
        })
    }
})