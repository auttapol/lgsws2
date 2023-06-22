({
    onInit : function(component, event, helper) {
        // helper.showSpinner(component);
        helper.getRecordInfo(component);
        // helper.hideSpinner(component);
    },

    handleChange : function(component, event, helper){
        var lookupId = event.getParam("value")[0];
        component.set('v.select_approver_id', lookupId);
    },

    handleSubmit : function(component, event, helper){
        helper.submitRequest(component, helper);
    },

    handleCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

    keyPressController : function(component, event, helper) {
        // get the search Input keyword
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper
        // else close the lookup result List part.
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selection
    clear :function(component,event,helper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null);
        component.set("v.selectedRecord", null);
    },

    // This function call when the end User Select any record from the result list.
    handleComponentEvent : function(component, event, helper) {
        // get the selected User record from the COMPONENT event
        var selectedUserGetFromEvent = event.getParam("userByEvent");
        component.set("v.selectedRecord" , selectedUserGetFromEvent);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
    },

    // automatically call when the component is done waiting for a response to a server request.
    hideSpinner : function (component, event, helper) {
        // var spinner = component.find('spinner');
        // var evt = spinner.get("e.toggle");
        // evt.setParams({ isVisible : false });
        // evt.fire();

        helper.hideSpinner(component);
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        // var spinner = component.find('spinner');
        // var evt = spinner.get("e.toggle");
        // evt.setParams({ isVisible : true });
        // evt.fire();

        helper.showSpinner(component);
    },
})