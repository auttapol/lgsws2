({ 
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    showSpinner: function (component) {
        component.set("v.spinner", true);
    },
    hideSpinner: function (component) {
        component.set("v.spinner", false);
    },

    navigateToObject : function(component,event,helper,id) {
        var theme = component.get("v.theme");

        var navigateTo = $A.get("e.force:navigateToSObject");

        if( !id ){
            var cancelEvent = $A.get("e.force:navigateToObjectHome");
            cancelEvent.setParams({
                "scope": "Lead"
            });
            cancelEvent.fire();
        }
        else if(theme == 'Theme4t'){
            navigateTo.setParams({
                "recordId": id,
                "slideDevName": "related"
            });
            navigateTo.fire();
            
        } else {
            if(component.get("v.isEdit") == true){
                helper.refreshFocusedTab(component,event,helper)
            }else{
                navigateTo.setParams({
                    "isredirect":true,
                    "recordId": id,
                    "slideDevName": "detail"
                }); 
                navigateTo.fire();
            }
           

        }
        
    },
    closeAndrefreshTab: function (component,event,helper) {
        var workspaceAPI = component.find("workspace");
        var navService = component.find('navService');
        var navigateTo = $A.get("e.force:navigateToSObject");       
        if (component.get('v.theme') != 'Theme4t') {
            workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
                    workspaceAPI.refreshTab({
                        tabId: primaryTab,
                        includeAllSubtabs: false
                    });

                    workspaceAPI.closeTab({
                        tabId: tabId
                    });

                    workspaceAPI.openTab({
                        pageReference: {
                            "type": "standard__recordPage",
                            "attributes": {
                                "recordId": component.get('v.recordId'),
                                "actionName":"view"
                            }
                        },
                        focus: true
                    }).then.then(function(response) {
                        workspaceAPI.focusTab({tabId : response});
                   })
                    $A.get('e.force:refreshView').fire();
                    })
                .catch(function (error) {
                });
        } else {
            navService.navigate({
                type: 'standard__recordPage',
                attributes: {
                    recordId: component.get('v.recordId'),
                    actionName: 'view'
                },
            }, true);
        }
    },
    closeTab: function (component) {
        var navService = component.find('navService');
        var workspaceAPI = component.find("workspace");

        if (component.get('v.recordId')) {
            if (component.get('v.theme') == 'Theme4t') {
                navService.navigate({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: component.get('v.recordId'),
                        actionName: 'view'
                    },
                }, true);
            } else if (['Theme4d', 'Theme4u'].includes(component.get('v.theme'))) {
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    
                });
            }
        } else {
            if (component.get('v.theme') == 'Theme4t'){
                navService.navigate({
                    "type": "standard__objectPage",
                    "attributes": {
                        "objectApiName": "Lead",
                        "actionName": "home"
                    }
                }, true);
            }else{
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    
                });

            }
           
        }

    },
    //get record from server
    getEditLeadRecord: function (component, event, helper, recordId) {
        var action = component.get("c.getLeadRecord");
        action.setParams({
            "editRecordId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var lead = response.getReturnValue();
                component.set("v.LeadRec", lead)
                component.set("v.editFormTextSubtitle", lead.Company);
                if(component.get("v.isAccount")==true){
                    component.set("v.isAccountedit",true);
                }
                //Assign Name
                component.set("v.defaultValue.FirstName",lead.FirstName);
                component.set("v.defaultValue.LastName",lead.LastName);
                component.set("v.defaultValue.Salutation",lead.Salutation);
                component.set("v.salutationValue",lead.Salutation);
            }
            
        });
        $A.enqueueAction(action);
    },
    //get record type
    getRecordTypeName: function (component, event, helper, recordTypeId) {
        var action = component.get("c.getRecordTypeName");
        action.setParams({
            "recordTypeId": recordTypeId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recordTypeName = response.getReturnValue();
                component.set("v.editFormTextSubtitle", recordTypeName);
                component.set("v.recordTypeIdString", recordTypeName);
                
                if(recordTypeName == 'Commercial Account'){
                    component.set("v.isAccount", true);
                }
                if (`${recordTypeName}`.includes('Commercial')) {
                    component.set("v.isCommercialAccount", true);
                }

            }
        });
        $A.enqueueAction(action);
    },
    handleFormSubmit: function (component, event, helper, fields) {
        var eventFields = event.getParam("fields");
        var recordId = component.get("v.recordId");
        // console.log(JSON.parse(JSON.stringify(eventFields)));
        eventFields["RecordTypeId"] = component.get("v.recordTypeId");
        
        helper.salutationSet(component,event,helper,eventFields);
        //name assign
        /*var name = component.find("LeadName");
        eventFields["FirstName"]= name.get("v.firstName");
        eventFields["LastName"]= name.get("v.lastName");
        eventFields["Salutation"]= name.get("v.salutation");*/
        ////handle no referral////
        if(eventFields["RTL_Referral__c"]==''){
            eventFields["RTL_Referral__c"]= null;
       }
       //////handle no type /////
       if(eventFields["ID_Type__c"]==''){
        eventFields["ID_Type__c"]= null;
   }
       /////handle no Account//////
        if(eventFields["Account__c"]==''){
            eventFields["Account__c"]= null;
        }
        /// handle no Id number
        if(eventFields["ID_Number__c"]==''){
            eventFields["ID_Number__c"]= null;
       }
        ///////////// edit mode////////////////
        if (recordId) { 
            ////ChangeCustomer//
            if (component.get("v.isAccount") == true){
                if(eventFields["Account__c"]!='' && eventFields["Account__c"]!= null ){
                    
                    helper.populatedAccount(component,event,helper,eventFields);
                }
            }
            var action = component.get("c.getLeadRecordByFields");
            action.setParams({
                leadfields: eventFields,
                RecordId: recordId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var duplication = response.getReturnValue()[0];
                    var bypassDuplication = response.getReturnValue()[1];
                    var referralError = response.getReturnValue()[2]; 
                    var accDup = response.getReturnValue()[3];
                    var accDupID = response.getReturnValue()[4];
                    var CommAccTypeRecordId = response.getReturnValue()[5];
                    var CommLeadTypeRecordId = response.getReturnValue()[6];
                    var isDisqualified = response.getReturnValue()[7];
                    var CompletedRecordTypeId = response.getReturnValue()[8];

                    //202108_INC0171769             
                    var acctNotMatch = response.getReturnValue()[9];
                    var acctErrorMsg = response.getReturnValue()[10];
                    
                    if(isDisqualified == 'true'){
                        helper.populatedLeadComplete(component,event,helper,eventFields,CompletedRecordTypeId);
                    }
                    
                    component.set("v.isDuplicated",JSON.parse(duplication));
                    if (acctNotMatch == 'true') {                        
                        component.set('v.spinner', false);
                        component.set('v.errorCheck', false);
                        component.set("v.errorText",acctErrorMsg);
                    }///Lead Duplicated
                    else if (duplication == 'true') {
                        var error = component.get("v.duplicatedErrorMessage")
                        //component.find('LeadMessage').setError(error);
                        component.set('v.spinner', false);
                        /*var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "",
                                message: error,
                                type: "error"
                            });
                            toastEvent.fire();*/
                            component.set('v.errorCheck', false);
                            component.set("v.errorText",error);
                    } else if (duplication == 'false') {
                        eventFields["isBypassDuplicateCheck__c"] = JSON.parse(bypassDuplication);;
                        ///Referral Error
                        if(referralError != 'No Referral Error'){
                            //component.find('LeadMessage').setError(referralError);
                            component.set('v.spinner', false);
                           /* var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "",
                                message: referralError,
                                type: "error"
                            });
                            toastEvent.fire();*/
                            component.set('v.errorCheck', false);
                            component.set("v.errorText",referralError);
                            
                        //Already customer
                        }else if(accDup=='true'){
                            var error = component.get("v.duplicatedErrorMessage");
                            
                            helper.populatedExistCustomer(component,event,helper,eventFields,accDupID,CommAccTypeRecordId,isDisqualified,CompletedRecordTypeId);
                            if(isDisqualified == 'true'){
                                helper.populatedLeadComplete(component,event,helper,eventFields,CompletedRecordTypeId);
                                component.find('recordCreateForm').submit(eventFields);
                            }   
                        //No Error
                        }else if(referralError == 'No Referral Error' && accDup !='true'){
                            
                            var recType = component.get("v.recordTypeIdString");
                            
                            //allChange to CommLead//
                            if((eventFields["Account__c"]==null)){
                                if(isDisqualified == 'true'){

                                }else{
                                    eventFields["RecordTypeId"] = CommLeadTypeRecordId;
                                }
                               
                            }
                            
                            /*if(((recType=='Commercial Account' || recType=='Commercial Completed') &&(eventFields["Account__c"]==null))==true){
                                eventFields["RecordTypeId"] = CommLeadTypeRecordId;
                            }*/
                            
                            var refstate = 'Edit';
                            if(eventFields["RTL_Referral__c"]!=null && eventFields["RTL_Referral__c"]!= ''){
                                helper.populatedReferral(component,event,helper,eventFields,refstate);
                            }else{
                                component.find('recordCreateForm').submit(eventFields);
                                

                            }
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
        ///////////////Create mode/////////////////////////
        else {
            
            if (component.get("v.isAccount") == true){
                if(eventFields["Account__c"]!='' && eventFields["Account__c"]!= null ){
                    helper.populatedAccount(component,event,helper,eventFields);
                }
            }
           ////handle no referral/////
           if(eventFields["RTL_Referral__c"]==''){
                eventFields["RTL_Referral__c"]= null;
           }
            var action = component.get("c.getLeadCreateRecordByFields");
            action.setParams({
                leadfields: eventFields,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var duplication = response.getReturnValue()[0];
                    var referralError = response.getReturnValue()[1]; 
                    var accDup = response.getReturnValue()[2];
                    var accDupID = response.getReturnValue()[3];
                    var CommAccTypeRecordId = response.getReturnValue()[4];
                    var CommLeadTypeRecordId = response.getReturnValue()[5];
                    var isDisqualified = response.getReturnValue()[6];
                    var CompletedRecordTypeId = response.getReturnValue()[7];
                    component.set("v.isDuplicated", JSON.parse(duplication));
                    //Lead Dup
                    if(isDisqualified == 'true'){
                        helper.populatedLeadComplete(component,event,helper,eventFields,CompletedRecordTypeId);
                    }
                    if (duplication == 'true') {
                        var error = component.get("v.duplicatedErrorMessage");
                        //component.find('LeadMessage').setError(error);
                        component.set('v.spinner', false);/*
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "",
                            message: error,
                            type: "error"
                        });
                        toastEvent.fire();*/
                        component.set('v.errorCheck', false);
                        component.set("v.errorText",error);
                        
                    } else if (duplication == 'false') {
                        //referral error
                        if(referralError != 'No Referral Error'){
                            //component.find('LeadMessage').setError(referralError);
                            component.set('v.spinner', false); 
                            /*var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "",
                                message: referralError,
                                type: "error"
                            });
                            toastEvent.fire();*/
                            component.set('v.errorCheck', false);
                            component.set("v.errorText",referralError);
                        //Already customer
                        }else if(accDup=='true'){
                            var error = component.get("v.duplicatedErrorMessage");
                            
                            helper.populatedExistCustomer(component,event,helper,eventFields,accDupID,CommAccTypeRecordId,isDisqualified,CompletedRecordTypeId);
                            if(isDisqualified == 'true'){
                                helper.populatedLeadComplete(component,event,helper,eventFields,CompletedRecordTypeId);
                                component.find('recordCreateForm').submit(eventFields);
                            }
                        // no Error    
                        }else if(referralError == 'No Referral Error' && accDup !='true'){
                            
                            var recType = component.get("v.recordTypeIdString");
                            //allChange to CommLead//
                            if((eventFields["Account__c"]==null)){
                                if(isDisqualified == 'true'){

                                }else{
                                    eventFields["RecordTypeId"] = CommLeadTypeRecordId;
                                }
                            }
                           /* if(((recType=='Commercial Account'|| recType=='Commercial Completed') &&(eventFields["Account__c"]==null))==true){
                                eventFields["RecordTypeId"] = CommLeadTypeRecordId;
                            }*/
                            var refstate = 'Create';
                            if(eventFields["RTL_Referral__c"]!=null && eventFields["RTL_Referral__c"]!= ''){
                                helper.populatedReferral(component,event,helper,eventFields,refstate);
                                
                            }else{
                                component.find('recordCreateForm').submit(eventFields);
                                
                            }
                            
                        }
                    }
                }
            });
           /* 
            var dupacc = (eventFields["ID_Number__c"].toLowerCase()).includes('duplicated');
            if(dupacc == true){
                component.set('v.spinner', false); 
                return;

            }*/
            $A.enqueueAction(action);
        }

    },

    getErrorMessage: function (component) {
        var action = component.get("c.getErrorMessage");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var errorMessage = response.getReturnValue();
                component.set("v.duplicatedErrorMessage", errorMessage)
            }
        });
        $A.enqueueAction(action);
    },
    
    getReferralErrorMessage: function (component) {
        var action = component.get("c.getReferralErrorMessage");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var errorMessage = response.getReturnValue();
                component.set("v.referralErrorMessage", errorMessage)
            }
        });
        $A.enqueueAction(action);
    },
    populatedAccount: function(component, event, helper,eventFields){
        var AccId = eventFields["Account__c"];
        if(AccId!='' && AccId!= null){
            var action = component.get("c.getAccountInfo");
            action.setParams({
                AccId: AccId,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var acc = response.getReturnValue();
                    component.set("v.AccRec", acc)
                    var dupacc = (acc.ID_Number_PE__c.toLowerCase()).includes('duplicated')
                    helper.populatedAccountPrefill(component,eventFields);
                }
            });
            $A.enqueueAction(action);
        }

    },
    populatedAccountPrefill:function(component,eventFields){
        var acc = component.get("v.AccRec");
        eventFields["Company"] = acc.Name;
        eventFields["Customer_Name_EN__c"] = acc.Customer_Name_PE_Eng__c;
        eventFields["Customer_Type__c"] = acc.Customer_Type__c;
        eventFields["ID_Type__c"] = acc.ID_Type_PE__c;
        eventFields["ID_Number__c"] = acc.ID_Number_PE__c;
        
        eventFields["Mobile_No__c"] = acc.Mobile_Number_PE__c;
        eventFields["Office_No__c"] = acc.Phone;
        eventFields["Ext__c"] = acc.Primary_Phone_Ext_PE__c;
        eventFields["Email__c"] = acc.Email_Address_PE__c;
        eventFields["Address_Line_1__c"] = (acc.Primary_Address_Line_1_PE__c=='Primary_Address_Line_1_PE__c')?'':acc.Primary_Address_Line_1_PE__c;
        eventFields["Address_Line_2__c"] = (acc.Primary_Address_Line_2_PE__c=='Primary_Address_Line_2_PE__c')?'':acc.Primary_Address_Line_2_PE__c;
        eventFields["Address_Line_3__c"] = (acc.Primary_Address_Line_3_PE__c=='Primary_Address_Line_3_PE__c')?'':acc.Primary_Address_Line_3_PE__c;
        eventFields["Province__c"] = (acc.Province_Primary_PE__c=='Province_Primary_PE__c')?'':acc.Province_Primary_PE__c;
        eventFields["Zipcode__c"] = acc.Zip_Code_Primary_PE__c;
        eventFields["Country__c"] = acc.Country_Primary_PE__c;
        eventFields["Industry__c"] = acc.Industry__c;
        eventFields["Parent_Company__c"] = acc.ParentId;
        eventFields["Sales_amount_per_year__c"] = acc.Sales_amount_per_year__c;
        eventFields["Group__c"] = acc.Group__c;
        eventFields["No_of_Years_Business_Run__c"] = acc.No_of_years_business_run__c;
        eventFields["Preferred_Branch__c"] = acc.Branch_and_Zone__c;
        var dupacc = (acc.ID_Number_PE__c.toLowerCase()).includes('duplicated');
        if(dupacc == true){
        component.set("v.isDupByAcc", true)
        }
    },

    populatedExistCustomer:function (component,event,helper,eventFields,accDupID,CommAccTypeRecordId,isDisqualified,CompletedRecordTypeId){
        if(accDupID !='' && accDupID != null){
            var action = component.get("c.getAccountInfo");
            action.setParams({
                AccId: accDupID,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var acc = response.getReturnValue();
                    //eventFields["RecordTypeId"] = CommAccTypeRecordId;
                    eventFields["Company"] = acc.Name;
                    eventFields["Customer_Name_EN__c"] = acc.Customer_Name_PE_Eng__c;
                    eventFields["Customer_Type__c"] = acc.Customer_Type__c;
                    eventFields["ID_Type__c"] = acc.ID_Type_PE__c;
                    
                    eventFields["ID_Number__c"] = acc.ID_Number_PE__c;;
                    
                    eventFields["Mobile_No__c"] = acc.Mobile_Number_PE__c;
                    eventFields["Office_No__c"] = acc.Phone;
                    eventFields["Ext__c"] = acc.Primary_Phone_Ext_PE__c;
                    eventFields["Email__c"] = acc.Email_Address_PE__c;
                    eventFields["Address_Line_1__c"] = (acc.Primary_Address_Line_1_PE__c=='Primary_Address_Line_1_PE__c')?'':acc.Primary_Address_Line_1_PE__c;
                    eventFields["Address_Line_2__c"] = (acc.Primary_Address_Line_2_PE__c=='Primary_Address_Line_2_PE__c')?'':acc.Primary_Address_Line_2_PE__c;
                    eventFields["Address_Line_3__c"] = (acc.Primary_Address_Line_3_PE__c=='Primary_Address_Line_3_PE__c')?'':acc.Primary_Address_Line_3_PE__c;
                    eventFields["Province__c"] = (acc.Province_Primary_PE__c=='Province_Primary_PE__c')?'':acc.Province_Primary_PE__c;
                    eventFields["Zipcode__c"] = acc.Zip_Code_Primary_PE__c;
                    eventFields["Country__c"] = acc.Country_Primary_PE__c;
                    eventFields["Industry__c"] = acc.Industry__c;
                    eventFields["Parent_Company__c"] = acc.ParentId;
                    eventFields["Sales_amount_per_year__c"] = acc.Sales_amount_per_year__c;
                    eventFields["Group__c"] = acc.Group__c;
                    eventFields["No_of_Years_Business_Run__c"] = acc.No_of_years_business_run__c;
                    eventFields["Preferred_Branch__c"] = acc.Branch_and_Zone__c;
                    eventFields["Account__c"] = acc.Id;
                    
                    component.set("v.AccountIdByPass",eventFields["Account__c"]);
                    component.find('recordCreateForm').submit(eventFields);
                }
            });
            $A.enqueueAction(action);
        }    
    },
    populatedLeadComplete:function (component,event,helper,eventFields,CompletedRecordTypeId){
        eventFields["Status"] ='Unqualified';
        eventFields["Unqualified_Rejected_List__c"] = 'Owned by another RM';
        eventFields["Unqualified_Reasons__c"] = 'Owned by another RM';            
        //eventFields["RecordTypeId"] = CompletedRecordTypeId;
        component.set("v.CompleteBypass",true);
        

    },
    populatedReferral: function (component,event,helper,eventFields,refstate){
        
        var action = component.get("c.populateReferralInfo");
        action.setParams({
            referralId: eventFields["RTL_Referral__c"],
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var referral = response.getReturnValue();
                if(state = 'Create'){
                    eventFields["LastName"] = referral.RTL_LastName__c;
                    eventFields["Salutation"] = referral.RTL_Title__c;
                    eventFields["FirstName"] = referral.RTL_FirstName__c;
                    eventFields["Phone__c"] = referral.RTL_Mobile1__c;
                    eventFields["Ext__c"] = referral.RTL_Ext__c;
                    eventFields["Company"] = (referral.RTL_Company__c==null)?referral.RTL_FirstName__c+' '+referral.RTL_LastName__c:referral.RTL_Company__c;
                    eventFields["Title"] = referral.RTL_Position__c;
                    eventFields["Office_No__c"] = referral.RTL_Phone1__c;
                    eventFields["Mobile_No__c"] = referral.RTL_Mobile1__c;
                    eventFields["Email__c"] = referral.RTL_Email__c;
                    eventFields["Remark__c"] = referral.RTL_Comment__c;
                    eventFields["Preferred_Branch__c"] = referral.RTL_Preferred_Branch__c;
                }
                eventFields["Referral_Staff_ID__c"] = referral.RTL_EmployeeID__c;
                eventFields["Referral_Staff_Name__c"] = referral.RTL_Employee_Name__c;
                eventFields["Status"] = 'Contacted';
                eventFields["Contacted_Flag__c"] = true;
                eventFields["Pre_screening_Result__c"] = 'Passed';
                if(referral.RecordType.DeveloperName == 'Refer_within_Commercial'|| referral.RecordType.DeveloperName == 'Closed_Refer_within_Commercial'){
                    eventFields["LeadSource"] = referral.RTL_Channel_Segment__c;
                }else{
                    eventFields["LeadSource"] = 'Refer within Commercial';
                }
                
                component.find('recordCreateForm').submit(eventFields);
            }
        });
        $A.enqueueAction(action);
        
    },

    getReferralRecord: function (component, event, helper) {
        var action = component.get("c.populateReferralInfo");
        action.setParams({
            "referralId": component.get("v.defaultValue.RTL_Referral__c")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ref = response.getReturnValue();
                component.set("v.RefRec", ref)
                
                var fields = component.find("fieldName");
                fields.forEach(function (field) {
                    if(field.get("v.fieldName") === 'LastName'){
                        field.set("v.values",component.get("v.RefRec.RTL_LastName__c"))
                    } 
                });

            }
        });
        $A.enqueueAction(action);
    },
    linkCustomerBypass: function (component, event, helper) {
        var action = component.get("c.linkCustomerBypass");
        action.setParams({
            "accountId": component.get("v.AccountIdByPass"),
            "leadId":component.get("v.recordId"),
            "disqualifiedFlag":component.get("v.CompleteBypass") 
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            }
        });
        $A.enqueueAction(action);

    },
    salutationSet: function(component,event,helper,eventFields){
        if(eventFields["Salutation"] == '--None--'){

        }else{
            eventFields["Salutation"]= component.get("v.salutationValue");
        }
    },
    navHome : function (component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Lead"
        });
        homeEvent.fire();
        
    },
    checkBrowser: function(component) {
        var device = $A.get("$Browser.isAndroid");
    },
    thaiEncode: function(component,event,helper){
        if(component.get("v.defaultValue.Company") != ''){
            component.set("v.defaultValue.Company", decodeURIComponent(escape(window.atob(component.get("v.defaultValue.Company")))));
        }
        if(component.get("v.defaultValue.FirstName") != ''){
            component.set("v.defaultValue.FirstName", decodeURIComponent(escape(window.atob(component.get("v.defaultValue.FirstName")))));
        }
        if(component.get("v.defaultValue.LastName") != ''){
            component.set("v.defaultValue.LastName", decodeURIComponent(escape(window.atob(component.get("v.defaultValue.LastName")))));
        }
        if(component.get("v.defaultValue.Ext__c") != ''){
            component.set("v.defaultValue.Ext__c", decodeURIComponent(escape(window.atob(component.get("v.defaultValue.Ext__c")))));
        }
        if(component.get("v.defaultValue.Title") != ''){
            component.set("v.defaultValue.Title", decodeURIComponent(escape(window.atob(component.get("v.defaultValue.Title")))));
        }
        if(component.get("v.defaultValue.Remark__c") != ''){
            component.set("v.defaultValue.Remark__c", decodeURIComponent(escape(window.atob(component.get("v.defaultValue.Remark__c")))));
        }
        if(component.get("v.defaultValue.Referral_Staff_Name__c") != ''){
            component.set("v.defaultValue.Referral_Staff_Name__c", decodeURIComponent(escape(window.atob(component.get("v.defaultValue.Referral_Staff_Name__c")))));
        }
    },
    isHasAccess: function (component, event, helper) {
        var action = component.get("c.checkAccess");
        action.setParams({
            "leadId":component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var access = response.getReturnValue();
                component.set("v.AccessPermission", access);
                if(access===false){
                    component.set('v.spinner', false);
                    component.set("v.errorText", 'Lead cannot be created. Your access is set to \'Read Only\'.(ไม่สามารถ สร้าง Lead ได้ เนื่องจากสิทธิ์เข้าถึงลูกค้าได้เพียง \"ดูได้อย่างเดียว \")');
                }
            }
        });
        $A.enqueueAction(action);

    },
    completeBypass: function (component, event, helper) {
        var action = component.get("c.completeBypass");
        action.setParams({
            "leadId":component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
            }
        });
        $A.enqueueAction(action);

    },
        refreshFocusedTab : function(component, event, helper) {
        var theme = component.get("v.theme");
        if(theme=="Theme4u"){
            var _recordId = component.get('v.recordId');
            var workspaceAPI = component.find("workspace");

            workspaceAPI.getEnclosingTabId().then(function (tabId) {
                var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
                workspaceAPI.getTabInfo({
                    tabId: primaryTab
                }).then(function (response) {
                    if (response.recordId == _recordId && !response.isSubtab) {
                        workspaceAPI.refreshTab({
                            tabId: primaryTab,
                            includeAllSubtabs: false
                        });
                    }
        
                    var subtabs = response.subtabs.filter(f => f.pageReference.attributes.recordId == _recordId);
                    subtabs.forEach(e => {
                        workspaceAPI.refreshTab({
                            tabId: e.tabId,
                            includeAllSubtabs: false
                        });
                    })
        
                    setTimeout(() => {
                        workspaceAPI.closeTab({
                            tabId: tabId
                        });
                        
                        $A.get('e.force:refreshView').fire();
                        
                    }, 250);
                });
            
            })
            .catch(function (error) {
                
            });
        }
        
        }
})