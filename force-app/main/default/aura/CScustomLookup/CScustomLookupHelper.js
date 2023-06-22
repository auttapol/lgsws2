({
	searchHelper : function(component,event,getInputkeyWord) {

     var action = component.get("c.fetchAccount");

        action.setParams({
            'searchKeyWord': getInputkeyWord
          });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();

                if (storeResponse.length == 0) {
                    component.set("v.Message", $A.get("$Label.c.E_Client_Lookup_NoResult_Text"));
                } else {
                    component.set("v.Message", $A.get("$Label.c.E_Client_Lookup_SearchResult_Text"));
                }

                component.set("v.listOfSearchRecords", storeResponse);
         
            }
            else
            {
                component.set("v.checkInputRM",true);
                component.set("v.checkInputFX",true);
            }
 
        });

        $A.enqueueAction(action);
    
    },
    
    getCurrentUser : function(component, event, helper) {
        var action = component.get("c.fetchUser");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var storeResponse = response.getReturnValue();

                    component.set("v.SearchKeyWord",storeResponse.Name);
                    this.searchHelper(component,event,storeResponse.Name);
                }
            });
        $A.enqueueAction(action);
    },

    getAccountOwner : function(component, event, helper) {
        var accountId = component.get("v.accountId");
        var action = component.get("c.fetchAccountOwner");
        action.setParams({
            'accountId': accountId
          });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var storeResponse = response.getReturnValue();
     
                component.set("v.SearchKeyWord",storeResponse.Name);
                this.searchHelper(component,event,storeResponse.Name);

            }
            else
            {
                component.set("v.checkInputFX",false);
                component.set("v.checkInputRM",false);
            }
        });
        $A.enqueueAction(action);
    },
})