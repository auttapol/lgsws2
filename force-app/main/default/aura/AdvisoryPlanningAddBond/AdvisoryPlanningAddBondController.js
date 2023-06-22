({
    closeModal : function(component){
        var closeEvent = component.getEvent("close_add_bond_evt");
        closeEvent.setParams({
            data: {
                'isDisplayModal': false
            }
        })
        closeEvent.fire();
    },

    handleSave : function(component, event, helper){
        event.preventDefault();       // stop the form from submitting
        
        var bondItem = component.get("v.bondItem");
        var isNew    = component.get("v.isNew");
        var editIndex= component.get("v.editIndex");
        // console.log(JSON.stringify(bondItem));
        // console.log(allValid);

        if(isNew == true){
            bondItem.Target_Amount__c = 0;
        }
        if (!$A.util.isEmpty(bondItem.Product_Holding_Code__c) && !$A.util.isEmpty(bondItem.Product_Name__c) && !$A.util.isEmpty(bondItem.Baseline_Amount__c) ) {
            var saveEvent = component.getEvent("save_add_bond_evt");
            saveEvent.setParams({
                data: {
                    'isDisplayModal': false,
                    'bondItem' : bondItem,
                    'isNew'    : isNew,
                    'editIndex': editIndex
                }
            })
            saveEvent.fire();
        }else{
        }
    }

})