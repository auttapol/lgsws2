({
    onInit : function(component, event, helper) {
        const individual =component.get('v.individual');
        if (individual == undefined || individual == null || individual == 0) {
            component.set('v.individual',0.00);
        }

        const bankwide = component.get('v.bankwide');
        if (bankwide == undefined || bankwide == null || bankwide == 0) {
            component.set('v.bankwide',0.00);
        }
    },
    scriptsLoaded : function(component, event, helper) {
        helper.setChartClass();
        component.set('v.scriptLoaded',true);
        helper.drawChart(component, event, helper);
    },

    valueChange : function(component, event, helper) {
        var individual = component.get('v.individual');
        if(component.get('v.scriptLoaded')) {
            helper.drawChart(component,event,helper,individual);
        }
    },

    checkBankWide : function(component, event, helper) {
        // console.log('debug bank wide on section c',component.get('v.bankwide'));
    },

    
})