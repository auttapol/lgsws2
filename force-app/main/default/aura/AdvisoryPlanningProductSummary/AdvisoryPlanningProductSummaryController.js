({
    handleAdvisoryPlanning : function(component, event, helper){
        var planningRecord = component.get("v.planningRecord");
        var customerId     = planningRecord.Customer__c;
        if(!$A.util.isEmpty(customerId)){
            console.log('show displayPlanningSummary')
            component.set('v.displayPlanningSummary', true);
        }
    }
})