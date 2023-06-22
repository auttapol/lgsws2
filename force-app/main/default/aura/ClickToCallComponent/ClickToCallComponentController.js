({
    onInit: function(component, event, helper) {
 
        helper.getCurrentUser(component, event, helper);
        helper.getTimeOut(component, event, helper);
        //helper.subscribe(component, event, helper);
    },  

    onRecordIdChange : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var objectName;
        //console.log("recordId:"+recordId);
        if(recordId != null)
        {
            if(recordId.substring(0, 3) == '001')
            {
                objectName = 'Account';
                component.set('v.iconName','standard:account');
                component.set('v.iconText','Account');
            }
            else if(recordId.substring(0, 3) == '003')
            {
                objectName = 'Contact';
                component.set('v.iconName','standard:contact');
                component.set('v.iconText','Contact');
            }
            else if(recordId.substring(0, 3) == '00Q')
            {
                objectName = 'Lead';
                component.set('v.iconName','standard:lead');
                component.set('v.iconText','Lead');
            }
        	else if(recordId.substring(0, 3) == 'a2S')
            {
                objectName = 'RTL_Referral__c';
                component.set('v.iconName','custom:custom50');
                component.set('v.iconText','Referral');
            }
            else if(recordId.substring(0, 3) == '00v')
            {
                objectName = 'CampaignMember';
                component.set('v.iconName','standard:campaign_members');
                component.set('v.iconText','CampaignMember');
            }
            
            if(recordId && objectName)
            {
                helper.getFieldPhone(component, event, helper,recordId,objectName);
                component.set('v.isRender',true);
            }
            else
            {
                component.set('v.isRender',false);
            }
        }
        else
        {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                
                // console.log("focusedTabId:",focusedTabId);
                var url = decodeURIComponent(response.url.split('one/one.app#')[1]);
                var decodeBase64 = atob(url);
                // console.log('decodeBase64:',decodeBase64);           
                var recordId = decodeBase64.split('"recordId":')[1].split(',')[0].replace('"','').replace('"','')
                //console.log('recordId:',recordId);
                //component.set('v.recordId',recordId);
                if(recordId.substring(0, 3) == '00v')
                {
                    objectName = 'CampaignMember';
                    component.set('v.iconName','standard:campaign_members');
                    component.set('v.iconText','CampaignMember');
                }
                
                if(recordId && objectName)
                {
                    helper.getFieldPhone(component, event, helper,recordId,objectName);
                    component.set('v.isRender',true);
                }
                else
                {
                    component.set('v.isRender',false);
                }

            })
            .catch(function(error) {
                console.log(error);
            });
        }
    },

    onClickHandle : function(component, event, helper) {
        //console.log(event.target.getAttribute('id'));
        helper.startSpinner(component);
        var serviceTimeOut = component.get('v.serviceTimeOut');
        var employeeId = component.get('v.employeeId');
        var phoneNum = event.target.getAttribute('id');

        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
        
        var action = component.get('c.clickToCallAPI');
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "phoneNum" : phoneNum
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('state ',state)
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                // console.log('result:',result); 
                // console.log('result:',result.status); 
                if(result)
                {
                    if(result.status == "ERROR")
                    {
                        helper.showToast(component, event, helper,'error','Error!!',$A.get("$Label.c.ERR001"));
                        helper.stopSpinner(component);  
                    }
                    else if(result.status == "SUCCESS")
                    {
                        helper.showToast(component, event, helper,'success','Success!!','Success');
                        //Set time out 
                        window.setTimeout(function(){
                            //console.log('Set timeout');
                            helper.sendEventToStopCall(component, event, helper,employeeId);
                        }, serviceTimeOut);                

                    }  
                    else if(result.status == "TIME OUT")
                    {
                        helper.showToast(component, event, helper,'error','Error!!',$A.get("$Label.c.Product_Holding_Timeout"));
                        helper.stopSpinner(component);     
                    }                                      
                }  
                else
                {
                    helper.showToast(component, event, helper,'error','Error!!',$A.get("$Label.c.ERR001"));
                }
                //component.set('v.isLoading', true);           
            }
            else
            {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);
                helper.showToast(component, event, helper,'error','Error!!!',$A.get("$Label.c.ERR001"));
                helper.stopSpinner(component);  
            }         
        });
        
        $A.enqueueAction(action);
    },
      
    handleEvent : function(component, event, helper){
        var recordId_event = event.getParam("recordId"); 
        //console.log("recordId_event:"+recordId_event);
        
        if(recordId_event != null)
        {
            component.set("v.recordId",recordId_event);
            if(recordId_event.substring(0, 3) == '00v')
            {
                objectName = 'CampaignMember';
                component.set('v.iconName','standard:campaign_members');
                component.set('v.iconText','CampaignMember');
            }
  
            if(recordId_event && objectName)
            {
                helper.getFieldPhone(component, event, helper,recordId_event,objectName);
                component.set('v.isRender',true);
            }
            else
            {
                component.set('v.isRender',false);
            }
        }
    },

    
})