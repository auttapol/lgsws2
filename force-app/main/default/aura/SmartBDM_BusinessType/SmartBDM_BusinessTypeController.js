({
	onInit: function (component, event, helper) {
        helper.getDeepLink(component, event, helper);
        
    },
    keyPressController: function (component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if (getInputkeyWord.length > 0) {
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        } else {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }

        var backgroudImage = component.find("backgroudImage");
        if(!component.get('v.isSelected') && component.get('v.SearchKeyWord') == '') {
            $A.util.addClass(backgroudImage, 'slds-show');
            $A.util.removeClass(backgroudImage, 'slds-hide');
        }
        else {
            $A.util.addClass(backgroudImage, 'slds-hide');
            $A.util.removeClass(backgroudImage, 'slds-show');
        }
    },

    // function for clear the Record Selaction 
    clear: function (component, event, heplper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");
        var backgroudImage = component.find("backgroudImage");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        $A.util.addClass(backgroudImage, 'slds-show');
        $A.util.removeClass(backgroudImage, 'slds-hide');

        component.set("v.SearchKeyWord", '');
        component.set("v.listOfSearchRecords", null);
        component.set("v.isSelected", false);
    },

    // This function call when the end User Select any record from the result list.   
    handleComponentEvent: function (component, event, helper) {
 
        var selectedIndustryMasterByEvent = event.getParam("IndustryMasterByEvent");
        component.set("v.selectedRecord", selectedIndustryMasterByEvent);

        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');

        helper.getDataSelectedHelper(component, event, helper, selectedIndustryMasterByEvent['Id']);
    },
    // automatically call when the component is done waiting for a response to a server request.  
    hideSpinner: function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({
            isVisible: false
        });
        evt.fire();
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner: function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({
            isVisible: true
        });
        evt.fire();
    },
    redirectToSmartBDM: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get('v.varDeepLink')
        });
        urlEvent.fire();
    }
})