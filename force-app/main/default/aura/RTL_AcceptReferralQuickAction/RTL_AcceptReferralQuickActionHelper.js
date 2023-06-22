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
    NOW: function () {
        var date = new Date();
        var dd = String(date.getDate()).padStart(2, '0');
        var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
        return date.getFullYear() + "-" + mm + "-" + dd;
    },
    runInit: function (component, event, helper) {
        var ERR005 = $A.get('$Label.c.RTL_Referral_ERR005');
        var ERR003 = $A.get('$Label.c.RTL_Referral_ERR003');
        var ERR_NO_LICENSE = $A.get('$Label.c.RTL_Referral_NO_LICENSE');

        var isOnce = component.get('v.isOnce');
        var referralObj = component.get('v.referralObj');
        var userObj = component.get('v.userObj');

        if (referralObj && userObj && isOnce) {
            component.set('v.isOnce', !isOnce);
            // helper.stopSpinner(component);

            if (referralObj.OwnerId == userObj.Id) {
                helper.displayToast(component, 'Error', ERR005);
                $A.get("e.force:closeQuickAction").fire();
            } else if (referralObj.OwnerId.startsWith('005')) {
                helper.displayToast(component, 'Error', ERR003);
                $A.get("e.force:closeQuickAction").fire();
            } else {

                var license = userObj.RTL_License_No_Paper_1__c;
                var license_Expiry = userObj.RTL_Expiry_Date_Paper_1__c;
                var licenseComplexP2 = userObj.RTL_License_No_Complex_P2__c;
                var licenseComplexP2_Expiry = userObj.RTL_Expiry_Date_Complex_P2__c;

                var RecordType = referralObj.RTL_RecordType_Name__c;
                if (RecordType == "Retail Order Transaction" && (!licenseComplexP2 || licenseComplexP2_Expiry < helper.NOW()) && (!license || license_Expiry < helper.NOW())) {
                    helper.displayToast(component, 'Error', ERR_NO_LICENSE);
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    var action = component.get('c.acceptReferral');
                    action.setParams({
                        referralId: referralObj.Id
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (component.isValid() && state === 'SUCCESS') {
                            var result = response.getReturnValue();

                            if (result == "Success") {
                                helper.displayToast(component, 'success', 'ระบบได้ทำการเปลี่ยนเจ้าของ ' + referralObj.Name + ' มาเป็นของท่านแล้ว ท่านสามารถดำเนินการต่อได้');
                                $A.get('e.force:refreshView').fire();
                            } else {
                                helper.displayToast(component, 'Error', result);
                            }

                            helper.stopSpinner(component);
                            $A.get("e.force:closeQuickAction").fire();
                        } else {
                            var errors = response.getError();
                            errors.forEach(error => console.log(error.message));
                            helper.stopSpinner(component);
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    });
                    $A.enqueueAction(action);
                }

            }
        }

    }
})