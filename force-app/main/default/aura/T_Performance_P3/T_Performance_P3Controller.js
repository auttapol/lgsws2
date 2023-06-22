({
    onInit: function (component, event, helper) {
        var date = new Date();
        component.set('v.selectedYear', date.getFullYear());
        component.set('v.currentYear', date.getFullYear());
        component.set('v.previousYear', date.getFullYear() - 1);
        var monthLst = [
            { init: 'Jan', month: 'January', field: 'janKPI' },
            { init: 'Feb', month: 'February', field: 'febKPI' },
            { init: 'Mar', month: 'March', field: 'marKPI' },
            { init: 'Apr', month: 'April', field: 'aprKPI' },
            { init: 'May', month: 'May', field: 'mayKPI' },
            { init: 'Jun', month: 'June', field: 'junKPI' },
            { init: 'Jul', month: 'July', field: 'julKPI' },
            { init: 'Aug', month: 'August', field: 'augKPI' },
            { init: 'Sep', month: 'September', field: 'sepKPI' },
            { init: 'Oct', month: 'October', field: 'octKPI' },
            { init: 'Nov', month: 'November', field: 'novKPI' },
            { init: 'Dec', month: 'December', field: 'decKPI' },
        ];

        component.set('v.monthLst', monthLst);

        const years = [];

        years.push(new Date().getFullYear() - 1);
        years.push(new Date().getFullYear());
        component.set('v.yearList', years);

        
        helper.getLastSaleInfoInDB(component);

        helper.getLastSaleInfo(component);

        helper.getLastestPerformanceYear(component, event, helper).then(function (lastPerfYear) {
            helper.newPrepareDataForSectionC(component, helper, lastPerfYear);
            helper.setFocusedTabLabel(component, event, helper);
            helper.getBranchSectionA(component, event, helper);
            helper.getBranchInfo(component, event, helper);
            // helper.getMonthGap(component, event, helper);
            // helper.prepareDataForSectionC(component, event, helper);
            helper.checkLastPerf(component,event,helper).then(() => {
                helper.getCurrentMonthKPI(component, event, helper).then(() => {
                    helper.prepareDataForSectionD(component, event, helper);
                });
            });
            helper.getWatermarkHTML(component);
        }).catch(function (err) {
            helper.newPrepareDataForSectionC(component, helper, years[1]);
            helper.setFocusedTabLabel(component, event, helper);
            helper.getBranchSectionA(component, event, helper);
            helper.getBranchInfo(component, event, helper);
            // helper.getMonthGap(component, event, helper);
            // helper.prepareDataForSectionC(component, event, helper);
            // helper.prepareDataForSectionD(component, event, helper);
            helper.checkLastPerf(component,event,helper).then(() => {
                helper.prepareDataForSectionD(component, event, helper).then(() => {
                    helper.getCurrentMonthKPI(component, event, helper);
                });
            });
            helper.getWatermarkHTML(component);
        });
        
        helper.getSharePointLink(component);
    },

    handleChangeYear: function (component, event, helper) {
        var value = event.getSource().get("v.value");
        // helper.getMonthGap(component, event, helper);
        component.set('v.selectedYear', value),
        component.set('v.offset', 0);
        component.set('v.offsetTime', 0);
        component.set('v.dataLastMonth', 0);
        component.set('v.targetLastMonth', 0);
        helper.getCurrentMonthKPI(component, event, helper);
        helper.getBranchSectionA(component, event, helper);
        // helper.getMonthGap(component, event, helper);
        // helper.prepareDataForSectionC(component, event, helper);
        helper.prepareDataForSectionD(component, event, helper);

        helper.newPrepareDataForSectionC(component, helper, component.get('v.selectedYear'))

    },

    navigate: function (component, event, helper) {
        const selectedEmpId = event.target.id
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:T_Performance_P1",
            componentAttributes: {
                selectedEmpId
            }
        });
        evt.fire();
    },

    handlePrevious: function (component, event, helper) {
        var offsetDisplay = component.get('v.offsetDisplay');
        var offset = component.get('v.offset');
        var offsetTimes = component.get('v.offsetTime');

        if (offsetTimes > 0) {
            var newOffsetDisplay = offsetDisplay - offset;
            component.set('v.offsetDisplay', newOffsetDisplay);
            component.set('v.offsetTime', offsetTimes - 1);
            helper.getBracnhSectionDInfo(component, event, helper);
        }
    },

    handleNext: function (component, event, helper) {
        var offsetDisplay = component.get('v.offsetDisplay');
        var offset = component.get('v.offset');
        var offsetTimes = component.get('v.offsetTime');

        var newOffsetDisplay = offsetDisplay + offset;
        component.set('v.offsetDisplay', newOffsetDisplay);
        component.set('v.offsetTime', offsetTimes + 1);
        helper.getBracnhSectionDInfo(component, event, helper);

    },

    sortBy: function (component, event, helper) {
        var field = event.target.getAttribute("data-value");
        helper.sortBy(component, field);
    },

    onClickHelp : function(component, event, helper) {
        // helper.getSharePointLink(component,'Help');
        var link = component.get('v.helpLink');
        window.open(link);
    },

    onClickSummary : function(component, event, helper) {
        // helper.getSharePointLink(component,'Branch Summary');
        var link = component.get('v.summaryLink');
        window.open(link);
    }


})