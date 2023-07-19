({
    onInit: function (component, event, helper) {

        component.set('v.loaded', true);
        var recordId = component.get('v.recordId');
        var mcode = component.get('v.mcode');
        var tmbCustId = component.get('v.tmbCustId');

        // console.log('recordId:',recordId);
        // console.log('mcode:',mcode);
        // console.log('tmbCustId:',tmbCustId);

        if (recordId != null && recordId != '') {
            helper.getCampaignMember(component, event, helper);
            helper.getCampaignProductList(component, event, helper);
        }
        else if (mcode != null && tmbCustId != null) {

            helper.getCampaignINT06(component, event, helper);
            component.set('v.recordCanNotSell', true);
        }
        else {
            component.set('v.loaded', false);
        }

        helper.getCurrentUser(component, event, helper);

        helper.getFieldLabel(component, event, helper);
        helper.getOfferResultPickList(component, event, helper);
        helper.getContactStatusPickList(component, event, helper);
        helper.getUncontactReasonPickList(component, event, helper);
        helper.getLeadScoreLevelPickList(component, event, helper);
        // helper.getExistingCallback(component, event, helper);

        // CrossSell value
        helper.getProductGroupPickList(component, event, helper);
        helper.getMoreDetailAvailableProduct(component, event, helper);
    },

    changeState: function (component, event, helper) {
        var iconName = component.get('v.iconName');
        if (iconName == 'utility:chevrondown') {
            component.set('v.iconName', 'utility:chevronright');
        }
        else {
            component.set('v.iconName', 'utility:chevrondown');
        }
        component.set('v.isExpanded', !component.get('v.isExpanded'));
    },

    changeState2: function (component, event, helper) {
        var iconName = component.get('v.iconName2');
        if (iconName == 'utility:chevrondown') {
            component.set('v.iconName2', 'utility:chevronright');
        }
        else {
            component.set('v.iconName2', 'utility:chevrondown');
        }
        component.set('v.isExpanded2', !component.get('v.isExpanded2'));
    },

    changeState3: function (component, event, helper) {
        var iconName = component.get('v.iconName3');
        if (iconName == 'utility:chevrondown') {
            component.set('v.iconName3', 'utility:chevronright');
        }
        else {
            component.set('v.iconName3', 'utility:chevrondown');
        }
        component.set('v.isExpanded3', !component.get('v.isExpanded3'));
    },

    handleChangeUncontactReason: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected option
        var campaignMemObj = component.get('v.campaignMemObj');
        var selectedOptionValue = event.getParam("value");
        // console.log("Option selected with value: " + selectedOptionValue );
        campaignMemObj.RTL_Reason__c = selectedOptionValue;
        component.set('v.campaignMemObj', campaignMemObj);
        // console.log('campaignMemObj:',campaignMemObj);
    },
    handleChangeLeadScoreLevel: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected option
        var listMin = component.get('v.leadScoreLevelListmin');
        var campaignMemObj = component.get('v.campaignMemObj');
        var min;
            listMin.forEach(element => {
                if (element.label == campaignMemObj.Lead_Score_Level__c) {
                    campaignMemObj.Lead_Score__c = element.value;
                    campaignMemObj.RTL_Lead_Score_Flag__c = true;                  
                    return null
                }
            });
            component.set('v.campaignMemObj', campaignMemObj);
        
        // console.log('campaignMemObj:',campaignMemObj);
        // console.log('listMin:',listMin);
        // console.log('campaignMemObj.Lead_Score_Level__c:',campaignMemObj.Lead_Score_Level__c);
    },
    handleChangeContactStatus: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        var callbackCmp = component.find("callbackCmp");
        var campaignMemObj = component.get('v.campaignMemObj');
        var contactInput = component.find('contactStatus');
        var contactStatusReason = component.find('contactStatusReason');
        //var isConvert = component.get('v.isConvert');
        campaignMemObj.RTL_Contact_Status__c = selectedOptionValue;
        // console.log('selectedOptionValue', selectedOptionValue);
        $A.util.removeClass(contactInput, "slds-has-error"); // remove red border
        $A.util.addClass(contactInput, "hide-error-message");

        $A.util.removeClass(contactStatusReason, "slds-has-error"); // remove red border
        $A.util.addClass(contactStatusReason, "hide-error-message");

        // if(isConvert == true && selectedOptionValue == 'Call Back')
        // {
        //     component.set('v.isConvert',false);
        // }

        if (selectedOptionValue === 'Uncontact') {
            component.set('v.isChangeContact', true);
            component.set('v.requireReasonFlag', true);
            component.set('v.isReadonly', false);
            component.set('v.isCallBack', false);
            callbackCmp.callbackDeselected();
        }
        else {
            component.set('v.requireReasonFlag', false);
            component.set('v.isReadonly', true);
            component.set('v.isCallBack', false);

            campaignMemObj.RTL_Reason__c = '';
            callbackCmp.callbackDeselected();
        }
        if (selectedOptionValue === 'Contact') {
            component.set('v.isChangeContact', true);
            component.set('v.isDisabled', false);
        }
        else if (selectedOptionValue === 'Call Back') {
            component.set('v.isChangeContact', true);
            component.set('v.isCallBack', true);
            component.set('v.isDisabled', false);
            callbackCmp.callbackSelected();

        }
        else {
            component.set('v.isDisabled', true);
            callbackCmp.clearValidate();
        }

        component.set('v.campaignMemObj', campaignMemObj);
    },
    handleSave: function (component, event, helper) {
        helper.validateSaveCampaign(component, event, helper);
        //component.set('v.loaded', false); 
    },

    handleLeadConversionEvent: function (component, event, helper) {
        var accObj = event.getParam("accObj");
        var isMerge = event.getParam("isMerge");
        var name = event.getParam("Name");
        var mobileNumber = event.getParam("Mobile_Number");
        var idType = event.getParam("ID_Type");
        var idNumber = event.getParam("ID_Number");
        // console.log('accObj:',JSON.stringify(accObj));
        // console.log('isMerge:',isMerge);
        // console.log('name:',name);
        // console.log('mobileNumber:',mobileNumber);
        // console.log('idType:',idType);
        // console.log('idNumber:',idNumber);
        
        // if (isMerge) { BAU14118_INC0223998 fixed by support 
            component.set('v.isMerge', isMerge);
            if (isMerge == true) {
                if (accObj) {
                    component.set('v.accObj', accObj);
                }
            }
        // } BAU14118_INC0223998 fixed by support 

        if (name && mobileNumber && idType && idNumber) {
            component.set('v.customerName', name);
            component.set('v.mobileNumber', mobileNumber);
            component.set('v.idType', idType);
            component.set('v.idNoValue', idNumber);
        }

    },

    handleCrossSell: function (component, event, helper) {
        let crossSellList = component.get('v.CrossSellList')
        // console.log('CrossSell', crossSellList);
        crossSellList.forEach((crossSellRow, i) => {
            let product = crossSellRow.product;
            if (crossSellRow.selected.productName && product.productNameId !== crossSellRow.selected.productName.Id) {
                product.productName = crossSellRow.selected.productName.Name;
                product.productName_Id = crossSellRow.selected.productName.Id;
                component.set('v.CrossSellList[' + i + '].style.productName', '');
            }
            if (crossSellRow.selected.offerResult && product.offerResult !== crossSellRow.selected.offerResult) {
                product.offerResult = crossSellRow.selected.offerResult;
                component.set('v.CrossSellList[' + i + '].style.offerResult', '');
            }
            if (!crossSellRow.isSaved) {
                if (product.productGroup && crossSellRow.productSubGroupList.length === 0) {
                    helper.setProductSubGroupPickListCrossSell(component, event, helper, product.productGroup, i);
                } else if (product.productGroup && crossSellRow.stageList.length === 0) {
                    // console.log('get stage index' + i);
                    helper.setStagePickListCrossSell(component, event, helper, product.productGroup, i);
                } else if (product.stage && crossSellRow.statusList.length === 0 && crossSellRow.schema) {
                    // console.log('get status index' + i);
                    let record_typeDevName = crossSellRow.schema.RTL_Record_Type_DevName__c;
                    helper.setStatusPickListCrossSell(component, event, helper, record_typeDevName, i);
                }
            }
        });
    },

    handleProductGroup: function (component, event, helper) {

        var productList = component.get('v.productList');
        var indexVar = event.getSource().get("v.name");
        var index_Input;
        index_Input = (indexVar * 2) + 1;

        productList[indexVar].productGroup = event.getSource().get("v.value");
        productList[indexVar].isValidate = false;
        component.set('v.productList', productList);

        // console.log('productList:',productList);  

        $A.util.removeClass(component.find('inputProductGroup')[index_Input], "slds-has-error"); // remove red border
        $A.util.addClass(component.find('inputProductGroup')[index_Input], "hide-error-message");
    },

    handleProductSubGroup: function (component, event, helper) {

        var productList = component.get('v.productList');
        var customLookup = component.find('customLookup');

        var indexVar = event.getSource().get("v.name");

        var index_Input;
        index_Input = (indexVar * 2) + 1;
        // console.log('sub : ' + productList[indexVar].selectedproductsubgroup);
        productList[indexVar].productSubGroup =  productList[indexVar].selectedproductsubgroup;
        if(productList[indexVar].selectedproductsubgroup == null || productList[indexVar].selectedproductsubgroup == ''){
            // console.log('SELECT NONE');
        }
        customLookup[index_Input].clearSelectedValue();

        
        // productList[indexVar].isValidate = false;
        component.set('v.productList', productList);
        // console.log('productList:',productList);  
        $A.util.removeClass(component.find('inputProductSubGroup')[index_Input], "slds-has-error"); // remove red border
        $A.util.addClass(component.find('inputProductSubGroup')[index_Input], "hide-error-message");
    },

    handleOfferResult: function (component, event, helper) {

        var productList = component.get('v.productList');
        var indexVar = event.getSource().get("v.name");
        productList[indexVar].reason = '';
        productList[indexVar].offerResult = event.getSource().get("v.value");
        // productList[indexVar].isValidate = false;
        if (event.getSource().get("v.value") == 'Not Interested' || event.getSource().get("v.value") == 'Not Qualified') {
            helper.getReasonForNotInterestPickList(component, event, helper, indexVar, productList[indexVar].productGroup, productList[indexVar].offerResult);
        }
        else if (event.getSource().get("v.value") == 'Interested') {
            helper.getStagePickList(component, event, helper, indexVar, productList[indexVar].objOpp.RecordTypeId);
            helper.getStatusPickList(component, event, helper, indexVar, productList[indexVar].objOpp.RecordTypeId);
            productList[indexVar].reason = '';
        }
        else {
            productList[indexVar].reason = '';
        }

        component.set('v.productList', productList);

        if (productList.length == 1) {
            $A.util.removeClass(component.find('inputOfferResult'), "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputOfferResult'), "hide-error-message");
        }
        else {
            $A.util.removeClass(component.find('inputOfferResult')[indexVar], "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputOfferResult')[indexVar], "hide-error-message");
        }
        // console.log('productList:',productList); 

    },


    handleReason: function (component, event, helper) {

        var productList = component.get('v.productList');
        var indexVar = event.getSource().get("v.name");

        productList[indexVar].reason = event.getSource().get("v.value");
        // productList[indexVar].isValidate = false;
        component.set('v.productList', productList);
        // console.log('productList:',productList);  

        if (productList.length == 1) {
            $A.util.removeClass(component.find('inputReason'), "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputReason'), "hide-error-message");
        }
        else {
            $A.util.removeClass(component.find('inputReason')[indexVar], "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputReason')[indexVar], "hide-error-message");
        }

    },

    handleStage: function (component, event, helper) {

        var productList = component.get('v.productList');
        var indexVar = event.getSource().get("v.name");

        productList[indexVar].objOpp.StageName = event.getSource().get("v.value");
        // productList[indexVar].isValidate = false;
        component.set('v.productList', productList);

        // console.log('productList:',productList);   
        if (productList.length == 1) {
            $A.util.removeClass(component.find('inputStage'), "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputStage'), "hide-error-message");
        }
        else {
            $A.util.removeClass(component.find('inputStage')[indexVar], "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputStage')[indexVar], "hide-error-message");
        }
    },

    handleStatus: function (component, event, helper) {

        var productList = component.get('v.productList');
        var indexVar = event.getSource().get("v.name");

        productList[indexVar].objOpp.RTL_Status__c = event.getSource().get("v.value");
        // productList[indexVar].isValidate = false;
        component.set('v.productList', productList);

        // console.log('productList:',productList);  
        if (productList.length == 1) {
            $A.util.removeClass(component.find('inputStatus'), "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputStatus'), "hide-error-message");
        }
        else {
            $A.util.removeClass(component.find('inputStatus')[indexVar], "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputStatus')[indexVar], "hide-error-message");
        }
    },

    handleAmount: function (component, event, helper) {

        var productList = component.get('v.productList');
        var indexVar = event.getSource().get("v.name");
        // productList[indexVar].isValidate = false;
        productList[indexVar].objOpp.Amount = event.getSource().get("v.value");

        component.set('v.productList', productList);

        // console.log('productList:',productList);  
        if (productList.length == 1) {
            $A.util.removeClass(component.find('inputAmount'), "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputAmount'), "hide-error-message");
        }
        else {
            $A.util.removeClass(component.find('inputAmount')[indexVar], "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputAmount')[indexVar], "hide-error-message");
        }
    },

    handleExpectedDate: function (component, event, helper) {

        var productList = component.get('v.productList');
        var indexVar = event.getSource().get("v.name");

        productList[indexVar].isValidate = false;
        productList[indexVar].objOpp.CloseDate = event.getSource().get("v.value");

        component.set('v.productList', productList);

        // console.log('productList:',productList);  
        // console.log('indexVar:',indexVar);  
        // console.log('inputExpectedDate:',component.find('inputExpectedDate').length);  
        if (productList.length == 1) {
            $A.util.removeClass(component.find('inputExpectedDate'), "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputExpectedDate'), "hide-error-message");
        }
        else {
            $A.util.removeClass(component.find('inputExpectedDate')[indexVar], "slds-has-error"); // remove red border
            $A.util.addClass(component.find('inputExpectedDate')[indexVar], "hide-error-message");
        }

    },

    navigateToObject: function (component, event, helper) {
        // var recordId = component.get('v.recordId');
        var recordId = event.target.getAttribute('id');
        var objectName;
        if (recordId.startsWith("001")) {
            objectName = 'Account';
        }
        else if (recordId.startsWith("701")) {
            objectName = 'Campaign';
        }
        else if (recordId.startsWith("00Q")) {
            objectName = 'Lead';
        }
        else if (recordId.startsWith("006")) {
            objectName = 'Opportunity';
        }

        component.find("navService").navigate({
            'type': 'standard__recordPage',
            'attributes': {
                'recordId': recordId,
                'objectApiName': objectName,
                'actionName': 'view'
            }
        }, false);
    },

    navigateToProductHoldingandNBO: function (component, event, helper) {
        var campaignMemObj = component.get('v.campaignMemObj');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/CustomerProductHoldingsAndNBO?id=" + campaignMemObj.Customer__c
        });
        urlEvent.fire();
    },

    handleEdit: function (component, event, helper) {
        helper.redirectToEdit(component, event, helper);
        // $A.get('e.force:refreshView').fire();
    },

    handleCancelEdit: function (component, event, helper) {
        helper.redirectAfterSave(component, event, helper);
        // $A.get('e.force:refreshView').fire();
    },

    closeFocusedTab: function (component, event, helper) {
        helper.closeFocusedTab(component, event, helper);
    },

    newReferral: function (component, event, helper) {
        var campaign = component.get('v.campaignMemObj');
        var acc_name = '';
        if (campaign.ContactId != null && campaign.Contact.Account__c != null) {
            acc_name = campaign.Contact.Account__c;
        } else if (campaign.Customer__c != null) {
            acc_name = campaign.Customer__c;
        }
        var FName = campaign.FirstName ? campaign.FirstName : '';
        var LName = campaign.LastName ? campaign.LastName : '';
        var Phone = campaign.RTL_CampHis_Phone__c ? campaign.RTL_CampHis_Phone__c : '';
        var avatime = campaign.RTL_AL_available_time__c ? campaign.RTL_AL_available_time__c : '';
        var carbf = campaign.RTL_AL_car_bought_from__c ? campaign.RTL_AL_car_bought_from__c : '';
        var car_brand = campaign.RTL_AL_car_brand__c ? campaign.RTL_AL_car_brand__c : '';
        var cargear = campaign.RTL_AL_car_gear__c ? campaign.RTL_AL_car_gear__c : '';
        var carg = campaign.RTL_AL_car_group__c ? campaign.RTL_AL_car_group__c : '';
        var carsub = campaign.RTL_AL_car_subtype__c ? campaign.RTL_AL_car_subtype__c : '';
        var cartype = campaign.RTL_AL_car_type__c ? campaign.RTL_AL_car_type__c : '';
        var caryear = campaign.RTL_AL_car_year__c ? campaign.RTL_AL_car_year__c : '';
        var comment = campaign.RTL_AL_comment__c ? campaign.RTL_AL_comment__c : '';
        var cChannel = campaign.RTL_AL_contact_channel__c ? campaign.RTL_AL_contact_channel__c : '';
        var instAmount = campaign.RTL_AL_installment_amount__c ? campaign.RTL_AL_installment_amount__c : '';
        var instPeriod = campaign.RTL_AL_installment_periods__c ? campaign.RTL_AL_installment_periods__c : '';
        var nprice = campaign.RTL_AL_normal_price__c ? campaign.RTL_AL_normal_price__c : '';
        var wAmount = campaign.RTL_AL_wanted_amount__c ? campaign.RTL_AL_wanted_amount__c : '';
        var refCode = campaign.RTL_AL_oa_ref_code__c ? campaign.RTL_AL_oa_ref_code__c : '';
        var carplate = campaign.RTL_AL_car_plate_no__c ? campaign.RTL_AL_car_plate_no__c : '';
        var intRate = campaign.RTL_AL_Interested_Rate__c ? campaign.RTL_AL_Interested_Rate__c : '';
        var cDistrict = campaign.RTL_AL_ContactDistrict__c ? campaign.RTL_AL_ContactDistrict__c : '';
        var cSubDis = campaign.RTL_AL_ContactSubDistrict__c ? campaign.RTL_AL_ContactSubDistrict__c : '';
        var cZip = campaign.RTL_AL_ContactZipcode__c ? campaign.RTL_AL_ContactZipcode__c : '';
        var cProvince = campaign.RTL_AL_ContactProvince__c ? campaign.RTL_AL_ContactProvince__c : '';
        var maxAmount = campaign.RTL_AL_max_set_up_amount__c ? campaign.RTL_AL_max_set_up_amount__c : '';
        var ILA = campaign.RTL_AL_ILA_AMT__c ? campaign.RTL_AL_ILA_AMT__c : '';
        var REMN = campaign.RTL_AL_REMN_MTH__c ? campaign.RTL_AL_REMN_MTH__c : '';
        var oILA_AMT = campaign.RTL_AL_OFFR_ILA_AMT__c ? campaign.RTL_AL_OFFR_ILA_AMT__c : '';
        var oILA_MTH = campaign.RTL_AL_OFFR_ILA_MTH__c ? campaign.RTL_AL_OFFR_ILA_MTH__c : '';
        var BlueBook = campaign.RTL_AL_BlueBook__c ? campaign.RTL_AL_BlueBook__c : '';
        var CMId = campaign.Id ? campaign.Id : '';
        var Campaign = campaign.CampaignId ? campaign.CampaignId : '';
        var LeadSource = campaign.LeadSource ? campaign.LeadSource : '';
        var RTL_TMB_Campaign_Source__c = campaign.RTL_TMB_Campaign_Source__c ? campaign.RTL_TMB_Campaign_Source__c : '';
        var RTL_TMB_Campaign_Reference__c = campaign.RTL_TMB_Campaign_Reference__c ? campaign.RTL_TMB_Campaign_Reference__c : '';
        var RTL_Lead_Group__c = campaign.RTL_Lead_Group__c ? campaign.RTL_Lead_Group__c : '';
        var RTL_Marketing_Code__c = campaign.RTL_Marketing_Code__c ? campaign.RTL_Marketing_Code__c : '';
        var RTL_Web_Unique_ID__c = campaign.RTL_Web_Unique_ID__c ? campaign.RTL_Web_Unique_ID__c : '';
        var RTL_Media_Source__c = campaign.LeadId && campaign.Lead.RTL_Media_Source__c ?  campaign.Lead.RTL_Media_Source__c : '';
        var RTL_Medium__c = campaign.LeadId && campaign.Lead.RTL_Medium__c ?  campaign.Lead.RTL_Medium__c : '';
        var RTL_W2L_Campaign_Name__c = campaign.LeadId && campaign.Lead.RTL_W2L_Campaign_Name__c ?  campaign.Lead.RTL_W2L_Campaign_Name__c : '';
        var RTL_W2L_Content__c = campaign.LeadId && campaign.Lead.RTL_W2L_Content__c ?  campaign.Lead.RTL_W2L_Content__c : '';
        var RTL_W2L_Term__c = campaign.LeadId && campaign.Lead.RTL_W2L_Term__c ?  campaign.Lead.RTL_W2L_Term__c : '';
        var LGS_Assignment_Code = campaign.LGS_Assignment_Code__c ? campaign.LGS_Assignment_Code__c : '';
        var LGS_LinkInfo = campaign.LGS_LinkInfo__c ? campaign.LGS_LinkInfo__c : '';
        // console.log('LINK INFO: ' + LGS_LinkInfo);
        var LGS_BrandCode = campaign.LGS_BrandCode__c ? campaign.LGS_BrandCode__c : '';
        var LGS_BrandShowroomCode = campaign.LGS_BrandShowroomCode__c ? campaign.LGS_BrandShowroomCode__c : '';
        var LGS_PartnerCode = campaign.LGS_PartnerCode__c ? campaign.LGS_PartnerCode__c : '';
        var Lead_Score = campaign.Lead_Score__c;
        // console.log('Lead_Score : ' + campaign.Lead_Score__c);
        var Lead_Score_level = campaign.Lead_Score_Level__c ? campaign.Lead_Score_Level__c : '';
        var LGS_VIN_No = campaign.LGS_VIN_No__c ? campaign.LGS_VIN_No__c : '';
        var LGS_File_Upload = campaign.LGS_File_Upload__c ? campaign.LGS_File_Upload__c : '';
        var LGS_Campaign_Start_Date = campaign.LGS_Campaign_Start_Date__c ? campaign.LGS_Campaign_Start_Date__c : '';
        var LGS_Campaign_End_Date = campaign.LGS_Campaign_End_Date__c ? campaign.LGS_Campaign_End_Date__c : '';
        var LGS_Child_Campaign_ID = campaign.LGS_Child_Campaign_ID__c ? campaign.LGS_Child_Campaign_ID__c : '';
        var Car_Reference_No = campaign.Car_Reference_No__c ? campaign.Car_Reference_No__c : '';

        var param = 'RTL_FirstName__c=' + FName + ',RTL_LastName__c=' + LName + ',RTL_Mobile1__c=' + Phone + ',RTL_AL_available_time__c=' + avatime +
            ',RTL_AL_car_bought_from__c=' + carbf + ',RTL_AL_car_brand__c=' + car_brand + ',RTL_AL_car_gear__c=' + cargear +
            ',RTL_AL_car_group__c=' + carg + ',RTL_AL_car_subtype__c=' + carsub + ',RTL_AL_car_type__c=' + cartype + ',RTL_AL_car_year__c=' + caryear +
            ',RTL_AL_comment__c=' + comment + ',RTL_AL_contact_channel__c=' + cChannel + ',RTL_AL_installment_amount__c=' + instAmount +
            ',RTL_AL_installment_periods__c=' + instPeriod + ',RTL_AL_normal_price__c=' + nprice + ',RTL_AL_wanted_amount__c=' + wAmount +
            ',RTL_AL_oa_ref_code__c=' + refCode + ',RTL_AL_car_plate_no__c=' + carplate + ',RTL_AL_Interested_Rate__c=' + intRate +
            ',RTL_AL_ContactDistrict__c=' + cDistrict + ',RTL_AL_ContactSubDistrict__c=' + cSubDis + ',RTL_AL_ContactZipcode__c=' + cZip +
            ',RTL_AL_ContactProvince__c=' + cProvince + ',RTL_AL_max_set_up_amount__c=' + maxAmount + ',RTL_AL_ILA_AMT__c=' + ILA +
            ',RTL_AL_REMN_MTH__c=' + REMN + ',RTL_AL_OFFR_ILA_AMT__c=' + oILA_AMT + ',RTL_AL_OFFR_ILA_MTH__c=' + oILA_MTH +
            ',RTL_AL_BlueBook__c=' + BlueBook + ',RTL_Account_Name__c=' + acc_name + ',RTL_Campaign_Member__c=' + CMId +
            ',RTL_CampaignID__c=' + Campaign + ',RTL_LeadSource__c=' + LeadSource + ',RTL_TMB_Campaign_Source__c=' + RTL_TMB_Campaign_Source__c +
            ',RTL_TMB_Campaign_Reference__c=' + RTL_TMB_Campaign_Reference__c + ',RTL_Lead_Group__c=' + RTL_Lead_Group__c + ',RTL_Marketing_Code__c=' + RTL_Marketing_Code__c + 
            ',RTL_Web_Unique_ID__c=' + RTL_Web_Unique_ID__c +',RTL_Media_Source__c=' + RTL_Media_Source__c + ',RTL_Medium__c=' + RTL_Medium__c +
            ',RTL_W2L_Campaign_Name__c=' + RTL_W2L_Campaign_Name__c + ',RTL_W2L_Content__c=' + RTL_W2L_Content__c + ',RTL_W2L_Term__c=' + RTL_W2L_Term__c +
            ',LGS_Assignment_Code__c=' + LGS_Assignment_Code  + ',LGS_BrandCode__c=' + LGS_BrandCode +
            ',LGS_BrandShowroomCode__c=' + LGS_BrandShowroomCode + ',LGS_PartnerCode__c=' + LGS_PartnerCode + ',Lead_Score__c=' + Lead_Score +
            ',Lead_Score_Level__c=' + Lead_Score_level + ',LGS_VIN_No__c=' + LGS_VIN_No + ',LGS_File_Upload__c=' + LGS_File_Upload + ',Car_Reference_No__c=' + Car_Reference_No +
            ',LGS_Campaign_Start_Date__c=' + LGS_Campaign_Start_Date + ',LGS_Campaign_End_Date__c=' + LGS_Campaign_End_Date + ',LGS_Child_Campaign_ID__c=' + LGS_Child_Campaign_ID;

        param += ',LGS_LinkInfo__c=' +LGS_LinkInfo;
        // console.log('param to ref:',param);

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/RTL_Referral__c/new?useRecordTypeCheck=1&defaultFieldValues=" +  encodeURIComponent(param)
        });
        urlEvent.fire();
    },

    confirmModal: function (component, event, helper) {
        var hideModal = component.get('v.showModal');
        component.set('v.showModal', !hideModal);
        component.set('v.confirmDNC', true)
        helper.validateSaveCampaign(component, event, helper);
        //logic to do something
    },

    closeModal: function (component, event, helper) {
        var showModal = component.get('v.showModal');
        component.set('v.showModal', !showModal);
        component.set('v.loaded', false);
    },

    handleButtonDisable: function (component, event, helper) {

        var isExpire = component.get('v.isExpire');
        var recordIsClosed = component.get('v.recordIsClosed');
        var recordCanNotSell = component.get('v.recordCanNotSell');
        if (isExpire || recordIsClosed || recordCanNotSell) {
            component.set('v.saveDisable', true);
        }
    },
    handleSelectedProduct: function (component,event, helper){
        // console.log('-----handleSelectedProduct-------');
        var productList = component.get('v.productList');
        // console.log('SELECT RECORD : '+event.getSource().get("v.selectedRecord") )
        var indexVar = event.getSource().get("v.index");
        var productsubgroup = null;

        if(event.getSource().get("v.selectedRecord") != null){
            productsubgroup = event.getSource().get("v.selectedRecord").extraValue.RTL_Product_Sub_Group_Upper__c;
            // console.log('productsubgroup : ' + productsubgroup);
            if(productsubgroup != null && productsubgroup != ''){
               // productList[indexVar].productSubGroup = productsubgroup;
                productList[indexVar].selectedproductsubgroup = productsubgroup;
            }
        }else{
            // productList[indexVar].selectedproductsubgroup = null;
            // console.log('set product sub : ' + productList[indexVar].selectedproductsubgroup)
            productList[indexVar].productSubGroup = productList[indexVar].selectedproductsubgroup;
        }
        //productList[indexVar].productSubGroup = productList[indexVar].selectedproductsubgroup;
        component.set("v.productList",productList);
    },
    showMoreDetail: function (component, event, helper) {
        //console.log(component.campaignMemObj.RTL_Product_name__c);
        let i = 1;
        var campaign = component.get('v.campaignMemObj');
        //var productName = campaign.RTL_Product_Name__c;
        var workspaceAPI = component.find("workspace");
        var productList = component.get('v.productList');
        var indexVar = event.target.getAttribute('id');
        var productName = productList[indexVar].productName;
        var navigateTo;
        // var AutoloanList = 'CYC, CYB, NEW, USED';
        var AutoloanList = component.get("v.ALPrdNameSet");
        // var Homeloan = 'Home Loan';
        var Homeloan = component.get("v.HLCALPrdNameSet");

        if (AutoloanList.includes(productName)) {
            navigateTo = 'c__CampaignMember_AutoLoanCalInfo';
        }
        else if (Homeloan.includes(productName)) {
            navigateTo = 'c__CampaignMember_HomeLoanCalInfo';
        }

        workspaceAPI.isConsoleNavigation().then(function (response) {
            var isConsoleApp = response;

            if (isConsoleApp) {
                workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    var primaryTab = tabId.replace(/(_[0-9].*)/g, '');

                    workspaceAPI.getTabInfo({ tabId: primaryTab }).then(function (response) {
                        workspaceAPI.openSubtab({
                            parentTabId: primaryTab,
                            pageReference: {
                                'type': 'standard__component',
                                'attributes': {
                                    'componentName': navigateTo,
                                },
                                'state': {
                                    'c__campaignMemberId': component.get('v.recordId'),
                                    'c__productNumber' : parseInt(indexVar)+1
                                }
                            },
                            focus: true
                        });
                    }).catch(function (error) {
                        console.error(helper.parseObj(error));
                    });
                }).catch(function (error) {
                    console.error(helper.parseObj(error));
                });
            } else {
                // For Saleforce Lightning Experience Application
                // var urlEvent = $A.get("e.force:navigateToURL");
                // urlEvent.setParams({
                //     "url": _url
                // });
                // urlEvent.fire();   
            }
        })
            .catch(function (error) {
                console.error(error);
            });
    },
    
    handleCreateCallback: function (component, event, helper) {      
        var isCreateCallback = component.get('v.isCreateCallback');
        if(isCreateCallback)
        {
            $A.get('e.force:refreshView').fire();         
        }
    },
})