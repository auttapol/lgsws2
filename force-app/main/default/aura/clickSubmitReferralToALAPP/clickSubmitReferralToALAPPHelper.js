({
    closeSubtab: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    getRecord: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        // console.log('getRecord : ' + recordId);
        var action = component.get("c.getRecord");
        action.setParams({
            recordId: recordId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                // console.log('SUCCESS');
                var result = response.getReturnValue();
                var isAccess = result.isAccess;
                if (isAccess == false) {
                    var RTL_Referral_ERR004 = $A.get('$Label.c.RTL_Referral_ERR004');
                    helper.displayToast('Error', RTL_Referral_ERR004);
                    helper.closeSubtab(component, event, helper);
                }
                var isSend = result.isSend;
                var RefNo = result.RefNo;
                var isSendDone = result.isSendDone;

                // console.log('Return Value :' + JSON.stringify(result));
                // console.log('Return Value isSend:' + isSend);
                // console.log('Return Value isSend Done:' + isSendDone);
                // console.log('Return Value RefNo:' + RefNo);
                component.set('v.isSendDone', isSendDone);
                component.set('v.isSend', isSend);

                if (!isSendDone) {
                    component.set('v.iconName', 'utility:warning');
                } else if (isSendDone && isSend) {
                    component.set('v.iconName', 'action:approval');
                    component.set('v.RefNo', RefNo);

                } else if (isSendDone && !isSend) {
                    component.set('v.iconName', 'action:preview');
                }

                // if (result != null && isSend == false) {
                //     component.set('v.isSend', isSend);
                // } else if (result != null && isSend == true) {
                //     component.set('v.iconName', 'utility:warning');
                // }
                component.set("v.isLoading", false);
            } else {
                var error = response.getError();
                // console.log(JSON.stringify(error));
                // console.log('Err : ' + JSON.stringify(error[0].message));
                component.set('v.iconName', 'action:close');
                component.set('v.isSendDone', true);
                component.set('v.isError', true);
                component.set('v.errorMessage', error[0].message);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    sendRequest: function (component, event, helper, round) {
        return new Promise($A.getCallback(function (res, rej) {
            var recordId = component.get("v.recordId");
            var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
            var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
            // console.log(numOfRetryTime);
            // console.log(retrySetTimeOut);

            // console.log('Send recordId : ' + recordId);
            var action = component.get("c.submitALALPP");
            action.setParams({
                rec: recordId,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    // console.log('SUCCESS');
                    var result = response.getReturnValue();
                    var Err = result.ErrMsg;
                    var RefNo = result.RefNo;
                    // console.log('Return Value :' + JSON.stringify(result));
                    // console.log('Return Value Err:' + Err);
                    // console.log('Return Value RefNo:' + RefNo);
                    // console.log('Round:' + round);

                    if (result != null && RefNo != null) { // SUCCESS
                        component.set('v.iconName', 'action:approval');
                        component.set('v.isError', false);
                        component.set('v.RefNo', RefNo);
                        component.set('v.isSend', true);
                        component.set("v.isLoading", false);

                    } else if (result != null && Err != null && Err.includes('401') && round < numOfRetryTime) { //FAILED 401
                        round++;
                        component.set('v.isError', true);
                        var retry = 'Retry ' + round + '...';
                        component.set('v.errorMessage', retry);
                        window.setTimeout(
                            $A.getCallback(function () {
                                helper.sendRequest(component, event, helper, round);
                            }), retrySetTimeOut
                        );
                    } else if(result != null && Err != null && (Err == 'Read timed out' || Err.includes('500')) && round < 2){
                        round++;
                        component.set('v.isError', true);
                        var retry = 'Retry ' + round + '...';
                        component.set('v.errorMessage', retry);
                        helper.sendRequest(component, event, helper, round);
                    } else if (result != null && Err != null) { // FAILED
                        component.set('v.iconName', 'action:close');
                        component.set('v.isError', true);
                        component.set('v.errorMessage', Err);
                        component.set("v.isLoading", false);
                    }
                    // helper.closeSubtab();
                    // helper.displayToast(status, Message);
                    // helper.refreshFocusedTab(component, event, helper);
                } else {
                    var error = response.getError();
                    // console.log(JSON.stringify(error));
                    // console.log('Err : ' + JSON.stringify(error[0].pageErrors[0].message));
                    component.set('v.iconName', 'action:close');
                    component.set('v.isError', true);
                    component.set('v.errorMessage', error[0].pageErrors[0].message);
                    component.set("v.isLoading", false);
                    // helper.closeSubtab();
                    // helper.displayToast('error', error[0].message);
                }
            });
            $A.enqueueAction(action);
        }));
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