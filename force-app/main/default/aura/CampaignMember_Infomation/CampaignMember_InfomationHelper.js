({
	displayToast : function(component ,helper, title, type, message) {
	    var toastEvent = $A.get('e.force:showToast');
	    toastEvent.setParams({
            title: title,
	        type: type,
	        message: message
	    });
	    toastEvent.fire();
    },
    getCurrentUser: function(component,event,helper){
        var action = component.get('c.getCurrentUser');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                // console.log('currentUser:',result); 
                component.set('v.currentUser',result);               
            }         
        });
        
        $A.enqueueAction(action);
    },
    getCampaignMember: function (component,event,helper)
    {
        component.set('v.loaded', true);  
        var recordId = component.get('v.recordId');
        // console.log('recordId:'+recordId);
     
        var action = component.get('c.getCampaignMember');
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var result =  response.getReturnValue();
                // console.log('campaignMemObj:',result);    
                component.set('v.campaignMemObj',result);
                if(result)
                {
                    if(result.RTL_Web_Unique_ID__c)
                    {
                        component.set('v.marketingCodeOrWebUniqueId',result.RTL_Web_Unique_ID__c);
                    }
                    else if(result.RTL_Marketing_Code__c)
                    {
                        component.set('v.marketingCodeOrWebUniqueId',result.RTL_Marketing_Code__c);
                    }
                    
                    if(result.RTL_Contact_Status__c == 'New')
                    {
                        component.set('v.isChangeContact', true);
                    }
                    else
                    {
                        if(result.RTL_Contact_Status__c == 'Contact')
                        {                       
                            // component.set('v.isChangeContact', true);
                            component.set('v.isDisabled', false);
                            component.set('v.isConvert',false); 
                        }
                        else if(result.RTL_Contact_Status__c == 'Call Back')
                        {
                            component.set('v.isChangeContact', true);
                            component.set('v.isCallBack', true);
                            component.set('v.isDisabled', false);
                            component.set('v.isCallBack', true);

                        }               
                        else if(result.RTL_Contact_Status__c == 'Uncontact')
                        {
                            component.set('v.isChangeContact', true);
                            component.set('v.isReadonly', false);
                            component.set('v.isDisabled', true);
                            component.set('v.isConvert',false); 
                        }
                        else
                        {
                            component.set('v.isChangeContact', false);
                            component.set('v.isDisabled', true);
                            component.set('v.isConvert',true); 
                            component.set('v.confirmDNC',true);
                        }
                    }
                   
                 
                    if(!result.ContactId)
                    {
                        //console.log(result.Lead.Name + ' ' +  result.Campaign.Name);
                        if(result.Lead.Name)
                        {
                            component.set('v.customerName', result.Lead.Name );
                        }
                        component.set('v.mobileNumber',result.RTL_CampHis_Phone__c);
                        component.set('v.idNoValue',result.RTL_CampHis_Phone__c);
                        component.set('v.idType','Other ID');
                       
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getTabInfo().then(function(response) {
                            // console.log('isSubtab:',response.isSubtab);
                            var focusedTabId = response.tabId;
                            workspaceAPI.setTabIcon({
                                tabId: focusedTabId,
                                icon: "standard:campaign_members",
                                iconAlt: "Campaign_Members",
                            });
                            workspaceAPI.setTabLabel({
                                tabId: focusedTabId,
                                label: result.Lead.Name  + ' ' +  result.Campaign.Name
                            });              
                       })
                        .catch(function(error) {
                            console.log(error);
                        });                   
                    } 
                    else
                    {
                        if(result.Contact.Name)
                        {
                            //console.log(result.Contact.Name + ' ' +  result.Campaign.Name);
                            var workspaceAPI = component.find("workspace");
                            workspaceAPI.getTabInfo().then(function(response) {
                                // console.log('isSubtab:',response.isSubtab);
                                var focusedTabId = response.tabId;
                                workspaceAPI.setTabIcon({
                                    tabId: focusedTabId,
                                    icon: "standard:campaign_members",
                                    iconAlt: "Campaign_Members",
                                });
                                workspaceAPI.setTabLabel({
                                    tabId: focusedTabId,
                                    label: result.Contact.Name + ' ' +  result.Campaign.Name
                                });                              
                            })
                            .catch(function(error) {
                                console.log(error);
                            });
                        }
                    } 
                }          
                //helper.getCustomerInfo(component, event, helper);
                component.set('v.loaded', false);  
            }
            else
            {
                component.set('v.loaded', false);  
            }

        });
        $A.enqueueAction(action);
    },

    getCampaignProductList: function (component,event,helper)
    {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getCampaignProductWrapper');
        // var isConvert = true;
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var productList =  response.getReturnValue();              
                //console.log('productList:',productList);
                if(productList != null)
                {
                    productList.forEach((product,index) => {        
                        product.productGroupList = [];                 
                        product.productNameList = [];
                        product.offerResultList = [];                    
                        product.selectedproductsubgroup = product.productSubGroup;
                        var items = [];
                        // var value1 = {
                        //     "label": '-- None --',
                        //     "value": ''
                        // };
                        // items.push(value1);

                        product.reasonOfNotInterestedList = items;

                        product.opptyStageList = [];
                        product.opptyStatusList = [];
                        if(product.productGroup)
                        {
                            product.productGroupUpper = product.productGroup.toUpperCase();
                        }  
                        if(!product.objOpp.Amount)
                        {
                            product.objOpp.Amount = 0;
                        }  
                        if(!product.viewOfferResult)
                        {
                            component.set('v.isChangeContact', true);
                        }  
                        // if(product.offerResult != null || product.offerResult != undefined)
                        // {
                        //     if(product.objOpp.Name != null || product.objOpp.Name != undefined )
                        //     {                               
                        //         isConvert = true;
                        //     }
                        //     // if(product.offerResult == 'Interested')
                        //     // {
                        //     //     isConvert = true;                          
                        //     // }
                        //     // else if(product.offerResult != 'Interested' && product.reason != null && product.reason != undefined )
                        //     // {
                        //     //     isConvert = false;                          
                        //     // }
                        // }
                        // else
                        // {
                        //     isConvert = false;   
                        // }                           
                        // product.isValidate = false;
                    }); 
                }
                // console.log('isConvert:',isConvert);  
                // console.log('Product:',productList);  
                // component.set('v.isConvert',isConvert); 
                component.set('v.productList',productList); 
                // console.log('productList:',component.get('v.productList')); 

                //helper.getFieldLabel(component, event, helper,result);
                if(productList != null)
                {
                    productList.forEach((product,index) => {        
                        if(product.viewGroup && !product.viewSubGroup)
                        {
                            helper.getProductSubGroupPickList(component,event,helper,index,product.productGroup); 
                        }
                        if(product.offerResult != 'Interested' && product.reason != null && product.reason != undefined )
                        {
                            helper.getReasonForNotInterestPickList(component, event, helper, index, product.productGroup,product.offerResult);
                        }
                    }); 
                }
            }

        });
        $A.enqueueAction(action);       
    },

    getCampaignProductINT06: function (component,event,helper, cmObj)
    {
        component.set('v.loaded', true); 
        var action = component.get('c.getCampaignProductWrapperINT06');
        // var isConvert = true;
        action.setParams({
            "cmObj" : cmObj
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var productList =  response.getReturnValue();              
                //console.log('productList:',productList);
                if(productList != null)
                {
                    productList.forEach((product,index) => {        
                        product.productGroupList = [];                 
                        product.productNameList = [];
                        product.offerResultList = [];                    

                        var items = [];
                        var value1 = {
                            "label": '-- None --',
                            "value": ''
                        };
                        items.push(value1);

                        product.reasonOfNotInterestedList = items;

                        product.opptyStageList = [];
                        product.opptyStatusList = [];
                        if(product.productGroup)
                        {
                            product.productGroupUpper = product.productGroup.toUpperCase();
                        }  
                        if(!product.objOpp.Amount)
                        {
                            product.objOpp.Amount = 0;
                        }  
                        if(!product.viewOfferResult)
                        {
                            component.set('v.isChangeContact', true);
                        }  
                    }); 
                }
                // console.log('isConvert:',isConvert);  
                // console.log('Product:',productList);  
                // component.set('v.isConvert',isConvert); 
                component.set('v.productList',productList); 


                if(productList != null)
                {
                    productList.forEach((product,index) => {        
                        if(product.viewGroup && !product.viewSubGroup)
                        {
                            helper.getProductSubGroupPickList(component,event,helper,index,product.productGroup); 
                        }
                        if(product.offerResult != 'Interested' && product.reason != null && product.reason != undefined )
                        {
                            helper.getReasonForNotInterestPickList(component, event, helper, index, product.productGroup,product.offerResult);
                        }
                    }); 
                }
                component.set('v.loaded', false); 
            }
            else
            {
                component.set('v.loaded', false); 
            }

        });
        $A.enqueueAction(action);       
    },

    getFieldLabel: function (component,event,helper,campaignMemObj) {
        
        var action = component.get('c.getFieldLabel');
        action.setParams({
            "objectName" : 'CampaignMember'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                // console.log('label:',result); 
                component.set('v.labelMap',result);               
            }         
        });
        
        $A.enqueueAction(action);
    },

    getContactStatusPickList: function (component,event,helper) {
        
        var action = component.get('c.getPickListValues');
        action.setParams({
            "objectName": 'Business_Outcome_Mapping__c',
            "fieldName": 'Contact_Status__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                //console.log('CM Contact_Status__c : ',result);
                var items = [];
                if(result)
                {
                    result.forEach(value => {
                        var item = {
                            "label": value.split(',')[0],
                            "value": value.split(',')[1]
                        };
                        items.push(item);              
                    }); 
                }
                // if(component.get('v.campaignMemObj').RTL_Contact_Status__c == 'Unused')
                // {
                //     var item1 = {
                //         "label": 'Unused',
                //         "value": 'Unused'
                //     };
                //     items.push(item1);
                // }
                
                component.set("v.contactStatusList", items);
            }                     
        });
        
        $A.enqueueAction(action);
    },

    getUncontactReasonPickList: function (component,event,helper) {
        
        var action = component.get('c.getPickListValues');
        action.setParams({
            "objectName" : 'Business_Outcome_Mapping__c',
            "fieldName" : 'Uncontact_Reason__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                var items = [];
                if(result)
                {
                    // console.log('getUncontactReasonPickList',result);
                    result.forEach(value => {
                        var item = {
                            "label": value.split(',')[0],
                            "value": value.split(',')[1]
                        };
                        items.push(item);
                    }); 
                }
                component.set("v.uncontactReasonList", items);
            }                  
        });
        
        $A.enqueueAction(action);
    },

    // lgsws2
    getLeadScoreLevelPickList: function (component,event,helper) {
        
        var action = component.get('c.getLeadScoreLevelPickListValues');
        // action.setParams({
        //     "objectName": 'Business_Outcome_Mapping__c',
        //     "fieldName": 'Contact_Status__c'
        // });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                var items = [];
                var mins = [];
                if(result)
                {
                    result.forEach(value => {
                        // console.log('Result items',value);
                        var item = {
                            "label": value.Name,
                            "value": value.Name
                        };
                        // var item =value.Name;
                        
                        items.push(item);
                        var min = {
                            "label": value.Name,
                            "value": value.Score_Min__c
                        };
                        mins.push(min);
                    });
                    // console.log('Result items',items);
                    // console.log('Result lead Score Level List',result);
                    
                }
                component.set("v.leadScoreLevelList", items);
                component.set("v.leadScoreLevelListmin", mins);
            }
        });
        
            $A.enqueueAction(action);
        
            
    },
    getReasonForNotInterestPickList: function (component,event,helper,index,productGroup,offerResult) {
        var productList = component.get('v.productList');
        var action = component.get('c.getReasonNotInterestFromBOM');
        action.setParams({
            "productGroup" : productGroup,
            "offerResult" : offerResult
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                // console.log('Reason',result);
                var items = [];
                var value1 = {
                    "label": '-- None --',
                    "value": ''
                };
                items.push(value1);
                if(result)
                {
                    result.forEach(value => {
                        var item = {
                            "label": value,
                            "value": value
                        };
                        items.push(item);
                    }); 
                }
                // console.log('befot sort:',items);
                items.sort(function(a, b) {
                    var nameA = a.label.toUpperCase(); // ignore upper and lowercase
                    var nameB = b.label.toUpperCase(); // ignore upper and lowercase
                    if (nameA < nameB) {
                      return -1;
                    }
                    if (nameA > nameB) {
                      return 1;
                    }
                  
                    // names must be equal
                    return 0;
                  });
                // console.log('after sort:',items);
                productList[index].reasonOfNotInterestedList = items;  
                component.set("v.productList", productList);   
                component.set("v.reasonOfNotInterestedList", items);
            }                     
        });
        
        $A.enqueueAction(action);
    },

    getProductGroupPickList: function (component,event,helper) {
        var productList = component.get('v.productList');
        var action = component.get('c.getPickListValues');
        action.setParams({
            "objectName" : 'CampaignMember',
            "fieldName" : 'RTL_Product_Group_1__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                 //productList[productNo-1].productGroupList = result;  
                //component.set("v.productList", productList);  
                productList.forEach((product,index) => {
                    // if(!product.viewGroup)
                    // {
                        var items = [];
                        if(result)
                        {
                            result.forEach(value => {
                                var item = {
                                    "label": value.split(',')[0],
                                    "value": value.split(',')[1]
                                    // "label": value.toUpperCase(),
                                    // "value": value.toUpperCase()
                                };
                                items.push(item);
                            }); 
                        }
                        productList[index].productGroupList = items; 
                    // }
                   
                });   
                // component.set("v.productGroupList", items);
                // console.log('productGroupList:',result);
            }                     
        });
        
        $A.enqueueAction(action);
    },

    getProductSubGroupPickList: function (component,event,helper,index,productGroup) {
        var productList = component.get('v.productList');
        var action = component.get('c.getDependentPicklistValues');

        action.setParams({
            "objectName" : 'CampaignMember',
            "fieldName" : 'RTL_Sub_Group_1__c',
            "contrlValue" : productGroup
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();           
                //productSubGroupList = result;
                var items = [];
                if(result)
                {
                    result.forEach(value => {
                        var item = {
                            "label": value.split(',')[0],
                            "value": value.split(',')[1]
                        };
                        items.push(item);
                    }); 
                }         
                productList[index].productSubGroupList = items;    
                component.set("v.productList", productList);   
                component.set("v.productSubGroupList", items);
            }                     
        });
        
        $A.enqueueAction(action);
        //return productSubGroupList;
    },

    setProductSubGroupPickListCrossSell: function (component, event, helper, productGroup, index) {
        if(productGroup != null && productGroup != ''){
            var action = component.get('c.getDependentPicklistValues');
            action.setParams({
                "objectName" : 'CampaignMember',
                "fieldName" : 'RTL_Sub_Group_1__c',
                "contrlValue" : productGroup
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {               
                    var result =  response.getReturnValue();  
                    var items = [];
                    if(result)
                    {
                        result.forEach(value => {
                            var item = {
                                "label": value.split(',')[0],
                                "value": value.split(',')[1]
                            };
                            items.push(item);
                        }); 
                    }
                    component.set('v.CrossSellList['+index+'].productSubGroupList', items);
                }                     
            });
        
            $A.enqueueAction(action);
        }else{
            var action = component.get('c.getPickListValues');
            action.setParams({
                "objectName" : 'CampaignMember',
                "fieldName" : 'RTL_Sub_Group_1__c'
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {               
                    var result =  response.getReturnValue(); 
                    
                    var items = [];
                    if(result)
                    {
                        result.forEach(value => {
                            if(!value.includes("N/A"))
                            {
                                var item = {
                                    "label": value.split(',')[0],
                                    "value": value.split(',')[1]
                                };
                                items.push(item);   
                            }                  
                        }); 
                    }  
                    component.set('v.CrossSellList['+index+'].productSubGroupList', items);
                }                     
            });
            
            $A.enqueueAction(action);
        }
    },

    getOfferResultPickList: function (component,event,helper) {
        var productList = component.get('v.productList');
        var action = component.get('c.getPickListValues');
        action.setParams({
            "objectName" : 'CampaignMember',
            "fieldName" : 'RTL_OfferResult_Product_1__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue(); 
                
                var items = [];
                var value1 = {
                    "label": '-- None --',
                    "value": ''
                };
                items.push(value1);
                if(result)
                {
                    result.forEach(value => {
                        if(!value.includes("N/A"))
                        {
                            var item = {
                                "label": value.split(',')[0],
                                "value": value.split(',')[1]
                            };
                            items.push(item);   
                        }                  
                    }); 
                }
                //productList[productNo-1].offerResultList = result;    
                // component.set("v.productList", productList);   
                component.set("v.offerResultList", items);
            }                     
        });
        
        $A.enqueueAction(action);
    },
    getCampaignINT06: function(component, event, helper){
        var action = component.get('c.getCustomerSegment');
        action.setParams({
            "marketingCode" : component.get('v.mcode'),
            "tmbCustId" : component.get('v.tmbCustId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                // console.log('segment SUCCESS')
                var result = response.getReturnValue();
                // console.log('customerSegment reponse', result);
                
                var channel = '';
                if(result.RTL_Channel_Branch__c)
                {
                    if(channel != '')
                    {
                        channel += ', ';
                    }
                    channel += 'Branch';
                }
                if(result.RTL_Channel_DirectMail__c)
                {
                    if(channel != '')
                    {
                        channel += ', ';
                    }
                    channel += 'DirectMail';
                }
                if(result.RTL_Channel_SMS__c)
                {
                    if(channel != '')
                    {
                        channel += ', ';
                    }
                    channel += 'SMS';
                }
                if(result.RTL_Channel_MIB__c)
                {
                    if(channel != '')
                    {
                        channel += ', ';
                    }
                    channel += 'MIB';
                }
                if(result.RTL_Channel_OBD__c)
                {
                    if(channel != '')
                    {
                        channel += ', ';
                    }
                    channel += 'OBD';
                }
                if(result.RTL_Channel_Outbound__c)
                {
                    if(channel != '')
                    {
                        channel += ', ';
                    }
                    channel += 'Outbound';
                }
                if(result.RTL_Channel_Edm__c)
                {
                    if(channel != '')
                    {
                        channel += ', ';
                    }
                    channel += 'Edm';
                }
                result.RTL_Campaign_Channel_formula__c = channel;
                component.set('v.campaignMemObj',result);
                
                if(!result.ContactId)
                {
                    //console.log(result.Lead.Name + ' ' +  result.Campaign.Name);
                    if(result.Lead)
                    {
                        component.set('v.customerName', result.Lead.Name );
                    }
                    component.set('v.mobileNumber',result.RTL_CampHis_Phone__c);
                    component.set('v.idNoValue',result.RTL_CampHis_Phone__c);
                    component.set('v.idType','Other ID');
                   
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "standard:campaign_members",
                            iconAlt: "Campaign_Members",
                        });
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: result.Lead.Name  + ' ' +  result.Campaign.Name
                        });                      
                   })
                    .catch(function(error) {
                        console.log(error);
                    });
                
                } 
                else
                {
                    if(result.Contact)
                    {
                        //console.log(result.Contact.Name + ' ' +  result.Campaign.Name);
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.setTabIcon({
                                tabId: focusedTabId,
                                icon: "standard:campaign_members",
                                iconAlt: "Campaign_Members",
                            });
                            workspaceAPI.setTabLabel({
                                tabId: focusedTabId,
                                label: result.Contact.Name + ' ' +  result.Campaign.Name
                            });
                        
                        })
                        .catch(function(error) {
                            console.log(error);
                        });
                    }
                } 

                helper.getCampaignProductINT06(component, event, helper, result);
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('segment Error');
                // helper.displayToast(component,helper,'Error','error',message);
                //$A.get('e.force:refreshView').fire();            
            }
        });
        $A.enqueueAction(action);
    },

    getStagePickList: function (component,event,helper,index,recordTypeId) {
        var productList = component.get('v.productList');
        // var action = component.get('c.getStageNameSchema');
        // action.setParams({
        //     "productGroup" : productGroup
        // });
        var action = component.get('c.callGetFieldValue');
        action.setParams({
            "recordTypeApiName" : null,
            "recordTypeId" : recordTypeId,
            "fieldName" : 'StageName'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                var items = [];
                // console.log('getStageNameSchema',result);
                if(result)
                {
                    result.values.forEach(element => {
                        var item = {
                            "label": element.label,
                            "value": element.value
                        };
                        items.push(item);
                    }); 
                }

                productList[index].opptyStageList = items;
                component.set("v.productList", productList);
                component.set("v.opptyStageList", result);
            }                     
        });
        
        $A.enqueueAction(action);
    },

    setStagePickListCrossSell : function(component, event, helper, productGroup, index){
        var action = component.get('c.getStageNameSchema');
        action.setParams({
            "productGroup" : productGroup
        });
        // var action = component.get('c.callGetFieldValue');
        // action.setParams({
        //     "recordTypeApiName" : null,
        //     "recordTypeId" : recordTypeId,
        //     "fieldName" : 'StageName'
        // });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();
                // console.log('getStageNameSchema',result);
                let stageList = [];
                if(result)
                {
                    result.values.forEach(element => {
                        var item = {
                            "label": element.label,
                            "value": element.value
                        };
                        stageList.push(item);
                    }); 
 
                }
                let crossSellRow = component.get('v.CrossSellList['+index+']');
                crossSellRow.stageList = stageList;
                crossSellRow.schema = result;
                crossSellRow.default.stage = result.defaultValue;
                crossSellRow.product.stage = result.defaultValue;
                crossSellRow.selected.stage = result.defaultValue;
                component.set('v.CrossSellList['+index+']', crossSellRow);
                // component.set('v.CrossSellList['+index+'].default.stage', result.Schema.Default_Stage__c);
                // component.set('v.CrossSellList['+index+'].stageList', result.stageList);
                // component.set('v.CrossSellList['+index+'].product.stage', result.Schema.Default_Stage__c);
                // component.set('v.CrossSellList['+index+'].selected.stage',result.Schema.Default_Stage__c);
                // component.set('v.CrossSellList['+index+'].schema', result);
            }                 
        });
        
        $A.enqueueAction(action);
    },

    setStatusPickListCrossSell : function(component, event, helper, record_typeDevName, index){
        // console.log('setStatusPickListCrossSell', record_typeDevName);
        var action = component.get('c.callGetFieldValue');
        action.setParams({
            "recordTypeApiName" : record_typeDevName,
            "recordTypeId" : null,
            "fieldName" : 'RTL_Status__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // console.log('get state', state);
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();
                // console.log('callGetStatus', result);
                let statusList = [];
                if(result)
                {
                    result.values.forEach(element => {
                        var item = {
                            "label": element.label,
                            "value": element.value
                        };
                        statusList.push(item);
                    }); 
                }
                let crossSellRow = component.get('v.CrossSellList['+index+']');
                crossSellRow.statusList =  statusList;
                crossSellRow.default.status =  result.defaultValue.value;
                crossSellRow.product.status =  result.defaultValue.value;
                crossSellRow.selected.status = result.defaultValue.value;
                component.set('v.CrossSellList['+index+']', crossSellRow);

                // component.set('v.CrossSellList['+index+'].default.status', result.defaultValue.value);
                // component.set('v.CrossSellList['+index+'].statusList', statusList);
                // component.set('v.CrossSellList['+index+'].product.status', result.defaultValue.value);
                // component.set('v.CrossSellList['+index+'].selected.status',result.defaultValue.value);
            }                 
        });
        
        $A.enqueueAction(action);
    },

    getStatusPickList: function (component,event,helper,index,recordTypeId) {
        var productList = component.get('v.productList');
        var action = component.get('c.callGetFieldValue');
        action.setParams({
            "recordTypeApiName" : null,
            "recordTypeId" : recordTypeId,
            "fieldName" : 'RTL_Status__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                var statusList = [];
                if(result)
                {
                    result.values.forEach(element => {
                        var item = {
                            "label": element.label,
                            "value": element.value
                        };
                        statusList.push(item);
                    });
                }   
                productList[index].opptyStatusList = statusList;    
                component.set("v.opptyStatusList", statusList);
                component.set("v.productList", productList);
            }                     
        });
        
        $A.enqueueAction(action);
    },

    validateProduct: function(component, event, helper){
        var productList = component.get('v.productList');
        var isValidate = true;
        var campaignMemObj = component.get('v.campaignMemObj');
        var productGroup = component.find('inputProductGroup');
        var productSubGroup = component.find('inputProductSubGroup');
        var productName = component.find('customLookup');
        var offerResult = component.find('inputOfferResult');
        var reason = component.find('inputReason');
        var stage = component.find('inputStage');
        var status = component.find('inputStatus');
        var amount = component.find('inputAmount');
        var expectedDate = component.find('inputExpectedDate');
        var index_Input = 1;
        var currentUser = component.get('v.currentUser');
        //var checkLeadConversion = false;

        // console.log('productList:',productList.length);

        if(productList != null)
        {        
            productList.forEach((product,index) => {      
                if(productList.length == 1)
                {
                    if(product.offerResult != undefined )
                    {                            
                        if(product.offerResult)
                        {
                			// console.log('product.offerResult------>' + product.offerResult);
                            if(product.offerResult == 'Interested')
                            {
                				console.log('Step ---------> productGroup');
                                if(product.productGroup)
                                {
                                    if(product.productGroup == null || product.productGroup == "" )
                                    {
                                        
                                        isValidate = false;
                                        $A.util.addClass(productGroup[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    isValidate = false;
                                    $A.util.addClass(productGroup[index+index_Input], "slds-has-error");
                                }
                                if(product.productSubGroup)
                                {
                                    
                                    if(product.productSubGroup == null || product.productSubGroup == "" )
                                    {                         
                                        isValidate = false;
                                        $A.util.addClass(productSubGroup[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    isValidate = false;
                                    $A.util.addClass(productSubGroup[index+index_Input], "slds-has-error");
                                }
                				console.log('Step ---------> productId');
                                if(product.productId)
                                {                              
                                    
                                    if(product.productId == null || product.productId == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    if(product.productNameSelect)
                                    {
                                        product.productId = product.productNameSelect.Id;
                                    }
                                    else
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }                          
                                }
// console.log('Step product.offerResult ---------> ' + product.offerResult);
                                if(product.offerResult == null || product.offerResult == "" )
                                {                         
                                    isValidate = false;
                                    $A.util.addClass(offerResult, "slds-has-error");
                                }            
        // console.log('product.objOpp.StageName ---------> ' + product.objOpp.StageName);
                                if(product.objOpp.StageName)
                                {
                                    if(product.objOpp.StageName == null || product.objOpp.StageName == "" )
                                    {                              
                                        isValidate = false;
                                        $A.util.addClass(stage, "slds-has-error");
                                    }
                            
                                    if (product.objOpp.StageName)  
                                    {     
                                        if (product.objOpp.StageName.includes('Submit App (Loans)') || product.objOpp.StageName.includes('Sales (Loans)') ||
                                            product.objOpp.StageName.includes('Submit App') || product.objOpp.StageName.includes('Sales (Investment)') ||
                                            product.objOpp.StageName.includes('Sales (BA)'))  
                                        {
                                            if(product.objOpp.Amount)
                                            {

                                                if(product.objOpp.Amount == null || product.objOpp.Amount == "" )
                                                {                           
                                                    isValidate = false;
                                                    $A.util.addClass(amount, "slds-has-error");
                                                }
                                            }
                                            else
                                            {
                                                
                                                isValidate = false;
                                                $A.util.addClass(amount, "slds-has-error");
                                            }
                                        }
                                        else if(currentUser.Profile.Name != 'System Administrator' && product.objOpp.StageName.includes('Closed Won') )
                                        {
                                            // isValidate = false;
                                            $A.util.addClass(stage, "slds-has-error");                                  
                                            
                                        }
                                        else if(product.objOpp.StageName == 'Closed Lost')
                                        {
                                            $A.util.addClass(stage, "slds-has-error");                                  
                                        }
                                    }
                                }
                                else
                                {
                                    
                                    isValidate = false;
                                    $A.util.addClass(stage, "slds-has-error");
                                }
         console.log('product.objOpp.RTL_Status__c ---------> ' + product.objOpp.RTL_Status__c);
                                if(product.objOpp.RTL_Status__c)
                                {   
                                    if(product.objOpp.RTL_Status__c == null || product.objOpp.RTL_Status__c == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(status, "slds-has-error");
                                    }
                                }
                                else
                                { 
                                    isValidate = false;
                                    $A.util.addClass(status, "slds-has-error");
                                }
    console.log('product.objOpp.CloseDate ---------> ' + product.objOpp.CloseDate);
                                if(product.objOpp.CloseDate)
                                {               
                                    if(product.objOpp.CloseDate == null || product.objOpp.CloseDate == "" )
                                    {                           
                                        isValidate = false;
                                        $A.util.addClass(expectedDate, "slds-has-error");
                                    }
                                }
                                else
                                {   
                                    isValidate = false;
                                    $A.util.addClass(expectedDate, "slds-has-error");
                                }
                            }
                            else if(product.offerResult == 'Not Interested' || product.offerResult == 'Not Qualified' )  
                            {
                                if(product.productId)
                                {                              
                                    
                                    if(product.productId == null || product.productId == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    if(product.productNameSelect)
                                    {
                                        product.productId = product.productNameSelect.Id;
                                    }
                                    else
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }                          
                                }
                                //checkLeadConversion = false;                       
                                if(product.reason)
                                {
                                    if(product.reason == null || product.reason == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(reason, "slds-has-error");
                                    }   
                                }
                                else
                                {
                                    isValidate = false;
                                    $A.util.addClass(reason, "slds-has-error");
                                }    
                            }
                            else if(product.offerResult == 'Referred' )  
                            {
                                //checkLeadConversion = false;   
                                if(product.productId)
                                {                              
                                    
                                    if(product.productId == null || product.productId == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    if(product.productNameSelect)
                                    {
                                        product.productId = product.productNameSelect.Id;
                                    }
                                    else
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }                          
                                }        
                            }
                            else
                            {
                                if(campaignMemObj.RTL_Contact_Status__c == 'Contact')
                                {
                                    isValidate = false;
                                    $A.util.addClass(reason, "slds-has-error");
                                }
                            }
                        }              
                        else
                        {
                            if(campaignMemObj.RTL_Contact_Status__c == 'Contact')
                            {
                                isValidate = false;                       
                                $A.util.addClass(offerResult, "slds-has-error");
                            }
                        }                       
                    }
                }   
                else
                {             
                    if(product.offerResult != undefined )
                    {                            
                        if(product.offerResult)
                        {
                            if(product.offerResult == 'Interested')
                            {
                                if(product.productGroup)
                                {
                                    if(product.productGroup == null || product.productGroup == "" )
                                    {
                                        
                                        isValidate = false;
                                        $A.util.addClass(productGroup[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    isValidate = false;
                                    $A.util.addClass(productGroup[index+index_Input], "slds-has-error");
                                }
                                if(product.productSubGroup)
                                {
                                    if(product.productSubGroup == null || product.productSubGroup == "" )
                                    {                         
                                        isValidate = false;
                                        $A.util.addClass(productSubGroup[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    isValidate = false;
                                    $A.util.addClass(productSubGroup[index+index_Input], "slds-has-error");
                                }
                
                                if(product.productId)
                                {                              
                                    
                                    if(product.productId == null || product.productId == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    if(product.productNameSelect)
                                    {
                                        product.productId = product.productNameSelect.Id;
                                    }
                                    else
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }                          
                                }
                                
                                if(product.offerResult == null || product.offerResult == "" )
                                {                         
                                    isValidate = false;
                                    $A.util.addClass(offerResult[index], "slds-has-error");
                                }            
                                if(product.objOpp.StageName)
                                {    
                                    if(product.objOpp.StageName == null || product.objOpp.StageName == "" )
                                    {                              
                                        isValidate = false;
                                        $A.util.addClass(stage[index], "slds-has-error");
                                    }
                            
                                    if (product.objOpp.StageName)  
                                    {     
                                        if (product.objOpp.StageName.includes('Submit App (Loans)') || product.objOpp.StageName.includes('Sales (Loans)') ||
                                            product.objOpp.StageName.includes('Submit App') || product.objOpp.StageName.includes('Sales (Investment)') ||
                                            product.objOpp.StageName.includes('Sales (BA)'))  
                                        {
                                            if(product.objOpp.Amount)
                                            {

                                                if(product.objOpp.Amount == null || product.objOpp.Amount == "" )
                                                {                           
                                                    isValidate = false;
                                                    $A.util.addClass(amount[index], "slds-has-error");
                                                }
                                            }
                                            else
                                            {
                                                
                                                isValidate = false;
                                                $A.util.addClass(amount[index], "slds-has-error");
                                            }
                                        }
                                        else if(currentUser.Profile.Name != 'System Administrator' && product.objOpp.StageName.includes('Closed Won') )
                                        {
                                            // isValidate = false;
                                            $A.util.addClass(stage[index], "slds-has-error");                                  
                                            
                                        }
                                        else if(product.objOpp.StageName == 'Closed Lost')
                                        {
                                            $A.util.addClass(stage[index], "slds-has-error");                                  
                                        }
                                    }
                                }
                                else
                                {  
                                    isValidate = false;
                                    $A.util.addClass(stage[index], "slds-has-error");
                                }
                                if(product.objOpp.RTL_Status__c)
                                {   
                                    if(product.objOpp.RTL_Status__c == null || product.objOpp.RTL_Status__c == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(status[index], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    isValidate = false;
                                    $A.util.addClass(status[index], "slds-has-error");
                                }
    
                                if(product.objOpp.CloseDate)
                                {
                                    
                                    if(product.objOpp.CloseDate == null || product.objOpp.CloseDate == "" )
                                    {                           
                                        isValidate = false;
                                        $A.util.addClass(expectedDate[index], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    
                                    isValidate = false;
                                    $A.util.addClass(expectedDate[index], "slds-has-error");
                                }
                            }
                            else if(product.offerResult == 'Not Interested' || product.offerResult == 'Not Qualified' )  
                            {
                                //checkLeadConversion = false;     
                                if(product.productId)
                                {                              
                                    
                                    if(product.productId == null || product.productId == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    if(product.productNameSelect)
                                    {
                                        product.productId = product.productNameSelect.Id;
                                    }
                                    else
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }                          
                                }                         
                                if(product.reason)
                                {
                                    if(product.reason == null || product.reason == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(reason[index], "slds-has-error");
                                    }   
                                }
                                else
                                {
                                    isValidate = false;
                                    $A.util.addClass(reason[index], "slds-has-error");
                                }    
                            }
                            else if(product.offerResult == 'Referred')  
                            {
                                if(product.productId)
                                {                              
                                    
                                    if(product.productId == null || product.productId == "" )
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }
                                }
                                else
                                {
                                    if(product.productNameSelect)
                                    {
                                        product.productId = product.productNameSelect.Id;
                                    }
                                    else
                                    {
                                        isValidate = false;
                                        $A.util.addClass(productName[index+index_Input], "slds-has-error");
                                    }                          
                                }
                            }
                            else
                            {
                                if(campaignMemObj.RTL_Contact_Status__c == 'Contact')
                                {
                                    isValidate = false;
                                    $A.util.addClass(reason[index], "slds-has-error");
                                }
                            }
                            // product.isValidate = isValidate;
                        }              
                        else
                        {
                            if(campaignMemObj.RTL_Contact_Status__c == 'Contact')
                            {
                                isValidate = false;                       
                                $A.util.addClass(offerResult[index], "slds-has-error");
                            }
                        }
                        // product.isValidate = isValidate;                         
                    }
                }
                index_Input++;         
            });
        }
        
        //component.set('v.checkLeadConversion',checkLeadConversion);
        
        component.set('v.productList',productList);
        // console.log('productList:',component.get('v.productList'));
        return isValidate;
    },

    validateCrossSells: function(component, event, helper){
        let crossSellList = component.get('v.CrossSellList');
        let isValidate = true;

        crossSellList.forEach((crossSellRow, index) => {
            let product = crossSellRow.product;
            if(product.offerResult)
            {
                if(product.offerResult == 'Interested')
                {
                    if (! (product.productGroup && product.productSubGroup && product.productName && product.stage && product.status && product.expectedDate)) {
                        isValidate = false;
                    } 

                    if(product.stage)
                    {
        
                        if (product.stage.includes('Submit App (Loans)') || product.stage.includes('Sales (Loans)') ||
                            product.stage.includes('Submit App') || product.stage.includes('Sales (Investment)') ||
                            product.stage.includes('Sales (BA)'))  
                        {
                            if(product.amount)
                            {
                                if(product.amount == null || product.amount == "" )
                                {                           
                                    isValidate = false; 
                                }
                            }
                            else
                            {
                                isValidate = false; 
                            }
                        }
                        
                    }     
                }
            }
            else
            {
                isValidate = false;
            }
        });
        return isValidate;
    },

    saveCrossSells : function(component, event, helper){
        let crossSellList = component.get('v.CrossSellList');
        let crossSellProducts = [];

        // console.log('SaveCrossSells', crossSellList);
        if (crossSellList) {
            // console.log('CrossSellList', crossSellList);
            crossSellList.forEach(row => {
                if (!row.isSaved) {
                    if(Object.keys(row.schema).length !== 0 && row.schema.constructor === Object)
                    {
                        row.product.opptyRecordType_DevName = row.schema.RTL_Record_Type_DevName__c;  //Use in Save Oppourtunity
                    }
                    crossSellProducts.push(row.product);
                }
            });
            // console.log('CrossSellProducts to Save', crossSellProducts);
        }
        let jsonProductList = JSON.stringify(crossSellProducts)
        // console.log('jsonList', jsonProductList);
        
      
        return jsonProductList;
    }, 

    redirectAfterSave : function(component, event, helper) { 
        var recordId = component.get('v.recordId');
        var mcode = component.get('v.mcode');
        var tmbCustId = component.get('v.tmbCustId');
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CampaignMember_Main",
            componentAttributes: {
                recordId : recordId,
                mcode : mcode,
                tmbCustId : tmbCustId,
                mode : 'View'
            }
        });
        evt.fire();

        //helper.closeFocusedTab(component, event, helper);

    },

    redirectToEdit : function(component, event, helper) {
        // helper.closeFocusedTab(component, event, helper);
        var recordId = component.get('v.recordId');
        var mcode = component.get('v.mcode');
        var tmbCustId = component.get('v.tmbCustId');

        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CampaignMember_Main",
            componentAttributes: {
                recordId : recordId,
                mcode : mcode,
                tmbCustId : tmbCustId,
                mode : 'Edit',
            }
        });
        evt.fire();

        //helper.closeFocusedTab(component, event, helper);
    },

    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            // console.log('response:',response);
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    validateSaveCampaign : function(component, event, helper)
    {
        console.log('KYB event isMerge 1547: ' + event.getParam("isMerge"));
        component.set('v.loaded', true);  
        var productList = component.get('v.productList');
        var isValidate_Info = true;
        var isValidate_Product = true;
        var isValidateCrossSell = true;
        var isValidate_LeadConversion = true;
        var isValidate_Callback = false;

        var checkProduct = true;
        var checkCrossSellProduct = false;
        var checkLeadConvert = false;   

        var accId;
        var extAccObj = component.get('v.extAccObj');

        // Lean Conversion
        var accObj = component.get('v.accObj');
        var isMerge = component.get('v.isMerge');
        var callbackCmp = component.find("callbackCmp");
        var leadInput = {
            "Name" :  component.get('v.customerName'),
            "Mobile_Number_PE__c" : component.get('v.mobileNumber'),
            "ID_Type_PE__c" : component.get('v.idType'),
            "ID_Number_PE__c" : component.get('v.idNoValue')
 
        };

        console.log('KYB isMerge 1574: ' + component.get('v.isMerge'));

        // console.log('leadInput:',leadInput);

        // console.log('callbackCmp:',callbackCmp);

        // console.log('extAccObj:',JSON.stringify(extAccObj));  
        //Check Search from Lookup
        if(extAccObj != null)
        {
            accId = extAccObj.Id;
            isMerge = true;
            isValidate_LeadConversion = true;
            accObj = null;
        }
        console.log('KYB isMerge 1589: ' + component.get('v.isMerge'));
        console.log('KYB extAccObj 1590: ' + extAccObj);
     
        var campaignMemObj = component.get('v.campaignMemObj');

        if(campaignMemObj.RTL_Contact_Status__c == 'New' || campaignMemObj.RTL_Contact_Status__c == '')
        {
            var contactStatus = component.find('contactStatus');
            var contactStatusReason = component.find('contactStatusReason');
            isValidate_Info = false;  
            $A.util.addClass(contactStatus, "slds-has-error");
            helper.displayToast(component,helper,'Error','error',$A.get("$Label.c.RTL_CampaignMemberEdit_ContactStatus_ErrMsg"));
            component.set('v.loaded', false);  
        }

        if(campaignMemObj.RTL_Contact_Status__c == 'Uncontact')
        {
            if(campaignMemObj.RTL_Reason__c == null || campaignMemObj.RTL_Reason__c == '')
            {
                var contactStatusReason = component.find('contactStatusReason');
                isValidate_Info = false;  
                $A.util.addClass(contactStatusReason, "slds-has-error");
                helper.displayToast(component,helper,'Error','error',$A.get("$Label.c.RTL_CampaignMemberEdit_UncontactStatus_ErrMsg"));
                component.set('v.loaded', false);  
            }
        }

        //Validate CallBack
        if(campaignMemObj.RTL_Contact_Status__c == 'Call Back')
        {          
            if(callbackCmp)
            {
                isValidate_Callback = callbackCmp.validateCallBackInput();
                // console.log('validateCallBackInput:',isValidate_Callback);

                if(!isValidate_Callback)
                {
                    // console.log('Check Callback:');
                    //helper.displayToast(component,helper,'Error','error',$A.get("$Label.c.RTL_CampaignMemberEdit_CallBack_ErrMsg")); 
                    component.set('v.loaded', false);  
                }     
            }
        }
        else
        {
            isValidate_Callback = true;
            if(callbackCmp)
            {
                callbackCmp.clearValidate();
            }
        }

        // console.log('isValidate_Callback:',isValidate_Callback);
        // console.log('checkProduct:',checkProduct); 
        //Validate Product
        productList.forEach((product,index) => {                 
            if(product.offerResult == 'Interested')
            {
                checkLeadConvert = true;
            }
            if(product.productSubGroup == null || product.productSubGroup == ''){
                product.productSubGroup = product.selectedproductsubgroup;
            }
        });   
        
        if(isValidate_Info && isValidate_Callback)
        {        
            // console.log('RTL_Contact_Status__c:',campaignMemObj.RTL_Contact_Status__c);           
            if(campaignMemObj.RTL_Contact_Status__c != 'Uncontact' && !campaignMemObj.RTL_Contact_Status__c.includes('Do Not Contact'))
            {
                isValidate_Product = helper.validateProduct(component, event, helper);
                // console.log('isValidate_Product:',isValidate_Product);
                if(!isValidate_Product)
                {         
                    if(campaignMemObj.RTL_Contact_Status__c == 'Contact')
                    {
                        helper.displayToast(component,helper,'Error','error',$A.get("$Label.c.RTL_CampaignMemberEdit_Product_Invalid_ErrMsg"));
                        component.set('v.loaded', false);  
                    }
                    else
                    {
                        helper.displayToast(component,helper,'Error','error',$A.get("$Label.c.RTL_CampaignMemberEdit_Product_ErrMsg"));  
                        component.set('v.loaded', false);
                    }       
                }
                else
                {
                    //Validate Cross Sell Product
                    var validateCrossSell = component.find('crossSellProduct');
                    // console.log('validateCrossSell', validateCrossSell.validateInput());
                    if(validateCrossSell.validateInput())
                    {
                        checkCrossSellProduct = true;
                        isValidateCrossSell = helper.validateCrossSells(component, event, helper);
                        if (!isValidateCrossSell) {
                            helper.displayToast(component,helper,'Error','error',$A.get("$Label.c.RTL_CampaignMemberEdit_CrossSellProduct_ErrMsg"));   
                            component.set('v.loaded', false);    
                        }
                    }
                }
                // console.log('isValidateCrossSell:',isValidateCrossSell);
                productList.forEach((product,index) => {                 
                    if(product.offerResult == 'Interested')
                    {
                        checkLeadConvert = true;
                    }
                }); 
                //Validate Product with Opportunity                 
                if(isValidate_Product && isValidateCrossSell)
                {
                    var leadConversion = component.find("leadConversion");

                    if(!campaignMemObj.ContactId && campaignMemObj.ContactId == null && checkLeadConvert )
                    {
                        if(campaignMemObj.LeadId && campaignMemObj.LeadId != null && extAccObj == null)
                        {
                            if(leadConversion)
                            {
                                //console.log('leadConversion:',leadConversion.getLeadConversionData());
                                //Validate Lead Conversion
                                isValidate_LeadConversion = leadConversion.getLeadConversionData();
                                if(!isValidate_LeadConversion)
                                {
                                    helper.displayToast(component,helper,'Error','error',$A.get("$Label.c.RTL_CampaignMemberEdit_LeadConversion_ErrMsg"));
                                    component.set('v.loaded', false);
                                }
                            }
                            else
                            {
                                isValidate_LeadConversion = false;
                                helper.displayToast(component,helper,'Error','error',$A.get("$Label.c.RTL_CampaignMemberEdit_LeadConversion_ErrMsg"));
                                component.set('v.loaded', false);
                            }
                            
                        }
                    }
                    else
                    {
                        isValidate_LeadConversion = true;
                    }
                    
                }
                else
                {
                    isValidate_LeadConversion = false;
                }
            }
        }
        
        // console.log('isValidate_Info:',isValidate_Info);  
        // console.log('isValidate_LeadConversion:',isValidate_LeadConversion);
        // component.set('v.loaded', true); 
        if(campaignMemObj.RTL_Contact_Status__c == 'Uncontact' || campaignMemObj.RTL_Contact_Status__c.includes('Do Not Contact'))
        {
            if(isValidate_Info && isValidate_Product && isValidateCrossSell && isValidate_Callback && isValidate_LeadConversion )
            {
                // component.set('v.loaded', true)
                //helper.saveCampaignWithOutProduct(component, event, helper, campaignMemObj);
                if(campaignMemObj.RTL_Contact_Status__c.includes('Do Not Contact') && component.get('v.confirmDNC'))
                {               
                    helper.saveCampaignAll(component, event, helper, campaignMemObj, productList, productCrossSellList, accId , accObj , isMerge , null);              
                }
                else if(campaignMemObj.RTL_Contact_Status__c.includes('Do Not Contact') && !component.get('v.isConvert'))
                {
                    component.set('v.showModal', true);  
                }
                
                if(campaignMemObj.RTL_Contact_Status__c == 'Uncontact')
                {
                    helper.saveCampaignAll(component, event, helper, campaignMemObj, productList, productCrossSellList, accId , accObj , isMerge , null);              
                }                         
            }
        }
        else if(campaignMemObj.RTL_Contact_Status__c == 'Contact')
        {
            if(isValidate_Info && isValidate_LeadConversion && checkProduct && isValidate_Product && isValidateCrossSell && isValidate_Callback)
            {        
                var productCrossSellList;
                if(checkCrossSellProduct)
                {
                    productCrossSellList = helper.saveCrossSells(component, event, helper);
                }
                // component.set('v.loaded', true)
                console.log('KYB isMerge 1772: ' + isMerge);
                helper.saveCampaignAll(component, event, helper, campaignMemObj, productList, productCrossSellList, accId , accObj , isMerge, leadInput);                                       
    
            }
        }
        else if(campaignMemObj.RTL_Contact_Status__c == 'Call Back')
        {
            if(isValidate_Info && isValidate_Callback   && isValidate_Product && isValidateCrossSell && isValidate_LeadConversion )
            {        
                var productCrossSellList;
                if(checkCrossSellProduct)
                {
                    productCrossSellList = helper.saveCrossSells(component, event, helper);
                }
                // component.set('v.loaded', true)
                helper.saveCampaignAll(component, event, helper, campaignMemObj, productList, productCrossSellList, accId , accObj , isMerge, leadInput);                                       
    
            }
        }
    },

    saveCampaignAll : function(component, event, helper, campaignMemObj, productList, productCrossSellList, accId , accObj , isMerge , leadInput) {
        //component.set('v.loaded', true);  
        console.log('KYB isMerge 1759: ' + component.get('v.isMerge'));
        var callbackCmp = component.find("callbackCmp");
        var action = component.get('c.saveCampaign');

        // console.log('productList', productList);
        // console.log('productCrossSellList', productCrossSellList);

        action.setParams({
            "productList" : productList,
            "extAccId" : accId,
            "accObj" : JSON.stringify(accObj),
            "campaignMemObj" : campaignMemObj,
            "isMerge" : isMerge,
            "productCrossSellList" : productCrossSellList,
            "leadInput" : JSON.stringify(leadInput)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var result =  response.getReturnValue();
                if(callbackCmp)
                {
                    callbackCmp.parentSubmit();
                }            
                if(campaignMemObj.RTL_Contact_Status__c.includes('Do Not Contact') && campaignMemObj.ContactId == null)
                {
                    helper.displayToast(component,helper,'Warning','warning',$A.get('$Label.c.RTL_CampaignMember_DoNotContact_Warning'));
                }
                helper.displayToast(component,helper,'Success','success',result);
                //component.set('v.loaded', false);
                //$A.get('e.force:refreshView').fire();
                helper.redirectAfterSave(component,event,helper);
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.displayToast(component,helper,'Error','error',message);
                //$A.get('e.force:refreshView').fire();            
                component.set('v.loaded', false);
            }

        });
        if(campaignMemObj.RTL_Contact_Status__c == 'Call Back')
        { 
            callbackCmp.validateBusinessHour(function(result) 
            {           
                if(result)
                {
                    $A.enqueueAction(action);
                }
                else
                {
                    component.set('v.loaded', false);
                }
            });
        } 
        else
        {
            $A.enqueueAction(action);
        }       
    },
    
    sendVoiceTagging : function (component, event, helper)
    {
        // var action = component.get('c.execute');
        // action.setParams({
        //     "campaignMemObj" : campaignMemObj,
        // });
        // action.setCallback(this, function(response) {
        //     var state = response.getState();
        //     if(state === 'SUCCESS')
        //     {
        //         var result =  response.getReturnValue();
        //         helper.saveCrossSells(component, event, helper);
        //         helper.displayToast(component,helper,'Success','success',result);
        //         component.set('v.loaded', false);
        //     }
        //     else{
        //         var errors = response.getError();
        //         var message = 'Unknown error'; // Default error message
        //         // Retrieve the error message sent by the server
        //         if (errors && Array.isArray(errors) && errors.length > 0) {
        //             message = errors[0].message;
        //         }
        //         // Display the message
        //         helper.displayToast(component,helper,'Error','error',message);
        //         component.set('v.loaded', false);
        //     }

        // });
        // $A.enqueueAction(action);
    },
    getMoreDetailAvailableProduct: function (component, event, helper) {
        var action = component.get('c.getMoreDetailAvailableProduct');
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var result = response.getReturnValue()
                component.set('v.ALPrdNameSet',result.ALProductSet)
                component.set('v.HLCALPrdNameSet',result.HLProductSet)
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.log('message : ' + message);
                component.set('v.loaded', false);
            }
        });
        $A.enqueueAction(action);
    }
})