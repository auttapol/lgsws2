({
	recordSelected : function(component, event, helper) {
        
        var thisObject = this;
        
        // Make component visible
		$A.util.removeClass(component.getElement(), 'hidden');
        
        // Call OSC14-16 function to get Usage data.
        var custId = component.get('v.recordId');
        
        // Show spinner.
        helper.showSpinner(component);

        helper.checkStatus(component, custId);
       
    },

    refreshed: function(component, event, helper) {
        location.reload();
    },

    refreshOsc17 : function(component, event, helper) {
        
        var thisObject = this;
        
        // Make component visible
		$A.util.removeClass(component.getElement(), 'hidden');
        
        // Call OSC14-16 function to get Usage data.
        var custId = component.get('v.recordId');
        
        // Show spinner.
        helper.showSpinner(component);

        helper.runOSC16_17(component, custId);
        
        // thisObject.superAfterRender();
       
    },

    openProductHolding : function (component, event, helper) {
        // var recordId = component.get("v.recordId");
        // var url = '/apex/CustomerProductHoldingsView?acctId=' + recordId;
        // var urlEvent = $A.get("e.force:navigateToURL");
        // urlEvent.setParams({
        //     "url": url
        // });
        // urlEvent.fire();

        var recordId = component.get('v.recordId');
        window.open('/apex/CustomerProductHoldingsView?acctId=' + recordId);
    },

    // updateComponentView: function(component, event, helper) {
    //     var id = component.get("v.recordId");
    //     var main = component.find("main");
    //     $A.createComponent(
    //                         "c:CustomerSingleView",
    //                         {"recordId" : id},
    //                         function(cmp) {
    //                             // Just want to rerender.
    //                         });
    // }

})