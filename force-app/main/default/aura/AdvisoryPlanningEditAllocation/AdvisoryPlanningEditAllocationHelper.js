({
    COLUMNS: [
        { label: 'Product Group', fieldName: 'family'},
        { label: 'Product Sub Group - Asset Class', fieldName: 'subFamiltyAsset' },
        { label: 'Product Name', fieldName: 'productName' },
        { label: 'Product Code', fieldName: 'productCode' },
    ],

    FAMILY: {
        RETURN : ['ALL', 'DEPOSIT', 'INVESTMENT'],
        RISK   : ['BANCASSURANCE'],
        EXPENSE : ['LOAN']
    },

    getProducts : function(component, selectedProductList, maxReturnRow) {
        var action      = component.get("c.getProductInformation")
        var productFamily     = component.get("v.productFamily");
        var keyword1       = component.get("v.keyword1");
        var keyword2  = component.get("v.keyword2");
        var keyword3 = component.get("v.keyword3");
        var itemType          = component.get("v.itemType");

        var productFamilySet  = [];
        console.log("product family = "+  productFamily);
        if(itemType == 'Return'){
            if(productFamily == 'ALL'){
                var valueSet = JSON.parse(JSON.stringify(this.FAMILY.RETURN));
                valueSet.shift();
                console.log("valueSet = "+ valueSet);
                productFamilySet = valueSet;
            }else{
                productFamilySet.push(productFamily);
            }
        }else if(itemType == 'Risk'){
            productFamilySet = this.FAMILY.RISK;
        }else{
            // if(productFamily == 'ALL'){
            //     var valueSet = JSON.parse(JSON.stringify(this.FAMILY.EXPENSE));
            //     valueSet.shift();
            //     productFamilySet = valueSet;
            // }else{
            //     productFamilySet.push(productFamily);
            // }
            productFamilySet = this.FAMILY.EXPENSE;
        }

        console.log('productFamilySet = ' + productFamilySet);

        var existingProduuctIdSet = [];
        if(selectedProductList && selectedProductList.length > 0){
            for(let i = 0; i < selectedProductList.length; i++){
                existingProduuctIdSet.push(selectedProductList[i].productId);
            }
        }

        var criteria =  {
                            productFamily   : productFamilySet,
                            keyword1     : keyword1,
                            keyword2     : keyword2,
                            keyword3     : keyword3,
                            existingProduuctIdSet : existingProduuctIdSet,
                            maxReturnRow : maxReturnRow
                        }

        return new Promise(function (resolve, reject) {
            action.setParams({criteria : criteria});

            action.setCallback(this, function (response) {
               var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    reject(response.getError()[0]);
                }
            });

            $A.enqueueAction(action);
        });
    },

    showLoading: function (component) {
        var spinner = component.find("loadingSpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideLoading: function (component) {
        var spinner = component.find("loadingSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    toggleDataTable: function(component, event){
        var productData = component.find("productData");
        $A.util.toggleClass(productData, "slds-hide");
    },

    getProductFamily: function(component, itemType){
        if(itemType == 'Return'){
            component.set("v.familyOptions", this.FAMILY.RETURN);
            component.set("v.productFamily", this.FAMILY.RETURN[0]);
        }else if(itemType == 'Risk'){
            component.set("v.familyOptions", this.FAMILY.RISK);
            component.set("v.productFamily", this.FAMILY.RISK[0]);
        }else{
            component.set("v.familyOptions", this.FAMILY.EXPENSE);
            component.set("v.productFamily", this.FAMILY.EXPENSE[0]);
        }
    },

    getProductHeaderName : function(component, itemType){
        var addProductHeaderName = "";
        if(itemType == 'Return'){
            addProductHeaderName = 'Add Investment Products';
        }else if(itemType == 'Risk'){
            addProductHeaderName = 'Add Bancassurance Products';
        }else{
            addProductHeaderName = 'Add Loan Products';
        }

        component.set("v.addProductHeaderName", addProductHeaderName);
    },

    processDataTable : function(component, newData){
        var selectedRows = component.get("v.selectedProduct");
        console.log("---selectedProduct---");
        console.log(selectedRows);

        var data = [];
        if(selectedRows && selectedRows.length > 0){
            data = selectedRows;
        }

        if(newData != null && newData != undefined){
            data.push(...newData);
        }

        console.log(data);
        
        component.set("v.productData", data);
    },

    saveAdvisoryPlanningItem : function(component, allocatedData, toDeletedIdList) {
        var advisoryId  = component.get("v.advisoryId");
        var action      = component.get("c.saveAdvisoryPlanningItem");

        return new Promise(function (resolve, reject) {
            action.setParams({
                advisoryId : advisoryId,
                itemList : allocatedData,
                toDeletedIdList : toDeletedIdList
            });

            action.setCallback(this, function (response) {
               var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    reject(errors);
                }
            });

            $A.enqueueAction(action);
        });
    },

    generateAllocationTable : function(advisoryId,itemType, existingRecord, newSelectedProduct){
        var newAllocationData = [];
        var lastedProductIdSet= [];
        var lastedProductList = [];

        if(existingRecord && existingRecord.length > 0){
            // newAllocationData.push(...existingRecord);
            for(let i = 0; i < existingRecord.length; i++){
                var eachAllocation = existingRecord[i];
                if(eachAllocation.Id != null && eachAllocation.Id != undefined  && eachAllocation.Id != ''){
                    newAllocationData.push(eachAllocation);
                }else{
                    lastedProductIdSet.push(eachAllocation.Product_Master__c);
                    lastedProductList.push(eachAllocation);
                }
            }
        }
        if(newSelectedProduct && newSelectedProduct.length > 0){
            for(let i = 0; i < newSelectedProduct.length; i++){
                var eachProduct = newSelectedProduct[i];
                if(lastedProductIdSet.includes(eachProduct.productId)){
                    var indexOfItem = lastedProductIdSet.indexOf(eachProduct.productId);
                    var existingAllocation = lastedProductList[indexOfItem];
                    newAllocationData.push(existingAllocation);
                }else{
                    var yearReturn = (eachProduct.invest_1YearReturn) ? eachProduct.invest_1YearReturn : 0;
                    var newAllocation = {
                        Advisory_Item_Type__c: itemType,
                        Advisory_Planning__c: advisoryId,
                        Baseline_Allocation__c: 0,
                        Baseline_Amount__c: 0,
                        Id: null,
                        Name: null,
                        Product_Holding_Code__c: eachProduct.productCode,
                        Product_Group__c: eachProduct.family,
                        Product_Master__c: eachProduct.productId,
                        Product_Name__c: eachProduct.productName,
                        Product_Sub_Group_Asset_Class__c: eachProduct.subFamiltyAsset,
                        RMC_1Year_Return__c: yearReturn,
                        Target_Allocation__c: 0,
                        Target_Amount__c: 0,
                        Is_Product_Holding__c : false
                    }
                    newAllocationData.push(newAllocation);
                }

               
            }
        }
        
        return newAllocationData;
    },

    recalculateTarget : function(allocatedList){
        var totalTargetAmount   = 0;
        var totalBaselineAmount = 0;
        for(var eachItem of allocatedList){
            var eachTargetAmount    = parseFloat(eachItem.Target_Amount__c);
            var eachBaselineAmount  = parseFloat(eachItem.Baseline_Amount__c);
            totalTargetAmount       += eachTargetAmount;
            totalBaselineAmount     += eachBaselineAmount;
        }

        console.log("Total Baseline Amount = " + totalBaselineAmount);
        console.log("Total Target Amount = " + totalTargetAmount);

        var newAllocatedList = [];
        for(const eachItem of allocatedList){
            eachItem.Target_Allocation__c = parseFloat(eachItem.Target_Amount__c) / parseFloat(totalTargetAmount);
            eachItem.Baseline_Allocation__c = parseFloat(eachItem.Baseline_Amount__c) / parseFloat(totalBaselineAmount);
            
            newAllocatedList.push(eachItem);
        }

        return newAllocatedList;
    },


    closeModal : function(component, isEndProcess){
        var itemType = component.get("v.itemType");
        var closeEvent = component.getEvent("close_loading_evt");
        if(itemType == 'Return'){//remove last column : 1 year
            this.COLUMNS.splice(-2);
        }
        closeEvent.setParams({
            data: {
                'isDisplayModal': false,
                'isEndProcess' : isEndProcess
            }
        })
        closeEvent.fire();
    },

    parseFieldInfo : function(component){
        var allocatedColumn = component.get('v.allocatedColumn');
        var columnLabelList = {};
        if(allocatedColumn && allocatedColumn.length > 0){
            for(var eachColumn of allocatedColumn){
                columnLabelList[eachColumn.fieldName] = eachColumn.label;
            }
        }
        console.log(columnLabelList);
        component.set("v.columnLabelList", columnLabelList);
    },

    showToast : function(component, title, message, mode, toastType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode" : mode,
            "type" : toastType,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
})