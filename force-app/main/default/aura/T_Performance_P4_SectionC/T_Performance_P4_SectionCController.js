({
    onInit : function(component, event, helper) {
    
        component.set("v.sortAsc", false);
        component.set("v.sortField", "Sale_Type");
    },

    sortBy: function(component, event, helper) {
        var field = event.target.getAttribute("data-value");
        helper.sortsaleInfo(component, field);
    },

    sortByCM: function(component, event, helper) {
       
        var field = event.target.getAttribute("data-value"); 
        helper.sortCM(component, field);
        

    },

    sortByYTD: function(component, event, helper) {
        var field = event.target.getAttribute("data-value");
        helper.sortYTD(component, field);
    },
   /*  sortBySaleType: function(component, event, helper) {
        helper.sortBy(component, "Sale_Type");
    },

    sortByName: function(component, event, helper) {
        helper.sortBy(component, "Name");
    },

    sortByNoCustomer: function(component, event, helper) {
        helper.sortBy(component, "No_Of_Customer");
    },
    
    sortByCMActualPoint: function(component, event, helper) {
        helper.sortByCM(component, "Actual_Point__c");
    },

    sortByCMTargetPoint: function(component, event, helper) {
        helper.sortByCM(component, "Target_Point__c");
    },

    sortByCMPercentSuccess: function(component, event, helper) {
        helper.sortByCM(component, "Percent_Success__c");
    },

    sortByCMVariance: function(component, event, helper) {
        helper.sortByCM(component, "Variance__c");
    },

    sortByYTDSuccessYTD: function(component, event, helper) {
        helper.sortByYTD(component, "Percent_Success_YTD__c");
    },

    sortByYTDRankBankwide: function(component, event, helper) {
        helper.sortByYTD(component, "Rank_Bankwide__c");
    }, */

    nextPage : function(component, event, helper) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:T_Performance_P3",
              componentAttributes: {
                 "branchCode": component.get('v.branchId'),
                 "channel": component.get('v.channel'),
                 "region": component.get('v.region'),
                 "zone" : component.get('v.zone'),
                 "userType": component.get('v.userType')
             } 
        });
        evt.fire();
    }
})