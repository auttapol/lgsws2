({
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
    parseObj: function (objFields) {
        return JSON.parse(JSON.stringify(objFields));
    },
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },
    onInitSLSProduct: function (component, event, helper) {
        return new Promise((resolve, reject) => {
            var relatedRecordId;
            var flowType = component.get("v.flowType");
            if (flowType == 'QCALeadType') {
                relatedRecordId = component.get('v.leadObjId');
            } else if (flowType == 'QCAOpptyType') {
                relatedRecordId = component.get('v.opptyObjId');
            }
            var action = component.get('c.onInitQCASLSProduct');
            action.setParams({
                "relatedRecordId": relatedRecordId,
                "flowType": flowType,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var getReturnValue = response.getReturnValue();

                    component.set('v.HostProductMappingList', getReturnValue.HostProductMappingFieldValues);
                    helper.getProductGroup(component);
                    resolve(getReturnValue);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            helper.displayToast(component, "Error", "Error message: " + errors[0].message);
                            reject("Error message: " + errors[0].message)
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
    toNextStage: function (component) {
        var flowType = component.get("v.flowType");
        if (flowType == 'QCALeadType') {
            var compEvent = component.getEvent("varSimplifiedLeadProcessStatus");
            compEvent.setParams({
                "leadObjId": component.get('v.leadObjId'),
                "simplifiedLeadProcessStage": 3,
                "isAllowSimplifiedLeadProcessStage": true,
            });
            compEvent.fire();
        } else if (flowType == 'QCAOpptyType') {
            var compEvent = component.getEvent("varSimplifiedOpportunityProcessStatus");
            compEvent.setParams({
                "opptyObjId": component.get('v.opptyObjId'),
                "simplifiedOpportunityProcessStage": 3,
                "isAllowSimplifiedOpportunityProcessStage": true,
            });
            compEvent.fire();
        }
    },

    setupDefaultValueSLSProduct: function (component, helper) {
        var productList = component.get('v.productList');
        if (productList.length > 0) {
            var productItem = productList[0];
            component.set('v.productObj', {
                'Id': '',
                'sobjectType': 'Host_Product_Mapping__c',
                'Host_Product_Group__c': productItem.Host_Product_Group__c,
                'Product_Program__c': '',
                'Host_Prod_Name_Credit_Facility__c': '',
                'Salesforce_Product__c': '',
                'Amount__c': '',
                'index': '',
                'isSelected': false,
                'Product_Interest_Id': '',
                'OpportunityLineItem_Id': '',
            });
            helper.getValuesSLSProduct(component, 'v.ProductProgram', 'Host_Product_Group__c', 'Product_Program__c', productItem.Host_Product_Group__c, false);
        }
    },
    clearSLSProductForm: function (component) {
        var productItem = component.get('v.productList')[0];
        // console.log(productItem);
        component.set('v.productObj', {
            'Id': '',
            'sobjectType': 'Host_Product_Mapping__c',
            'Host_Product_Group__c': productItem ? productItem.Host_Product_Group__c : '',
            'Product_Program__c': '',
            'Host_Prod_Name_Credit_Facility__c': '',
            'Salesforce_Product__c': '',
            'Amount__c': '',
            'index': '',
            'isSelected': false,
            'Product_Interest_Id': '',
            'OpportunityLineItem_Id': '',
        });
        component.set('v.isEditSLSProduct', false);

    },
    clearSelectSLSProduct: function (component) {
        component.get('v.productList').forEach((productItem) => {
            productItem['isSelected'] = false;
            $A.util.removeClass(document.getElementById('varSLSProductItem' + productItem.index), 'focusSelected');
        });
    },
    resetValue: function (component, picklistKey, isRelated) {
        if (!isRelated) {
            component.set(picklistKey, '--None--');
        } else {
            component.set(picklistKey, '');
        }
    },
    getProductGroup: function (component) {
        var hostProdMap = component.get('v.HostProductMappingList');
        var ProductGroup = component.get('v.HostProductGroup');
        for (var index in hostProdMap) {
            var hostProdMapItem = hostProdMap[index];
            if (!ProductGroup.includes(hostProdMapItem.Host_Product_Group__c)) {
                ProductGroup.push(hostProdMapItem.Host_Product_Group__c);
            }
        }
        ProductGroup.sort();
        component.set('v.HostProductGroup', ProductGroup);
    },
    getValuesSLSProduct: function (component, key, primaryKey, secondKey, dependencyValue, isRelated) {
        var hostProdMap = component.get('v.HostProductMappingList');
        var values = component.get(key);
        for (var index in hostProdMap) {
            var hostProdMapItem = hostProdMap[index];
            var primaryValues = hostProdMapItem[primaryKey];
            var secondValues = hostProdMapItem[secondKey];
            if (!values.includes(secondValues) && primaryValues == dependencyValue) {
                // console.log(primaryValues + ' | ' + dependencyValue, primaryValues == dependencyValue, secondValues);
                if (!isRelated) {
                    values.push(secondValues);
                } else {
                    values[0] = {
                        'label': hostProdMapItem.Salesforce_Product__r.Name,
                        'value': hostProdMapItem.Salesforce_Product__r.Id
                    };
                }
            }
        }
        values.sort();
        component.set(key, values);
    },
    getSLSProduct: function (component, productItem) {
        var hostProdMap = component.get('v.HostProductMappingList');
        return hostProdMap.find((hostProdMapItem) => {
            return hostProdMapItem.Host_Prod_Name_Credit_Facility__c == productItem.Host_Prod_Name_Credit_Facility__c &&
                hostProdMapItem.Host_Product_Group__c == productItem.Host_Product_Group__c &&
                hostProdMapItem.Product_Program__c == productItem.Product_Program__c;
            // && hostProdMapItem.Salesforce_Product__c == productItem.Salesforce_Product__c
        });
    },

    getRecommendedProductList: function (component, helper) {
        var productList = component.get('v.productList');
        component.get('v.recommendedProductList').forEach((recommendedProductItem, index) => {
            var recommendedProductItemTemp = helper.parseObj(recommendedProductItem);
            var productItem = recommendedProductItemTemp.Host_Product_Mapping__r;
            productItem['index'] = index;
            productItem['Product_Interest_Id'] = recommendedProductItemTemp.Id;
            productItem['Amount__c'] = recommendedProductItemTemp.Amount__c.toString();
            productItem['isSelected'] = false;
            productList.push(productItem);
        });
        component.set('v.productList', productList);
    },

    getOpptyProductList: function (component, helper) {
        var productList = component.get('v.productList');
        component.get('v.opptyLineItemList').forEach((opportunityProductItem, index) => {
            var opportunityProductItemTemp = helper.parseObj(opportunityProductItem);
            var productItem = opportunityProductItemTemp.Host_Product_Mapping__r;
            productItem['index'] = index;
            productItem['OpportunityLineItem_Id'] = opportunityProductItemTemp.Id;
            productItem['Amount__c'] = opportunityProductItemTemp.UnitPrice.toString();
            productItem['isSelected'] = false;
            productList.push(productItem);
        });
        component.set('v.productList', productList);
    },
    onSummitSLSProduct: function (component, event, helper) {
        helper.startSpinner(component);
        var leadObjId = component.get('v.leadObjId');
        var productList = JSON.stringify(component.get('v.productList'));
        // console.log(helper.parseObj(component.get('v.productList')));

        var flowType = component.get("v.flowType");
        var opptyObjId = component.get('v.opptyObjId');
        // console.log('flowType:', flowType);

        var action;
        if (flowType == 'QCALeadType') {
            action = component.get("c.saveSLSProduct");
            action.setParams({
                "SLSProductList": productList,
                "relatedRecordId": leadObjId,
                "isNewLead": true,
            });
        } else if (flowType == 'QCAOpptyType') {
            action = component.get("c.saveSLSProduct");
            action.setParams({
                "SLSProductList": productList,
                "relatedRecordId": opptyObjId,
                "isNewLead": false,
            });
        }
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.toNextStage(component);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        helper.displayToast(component, "Error", "Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
    validateSLSProduct: function (component, event, helper) {
        return component.find('varSLSProductField').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
    }
})