({
    doInit: function (component, event, helper) {
        helper.getOppty(component, event, helper);
        helper.getProduct(component, event, helper);
        helper.getHost(component, event, helper);
        helper.getDeeplink(component, event, helper);
    },

    backToTMBSmart: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get('v.varDeepLink')
        });
        urlEvent.fire();
    },

    // handleShowNotice: function (component, event, helper) {
    //     var element = component.find("notify");
    //     $A.util.toggleClass(element, "slds-hide")
    // }
})