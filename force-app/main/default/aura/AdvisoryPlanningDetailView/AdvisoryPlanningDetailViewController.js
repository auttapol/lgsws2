({
    doInit : function(component, event, helper) {
        var action = component.get('c.getWatermarkHTML');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var watermarkHTML = response.getReturnValue();
                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(230,230,230)'  font-family='-apple-system, BlinkMacSystemFont, Roboto, Helvetica, Arial, sans-serif' font-size='25' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";
                component.set('v.waterMarkImage', bg);

                var bgBody = "@media print { forcegenerated-adg-rollup_component___force-generated__flexipage_-record-page___-advisory_-planning_-record_-page___-advisory_-planning__c___-v-i-e-w .detail-panel-root .base-record-form-header-container { display: none !important; } }";
                bgBody +=    "forcegenerated-adg-rollup_component___force-generated__flexipage_-record-page___-advisory_-planning_-record_-page___-advisory_-planning__c___-v-i-e-w .detail-panel-root .base-record-form-header-container{ display: block; width: 100%; height: 100%; background-image: "+bg+"; }";
                $A.createComponent(
                    "aura:html", {
                        tag: "style",
                        body: bgBody
                    },
                    function(components, status, errorMessage){
                        //Add the new button to the body array
                        if (status === "SUCCESS") {
                            console.log('SUCCESS');
                            component.set("v.body", components);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                        }
                        else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                    }
                );
            } else {
                var errors = response.getError();
            }
        });

        $A.enqueueAction(action);
    }
})