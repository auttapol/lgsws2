({
    onInit : function (component, event, helper) {
        component.set('v.loaded',true);
        var recordId = component.get('v.recordId');
        if(recordId != null && recordId != '' )
        {
            helper.getHistoryDetailsWithLimit(component, event, helper) 
        }
        else
        {
            component.set('v.displayData',null);  
            component.set('v.loaded',false);     
        }
    },
    handleClickUser : function(component, event, helper) {
        component.find("navigation").navigate({
            "type" : "standard__recordPage",
            "attributes": {
                "recordId"      : event.target.dataset.id,
                "actionName"    : "view"
            }
        })
    },
    handleViewAll : function(component, event, helper) {
        // component.find("navigation").navigate({
        //     "type": "standard__component",
        //     "attributes": {
        //         "componentName":"c__customAllCMH_Main"
        //     },
        //     "state": {
        //         "c__recordId": component.get('v.recordId')
        //     },
        // })
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:customAllCMH_Main",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();
    },

})