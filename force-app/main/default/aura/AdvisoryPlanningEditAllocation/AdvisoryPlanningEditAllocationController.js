({
    doInit : function(component, event, helper) {
        var itemType = component.get("v.itemType");
        var allocatedData = component.get("v.allocatedData");
        
        console.log(allocatedData);
        component.set("v.exisitingData", allocatedData);
        component.set("v.updatedAllocatedData", allocatedData);
        helper.getProductFamily(component, itemType);
        helper.getProductHeaderName(component, itemType);
        
        var maxReturnRow = 50;
        var existingProduuctIdSet = [];
        Promise.all([
            helper.getProducts(component, existingProduuctIdSet , maxReturnRow)
        ]).then(function(results) {
            console.log('------ AdvisoryPlanning - Edit Allocaltion : doInit ------');
            console.log(results[0]);

            var records = results[0];
            component.set("v.isReloadProduct", true);

            if(records.isSuccess){
                if(itemType == 'Return'){
                    helper.COLUMNS.push({
                        label: '1 Yr. Return',
                        fieldName: 'invest_1YearReturn',
                        type: 'number',
                        cellAttributes: { alignment: 'right',  class: 'percentField' },
                    });
                    helper.COLUMNS.push({
                        label: '1 Yr. Return as of Date',
                        fieldName: 'investmentSyncDateTime',
                        type: 'text',
                        cellAttributes: { alignment: 'left' },
                    });
                }
                component.set("v.columns", helper.COLUMNS);
                component.set("v.productData", records.data);
                helper.parseFieldInfo(component);
                helper.hideLoading(component, event);
                helper.toggleDataTable(component,event);
            }

        }).catch(function (err) {
            console.log(err);
        });
    },

    getProduct : function(component, event, helper){
        console.log('------ AdvisoryPlanning - Edit Allocaltion : Get Product ------');
        var lines = component.find('productData').getSelectedRows();
        component.set("v.selectedProduct", lines);
        console.log(JSON.stringify(lines));
        console.log(JSON.stringify(component.get("v.selectedProduct")));
        
        var maxReturnRow = 1000;

        helper.showLoading(component);
        Promise.all([
            helper.getProducts(component, lines, maxReturnRow)
        ]).then(function(results) {
            console.log(results[0]);
            var records = results[0];
            var newData;
            if(records.isSuccess){
                helper.hideLoading(component);
                newData = records.data;
            }

            helper.processDataTable(component, newData);
        }).catch(function (err) {
            console.log(err);
        });
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component, false);
    },

    onRowSelected : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
    },

    handleNext : function(component, event, helper){
        var stepNo = component.get("v.stepNo");
        stepNo     = stepNo + 1;
        var lines = component.find('productData').getSelectedRows();
        component.set("v.selectedProduct", lines);
        component.set("v.stepNo", stepNo);

        var itemType    = component.get("v.itemType");
        var advisoryId  = component.get("v.advisoryId");
        var existingRecord  = component.get("v.updatedAllocatedData");

        var newAllocationDataList = helper.generateAllocationTable(advisoryId,itemType, existingRecord, lines);
        var newAllocationCalList  = helper.recalculateTarget(newAllocationDataList);
        console.log(newAllocationCalList);
        component.set("v.updatedAllocatedData", newAllocationCalList);
        $A.util.addClass(component.find("add-product"), "slds-hide");
        $A.util.removeClass(component.find("allocated"), "slds-hide");
    },

    handleBack : function(component, event, helper){
        var stepNo = component.get("v.stepNo");
        stepNo     = stepNo -  1;
        component.set("v.stepNo", stepNo);
        $A.util.removeClass(component.find("add-product"), "slds-hide");
        $A.util.addClass(component.find("allocated"), "slds-hide");

        var deletedList = component.get("v.deletedList");
        if(deletedList){
            var productData = component.get("v.productData");
            productData.push(...deletedList);
            component.set("v.productData", productData);
        }
    },

    recalculateTarget : function(component, event, helper){
        var allocatedList  = component.get("v.updatedAllocatedData");
        var newAllocationCalList  = helper.recalculateTarget(allocatedList);
        component.set("v.updatedAllocatedData", newAllocationCalList);
    },


    handleDeleteItem : function(component, event, helper){
        var ctarget = event.currentTarget;
        var targetIndex = ctarget.dataset.value;
        if(!$A.util.isEmpty(targetIndex)){
            
            var allocatedList  = component.get("v.updatedAllocatedData");
            var deleteItemList     = allocatedList.splice(targetIndex, 1);
            var newAllocationCalList  = helper.recalculateTarget(allocatedList);
            component.set("v.updatedAllocatedData", newAllocationCalList);
            var productData = component.get("v.productData");
            var productIndex;
            var deletedList = component.get("v.deletedList");
            var toDeleteItemList = component.get("v.toDeleteItemList");
            if(toDeleteItemList == undefined || toDeleteItemList == null) toDeleteItemList = [];

            //process handle to be deleted list in the database
            if(deleteItemList){
                for(var deleteItem of deleteItemList){
                    if(deleteItem.Id != null && deleteItem.Id != undefined && deleteItem.Id != ''){
                        toDeleteItemList.push(deleteItem);
                    }
                }
                component.set("v.toDeleteItemList", toDeleteItemList);
            }

            //process deselected product data list
            for(let i = 0; i < productData.length; i++){
                var eachSelectedProduct = productData[i];
                if(eachSelectedProduct.productId == deleteItemList[0].Product_Master__c){
                    productIndex = i;
                    deletedList.push(eachSelectedProduct);
                    break;
                }
            }
            console.log('productIndex = ' + productIndex);
            if(!$A.util.isEmpty(productIndex)){
                productData.splice(productIndex, 1);
            }

            component.set("v.productData", productData);

        }
    },

    handleAddBond : function(component, event, helper){
        component.set("v.displayBondAction" , true);
        var currentAllocation = component.get("v.updatedAllocatedData");
        var currentBondHolding = [];

        for(var eachItem of currentAllocation){
            if(eachItem.Product_Group__c == 'BOND' && eachItem.Is_Product_Holding__c == false){
                currentBondHolding.push(eachItem);
            }
        }


        component.set("v.currentBondHolding", currentBondHolding);
    },

    handleCloseBondModal : function(component, event, helper) {
        var displayModal = event.getParam('data').isDisplayModal;
        component.set("v.displayBondAction", displayModal);
    },

    handleSaveBondModal : function(component, event, helper) {
        console.log(JSON.stringify(event.getParam('data')));
        var eventData = event.getParam('data');
        var bondList  = eventData.bondList;
        var toDeleteBondList = eventData.toDeleteBondList;

        if(toDeleteBondList){
            var main_toDeleteItemList = component.get('v.toDeleteItemList');
            main_toDeleteItemList.push(...toDeleteBondList);
            component.set("v.toDeleteItemList", main_toDeleteItemList);
        }

        var currentAllocation = component.get("v.updatedAllocatedData");
        var newAllocationWithoutBond = [];
        var newAllocationWithBond    = [];
        for(var eachItem of currentAllocation){
            if(eachItem.Is_Product_Holding__c){
                newAllocationWithoutBond.push(eachItem);
            }else{
                if(eachItem.Product_Group__c != 'BOND'){
                    newAllocationWithoutBond.push(eachItem);
                }
            }
        }

        if(newAllocationWithoutBond.length > 0) newAllocationWithBond.push(...newAllocationWithoutBond);

        if(bondList && bondList.length > 0){
            newAllocationWithBond.push(...bondList);
        }

        
        var newAllocationCalList  = helper.recalculateTarget(newAllocationWithBond);
        component.set("v.updatedAllocatedData", newAllocationCalList);

        var displayModal = eventData.isDisplayModal;
        component.set("v.displayBondAction", displayModal);
    },

    handleSave : function(component, event, helper){
        console.log("--------- Handle Save --------");
        var errorTarget     = $A.get("$Label.c.RMC_Edit_Allocation_Error_Target")
        var allocatedData    = component.get("v.updatedAllocatedData");
        var toDeleteItemList = component.get("v.toDeleteItemList");
        component.set("v.disableButton", true);

        var targetFieldsAmount = component.find('targetAmountField');

        var allValid = false;

        
        if(!$A.util.isEmpty(targetFieldsAmount)){
            var targetFieldsAmountList = [];

            if(targetFieldsAmount.length >= 0){
                targetFieldsAmountList.push(...targetFieldsAmount);
            }else{
                targetFieldsAmountList.push(targetFieldsAmount);
            }
            
            allValid = targetFieldsAmountList.reduce(function (validSoFar, inputCmp) {
                var isValueValid = true;
                var value = inputCmp.get("v.value");
                console.log(value);
                if($A.util.isEmpty(value) || parseFloat(value) <= 0){
                    inputCmp.setCustomValidity(errorTarget);
                    inputCmp.reportValidity();
                    isValueValid = false;
                }else{
                    inputCmp.setCustomValidity("");
                    inputCmp.reportValidity();
                }
                // inputCmp.showHelpMessageIfInvalid();
                // return validSoFar && inputCmp.get('v.validity').valid;
                return validSoFar && isValueValid;
            }, true);
        }else{
            allValid = true;
        }
        

        if (allValid) {
            console.log(allocatedData);
            console.log(toDeleteItemList);
            
            var toDeletedIdList = [];
            if(toDeleteItemList && toDeleteItemList.length > 0){
                var tempToDeleteIdList = [];
                for(var eachDeleteItem of toDeleteItemList){
                    var deleteId = eachDeleteItem.Id;
                    if(deleteId != null && deleteId != undefined && deleteId != ''){
                        var tempToDeleteIdListStr = tempToDeleteIdList.toString();
                        if(!tempToDeleteIdListStr.includes(deleteId)){
                            toDeletedIdList.push(deleteId);
                            tempToDeleteIdList.push(deleteId);
                        }
                    }
                }
            }
            
            helper.showLoading(component);
            Promise.all([
                helper.saveAdvisoryPlanningItem(component, allocatedData, toDeletedIdList)
            ]).then(function(results) {
                console.log(results[0]);
                var records = results[0];
                if(records.isSuccess){
                    helper.hideLoading(component);
                    helper.showToast(component, 'Success !', 'The Advisory Planning was updated.', 'dismissible', 'success')
                    helper.closeModal(component, true);
                }else{
                    var message = records.errorMessage;
                    helper.showToast(component, 'Cannot save the record', message, 'sticky', 'error');
                    component.set("v.disableButton", false);
                }
            }).catch(function (err) {
                helper.showToast(component, 'Cannot save the record', err.toString(), 'sticky', 'error');
                component.set("v.disableButton", false);
            });
        } else {
            component.set("v.disableButton", false);
        }
    },
})