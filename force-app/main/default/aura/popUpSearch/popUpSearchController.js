({
    onInit : function(component, event, helper) {
    
    },
    
    onWorkAccepted : function(component, event, helper) {
        console.log("Work accepted.");
        
        var workItemId = event.getParam('workItemId');

        if(workItemId.startsWith("500"))
        {
            helper.popUpSearchFromEmail(component, event, helper);                
        }
        else if(workItemId.startsWith("570"))
        {
            helper.popUpSearchFromChat(component, event, helper); 
        }
		
        
    }, 
})