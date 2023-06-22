({
    onInit : function(component, event, helper) {
        var date = new Date();
        // component.set('v.selectedMonth','Dec');
        component.set('v.selectedPeriod','year');
        // component.set('v.selectedYear',date.getFullYear());
        component.set('v.currentYear',date.getFullYear());
        component.set('v.previousYear',date.getFullYear()-1);

        var monthLst = [
            { init: 'Jan', month: 'Jan' },
            { init: 'Feb', month: 'Feb' },
            { init: 'Mar', month: 'Mar' },
            { init: 'Apr', month: 'Apr' },
            { init: 'May', month: 'May' },
            { init: 'Jun', month: 'Jun' },
            { init: 'Jul', month: 'Jul' },
            { init: 'Aug', month: 'Aug' },
            { init: 'Sep', month: 'Sep' },
            { init: 'Oct', month: 'Oct' },
            { init: 'Nov', month: 'Nov' },
            { init: 'Dec', month: 'Dec' },
        ];
        component.set('v.monthLst',monthLst);
    },

    scriptsLoaded : function(component, event, helper) {
        helper.setChartClass();
        component.set('v.scriptLoaded',true);
        helper.drawChart(component, event, helper);
    },

    handleTab : function(component, event, helper) {
        var isError = component.get('v.notifyError');
        if(!isError) {
            helper.loadTabs(component, event);
        }
    },

    handleSelectedMonth : function(component, event, helper) {
        var isError = component.get('v.notifyError');
        if(!isError) {
            component.set('v.selectedMonth',event.target.value);
            var parentComponent = component.get("v.parent");   
            parentComponent.reloadData()
        }
    },

    selectYear : function(component, event, helper) {
        var isError = component.get('v.notifyError');
        if(!isError) {
            var period = component.get('v.selectedPeriod');
            var lastAvailDataTimeObj = component.get('v.lastAvailDataTimeObj');
            if(component.get('v.selectedYear') == component.get('v.currentYear')) {
                component.set('v.selectedYear',component.get('v.previousYear'))
                if(period == 'month') {
                    component.set('v.selectedMonth',helper.getMonthInit(lastAvailDataTimeObj.prevYearDefaultMonth))
                }
                
            } else {
                component.set('v.selectedYear',component.get('v.currentYear'))
                if(period == 'month') {
                    component.set('v.selectedMonth',helper.getMonthInit(lastAvailDataTimeObj.currYearDefaultMonth))
                }
            }
            // component.set('v.selectedMonth',null);// reset month to get default
            var parentComponent = component.get("v.parent");   
            parentComponent.reloadData()
        }
    },

    valueChange : function(component, event, helper) {
        if(component.get('v.scriptLoaded')) {
            helper.drawChart(component,event,helper);
        }
    },

    handleDefaultYear : function(component, event, helper) {
       var defaultYear = component.get('v.defaultYear');
       if(!component.get('v.selectedYear')) {
            // first time set default
            component.set('v.selectedYear',parseInt(defaultYear));
       }
    }
})