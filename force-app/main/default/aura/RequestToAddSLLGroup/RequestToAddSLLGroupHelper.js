({
    getRecord: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var tabInfo = JSON.parse(JSON.stringify(response));
            var PageObject = tabInfo.pageReference.attributes.objectApiName;
            component.set("v.PageObject", PageObject);
            if (PageObject == 'Account') {
                component.set("v.isAccount", true);
                var action = component.get("c.getAccRec");
                action.setParams({
                    recordId: recordId
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.acctRec", result);
                        component.set("v.onInit", false);
                        component.set("v.isLoading", false);

                    } else {
                        component.set("v.onInit", false);
                        component.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(action);
            } else {
                component.set("v.isAccount", false);
                var action = component.get("c.getGroupPAM");
                action.setParams({
                    GroupId: recordId
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.groupRec", result);
                        if (result.Is_Active__c)
                            component.set("v.onInit", false);
                        component.set("v.isLoading", false);

                    } else {
                        component.set("v.onInit", false);
                        component.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(action);
                helper.getPAM(component, event, helper);
            }

        })
        var action = component.get("c.getPickListValues");
        action.setCallback(this, function (response) {
            var pklist = response.getReturnValue();
            component.set("v.picklistValues", pklist);
        })
        $A.enqueueAction(action);
        component.set("v.onInit", false);
        component.set("v.isLoading", false);
    },
    getPAM: function (component, event, helper) {
        var isAccount = component.get("v.isAccount");
        var groupId

        if (isAccount == true) {
            groupId = component.get("v.searchGroupId")[0];
        } else if (isAccount == false) {
            groupId = component.get("v.recordId");
        }
        
        if (groupId) {

            var action = component.get("c.getGroupPAM");

            action.setParams({
                GroupId: groupId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();

                if(state === "SUCCESS" && component.isValid()) {
                    var result = response.getReturnValue();
                    if (!result.Is_Active__c) {
                        component.set("v.errHeaderMsg", $A.get("$Label.c.SLLGroupMessage15"));
                        component.set("v.isError", true);
                        component.set("v.isGroupInActive", true);
                    }
                    var checkPAM = result.hasOwnProperty('PAM__c');
                    if (checkPAM == true) {
                        var Pam = result.PAM__r.Name;
                        var PamId = result.PAM__c;
                        component.set("v.SLL_Group", result);
                        component.set("v.PAM_Id", PamId);
                        component.set("v.PAM_Name", Pam);
                        helper.getApprover(component, event, helper);
                    }
                    component.set("v.onInit", false);
                    component.set("v.isLoading", false);

                } else if(state === 'ERROR') {
                    component.set("v.onInit", false);
                    component.set("v.isLoading", false);
                    var errorRes = action.getError();
                    if (errorRes) {
                        if (errorRes[0] && errorRes[0].message) {
                            component.set("v.errMsg", errorRes[0].message);
                        }else{
                            component.set("v.errMsg", errorRes);
                        }
                    }else{
                        component.set("v.errMsg", errorRes);
                    }
                } else {
                    component.set("v.onInit", false);
                    component.set("v.isLoading", false);
                    var errorRes = action.getError();
                    component.set("v.errMsg", errorRes);
                }
            });
            $A.enqueueAction(action);
        }
    },
    getApprover: function (component, event, helper) {
        // component.set("v.onInit", true);
        component.set("v.isLoading", true);
        component.set("v.approverlst1", null);
        // component.set("v.approverlst2", null);
        component.set("v.hasApprover", false);
        var PAM_ID = component.get("v.PAM_Id");
        var action = component.get("c.getPAMapprover");
        action.setParams({
            userId: PAM_ID
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.approver1 != null ) {
                // if (result.approver1 != null && result.approver2 != null) {
                    const Approver1 = { isActive: result.approver1.IsActive, Id: result.approver1.Id, No: "Approver1", FirstName: result.approver1.FirstName, LastName: result.approver1.LastName, Title: result.approver1.Profile.Name };
                    // const Approver2 = { isActive: result.approver2.IsActive, Id: result.approver2.Id, No: "Approver2", FirstName: result.approver2.FirstName, LastName: result.approver2.LastName, Title: result.approver2.Profile.Name };
                    component.set("v.approverlst1", Approver1);
                    // component.set("v.approverlst2", Approver2);
                    component.set("v.hasApprover", true);
                } else {
                    component.set("v.errMsg", result.errMsg);
                    component.set("v.hasApprover", false);
                }
                component.set("v.onInit", false);
                component.set("v.isLoading", false);

            } else {
                component.set("v.onInit", false);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    createSLLGroupHistory: function (component, event, helper) {
        component.set("v.isLoading", true);
        //check approver1 and approver2 status active
        var IsApp1Active = component.get("v.approverlst1").isActive;
        // var IsApp2Active = component.get("v.approverlst2").isActive;

        if (IsApp1Active) {
        // if (IsApp1Active && IsApp2Active) {
            var isAccount = component.get("v.isAccount");

            var groupId;
            var cusId;

            if (isAccount) {
                groupId = component.get("v.searchGroupId");
                cusId = component.get("v.acctRec").Id;
            } else {
                groupId = component.get("v.groupRec").Id;
                cusId = component.get("v.searchCustomerId");
            }

            if (cusId != null && groupId != null && component.get("v.selectedReason") != "") {
                var action = component.get("c.createRecord");
                action.setParams({
                    GroupId: groupId,
                    CustomerId: cusId,
                    Reason: component.get("v.selectedReason"),
                    Approver1: component.get("v.approverlst1").Id,
                    // Approver2: component.get("v.approverlst2").Id
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.isLoading", false);
                        if (result === 'SUCCESS') {
                            helper.closeSubtab(component, event, helper);
                            helper.displayToast('success', $A.get("$Label.c.SLLGroupMessage17"))
                            helper.refreshFocusedTab(component, event, helper);
                        } else {
                            component.set("v.errHeaderMsg", result);
                            component.set("v.isError", true);
                        }
                    } else if(state === 'ERROR') {
                        component.set("v.isError", true);
                        component.set('v.isLoading', false);
                        var errorRes = action.getError();
                        
                        if (errorRes) {
                            if (errorRes[0] && errorRes[0].message) {
                                if(errorRes[0].message.includes("please select Existing Customer Type")) {
                                    component.set('v.errHeaderMsg', 'Please select Existing Customer Type.')
                                } else {
                                    component.set('v.errHeaderMsg', errorRes[0].message)
                                }
                            }else{
                                component.set('v.errHeaderMsg', errorRes)
                            }
                        }else{
                            component.set('v.errHeaderMsg', errorRes)
                        }
                    } else {
                        var errorRes = action.getError();
                        component.set("v.isError", true);
                        component.set('v.isLoading', false);
                        component.set("v.errHeaderMsg", errorRes);
                    }
                });
                $A.enqueueAction(action);
            } else {
                component.set("v.errHeaderMsg", $A.get("$Label.c.SLLGroupMessage7"));
                component.set("v.isError", true);
                component.set("v.isLoading", false);
            }
        } else {
            var errormsg;
            if (IsApp1Active == false) {
                errormsg = $A.get("$Label.c.SLLGroupMessage6");
            } 
            component.set("v.errHeaderMsg", errormsg);
            component.set("v.isError", true);
            component.set("v.isLoading", false);
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