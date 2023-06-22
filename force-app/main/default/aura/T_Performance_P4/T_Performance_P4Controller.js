({
    onInit : function(component, event, helper) {
        helper.setFocusedTabLabel(component, event, helper);
        helper.getPerformanceData(component, event, helper);
        helper.getWatermarkHTML(component);
        
    },

    prepareData: function(component, event, helper) {
        helper.getPerformanceData(component, event, helper);
    },
   
})