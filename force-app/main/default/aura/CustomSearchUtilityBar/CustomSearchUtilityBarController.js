({
    onInit : function(component, event, helper)
    {
        helper.checkProfileAssign(component, event, helper);
    },

    handleSelectSearch : function(component, event, helper) {
        component.set('v.isSelected',true);
    },

    searchCamapignMember : function(component, event, helper) {
        // $A.get('e.force:refreshView').fire();
        var searchkey = component.get('v.searchkey');
        // console.log('searchkey:',searchkey);
        component.set('v.loaded', true)
        var action = component.get('c.searchCampaignMember');
        action.setParams({
            "searchKey" : searchkey,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                // console.log('result:',result);
                if(result.length > 0 )
                {
                    var items = [];
                    result.forEach(value => {
                        // console.log('value:',value);
                        if(searchkey && value)
                        {
                            if(searchkey.startsWith("00v"))
                            {
                                if(value.Id)
                                {                         
                                    component.set('v.dataType','Id');
                                }                      
                            }
                            else if(value.RTL_Marketing_Code__c)
                            {
                                if(String.valueOf(value.RTL_Marketing_Code__c) == String.valueOf(searchkey))
                                {
                                    component.set('v.dataType','Marketing Code');
                                }                           
                            }
                            else if(value.RTL_Web_Unique_ID__c)
                            {
                                if(String.valueOf(value.RTL_Web_Unique_ID__c) == String.valueOf(searchkey))
                                {
                                    component.set('v.dataType','Unique ID');
                                }                              
                            }
                            var item = {
                                "label": value,
                                "value": value
                            };
                            items.push(item);
                        }
                    }); 
                    // console.log('dataType',component.get('v.dataType'));
                    // console.log('dataList',items);
                    component.set("v.dataList", items);
                    
                }
                else
                {
                    component.set("v.dataList", null);
                }
                component.set('v.isSearched',true);
                component.set('v.loaded', false)
            } 
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('message',message);
                component.set('v.loaded', false)
            }                 
        });
        $A.enqueueAction(action);
    },

    handleLoadMore : function(component, event, helper) {
		// var size = component.get("v.size");
        //  size = size+parseInt(component.get("v.loadMoreSize"));
        // component.set("v.size",size);
        helper.showMore(component, event, helper);
    },
    
    handleBack : function(component, event, helper) {
        component.set('v.isSelected',false);
        component.set('v.searchkey',null);
    },

    handleBack2 : function(component, event, helper) {
        component.set('v.isSearched',false);
        component.set("v.dataList", null);
        component.set("v.size",10);
    },

    handleValueChange : function(component, event, helper){
        var value = event.getParam('value');
        // console.log('value:',value);
        if(value == '')
        {
            value = null;
        }
        component.set('v.searchkey',value);
    },

    navigateToMyComponent : function(component, event, helper) {
        var recordId = event.target.getAttribute('id');
        var checkProfileAssign = component.get('v.checkProfileAssign');
        if(checkProfileAssign)
        {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CampaignMember_Main",
                componentAttributes: {
                    recordId : recordId,
                    "mode": 'Edit'
                }
            });
            evt.fire();
        }
        else
        {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/"+recordId
            });
            urlEvent.fire();           
        }
    },
    onHandleScroll : function (component, event, helper){
        var didScrolled;
        var div = component.find('scroll_container');
        // console.log('div:',div.getElement());
        if(!$A.util.isEmpty(div)){
            div = div.getElement();
            div.onscroll = function(){       
                didScrolled = true;
            };
            //Interval function to check if the user scrolled or if there is a scrollbar
            var intervalId = setInterval($A.getCallback(function(){
                if(didScrolled){
                    didScrolled = false;             
                    if(div.scrollTop === (div.scrollHeight - div.offsetHeight)){
                        helper.showMore( component ); 
                        clearInterval(intervalId); 
                
                    }
                }
            }), 1000);
            // component.set('v.setIntervalId', intervalId);
        }
     
    }  
})