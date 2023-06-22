({
    showToast : function(component, event, helper,type,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },

    getCurrentUser : function (component, event, helper) {

        var action = component.get('c.getCurrentUser');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                //console.log('result:',result);
                if(result)
                {
                    //console.log('result:',result.Employee_ID__c);
                    helper.subscribe(component, event, helper,result.Employee_ID__c);
                    component.set('v.employeeId', result.Employee_ID__c);
                }
            }
            else{
                console.log(state);               
            }
        });

        $A.enqueueAction(action);

    },
    
    getFieldPhone : function(component, event, helper,recordId,objectName) {
 		helper.startSpinner(component);
        var action = component.get('c.getFieldTypePhone');
        action.setParams({
            "recordId": recordId,
            "objectName" : objectName
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('state ',state)
            if (state === "SUCCESS") {
                
                var result =  response.getReturnValue();   
   				//console.log('result ',result);
                if(result && result.length > 0)
                {
                    //console.log('result ',result);
                    //component.set('v.fieldList',Object.values(result[0]));
                    const resultMap = new Map(Object.entries(result[0]));
                    //console.log(resultMap);
                    
                    
                    helper.getFieldLabel(component,event,helper,objectName,resultMap);
                    
                    var size = 0;
                    if(resultMap.size >= 0)
                    {
                        size = resultMap.size-2;
                    }
                    //console.log("size:"+resultMap.size);
                    component.set('v.fieldListSize',size);
                }
                
                helper.stopSpinner(component);
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);
            }

        });
        
        $A.enqueueAction(action);
    },
    
    getFieldLabel: function (component,event,helper,objectName,resultMap) {
        
        var action = component.get('c.getFieldLabel');
        action.setParams({
            "objectName" : objectName
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('state ',state)
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                //console.log('label:',result);              
                var fieldList = [];
                
                if(result && result != null)
                {
                    const labelMap = new Map(Object.entries(result));
                    //console.log(labelMap);               
                    resultMap.forEach(function(value, key) {
                        //console.log(key + ' = ' + value)                   
                        if(labelMap.has(key))
                        {
                            //console.log(labelMap.get(key.toLowerCase()));                       
                            fieldList.push({
                                "label": labelMap.get(key),
                                "value": value
                                        });     
                        }
                        else
                        {
                            fieldList.push({
                                "label": key,
                                "value": value
                            }); 
                        }                   
                    });
                    //console.log('fieldList:',fieldList);
                    component.set('v.fieldList',fieldList);     
                }
            }         
        });
        
        $A.enqueueAction(action);
    },

     // Invokes the subscribe method on the empApi component
     subscribe : function(component, event, helper,current_empId) {
        // Get the empApi component
        const empApi = component.find('empApi');
        // Get the channel from the input box
        const channel = component.get('v.channel');
        // Replay option to get new events
        const replayId = -1;

        // var current_empId = component.get('v.employeeId');
        //console.log('current_empId: ',current_empId);
        //console.log('channel ', channel);
        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            //console.log('Received event ', JSON.stringify(eventReceived));
            //console.log('payload: ',eventReceived.data.payload);

            if(eventReceived.data.payload.Employee_Id__c)
            {
                var employee_Id  = eventReceived.data.payload.Employee_Id__c;
                //console.log('employee_Id: ',employee_Id);
                //console.log('current_empId: ',current_empId);
                if(employee_Id == current_empId)
                {
                    helper.stopSpinner(component);
                }
            }
        }))
        .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            //console.log('Subscribed to channel ', subscription.channel);
            // Save subscription to unsubscribe later
            component.set('v.subscription', subscription);
        });
    },

    getTimeOut : function (component, event, helper) 
    {
        var action = component.get('c.getTimeOut');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.serviceTimeOut',result);
                //console.log('result:',result);

            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);            
            }
        });

        $A.enqueueAction(action);

    },

    sendEventToStopCall : function (component, event, helper, empId) 
    {
        var action = component.get('c.publishC2CEvent');
        action.setParams({
            "empId" : empId,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){    
                //console.log('Send Event');      
                //helper.showToast(component, event, helper,'error','Error!!',$A.get("$Label.c.Product_Holding_Timeout"));
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);              
            }
        });
        $A.enqueueAction(action);

    },   

})