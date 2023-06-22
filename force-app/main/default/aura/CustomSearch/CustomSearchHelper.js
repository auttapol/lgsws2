({
    setTabNameEmail : function(component,event,helper,recordId)
    {
        var workspaceAPI = component.find("workspace");

        var action = component.get('c.getCase');
        action.setParams(
        {
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var tabName = ' - Search';

                if(result.Contact_Person_Email__c != null)
                {
                    tabName = result.Contact_Person_Email__c + ' - Search';
                }
                else
                {
                    tabName = result.ContactEmail + ' - Search';
                }
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    workspaceAPI.getTabInfo({
                        tabId: response.tabId
                    }).then(function (response) 
                    {
                        if(response.subtabs)
                        {
                            for(var i = 0; i < response.subtabs.length; i++)
                            {                 
                                if(response.subtabs[i].isSubtab && response.subtabs[i].pageReference.attributes.componentName == "c__CustomSearch") 
                                {                               
                                    workspaceAPI.setTabLabel({
                                        tabId: response.subtabs[i].tabId,
                                        label: tabName,
                                    });
                                    workspaceAPI.setTabIcon({
                                        tabId: response.subtabs[i].tabId,
                                        icon: "standard:search",
                                        iconAlt: "Search"
                                    });
                                }
                            }
                        }
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
            }
        });
        $A.enqueueAction(action);
    },

    setTabNameChat : function(component,event,helper,recordId)
    {
        var workspaceAPI = component.find("workspace");

        var action = component.get('c.getContactFromTranscript');
        action.setParams(
        {
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
				var tabName = ' - Search';

				if(result)
				{
                    tabName = result + ' - Search'; 
				}

                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    workspaceAPI.getTabInfo({
                        tabId: response.tabId
                    }).then(function (response) {
   
                        if(response.subtabs)
                        {
                            for(var i = 0; i < response.subtabs.length; i++)
                            {                 
                                if(response.subtabs[i].isSubtab && response.subtabs[i].pageReference.attributes.componentName == "c__CustomSearch") 
                                {                               
                                    workspaceAPI.setTabLabel({
                                        tabId: response.subtabs[i].tabId,
                                        label: tabName,
                                    });
                                    workspaceAPI.setTabIcon({
                                        tabId: response.subtabs[i].tabId,
                                        icon: "standard:search",
                                        iconAlt: "Search"
                                    });
                                }
                            }
                        }
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
            }
        });
        $A.enqueueAction(action);
       
    }
})