({
    valueChange : function(component, event, helper) {
        var saleInfo = component.get('v.saleInfo');
        if(saleInfo.Channel__c == 'Branch') {
            component.set('v.groupName','Branch Code');
        } else {
            component.set('v.groupName','Team');
        }
    },

    showtooltip : function(component, event, helper) {
        var index = event.target.getAttribute("data-value");
        helper.toggleHelper(component, event, index);
    },
    
    hidetooltip : function(component, event, helper) {
        var index = event.target.getAttribute("data-value");
        helper.toggleHelper(component, event, index);
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