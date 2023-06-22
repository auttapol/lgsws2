({
    getHistoryDetailsWithLimit : function(component, event, helper){
        var action = component.get('c.getHistoryDetailsWithLimit');
        action.setParams({
            recordId: component.get('v.recordId'),
            numOfElement : 2
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                // console.log('displayData:',result);
                if(result)
                {
                    component.set('v.displayData',result);                 
                }

                component.set('v.loaded',false);
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('Error:',message);
                //helper.displayToast(component,helper,'Error','error',message);  
                
                component.set('v.loaded',false);   
            }
        })

        $A.enqueueAction(action);

    },
})