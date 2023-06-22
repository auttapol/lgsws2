({
    doInit : function(component, event, helper){
        var bondColumn         = component.get("v.bondColumn");
        var columns         = [];
        helper.hideComponent(component, "loadingSpinner");
        helper.showComponent(component, "bond-list");
        var columnSet = ['Product_Group__c','Product_Name__c','Product_Code__c','Baseline_Amount__c'];
        if(bondColumn && bondColumn.length > 0){
            for(var eachColumn of bondColumn){
                if(columnSet.includes(eachColumn.fieldName)){
                    columns.push(eachColumn);
                }
            }
        }

        component.set("v.columns", columns);
    },

    closeModal : function(component){
        var closeEvent = component.getEvent("close_bond_evt");
        closeEvent.setParams({
            data: {
                'isDisplayModal': false
            }
        })
        closeEvent.fire();
    },

    addBond : function(component, event, helper){
        var advisoryPlanningId = component.get("v.advisoryId");
        var newBondItem = {
            Id              : null,
            Advisory_Item_Type__c : 'Return',
            Product_Group__c: 'BOND',
            Product_Name__c : '',
            Product_Holding_Code__c : '',
            Product_Sub_Group_Asset_Class__c : 'Debenture',
            Baseline_Amount__c : null,
            Target_Amount__c : null,
            Advisory_Planning__c : advisoryPlanningId,
            Is_Product_Holding__c : false,
            RMC_1Year_Return__c : 0

        }
        component.set("v.editBondItem", newBondItem);
        component.set("v.isNewBondItem", true);
        component.set("v.displayAddBondAction", true);
    },

    handleCloseAddBondModal : function(component, event, helper) {
        var displayModal = event.getParam('data').isDisplayModal;
        component.set("v.displayAddBondAction", displayModal);
    },

    handleSaveBondItem : function(component,event,helper){
        var data = event.getParam('data');
        var currentBondHoldingList = component.get("v.currentBondHolding");
        if(currentBondHoldingList == null || currentBondHoldingList == undefined){
            currentBondHoldingList = [];
        }
        
        if(data.bondItem){
            if(data.isNew){
                var bondItem = data.bondItem;
                currentBondHoldingList.push(bondItem);
            }else{
                var bondItem = data.bondItem;
                var editIndex = data.editIndex;
                
                currentBondHoldingList[editIndex] = bondItem;
            }
        }

        component.set("v.currentBondHolding", currentBondHoldingList );
        var displayModal = data.isDisplayModal;
        component.set("v.displayAddBondAction", displayModal);
    },

    handleEditItem : function(component,event,helper){
        var ctarget = event.currentTarget;
        var targetIndex = ctarget.dataset.value;
        if(!$A.util.isEmpty(targetIndex)){
            
            var currentBondHoldingList  = component.get("v.currentBondHolding");
            var bondItem = currentBondHoldingList[targetIndex];
            component.set("v.editIndex", targetIndex);
            component.set("v.editBondItem", bondItem);
            component.set("v.isNewBondItem", false);
            component.set("v.displayAddBondAction", true);
        }
    },

    handleDeleteItem : function(component,event,helper){
        
        var ctarget = event.currentTarget;
        var targetIndex = ctarget.dataset.value;
        if(!$A.util.isEmpty(targetIndex)){
            var currentBondHoldingList  = component.get("v.currentBondHolding");
            var toDeleteItemList = component.get('v.toDeleteItemList');
            if(toDeleteItemList == undefined || toDeleteItemList == null) toDeleteItemList = [];

            var deleteItemList     = currentBondHoldingList.splice(targetIndex, 1);
            
            component.set("v.currentBondHolding", currentBondHoldingList);
            // console.log(JSON.stringify(deleteItemList))
            if(deleteItemList){
                for(var deleteItem of deleteItemList){
                    if(deleteItem.Id != null && deleteItem.Id != undefined && deleteItem.Id != ''){
                        toDeleteItemList.push(deleteItem);
                    }
                }

                component.set("v.toDeleteItemList", toDeleteItemList);
            }
            
        }
    },

    handleDoneAddBondList : function(component, event, helper){
        var doneEvent = component.getEvent("save_bond_evt");
        doneEvent.setParams({
            data: {
                'isDisplayModal': false,
                'bondList' : component.get('v.currentBondHolding'),
                'toDeleteBondList' : component.get('v.toDeleteItemList')
            }
        })
        doneEvent.fire();
    }
})