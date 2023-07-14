({
    onInit: function (component, event, helper) {
        var pageRef = component.get('v.pageReference');
        
        component.set('v.campaignMemberId', pageRef.state.c__campaignMemberId ? pageRef.state.c__campaignMemberId : '');
        component.set('v.productNumber', pageRef.state.c__productNumber ? pageRef.state.c__productNumber : '');

        var proNum = pageRef.state.c__productNumber;
        var FirstSection = ['RTL_Campaign_Product_'+proNum+'__c','RTL_AL_BlueBook__c','RTL_AL_car_type__c','RTL_AL_wanted_amount__c','RTL_AL_car_brand__c','RTL_AL_max_set_up_amount__c','RTL_AL_car_group__c','RTL_AL_normal_price__c','RTL_AL_car_subtype__c','RTL_AL_DownPercent__c','RTL_AL_car_year__c','RTL_AL_DownAmt__c','RTL_AL_car_gear__c','RTL_AL_installment_amount__c','RTL_AL_car_plate_no__c','RTL_AL_installment_periods__c','RTL_AL_Province_Car_Plate_No__c','RTL_AL_PayPerMonth__c','RTL_AL_Car_Status__c','RTL_AL_Leasing_Condition__c','RTL_Partner_Branch__c','RTL_Partner_Employee__c','WS_Response_Detail__c','RTL_Contact_Method__c','LGS_VIN_No__c','Car_Reference_No__c','LGS_Assignment_Code__c','LGS_BrandShowroomCode__c','LGS_PartnerCode__c','RTL_Partner_Branch_Code__c','LGS_BrandCode__c','RTL_Partner_Employee_Code__c'];

        var SecondSection = ['RTL_AL_contact_channel__c','RTL_AL_available_time__c','RTL_Contact_Address__c','RTL_AL_ContactZipcode__c','RTL_AL_ContactProvince__c','RTL_AL_ContactDistrict__c','RTL_AL_ContactSubDistrict__c'];
        var ThirdSection = ['RTL_AL_Refer_No_'+proNum+'__c','RTL_AL_Req_No1_'+proNum+'__c','RTL_Reason_Lost__c','RTL_AL_Req_No2_'+proNum+'__c','Corebank_Emp_Name_'+proNum+'__c','Corebank_Emp_Phone_No_'+proNum+'__c','RTL_Hub_Code_'+proNum+'__c','RTL_Hub_Name_'+proNum+'__c','HPAP_Status_Code_1__c','RTL_Status_1__c','Details_of_Status_1__c','HPAP_Reason_Code_1__c','HPAP_Reason_Description_1__c','RTL_Status_Approve_1__c','RTL_Refer_Date_1__c','RTL_Submit_Date_1__c','Corebank_Approved_Date_Time_1__c','RTL_Request_Hub_Code_1__c','RTL_Stage_Name_Date_Time_1__c','RTL_Request_Hub_Name_1__c','Corebank_Branch_Code_1__c','RTL_Product_Campaign_Code_1__c','Corebank_Branch_Name_1__c','RTL_Product_Campaign_Name_1__c','Corebank_Sales_Manager_Head_Id_1__c','RTL_Dealer_Code_1__c','Corebank_Sales_Manager_Head_1__c','RTL_Dealer_Name_1__c']
        component.set('v.Firstfields',FirstSection);
        component.set('v.Secondfields',SecondSection);
        component.set('v.Thirdfields',ThirdSection);

        component.set('v.isLoading', false);

        helper.setTabDetail(component, event, helper);
        helper.checkPermissionToEdit(component, event, helper);
    },

    close: function (component) {
        var workspaceAPI = component.find('workspace');

        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
        .catch(function (error) {
             console.log(error);
        });
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },

    handleEdit : function(component, event, helper) {
        component.set('v.isEdit',true);
        component.set('v.isLoading', true);
        helper.prepareField(component, event, helper);
    },

    handleCancel : function(component, event, helper) {
        component.set('v.isEdit',false);
        helper.checkPermissionToEdit(component, event, helper);
    },

    handleSubmit: function(component, event, helper) {
        component.set('v.isLoading', true);
        event.preventDefault();
        const fields = event.getParam('fields');
        component.find('recordEditForm').submit(fields);
    },

    handleSuccess: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : "success",
            "title": "Success",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();
    },
});