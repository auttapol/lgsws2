({
    onInit : function(component, event, helper) {
        component.set('v.loading',true);
        helper.getWatermarkHTML(component);
        helper.setFocusedTabLabel(component, event, helper);
        helper.getLastAvailDataTime(component,event,helper).then((data) => {
            var lastAvailDataTime = component.get('v.lastAvailDataTimeObj');
            component.set('v.selectedYear',lastAvailDataTime.defaultYear);
            helper.getPerformanceData(component, event, helper);
            helper.getTargetProductTable(component, event, helper);
        })
        
    },

    reloadData : function(component, event, helper) {
        component.set('v.tabChangeWhileLoading', component.get('v.isLoadingGraphData'));
        helper.getPerformanceData(component, event, helper)
        helper.getTargetProductTable(component, event, helper);
    },
})