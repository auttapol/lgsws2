({
    doInit: function (component, event, helper) {
        helper.startSpinner(component);
        helper.clearSLSProductForm(component);
        var leadObjId = component.get('v.leadObjId');
        // console.log('Lead Id ::: ', leadObjId);
        helper.onInitSLSProduct(component, event, helper).then((result) => {
            var flowType = component.get("v.flowType");
            if (flowType == 'QCALeadType') {
                component.set('v.recommendedProductList', result.MyRecommendedProduct);
                helper.getRecommendedProductList(component, helper);
            } else if (flowType == 'QCAOpptyType') {
                component.set('v.opptyLineItemList', result.MyOpportunityLineItem);
                helper.getOpptyProductList(component, helper);
            }
            helper.setupDefaultValueSLSProduct(component, helper);
            helper.stopSpinner(component);
        }).catch((error) => {
            helper.stopSpinner(component);
            console.error(error.message)
        });

        // helper.getHostProductMappingValues(component, event, helper).then(() => {
        //     console.log('getHostProductMappingValues');
        //     return helper.getProductListAllFlow(component, event, helper);
        // }).then(() => {
        //     console.log('getProductListAllFlow');
        //     return helper.stopSpinner(component);
        // }).catch((error) => {
        //     helper.stopSpinner(component);
        //     console.error(error.message)
        // });

    },
    onChangeHostProductGroup: function (component, event, helper) {
        var value = event.getSource().get('v.value');
        helper.resetValue(component, 'v.ProductProgram', false);
        helper.resetValue(component, 'v.HostProdNameCreditFacility', false);
        helper.resetValue(component, 'v.SalesforceProduct', true);
        component.set('v.productObj.Product_Program__c', '');
        component.set('v.productObj.Host_Prod_Name_Credit_Facility__c', '');

        helper.getValuesSLSProduct(component, 'v.ProductProgram', 'Host_Product_Group__c', 'Product_Program__c', value, false);
    },
    onChangeProductProgram: function (component, event, helper) {
        var value = event.getSource().get('v.value');
        helper.resetValue(component, 'v.HostProdNameCreditFacility', false);
        helper.resetValue(component, 'v.SalesforceProduct', true);
        component.set('v.productObj.Host_Prod_Name_Credit_Facility__c', '');

        helper.getValuesSLSProduct(component, 'v.HostProdNameCreditFacility', 'Product_Program__c', 'Host_Prod_Name_Credit_Facility__c', value, false);
    },
    onChangeHostProdNameCreditFacility: function (component, event, helper) {
        var value = event.getSource().get('v.value');
        helper.resetValue(component, 'v.SalesforceProduct', true);

        helper.getValuesSLSProduct(component, 'v.SalesforceProduct', 'Host_Prod_Name_Credit_Facility__c', 'Salesforce_Product__c', value, true);

        if (value) {
            var productItem = component.get('v.productObj');
            var hostProductMappingItem = helper.getSLSProduct(component, productItem);
            component.set('v.productObj.Id', hostProductMappingItem.Id);
            component.set('v.productObj.Salesforce_Product__c', hostProductMappingItem.Salesforce_Product__c);
            component.set('v.productObj.Salesforce_Product__r', hostProductMappingItem.Salesforce_Product__r);
        }
        // console.log(helper.parseObj(component.get('v.productObj')));
    },
    onChnageAmount: function (component, event, helper) {
        var target = event.getSource();
        // console.log(target.get('v.value'));
    },
    selectSLSProduct: function (component, event, helper) {
        component.set('v.isEditSLSProduct', true);
        helper.clearSelectSLSProduct(component);

        var idx = event.currentTarget.dataset.idx;
        var productItem = component.get('v.productList')[idx];
        productItem['index'] = parseInt(idx);
        productItem['isSelected'] = true;

        var actionPromise = new Promise(function (resolve, reject) {
            helper.getValuesSLSProduct(component, 'v.ProductProgram', 'Host_Product_Group__c', 'Product_Program__c', productItem.Host_Product_Group__c, false);
            helper.getValuesSLSProduct(component, 'v.HostProdNameCreditFacility', 'Product_Program__c', 'Host_Prod_Name_Credit_Facility__c', productItem.Product_Program__c, false);
            helper.getValuesSLSProduct(component, 'v.SalesforceProduct', 'Host_Prod_Name_Credit_Facility__c', 'Salesforce_Product__c', productItem.Host_Prod_Name_Credit_Facility__c, true);
            resolve();
        });
        actionPromise.then(
            function () {
                component.set('v.productObj', helper.parseObj(productItem));
                component.find('varSLSProductField').reduce(function (validSoFar, inputCmp) {
                    inputCmp.focus();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                // console.log(idx, helper.parseObj(component.get('v.productObj')));

                component.get('v.productList').forEach((productItem, index) => {
                    if (productItem.isSelected && productItem.index == index) {
                        $A.util.addClass(document.getElementById('varSLSProductItem' + index), 'focusSelected');
                    }
                });
            },
            function (error) {

            }
        );
    },
    addSLSProdoct: function (component, event, helper) {
        var allValid = helper.validateSLSProduct(component, event, helper);

        if (allValid) {
            var productList = component.get('v.productList');
            var productItem = component.get('v.productObj');
            productItem['index'] = parseInt(productList.length);
            productList.push(helper.parseObj(productItem));
            component.set('v.productList', productList);

            // reset default value
            if (productList == 0) helper.resetValue(component, 'v.ProductProgram', false);
            helper.resetValue(component, 'v.HostProdNameCreditFacility', false);
            helper.resetValue(component, 'v.SalesforceProduct', true);
            helper.clearSLSProductForm(component);
            // console.log(helper.parseObj(component.get('v.productList')));
        }
    },
    updateSLSProduct: function (component, event, helper) {
        var allValid = helper.validateSLSProduct(component, event, helper);

        if (allValid) {
            var productItem = helper.parseObj(component.get('v.productObj'));
            var productList = component.get('v.productList');
            // productItem.Amount__c = parseFloat(productItem.Amount__c);
            productList[productItem.index] = productItem;
            component.set('v.productList', productList);

            // reset default value
            if (productList.length == 0) helper.resetValue(component, 'v.ProductProgram', false)
            helper.resetValue(component, 'v.HostProdNameCreditFacility', false);
            helper.resetValue(component, 'v.SalesforceProduct', true);
            helper.clearSelectSLSProduct(component);
            helper.clearSLSProductForm(component);
            // console.log(helper.parseObj(component.get('v.productList')));
        }

    },
    removeSLSProduct: function (component, event, helper) {
        var productList = component.get('v.productList');
        var productItem = productList[component.get('v.productObj.index')];
        var index = productList.indexOf(productItem);
        if (index !== -1) productList.splice(index, 1);
        component.set('v.productList', productList);

        if (productList.length == 0) helper.resetValue(component, 'v.ProductProgram', false);
        helper.resetValue(component, 'v.HostProdNameCreditFacility', false);
        helper.resetValue(component, 'v.SalesforceProduct', true);
        helper.clearSelectSLSProduct(component);
        helper.clearSLSProductForm(component);
        component.set('v.showModalProductItem', false);
    },
    openModalProductItem: function (component, event, helper) {
        component.set('v.showModalProductItem', true);
    },
    cancelModalProductItem: function (component, event, helper) {
        var productList = component.get('v.productList');
        if (productList.length == 0) helper.resetValue(component, 'v.ProductProgram', false);
        helper.resetValue(component, 'v.HostProdNameCreditFacility', false);
        helper.resetValue(component, 'v.SalesforceProduct', true);
        helper.clearSelectSLSProduct(component);
        helper.clearSLSProductForm(component);
        component.set('v.showModalProductItem', false);
    },
    closeModalProductItem: function (component, event, helper) {
        component.set('v.showModalProductItem', false);
    },
    onClickNextRecommendedProduct: function (component, event, helper) {
        var productList = component.get('v.productList')
        if (productList.length > 0) {
            helper.onSummitSLSProduct(component, event, helper);
        } else {
            helper.displayToast(component, 'Error', 'Please add at least one SLS Product')
        }
    }
})