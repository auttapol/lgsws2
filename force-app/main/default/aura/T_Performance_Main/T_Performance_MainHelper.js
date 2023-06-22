({
    onInit : function(component, event, helper) {
        var action = component.get('c.getUserInfo');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                console.log('userObj:',result);      
                component.set('v.userObj',result);
                if(result)
                {
                    if(result.user.RTL_Channel__c)
                    {
                        var channel = result.user.RTL_Channel__c == 'Branch' ? 'Branch' : 'RASC';
                        component.set('v.userType',channel); 
                        if (channel == 'Branch'){
                            component.set('v.branchCode',result.user.RTL_Branch_Code__c);
                        }
                        else{
                            component.set('v.branchCode',result.user.Zone_Code__c);
                        }
                        console.log('Debug usertype ',channel,component.get('v.branchCode'))
                    }
                    if(result.userChannel)
                    {
                        component.set("v.channel",result.userChannel);
                    }
                    component.set('v.renderPage',result.page);    
                }      
                console.log('renderPage:',component.get('v.renderPage'));   
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

    insertTermOfUseLog : function(component,event,helper){
        /* component.set('v.loaded',true); */
        var status = component.get('v.status');// at cmp
        var action = component.get('c.insertTermOfUseLog');// get function at apex
        action.setParams({
            "status" : status
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {               
                console.log('status',status)
                /* component.set('v.loaded', false); */
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

   
    // getWatermarkHTML : function(component) {
	// 	var action = component.get("c.getWatermarkHTML");
	// 	action.setCallback(this, function(response) {
	// 		var state = response.getState();
    //         if(state === "SUCCESS") {
    //         	var watermarkHTML = response.getReturnValue();
    //             // console.log('watermarkHTML: ', watermarkHTML);

    //             var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
    //                 "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
    //             var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

    //             console.log('watermarkHTML: ', bg);
    //             component.set('v.waterMarkImage', bg);
    //         } else if(state === 'ERROR') {
    //             console.log('STATE ERROR');
    //             console.log('error: ', response.error);
    //         } else {
    //             console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
    //         }
	// 	});
	// 	$A.enqueueAction(action);
	// },
})