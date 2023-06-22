({
    selectUser : function(component, event, helper){
        // get the selected Account from list
        var getSelectUser = component.get("v.oUser");
        // call the event
        var compEvent = component.getEvent("oSelectedUserEvent");
        // set the Selected Account to the event attribute.
        compEvent.setParams({"userByEvent" : getSelectUser });
        // fire the event
        compEvent.fire();
    },
})