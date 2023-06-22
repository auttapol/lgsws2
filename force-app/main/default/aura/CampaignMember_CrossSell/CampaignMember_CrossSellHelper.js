({
    
    doInitPicklist : function (component, event, helper) {
        // let pickListOption = {
        //     productGroup : [
        //         {id: 'Deposit', label: 'Deposit'},
        //         {id: 'Credit_Card', label: 'Credit Card'},
        //         {id: 'Loan', label: 'Loan'},
        //         {id: 'Bancassurance', label: 'Bancassurance'},
        //         {id: 'Investment', label: 'Investment'},                
        //     ],
        // }
        // component.set('v.pickListOption', pickListOption);
        //helper.getProductGroupPickList(component,event,helper);
    },


    getCampaignMember: function (component,event,helper)
    {
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
                    if(result.RTL_Contact_Status__c == 'New')
                    {
                        component.set('v.isChangeContact', true);
                    }
                    else
                    {
                        if(result.RTL_Contact_Status__c == 'Contact')
                        {                       
                            component.set('v.isConvert',false); 
                        }
                        else if(result.RTL_Contact_Status__c == 'Call Back')
                        {
                            component.set('v.isChangeContact', true);
                            component.set('v.isConvert',false); 
                        }               
                        else if(result.RTL_Contact_Status__c == 'Uncontact')
                        {
                            component.set('v.isChangeContact', true);
                            component.set('v.isConvert',false); 
                        }
                        else
                        {
                            component.set('v.isChangeContact', false);
                            component.set('v.isConvert',true); 
                        }
                    }
                 
                }  
                helper.doInitRowList(component, event, helper);             
            }

        });
        $A.enqueueAction(action);

        // console.log('isConvert:',component.get('v.isConvert'));
    },

    getProductGroupPickList: function (component,event,helper) {
        var action = component.get('c.getPickListValues');
        action.setParams({
            "objectName" : 'CampaignMember',
            "fieldName" : 'RTL_Product_Group_1__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();              
                var items = [];
                result.forEach(value => {
                    var item = {
                        "label": value.split(',')[0],
                        "value": value.split(',')[1]
                        // "label": value.toUpperCase(),
                        // "value": value.toUpperCase()
                    };
                    items.push(item);
                });                 

                component.set("v.productGroupList", items);
            }                     
        });
        
        $A.enqueueAction(action);
    },

    doInitselectedValues : function (component, event, helper) {
        let selectedValues = {
            productGroup : '',
            subProductGroup : '',
            ProductName : '',
            offer : '',
            status : '',
        }
        component.set('v.selectedValues', selectedValues);
        // console.log('SelectValues : ', component.get('v.selectedValues'));
    },

    doInitRowList : function (component, event, helper) {
        let recordId = component.get("v.recordId");
        
        helper.getOfferResultPickList(component, event, helper);
        let rowList = helper.getCrossSell(component, event, helper);
        //console.log('doInitRowList', rowList);

    },

    getOfferResultPickList: function (component,event,helper) {
        var action = component.get('c.getPickListValues');
        action.setParams({
            "objectName" : 'CampaignMember',
            "fieldName" : 'RTL_OfferResult_Product_1__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue(); 
                var offerResult = [];
                // console.log('RTL_OfferResult_Product_1__c:',result);
                if(result)
                {
                    result.forEach(value => {
                        if(value.split(',')[1] == 'Interested' || value.split(',')[1] == 'Referred')
                        {
                            var item = {
                                "label": value.split(',')[0],
                                "value": value.split(',')[1]
                            };
                            offerResult.push(item);   
                        }                         
                    }); 
                    // console.log('offerResultList:',offerResult);
                    component.set('v.offerResultList',offerResult);

                }         
            }                     
        });
        
        $A.enqueueAction(action);
    },

    getCrossSell : function (component, event, helper) {
        let recordId = component.get("v.recordId");
        let rowList = component.get("v.rowList");

        //console.log('recordId', recordId);
        if (recordId) {
            var action = component.get('c.getCrossSell');
            action.setParams({
                recordId : component.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    try {
                        let result =  response.getReturnValue();  
                        // console.log('getCrossSell Result:',result);
                        if (result.length > 0) {
                            result.forEach((crossSellObj, i) => {
                                //console.log('Create Cross Sell Row From Result');
                                let newRowObj = helper.newRowList(component, event, helper, rowList.length + 1, true);
                                newRowObj.product.productGroup = crossSellObj.Product_Group__c;
                                newRowObj.selected.productGroup = crossSellObj.Product_Group__c;
                                newRowObj.product.productSubGroup = crossSellObj.RTL_Sub_Group__c;
                                newRowObj.selected.productSubGroup = crossSellObj.RTL_Sub_Group__c;
                                newRowObj.product.productName = crossSellObj.Campaign_Product__r.Name;
                                newRowObj.product.productName_Id = crossSellObj.Campaign_Product__c;
                                newRowObj.product.offerResult = crossSellObj.RTL_OfferResult_Product__c;
                                newRowObj.product.offerResult = crossSellObj.RTL_OfferResult_Product__c;
                                newRowObj.selected.Id = crossSellObj.Id;
                                if (crossSellObj.OpportunityId__c) {
                                    newRowObj.product.stage = crossSellObj.OpportunityId__r.StageName;
                                    newRowObj.selected.stage = crossSellObj.OpportunityId__r.StageName;
                                    newRowObj.product.status = crossSellObj.OpportunityId__r.RTL_Status__c;
                                    newRowObj.selected.status = crossSellObj.OpportunityId__r.RTL_Status__c;
                                    newRowObj.product.amount = crossSellObj.OpportunityId__r.Amount;
                                    newRowObj.product.expectedDate = crossSellObj.OpportunityId__r.CloseDate;
                                    newRowObj.product.opportunity = crossSellObj.OpportunityId__c;
                                    newRowObj.product.opportunityName = crossSellObj.OpportunityId__r.Name;
                                }

                                rowList.push(newRowObj);
                            });
                            if(component.get('v.iconName') == 'utility:chevrondown')
                            {
                                component.set('v.iconName','utility:chevronright');
                            }
                            else
                            {
                                component.set('v.iconName','utility:chevrondown');
                            }
                            component.set('v.isExpanded',true);
                        } 
                        else 
                        {
                            // console.log('isConvert:',component.get('v.isConvert'));
                            // console.log('Cross Sell campaignMemObj:',component.get('v.campaignMemObj'));
                            if(rowList.length == 0)
                            {   
                                if(!component.get('v.isConvert') && component.get('v.isChangeContact'))
                                {
                                                            
                                        rowList.push(helper.newRowList(component, event, helper, rowList.length + 1, false));
                                
                                }
                            } 
                        }
                    } catch (error) {
                        console.log('Create Cross Sell Error', error);
                        rowList.push(helper.newRowList(component, event, helper, rowList.length + 1, false)); 
                    }               
                } else {
                    rowList.push(helper.newRowList(component, event, helper, rowList.length + 1, false)); 
                }                  
                component.set("v.rowList", rowList);
            });
            $A.enqueueAction(action);
        }
        return rowList;
    },


    newRowList : function (component, event, helper, value, isSaved ) {
        let rowObj = {
            value,
            isSaved,
            Id : '',
            isButtonDelete : value !== 1,
            productSubGroupList : [],
            productNameList : [],
            offerResultList : [],
            stageList : [],
            statusList : [],
            default : {
                stage : '',
                status : '',
            },
            schema : {},
            selected : {
                productGroup : '',
                productSubGroup : '',
                offerResult : '',
                stage : '',
                status : '',
                productName : '',
                amount : 0,
                expectedDate : '',
            },
            product : {
                productGroup : '',
                productSubGroup : '',
                productName : '',
                productName_Id : '',
                offerResult : 'Interested',
                stage : '',
                status : '',
                amount : 0,
                expectedDate : '',
                opportunity : '',
            },
            style : {
                productGroup : '',
                productSubGroup : '',
                productName : '',
                offerResult : '',
                stage : '',
                status : '',
                amount : '',
                expectedDate : '',
            }
        }         
        
        return rowObj;
    },

    validateCrossSellRow : function (component, event, helper, rowObj, rowNO) {
        let rowProduct = undefined;
        if (rowObj && rowObj.product) {
            rowProduct =  rowObj.product;
        } 

        if (rowProduct) {
            rowObj.style.productGroup = !rowProduct.productGroup ? 'slds-has-error' : ''
            rowObj.style.productSubGroup = !rowProduct.productSubGroup ? 'slds-has-error' : ''
            rowObj.style.productName = !(rowProduct.productName || rowObj.selected.productName) ? 'slds-has-error' : ''  
            rowObj.style.offerResult = !rowProduct.offerResult ? 'slds-has-error' : '' 
            rowObj.style.stage = !rowProduct.stage ? 'slds-has-error' : ''
            rowObj.style.status = !rowProduct.status ? 'slds-has-error' : ''
            // Amount can be 0 when product is Credit card

            if(rowProduct.stage)
            {
                if (rowProduct.stage.includes('Submit App (Loans)') || rowProduct.stage.includes('Sales (Loans)') ||
                    rowProduct.stage.includes('Submit App') || rowProduct.stage.includes('Sales (Investment)') ||
                    rowProduct.stage.includes('Sales (BA)'))  
                {
                    if(rowProduct.amount)
                    {
                        if(rowProduct.amount == null || rowProduct.amount == "" )
                        {                           
                            rowObj.style.amount = 'slds-has-error';
                        }
                    }
                    else
                    {
                        rowObj.style.amount = 'slds-has-error';
                    }
                }
                else if(rowProduct.stage == 'Closed Lost' || rowProduct.stage == 'Closed Won')
                {
                    rowObj.style.stage = 'slds-has-error';
                }
                else
                {
                    if(rowProduct.amount)
                    {
                        if (rowProduct.amount == 0 && rowProduct.productGroup.toUpperCase().includes('CREDIT CARD'))  
                        {
                            rowObj.style.amount = 'slds-has-error';
                        }
                        else
                        {
                            rowObj.style.amount = '';
                        }
                    }
                }
                
            }     

            // if (!rowProduct.amount) {  
            //     if (rowProduct.productGroup === 'Credit Card & RDC' && rowProduct.amount === 0) {
            //         rowObj.style.amount = ''
            //     } else {
            //         rowObj.style.amount = 'slds-has-error'
            //     }
            // } else {
            //     rowObj.style.amount = ''
            // }
            rowObj.style.expectedDate = !rowProduct.expectedDate ? 'slds-has-error' : ''
        }
        return rowObj;
    },

    changeErrorStyle : function (component, event, helper, element, isError) {
        if (isError) {
            $A.util.addClass(element, "slds-has-error");
        } else {
            $A.util.removeClass(element, "slds-has-error"); // remove red border
            $A.util.addClass(element, "hide-error-message"); 
        }
    },
})