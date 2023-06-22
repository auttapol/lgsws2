({
    doInit : function(component, event, helper){
        component.set("v.canEditAllocation", false);
        Promise.all([
            helper.getAdvisoryPlanningItem(component), 
            helper.getColumn(component)
        ]).then(function(results) {
            console.log('------ AdvisoryPlanningItemList : doInit ------');
            console.log(results[0]);
            console.log(results[1]);

            var records = results[0];
            var dataColumnList = results[1];

            var layoutTitleDefault = component.get("v.layoutTitle");

            if(records.isSuccess && dataColumnList.isSuccess){
                var layoutTitle = layoutTitleDefault + " (" +  records.data.length + ")";
                component.set("v.layoutTitleDisplay", layoutTitle);
                helper.processDataTable(component, records.data, dataColumnList.data);

                var planning = component.get("v.planningRecord");
                if(planning){
                    if(planning.Status__c != 'Closed' && planning.Status__c != 'Cancelled'){
                        component.set("v.canEditAllocation", true);
                    }
                }
            }
        }).catch(function (err) {
            console.log(err);
        });
    },
    
    goToEditAllocation : function(component, event, helper) {
        component.set("v.displayModal", true);
    },

    handleCloseModal : function(component, event, helper) {
        var displayModal = event.getParam('data').isDisplayModal;
        var endProcess   = event.getParam('data').isEndProcess;
        component.set("v.displayModal", displayModal);
        
        console.log('endprocess = ' + endProcess);
        if(endProcess == true){
            $A.util.addClass(component.find("list-view-table"), "slds-hide");
            $A.get('e.force:refreshView').fire();
            // window.location.reload();
            Promise.all([
                helper.getAdvisoryPlanningItem(component)
            ]).then(function(results) {
                console.log('------ AdvisoryPlanningItemList : endProcess ------');
                console.log(results[0]);
    
                var records = results[0];
                var layoutTitleDefault = component.get("v.layoutTitle");
    
                if(records.isSuccess){
                    var layoutTitle = layoutTitleDefault + " (" +  records.data.length + ")";
                    component.set("v.layoutTitleDisplay", layoutTitle);
                    component.set("v.data", records.data);
                    $A.util.removeClass(component.find("list-view-table"), "slds-hide");
                }
            }).catch(function (err) {
                console.log(err);
            });
        }
    },

    handleSort: function(component, event, helper) {
        helper.handleSort(component, event);
    }
})