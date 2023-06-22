({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    popupFromUniqueKey : function(component, event, helper,unique_key, task_id, callback_id){

        let action = component.get('c.preparePopupByUniqueKey');
        action.setParams({
            'unique_key': unique_key,
            'task_id': task_id,
            'callback_id': callback_id
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                let data = response.getReturnValue();
                if(data.type === 'CampaignMember'){
                    console.log('CampaignMember');
                    let urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/one/one.app#' + btoa(JSON.stringify({
                            "componentDef": "c:CampaignMember_Main",
                            "attributes": {
                                "recordId": data.id,
                                "mode" : 'Edit' 
                            }
                        }))
                    });
                    urlEvent.fire();
                    
                }
                if(data.type === 'Lead' || data.type === 'RTL_Referral__c'){
                    console.log('Lead or Referral');
                    component.find("navService").navigate({
                        'type': 'standard__recordPage',
                        'attributes': {
                            'recordId': data.id,
                            'actionName': 'view'
                        }
                    }, false);
                }
                console.log('preparePopupByUniqueKey', response.getReturnValue().id);
            }
        });

        $A.enqueueAction(action);
    },
    transferFromUniqueKey : function(component, event, helper, task_id, original_task){
        console.log('transfer '+ task_id);
        let action = component.get('c.prepareTransfer');
        action.setParams({
            'task_id': task_id,
            'original_task': original_task
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                let data = response.getReturnValue();
                // if(data.type === 'CampaignMember'){

                //     let urlEvent = $A.get("e.force:navigateToURL");
                //     urlEvent.setParams({
                //     "url": '/one/one.app#' + btoa(JSON.stringify({
                //             "componentDef": "c:CampaignMember_Main",
                //             "attributes": {
                //                 "recordId": data.id,
                //                 "mode" : 'Edit' 
                //             }
                //         }))
                //     });
                //     urlEvent.fire();

                // }
                /*else*/ if(data.type === 'Lead' || data.type === 'RTL_Referral__c'){
                    component.find("navService").navigate({
                        'type': 'standard__recordPage',
                        'attributes': {
                            'recordId': data.id,
                            'actionName': 'view'
                        }
                    }, false);
                }
                console.log(response.getReturnValue().id);
            }
        });

        $A.enqueueAction(action);
    },
    subscribeEvent : function(component, event, helper, agentId){
        console.log('subscribe');
        const empApi = component.find('empApi');
        var cmpTarget = component.find('status');
        var isSuccess = false;
        // console.log(agentId);
        
        // empApi.onError($A.getCallback(error => {
        //     // Error can be any type of error (subscribe, unsubscribe...)
        //     console.error('EMP API error: ', error);
        //     $A.util.addClass(cmpTarget, 'icon-status-offline');
        // }));

        const channel = component.get('v.channel');
        // const transfer_channel = component.get('v.transfer_channel');
        // const outbound_channel = component.get('v.outbound_channel');
        // console.log(channel);
        const replayId = -1;

        
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived));
            console.log('data ', JSON.stringify(eventReceived.data));
            console.log('payload: '+ JSON.stringify(eventReceived.data.payload));

            // const cust_id  = eventReceived.data.payload.TMB_Cust_ID__c;
            // if(eventReceived.data.payload.Employee_ID__c === agentId){
            //     component.set('v.cdata', eventReceived.data.payload); 
            //     component.set('v.incomingLog', eventReceived.data.payload);
            //     component.set('v.incomingChannel', channel);   
            // }
            if(eventReceived.data.sobject.Channel__c == 'Popup'){
                component.set('v.cdata', eventReceived.data.sobject); 
                component.set('v.incomingLog', eventReceived.data.sobject);  
            }
            else if(eventReceived.data.sobject.Channel__c == 'Transfer'){
                component.set('v.transfer_data', eventReceived.data.sobject);
                component.set('v.incomingLog', eventReceived.data.sobject);
            }
            // else if(eventReceived.data.sobject.Channel__c == 'Outbound'){
            //     component.set('v.outbound_data', eventReceived.data.sobject);
            //     component.set('v.incomingLog', eventReceived.data.sobject);
            // }

        }))
        .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            console.log('Subscribed to channel ', subscription.channel);
            // Save subscription to unsubscribe later
            component.set('v.subscription_Inbound', subscription);

            $A.util.removeClass(cmpTarget, 'icon-status-offline');
            $A.util.addClass(cmpTarget, 'icon-status-online');
            component.set('v.isSuccess',true);
        });

        
        // empApi.subscribe(transfer_channel, replayId, $A.getCallback(eventReceived => {
        //     // Process event (this is called each time we receive an event)
        //     console.log('Received event ', JSON.stringify(eventReceived));
        //     console.log('payload: '+eventReceived.data.payload);

        //     // const cust_id  = eventReceived.data.payload.TMB_Cust_ID__c;
        //     if(eventReceived.data.payload.Target_Agent_ID__c === agentId){
        //         component.set('v.transfer_data', eventReceived.data.payload);
        //     }

        // }))
        // .then(subscription => {
        //     // Confirm that we have subscribed to the event channel.
        //     // We haven't received an event yet.
        //     console.log('Subscribed to channel ', subscription.channel);
        //     // Save subscription to unsubscribe later
        //     component.set('v.subscription_Transfer', subscription);
        // });

        /*empApi.subscribe(outbound_channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived.data.payload));
            console.log('payload: '+eventReceived.data.payload);

            // const cust_id  = eventReceived.data.payload.TMB_Cust_ID__c;
            if(eventReceived.data.payload.Employee_ID__c === agentId){
                component.set('v.outbound_data', eventReceived.data.payload);
            }

        }))
        .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            console.log('Subscribed to channel ', subscription.channel);
            // Save subscription to unsubscribe later
            component.set('v.subscription_Outbound', subscription);
        });*/
        return isSuccess;
    },

    // Invokes the unsubscribe method on the empApi component
    unsubscribe : function(component, event, helper) 
    {
        var cmpTarget = component.find('status');
        return new Promise(function(resolve, reject){
                console.log('unsubscribe');
                // Get the empApi component
                const empApi = component.find('empApi');
                // Get the subscription that we saved when subscribing
                const subscription_Inbound = component.get('v.subscription_Inbound');
                // const subscription_Transfer = component.get('v.subscription_Transfer');
                // const subscription_Outbound = component.get('v.subscription_Outbound');
                // Unsubscribe from event          
                empApi.unsubscribe(subscription_Inbound, $A.getCallback(unsubscribed => {
                    // Confirm that we have unsubscribed from the event channel
                    console.log('Unsubscribed from channel '+ unsubscribed.subscription);
                    component.set('v.subscription_Inbound', null);

                    $A.util.removeClass(cmpTarget, 'icon-status-online');
                    $A.util.addClass(cmpTarget, 'icon-status-offline');
                }));

                // empApi.unsubscribe(subscription_Transfer, $A.getCallback(unsubscribed => {
                //     // Confirm that we have unsubscribed from the event channel
                //     console.log('Unsubscribed from channel '+ unsubscribed.subscription);
                //     component.set('v.subscription_Transfer', null);
                // }));

                /*empApi.unsubscribe(subscription_Outbound, $A.getCallback(unsubscribed => {
                    // Confirm that we have unsubscribed from the event channel
                    console.log('Unsubscribed from channel '+ unsubscribed.subscription);
                    component.set('v.subscription_Outbound', null);
                }));*/

                resolve(true);
         });
    }
})