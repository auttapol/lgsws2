({
    doInit: function (cmp, event, helper) {
        helper.clearMember(cmp);
        helper.getReasonList(cmp);
    },

    clickNext: function (component, event, helper) {
        // validate form
        component.set('v.headerErrorMsg', null);

        let sgName = component.get('v.newSG.Name');
        let sgPrimCus = component.get('v.newSG.Primary_Customer__c');
        let sgPAM = component.get('v.newSG.PAM__c');
        let sgRemark = component.get('v.newSG.Remark__c');
        if (sgName && JSON.parse(JSON.stringify(sgPrimCus)).length > 0 && JSON.parse(JSON.stringify(sgPAM)).length > 0 && sgRemark) {
            component.set('v.isLoading', true);
            helper.checkPAMAndPrimCus(component, sgPrimCus, sgName, sgPAM)
        } else {
            component.set('v.headerErrorMsg', $A.get("$Label.c.SLLGroupMessage7"))
        }
    },

    clickAddMoreCustomer: function (cmp, event, helper) {
        let cusList = cmp.get("v.memberList");
        cusList.push({ 'sobjectType': 'SLL_Group_Member__c', 'Id': null, 'Name': '', 'Reason__c': '' });

        cmp.set("v.memberList", cusList);
    },

    clickCancel: function (cmp, event, helper) {
        cmp.set("v.headerErrorMsg", null);
        helper.clearMember(cmp);
    },

    clickSave: function (cmp, event, helper) {
        cmp.set("v.headerErrorMsg", null);
        let gName = cmp.get("v.newSG.Name");
        let primCusId = cmp.get("v.newSG.Primary_Customer__c");
        let pamUsrId = cmp.get("v.newSG.PAM__c");
        let approver1 = cmp.get("v.approver1");
        // let approver2 = cmp.get("v.approver2");
        let inpRemark = cmp.get("v.newSG.Remark__c");
        let memberList = helper.filterMember(cmp, event, helper);
        helper.createSLLGroup(cmp, true, gName, primCusId, pamUsrId, approver1.Id, inpRemark, memberList);
        // helper.createSLLGroup(cmp, true, gName, primCusId, pamUsrId, approver1.Id, approver2.Id, inpRemark, memberList)
    },

    clickSaveAndNew: function (cmp, event, helper) {
        cmp.set("v.headerErrorMsg", null);
        let gName = cmp.get("v.newSG.Name");
        let primCusId = cmp.get("v.newSG.Primary_Customer__c");
        let pamUsrId = cmp.get("v.newSG.PAM__c");
        let approver1 = cmp.get("v.approver1");
        // let approver2 = cmp.get("v.approver2");
        let inpRemark = cmp.get("v.newSG.Remark__c");
        let memberList = helper.filterMember(cmp, event, helper);
        helper.createSLLGroup(cmp, false, gName, primCusId, pamUsrId, approver1.Id, inpRemark, memberList);
        // helper.createSLLGroup(cmp, false, gName, primCusId, pamUsrId, approver1.Id, approver2.Id, inpRemark, memberList);

    },

    closeError: function (cmp, event, handler) {
        cmp.set("v.headerErrorMsg", null);

    },

    customerSelect: function (cmp, event, handler) {
        let params = event.getParam('arguments');
        if (params) {
            let extractParams = JSON.parse(JSON.stringify(params));
            let memberList = JSON.parse(JSON.stringify(cmp.get("v.memberList")));
            for (let i = 0; i < memberList.length; i++) {
                let member = memberList[i];
                if (member.Customer_Name__c && member.Customer_Name__c == extractParams.customerId && i != params.idx) {
                    // duplicated customer
                    cmp.set("v.headerErrorMsg", $A.get("$Label.c.SLLGroupMessage1"));
                    memberList[params.idx] = { 'sobjectType': 'SLL_Group_Member__c', 'Id': null, 'Customer_Name__c': null, 'Name': '', 'Reason__c': '' };
                    return false;
                }
            }
            return true;
        }
    },
    closeTab: function (cmp, event, helper) {
        let workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        });
    }
})