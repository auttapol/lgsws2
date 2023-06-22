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
                // console.log(error);
            });
    },
    getOptyRecordType: function (component, event, helper) {
        var action = component.get('c.getOptyRecordType');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.opptyRecordTypeId', result);
                helper.getReferral(component, event, helper);
            } else {
                var errors = response.getError();
                // errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    getReferral: function (component, event, helper) {
        var action = component.get('c.getReferral');
        action.setParams({
            recordId: component.get('v.recordId')
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.referralObj', result);
            } else {
                var errors = response.getError();
                // errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    closeActionOrTab: function (component) {
        var helper = this;
        if (component.get('v.isReletedList')) {
            helper.closeTab(component);
        } else {
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    navigateToOpportunity: function (component, referralObj, isRetail, oppRecordType) {
        var recordId = component.get('v.recordId') ? component.get('v.recordId') : component.get('v.pageReference.state.c__recordId');
        var pageReference = {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__fetchRecordTypeLightning"
            },
            "state": {
                "c__recordId": recordId,
                "c__recordTypeId": oppRecordType ? oppRecordType : '',
                "c__sObjectName": "Opportunity",
                'c__header': $A.get('$Label.c.New_Opportunity'),
                'c__detail': $A.get('$Label.c.Select_a_record_type_for_this_Opportunity'),
                'c__defaultVaule': {
                    'RTL_Referral__c': recordId,
                    'AccountId': referralObj.RTL_Account_Name__r ? referralObj.RTL_Account_Name__r.Id : null,
                    'Name': isRetail ? "ค่าอัตโนมัติ (ไม่ต้องระบุ)" : '',
                    'RTL_Product_Name__c': referralObj && referralObj.RTL_Product_Name__r && oppRecordType ? referralObj.RTL_Product_Name__r.Id : null,
                    'RTL_AL_available_time__c': referralObj.RTL_AL_available_time__c ? referralObj.RTL_AL_available_time__c : '',
                    'RTL_AL_car_bought_from__c': referralObj.RTL_AL_car_bought_from__c ? referralObj.RTL_AL_car_bought_from__c : '',
                    'RTL_AL_car_brand__c': referralObj.RTL_AL_car_brand__c ? referralObj.RTL_AL_car_brand__c : '',
                    'RTL_AL_car_gear__c': referralObj.RTL_AL_car_gear__c ? referralObj.RTL_AL_car_gear__c : '',
                    'RTL_AL_car_group__c': referralObj.RTL_AL_car_group__c ? referralObj.RTL_AL_car_group__c : '',
                    'RTL_AL_car_subtype__c': referralObj.RTL_AL_car_subtype__c ? referralObj.RTL_AL_car_subtype__c : '',
                    'RTL_AL_car_type__c': referralObj.RTL_AL_car_type__c ? referralObj.RTL_AL_car_type__c : '',
                    'RTL_AL_car_year__c': referralObj.RTL_AL_car_year__c ? referralObj.RTL_AL_car_year__c : '',
                    'RTL_AL_comment__c': referralObj.RTL_AL_comment__c ? referralObj.RTL_AL_comment__c : '',
                    'RTL_AL_contact_channel__c': referralObj.RTL_AL_contact_channel__c ? referralObj.RTL_AL_contact_channel__c : '',
                    'RTL_AL_installment_amount__c': referralObj.RTL_AL_installment_amount__c ? referralObj.RTL_AL_installment_amount__c : '',
                    'RTL_AL_installment_periods__c': referralObj.RTL_AL_installment_periods__c ? referralObj.RTL_AL_installment_periods__c : '',
                    'RTL_AL_normal_price__c': referralObj.RTL_AL_normal_price__c ? referralObj.RTL_AL_normal_price__c : '',
                    'RTL_AL_wanted_amount__c': referralObj.RTL_AL_wanted_amount__c ? referralObj.RTL_AL_wanted_amount__c : '',
                    'RTL_AL_oa_ref_code__c': referralObj.RTL_AL_oa_ref_code__c ? referralObj.RTL_AL_oa_ref_code__c : '',
                    'RTL_AL_car_plate_no__c': referralObj.RTL_AL_car_plate_no__c ? referralObj.RTL_AL_car_plate_no__c : '',
                    'RTL_AL_Interested_Rate__c': referralObj.RTL_AL_Interested_Rate__c ? referralObj.RTL_AL_Interested_Rate__c : '',
                    'RTL_AL_ContactDistrict__c': referralObj.RTL_AL_ContactDistrict__c ? referralObj.RTL_AL_ContactDistrict__c : '',
                    'RTL_AL_ContactSubDistrict__c': referralObj.RTL_AL_ContactSubDistrict__c ? referralObj.RTL_AL_ContactSubDistrict__c : '',
                    'RTL_AL_ContactZipcode__c': referralObj.RTL_AL_ContactZipcode__c ? referralObj.RTL_AL_ContactZipcode__c : '',
                    'RTL_AL_ContactProvince__c': referralObj.RTL_AL_ContactProvince__c ? referralObj.RTL_AL_ContactProvince__c : '',
                    'RTL_AL_max_set_up_amount__c': referralObj.RTL_AL_max_set_up_amount__c ? referralObj.RTL_AL_max_set_up_amount__c : '',
                    'RTL_AL_ILA_AMT__c': referralObj.RTL_AL_ILA_AMT__c ? referralObj.RTL_AL_ILA_AMT__c : '',
                    'RTL_AL_REMN_MTH__c': referralObj.RTL_AL_REMN_MTH__c ? referralObj.RTL_AL_REMN_MTH__c : '',
                    'RTL_AL_OFFR_ILA_AMT__c': referralObj.RTL_AL_OFFR_ILA_AMT__c ? referralObj.RTL_AL_OFFR_ILA_AMT__c : '',
                    'RTL_AL_OFFR_ILA_MTH__c': referralObj.RTL_AL_OFFR_ILA_MTH__c ? referralObj.RTL_AL_OFFR_ILA_MTH__c : '',
                    'RTL_AL_BlueBook__c': referralObj.RTL_AL_BlueBook__c ? referralObj.RTL_AL_BlueBook__c : null,
                    'RTL_Contact_Address__c': referralObj.RTL_Contact_Address__c ? referralObj.RTL_Contact_Address__c : null
                },
                "c__uuid": 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                    let r = Math.random() * 16 | 0,
                        v = c == 'x' ? r : (r & 0x3 | 0x8);
                    return v.toString(16);
                })
            }
        };
        //      if (component.get('v.isReletedList') || component.get('v.theme') == 'Theme4t') { // SF Support commented code
        if (component.get('v.isReletedList') || !$A.get("$Browser").isDesktop) { // SF Support

            component.find("navService").navigate(pageReference, component.get('v.isReletedList'));
            component.set('v.recordId', null); // clear cache
            component.set('v.pageReference', null); // clear cache
        } else {
            pageReference.state.c__defaultVaule = JSON.stringify(pageReference.state.c__defaultVaule);
            component.find("navService").generateUrl(pageReference)
                .then($A.getCallback(function (url) {
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        workspaceAPI.openSubtab({
                            parentTabId: response.tabId,
                            url: url,
                            focus: true
                        });
                    }).catch(function (error) {
                        // console.log(JSON.parse(JSON.stringify(error)));
                    });
                }), $A.getCallback(function (error) {
                    // console.log(error);
                }));
        }

    },
    runInit: function (component, event, helper) {
        var referralObj = component.get('v.referralObj');
        var opptyRecordTypeId = component.get('v.opptyRecordTypeId');

        var RTL_Referral_ERR001 = $A.get('$Label.c.RTL_Referral_ERR001');
        var RTL_Referral_ERR004 = $A.get('$Label.c.RTL_Referral_ERR004');
        var RTL_Referral_ERR009 = $A.get('$Label.c.RTL_Referral_ERR009');
        var RTL_Referral_ERR013 = $A.get('$Label.c.RTL_Referral_ERR013');
        var RTL_Referral_ERR020 = $A.get('$Label.c.RTL_Referral_ERR020');

        var isOnce = component.get('v.isOnce');
        if (referralObj && opptyRecordTypeId && isOnce) {
            component.set('v.isOnce', !isOnce);
            component.set('v.referralObj', null);

            var isOwner = referralObj.RTL_Is_Owner__c;
            var isClosed = referralObj.RTL_Stage__c.includes('Closed');
            var stage = referralObj.RTL_Stage__c;
            var type = referralObj.RTL_Type__c;
            var recordType = referralObj.RTL_RecordType_Name__c;

            if (type == 'To Product Team (เพื่อส่งให้ทีม Product)' && stage != 'New' && stage != 'In progress_Contacted' && stage != 'Closed (Service Completed)') {
                helper.displayToast(component, 'Error', RTL_Referral_ERR020);
                helper.closeActionOrTab(component);
            } else if (type != 'To Product Team (เพื่อส่งให้ทีม Product)' && stage != 'New' && stage != 'In progress_Contacted' && stage != 'Closed (Interested)') {
                helper.displayToast(component, 'Error', RTL_Referral_ERR009);
                helper.closeActionOrTab(component);
            } else if (type == 'Account Opening/Service (เพื่อเปิดบัญชี / สมัครบริการ)') {
                helper.displayToast(component, 'Error', RTL_Referral_ERR013);
                helper.closeActionOrTab(component);
            } else if (isOwner == false && isClosed == false) {
                helper.displayToast(component, 'Error', RTL_Referral_ERR004);
                helper.closeActionOrTab(component);
            } else if (!referralObj.RTL_Account_Name__c) {
                helper.displayToast(component, 'Error', RTL_Referral_ERR001);
                helper.closeActionOrTab(component);
            } else {

                if (recordType == 'Refer to Commercial' || recordType == 'Closed Refer to Commercial' || recordType == 'Refer within Commercial' || recordType == 'Closed Refer within Commercial') {
                    helper.navigateToOpportunity(component, referralObj, false, '');
                } else if (recordType == 'Refer to Retail' || recordType == 'Closed Refer to Retail' || recordType == 'Retail Order Transaction' || recordType == 'Closed Retail Order Transaction') {
                    helper.navigateToOpportunity(component, referralObj, true, '');
                } else {
                    if (stage == 'Closed (Interested)') {
                        helper.navigateToOpportunity(component, referralObj, true);
                    } else {
                        var productGroup = referralObj.RTL_Product_Name__r ? referralObj.RTL_Product_Name__r.Product_Group__c : '';
                        var oppRecordType = productGroup ? opptyRecordTypeId[productGroup] : '';
                        helper.navigateToOpportunity(component, referralObj, true, oppRecordType);
                    }
                }

            }
            // helper.stopSpinner(component);
        }
    }
})