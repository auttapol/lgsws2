({
    checkPAMAndPrimCus: function (component, primCusId, sgName, pamId) {
        let action = component.get("c.getSLLGroupOfCustomer");
        action.setParams({
            "recordId": primCusId,
            "groupName": sgName,
        });
        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state == "SUCCESS") {
                let result = response.getReturnValue();
                if (result.length > 0) {
                    component.set('v.isLoading', false);
                    component.set('v.headerErrorMsg', $A.get("$Label.c.SLLGroupMessage13"))
                } else {
                    this.checkPAMApprover(component, pamId)
                }
            } else if(state === 'ERROR') {
                var errorRes = action.getError();
                
                if (errorRes) {
                    if (errorRes[0] && errorRes[0].message) {
                        if(errorRes[0].message.includes("The Primary Customer is already in another SLL Group")) {
                            component.set('v.headerErrorMsg', $A.get("$Label.c.SLLGroupMessage13"))
                        } else if(errorRes[0].message.includes("This record is currently in an approval process.")){
                            component.set('v.headerErrorMsg',  $A.get("$Label.c.RequestChangeOwnerMessage2"))
                        } else {
                            component.set('v.headerErrorMsg', errorRes[0].message)
                        }
                    }else{
                        component.set('v.headerErrorMsg', errorRes)
                    }
                }else{
                    component.set('v.headerErrorMsg', errorRes)
                }
                component.set('v.isLoading', false);
            } else {
                var errorRes = action.getError();
                component.set('v.headerErrorMsg', errorRes)
                component.set('v.isLoading', false);
            }
            // component.set("v.primCusErrMsg", errMsg);

        })
        $A.enqueueAction(action)
    },

    checkPAMApprover: function (component, userId) {
        let action = component.get("c.getPAMApprover");
        action.setParams({
            "userId": userId
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let errMsg = null;
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                // console.log(result);
                if (result.approver1) {
                // if (result.approver1 && result.approver2) {
                    if (!result.approver1.IsActive) {
                        component.set('v.headerErrorMsg', $A.get("$Label.c.SLLGroupMessage6"))
                    // } else if (!result.approver2.IsActive) {
                    //     component.set('v.headerErrorMsg', $A.get("$Label.c.SLLGroupMessage2"))
                    } else {
                        component.set("v.approver1", result.approver1);
                        // component.set("v.approver2", result.approver2);

                        let sgName = component.get('v.newSG.Name');
                        let sgPrimCus = component.get('v.newSG.Primary_Customer__c');
                        let sgPAM = component.get('v.newSG.PAM__c');
                        let sgRemark = component.get('v.newSG.Remark__c');
                        if (sgName && sgPrimCus && sgPAM && sgRemark && !component.get('v.headerErrorMsg')) {
                            component.set("v.isSelectingCustomer", true);
                        }

                    }
                } else {
                    component.set('v.headerErrorMsg', $A.get("$Label.c.SLLGroupMessage3"))
                    console.log("error001");
                }
            } else if(state === 'ERROR') {
                var errorRes = action.getError();
                
                if (errorRes) {
                    if (errorRes[0] && errorRes[0].message) {
                        if(errorRes[0].message.includes("The Primary Customer is already in another SLL Group")) {
                            component.set('v.headerErrorMsg', $A.get("$Label.c.SLLGroupMessage13"))
                        } else if(errorRes[0].message.includes("This record is currently in an approval process.")){
                            component.set('v.headerErrorMsg', $A.get("$Label.c.RequestChangeOwnerMessage2"))
                        } else {
                            component.set('v.headerErrorMsg', errorRes[0].message)
                        }
                    }else{
                        component.set('v.headerErrorMsg', errorRes)
                    }
                }else{
                    component.set('v.headerErrorMsg', errorRes)
                }
            } else {
                var errorRes = action.getError();
                component.set('v.headerErrorMsg', errorRes)
            }
            component.set('v.isLoading', false);
            
        }); // prepare callout
        $A.enqueueAction(action)
    },
    
    createSLLGroup: function (component, closeTab, gName, primCusId, pamUsrId, approverId1, inpRemark, memberList) {
    // createSLLGroup: function (component, closeTab, gName, primCusId, pamUsrId, approverId1, approverId2, inpRemark, memberList) {
        if (!component.get('v.headerErrorMsg')) {
            component.set('v.isLoading', true);
            let action = component.get("c.createSLLGroup");
            action.setParams({
                "gName": gName,
                "primCusId": primCusId,
                "userId": pamUsrId,
                "approverId1": approverId1,
                "inpRemark": inpRemark,
                "memberList": memberList,
            });
            action.setCallback(this, function (response) {
                let state = response.getState();

                if (state === "SUCCESS") {
                    
                    let result = response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "SLL Group has been created.",
                        type: "success"
                    });
                    toastEvent.fire();

                    if (closeTab) {
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.openTab({
                                pageReference: {
                                    "type": "standard__recordPage",
                                    "attributes": {
                                        "recordId": result.Id,
                                        "actionName": "view"
                                    },
                                    "state": {}
                                },
                                focus: true
                            }).then(function (response) {
                                workspaceAPI.closeTab({ tabId: focusedTabId });
                                workspaceAPI.getTabInfo({
                                    tabId: response

                                });
                            }).catch(function (error) {
                                console.log(error);
                            });
                        });
                    }else{
                        this.clearGroupInfo(component);
                        this.clearMember(component);
                    }
                    component.set('v.isLoading', false);
                } else if(state === 'ERROR') {
                    var errorRes = action.getError();
                    
                    if (errorRes) {
                        if (errorRes[0] && errorRes[0].message) {
                            if(errorRes[0].message.includes("The Primary Customer is already in another SLL Group")) {
                                component.set('v.headerErrorMsg',  $A.get("$Label.c.SLLGroupMessage13"))
                            } else if(errorRes[0].message.includes("This record is currently in an approval process.")){
                                component.set('v.headerErrorMsg', $A.get("$Label.c.RequestChangeOwnerMessage2"))
                            } else {
                                component.set('v.headerErrorMsg', errorRes[0].message)
                            }
                        }else{
                            component.set('v.headerErrorMsg', errorRes)
                        }
                    }else{
                        component.set('v.headerErrorMsg', errorRes)
                    }
                    component.set('v.isLoading', false);
                } else {
                    var errorRes = action.getError();
                    component.set('v.headerErrorMsg', errorRes)
                    component.set('v.isLoading', false);
                }
            });

            $A.enqueueAction(action)
        }
    },

    filterMember: function (cmp, event, helper) {
        let resMemberList = [];
        let memberLst = cmp.get("v.memberList");
        let curMemberList = JSON.parse(JSON.stringify(memberLst));
        // console.log('Check member list',curMemberList);
        for (let i = 0; i < curMemberList.length; i++) {
            let member = curMemberList[i];
            if (member.Customer_Name__c && member.Customer_Name__c.length > 0) {
                member.Id = member.Customer_Name__c;
                if (!member.Reason__c) {
                    cmp.set("v.headerErrorMsg", $A.get("$Label.c.SLLGroupMessage9"));
                    return false;
                } else {
                    for (let j = 0; j < curMemberList.length; j++) {
                        let member2 = curMemberList[j];
                        if (i != j &&
                            member.Customer_Name__c == member2.Customer_Name__c) {
                            cmp.set("v.headerErrorMsg", $A.get("$Label.c.SLLGroupMessage1"));
                            return false;
                        }
                    }
                    resMemberList.push(member);
                }
            }
        }
        return resMemberList;
    },

    clearMember: function (cmp) {
        cmp.set("v.isSelectingCustomer", false);
        let defaultCusList = [
            { 'sobjectType': 'SLL_Group_Member__c', 'Id': null, 'Customer_Name__c': null, 'Name': '', 'Reason__c': '' },
            { 'sobjectType': 'SLL_Group_Member__c', 'Id': null, 'Customer_Name__c': null, 'Name': '', 'Reason__c': '' },
            { 'sobjectType': 'SLL_Group_Member__c', 'Id': null, 'Customer_Name__c': null, 'Name': '', 'Reason__c': '' },
            { 'sobjectType': 'SLL_Group_Member__c', 'Id': null, 'Customer_Name__c': null, 'Name': '', 'Reason__c': '' },
            { 'sobjectType': 'SLL_Group_Member__c', 'Id': null, 'Customer_Name__c': null, 'Name': '', 'Reason__c': '' }];
        cmp.set("v.memberList", defaultCusList);
    },

    clearGroupInfo: function (cmp) {
        cmp.set('v.primCusErrMsg', null);
        cmp.set('v.pamErrMsg', null);
        cmp.set('v.newSG', {
            'sobjectType': 'SLL_Group__c',
            'Name': '',
            'Primary_Customer__c': '',
            'PAM__c': '',
            'Remark__c': ''
        })
        cmp.set('v.approver1', null);
        // cmp.set('v.approver2', null);
    },

    getReasonList: function(cmp) {
        let action = cmp.get("c.getReasonList");
        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state == "SUCCESS") {
                let result = response.getReturnValue();
                if (result.length > 0) {
                    cmp.set('v.reasonList', result);
                }
            }

        })
        $A.enqueueAction(action)
    },
})