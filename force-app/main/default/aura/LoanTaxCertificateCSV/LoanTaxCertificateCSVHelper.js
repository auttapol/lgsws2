({
    getData: function(component, event, helper) {
        var action = component.get("c.getdataosc01");
        var accId = '';
       
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        var needRetry = false;

        if(component.get('v.recordId')){
            accId = component.get('v.recordId');
        }else{
            var pageRef = component.get("v.pageReference")
            accId = pageRef.state.c__accIdParameter;

            //accId = component.get('v.accIdParameter');
        }
        action.setParams({
            "recordId": accId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    needRetry =  result.statusDesc01 == "Unauthorized" ? true : false;
                    if(needRetry){
                        this.retryOSC01(component, event, helper, numOfRetryTime);
                    }else{
                        component.set('v.loading', false);
                        component.set('v.isError', result.statusDesc01 == "ERROR" ? true : false);
                        component.set('v.is01Timeout', result.statusDesc01 == "TIMEOUT" ? true : false);
                        component.set('v.hasPermission', result.dataPartitionPermission == true ? true : false);

                        component.set('v.taxList', result.loanWrapper != null ? result.loanWrapper : null);
                    }
                    // Add Water Mark
                    var watermarkHTML = result.employeeId != null ? result.employeeId : null;
                    var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(240,240,240)' font-size='25' font-family='Helvetica' weight='700'>" + watermarkHTML + "</text></svg>");
                    var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                    component.set('v.waterMarkImage', bg);
                }

            } else {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.displayToast(component, 'Error', message);
                component.set('v.loading', false);
            }
        });
        $A.enqueueAction(action);
    },

    displayToast: function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },

    retryOSC01: function(component, event, helper, numOfRetryTime){
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        numOfRetryTime -= 1;
        setTimeout(()=>{
            var action = component.get("c.getdataosc01");
            var needRetry = false;

            action.setParams({
                "recordId": component.get('v.recordId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result != null) {
                        needRetry =  (result.statusDesc01 == "Unauthorized") ? true : false;
                        if(numOfRetryTime > 0 && needRetry == true){
                            this.retryOSC01(component, event, helper, numOfRetryTime);
                        }
                        else{
                            component.set('v.loading', false);
                            if(needRetry == true){
                                component.set('v.isError', true);
                                component.set('v.is01Timeout', result.statusDesc01 == "TIMEOUT" ? true : false);
                                component.set('v.hasPermission', result.dataPartitionPermission == true ? true : false);
                                component.set('v.taxList', result.loanWrapper != null ? result.loanWrapper : null); 
                            }
                            else{
                                component.set('v.taxList', result.loanWrapper != null ? result.loanWrapper : null); 
                                component.set('v.isError', result.statusDesc01 == "ERROR" ? true : false);
                                component.set('v.is01Timeout', result.statusDesc01 == "TIMEOUT" ? true : false);
                                component.set('v.hasPermission', result.dataPartitionPermission == true ? true : false);
                            }
                            
                        }
                    }
                    // Add Water Mark
                    var watermarkHTML = result.employeeId != null ? result.employeeId : null;
                    var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                        "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                    var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                    component.set('v.waterMarkImage', bg);
                } else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    helper.displayToast(component, 'Error', message);
                    component.set('v.loading', false);
                }
            });
            $A.enqueueAction(action);
        }, retrySetTimeOut)
     
    },
})