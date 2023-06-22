({
	popUpSearchFromEmail : function(component,event,helper)
	{
		var workItemId = event.getParam('workItemId');
        
        var workspaceAPI = component.find("workspace");

		var caseObj = caseObj;
        
		var action = component.get('c.popUpSearchInCase');	
		action.setParams({
			"recordId": workItemId,
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();

				if(result != 'Match')
				{
                    workspaceAPI.getAllTabInfo ().then(function(response) {	                  
                        var subTabIsOpen = false;
                        for(var i = 0; i < response.length; i++)
                        { 
                            if(response[i].recordId.startsWith(workItemId))
                            {                        	
                                var subTabIsOpen = false;
                                if(response[i].subtabs.length > 0)
                                {
                                    for(var j = 0; j < response[i].subtabs.length; j++)
                                    {          
                                        if(response[i].subtabs[j].pageReference.attributes.componentName == 'c__CustomSearch')
                                        {
                                            subTabIsOpen = true;
                                        }
                                        if(!subTabIsOpen)    
                                        {     						  
                                            workspaceAPI.openSubtab({
                                                parentTabId: response[i].tabId,
                                                focus: false,
                                                pageReference: {
                                                    "type": "standard__component",
                                                    "attributes": {
                                                        "componentName": "c__CustomSearch"
                                                    },
                                                    "state": {
                                                        "c__caseId": workItemId
                                                    }
                                                }
                                            }).catch(function(error) {
                                                console.log("error:",error);
                                            }); 
                                        }                                    
                                    }  
                                }
                                else
                                {
                                    workspaceAPI.openSubtab({
                                        parentTabId: response[i].tabId,
                                        focus: false,
                                        pageReference: {
                                            "type": "standard__component",
                                            "attributes": {
                                                "componentName": "c__CustomSearch"
                                            },
                                            "state": {
                                                "c__caseId": workItemId
                                            }
                                        }
                                    }).catch(function(error) {
                                        console.log("error:",error);
                                    }); 
                                }
                                break; 
                            }
                        }
                    });
					/*workspaceAPI.getFocusedTabInfo().then(function(response) {                              
						if(response.subtabs.length == 0 )
						{                                                                             
							workspaceAPI.openSubtab({
								parentTabId: response.tabId,
								focus: false,
								pageReference: {
									"type": "standard__component",
									"attributes": {
										"componentName": "c__CustomSearch"
									},
									"state": {
										"c__caseId": workItemId
									}
								}
								
							}).catch(function(error) {
								console.log("error:",error);
							});              
						}
					});*/
				}
			}
		});
		
		$A.enqueueAction(action);
        
	},

	popUpSearchFromChat : function(component,event,helper)
	{
		var workItemId = event.getParam('workItemId');
        
		var workspaceAPI = component.find("workspace");
		        
		var action = component.get('c.popUpSearchInChat');	
		action.setParams({
                "recordId": workItemId,
		});
		action.setCallback(this, function(response) 
		{
			var state = response.getState();   
			if (state === "SUCCESS") 
            {
				var result = response.getReturnValue();
  				console.log("result :",result );
				if(result != 'Match')
                {					                 
                    workspaceAPI.getAllTabInfo ().then(function(response) {	                  
                        var subTabIsOpen = false;
                        for(var i = 0; i < response.length; i++)
                        { 
                            if(response[i].recordId.startsWith(workItemId))
                            {                        	
                                var subTabIsOpen = false;
                                if(response[i].subtabs.length > 0)
                                {
                                    for(var j = 0; j < response[i].subtabs.length; j++)
                                    {          
                                        if(response[i].subtabs[j].pageReference.attributes.componentName == 'c__CustomSearch')
                                        {
                                            subTabIsOpen = true;
                                        }
                                        if(!subTabIsOpen)    
                                        {     						  
                                            workspaceAPI.openSubtab({
                                                parentTabId: response[i].tabId,
                                                focus: false,
                                                pageReference: {
                                                    "type": "standard__component",
                                                    "attributes": {
                                                        "componentName": "c__CustomSearch"
                                                    },
                                                    "state": {
                                                        "c__caseId": workItemId
                                                    }
                                                }
                                            }).catch(function(error) {
                                                console.log("error:",error);
                                            }); 
                                        }                                    
                                    }  
                                }
                                else
                                {
                                    workspaceAPI.openSubtab({
                                        parentTabId: response[i].tabId,
                                        focus: false,
                                        pageReference: {
                                            "type": "standard__component",
                                            "attributes": {
                                                "componentName": "c__CustomSearch"
                                            },
                                            "state": {
                                                "c__caseId": workItemId
                                            }
                                        }
                                    }).catch(function(error) {
                                        console.log("error:",error);
                                    }); 
                                }
                                break; 
                            }
                        }
                    });
				}                   
			}
		});		
		$A.enqueueAction(action);
	},
})