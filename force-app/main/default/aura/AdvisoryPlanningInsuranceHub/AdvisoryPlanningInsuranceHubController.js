({
    doInit : function(component, event, helper) {
        console.log('------ getBancassuranceDetail : doInit ------');
        console.log(JSON.stringify(component.get("v.planningRecord")));
        helper.getInsuranceData(component,event,helper);
    },

    handleRefresh : function(component, event, helper){
        console.log('------ getBancassuranceDetail : handleRefresh ------');
        helper.getInsuranceData(component,event,helper);
    }
})