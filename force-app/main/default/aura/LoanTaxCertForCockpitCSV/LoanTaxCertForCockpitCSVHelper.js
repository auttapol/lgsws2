({
    getData: function(component, event, helper) {
        var action = component.get("c.getdataosc01");

        action.setParams({
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    component.set('v.isError', result.statusDesc01 == "ERROR" ? true : false);
                    component.set('v.is01Timeout', result.statusDesc01 == "TIMEOUT" ? true : false);
                    component.set('v.hasPermission', result.dataPartitionPermission == true ? true : false);

                    if(result.loanWrapper != null){
                        component.set('v.taxList', result.loanWrapper);
                    }else{
                        component.set('v.taxList', null);
                        component.set('v.nodata', 'No data. / ไม่มีข้อมูล');
                    }
                    // component.set('v.taxList', result.loanWrapper != null ? result.loanWrapper : null);
                
                    // Add Water Mark
                    var watermarkHTML = result.employeeId != null ? result.employeeId : null;
                    // var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    //     "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                    var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(240,240,240)' font-size='25' font-family='Helvetica' weight='700'>" + watermarkHTML + "</text></svg>");
                    var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                    component.set('v.waterMarkImage', bg);
                    component.set('v.loading', false);
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

})