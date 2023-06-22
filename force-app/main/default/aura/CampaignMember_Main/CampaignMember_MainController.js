({
    onInit : function(component, event, helper) {
        var recordId = component.get('v.recordId')
        var mcode = component.get('v.mcode')
        var tmbCustId = component.get('v.tmbCustId')
        // console.log('recordId:',component.get('v.recordId'));
        // console.log('mcode:',component.get('v.mcode'));
        // console.log('tmbCustId:',component.get('v.tmbCustId'));
        if(recordId != null && recordId != '' )
        {
            helper.getCampaign(component, event, helper);
            helper.getCampaignMember(component, event, helper);
        }  
        else if(mcode != null && tmbCustId != null)
        {
            component.set('v.recordCanNotSell',true);
            component.set('v.showWarning',true); 
        }   
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            // console.log('response:',response);
            for(var i = 0; i < response.length; i++)
            {
                for(var j = i+1; j < response.length; j++)
                {
                    // console.log('i:',i);
                    // console.log('response i:',response[i].pageReference.attributes);
                    // console.log('j:',j);
                    // console.log('response j:',response[j].pageReference.attributes);
                    if(response[i].pageReference.attributes.attributes && response[j].pageReference.attributes.attributes)
                    {
                        if(response[i].pageReference.attributes.attributes.recordId == response[j].pageReference.attributes.attributes.recordId)
                        {
                            if(response[i].focused)
                            {
                                workspaceAPI.closeTab({tabId: response[i].tabId});
                            }
                            else if(response[j].focused)
                            {
                                workspaceAPI.closeTab({tabId: response[j].tabId});
                            }
                        }
                    }
                    
                }
            }
        })
        .catch(function(error) {
            console.log(error);
        });

        workspaceAPI.getFocusedTabInfo().then(function(response) {
            if(response.isSubtab)
            {
                // console.log('isSubtab',response.isSubtab);
                workspaceAPI.getAllTabInfo().then(function(response1) {
                    // console.log('response1',response1);

                    for(var i = 0; i < response1.length; i++)
                    {     
                        if(response1[i].subtabs != undefined && response1[i].subtabs.length > 0)
                        {    
                            for(var j = 0; j < response1.length; j++)
                            {          
                                // if(response1[i].subtabs[j].pageReference.attributes.attributes && response.pageReference.attributes.attributes)      
                                // {

                                // }
                                for(var k = j+1; k < response1.length; k++)
                                {                 
                                    if(response1[i].subtabs[k] != undefined &&  response1[i].subtabs[j] != undefined && response1[i].subtabs[j].pageReference.attributes.attributes && response1[i].subtabs[k].pageReference.attributes.attributes
                                        && response1[i].subtabs[j].pageReference.attributes.attributes.recordId != null && response1[i].subtabs[k].pageReference.attributes.attributes.recordId != null)
                                    {
                                        // console.log('response i:',response1[i].subtabs[j]);
                                        // console.log('response j:',response1[i].subtabs[k]);
                                        if(response1[i].subtabs[j].pageReference.attributes.attributes.recordId == response1[i].subtabs[k].pageReference.attributes.attributes.recordId)
                                        {
                                            if(response1[i].subtabs[j].focused)
                                            {
                                                workspaceAPI.closeTab({tabId: response1[i].subtabs[k].tabId});
                                            }
                                            else if(response1[i].subtabs[k].focused)
                                            {
                                                workspaceAPI.closeTab({tabId: response1[i].subtabs[j].tabId});
                                            }
                                        }
                                    }  
                                }    
                            } 
                        }
                    }                             
                })
            }                    
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    handleInfoEvent : function(component, event, helper) {
        var mode = event.getParam("Mode");
        // console.log('mode:',mode);
        component.set('v.mode',mode);

    },


})