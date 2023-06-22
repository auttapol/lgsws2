({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    displayToast: function (component, type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    closeTab: function (component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function (error) {
                console.log(error);
            });
    },
    getLeadByReferralId: function (component, event, helper) {
        var action = component.get('c.getLeadByReferralId');
        action.setParams({
            recordId: component.get('v.recordId') ? component.get('v.recordId') : component.get('v.pageReference.state.c__recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.leads', result ? result : []);
            } else {
                component.set('v.leads', []);
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    closeActionOrTab: function (component, event, helper) {
        if (component.get('v.isReletedList')) {
            helper.closeTab(component);
        } else {
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    navigateToCreateRecord: function (component, referralObj) {
        var theme = component.get('v.theme');
        var workspaceAPI = component.find("workspace");
        var navService = component.find("navService");
        var pageRef = {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__fetchRecordTypeLightning"
            },
            "state": {
                "c__sObjectName": "Lead",
                "c__url": "/apex/LeadProxyExtension?referralId=" + referralObj.Id + "&ret=" + referralObj.Id,
                "c__isCustom": true,
            }
        };

        if (component.get('v.isReletedList') || theme == 'Theme4t') {
            navService.navigate(pageRef, false);
        } else {
            navService.generateUrl(pageRef)
                .then($A.getCallback(function (url) {
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        workspaceAPI.openSubtab({
                            parentTabId: response.tabId,
                            url: url,
                            focus: true
                        });
                    }).catch(function (error) {
                        console.log(error);
                    });
                }), $A.getCallback(function (error) {
                    console.log(error);
                }));
        }
    },
    runInit: function (component, event, helper) {
        var leads = component.get('v.leads');
        var referralObj = component.get('v.referralObj');

        var RTL_Referral_ERR002 = $A.get('$Label.c.RTL_Referral_ERR002');
        var RTL_Referral_ERR004 = $A.get('$Label.c.RTL_Referral_ERR004');
        var RTL_Referral_ERR010 = $A.get('$Label.c.RTL_Referral_ERR010');
        var RTL_Referral_ERR011 = $A.get('$Label.c.RTL_Referral_ERR011');
        var RTL_Referral_ERR014 = $A.get('$Label.c.RTL_Referral_ERR014');
        var RTL_Referral_ERR021 = $A.get('$Label.c.RTL_Referral_ERR021');

        var isOnce = component.get('v.isOnce');
        if (Array.isArray(leads) && referralObj && isOnce) {
            component.set('v.isOnce', !isOnce);
            component.set('v.referralObj', null);

            var isOwner = referralObj.RTL_Is_Owner__c;
            var isClosed = referralObj.RTL_Stage__c.includes('Closed');
            var stage = referralObj.RTL_Stage__c;
            var type = referralObj.RTL_Type__c;

            if (type == 'To Product Team (เพื่อส่งให้ทีม Product)' && stage != 'New' && stage != 'In progress_Contacted' && stage != 'Closed (Service Completed)') {
                helper.displayToast(component, 'Error', RTL_Referral_ERR021);
                helper.closeActionOrTab(component, event, helper);
            } else if (type != 'To Product Team (เพื่อส่งให้ทีม Product)' && stage != 'New' && stage != 'In progress_Contacted') {
                helper.displayToast(component, 'Error', RTL_Referral_ERR010);
                helper.closeActionOrTab(component, event, helper);
            } else if (type == 'Account Opening/Service (เพื่อเปิดบัญชี / สมัครบริการ)') {
                helper.displayToast(component, 'Error', RTL_Referral_ERR014);
                helper.closeActionOrTab(component, event, helper);
            } else if (isOwner == false && isClosed == false) {
                helper.displayToast(component, 'Error', RTL_Referral_ERR004);
                helper.closeActionOrTab(component, event, helper);
            } else if (referralObj.RTL_Account_Name__c) {
                helper.displayToast(component, 'Error', RTL_Referral_ERR002);
                helper.closeActionOrTab(component, event, helper);
            } else if (leads.length > 0) {
                helper.displayToast(component, 'Error', RTL_Referral_ERR011);
                helper.closeActionOrTab(component, event, helper);
            } else {

                helper.navigateToCreateRecord(component, referralObj);

            }
            // helper.stopSpinner(component);
        }
    }
})