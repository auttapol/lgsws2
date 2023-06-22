({
    displayToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        if(type == 'Success')
        {
            toastEvent.setParams({
            type: type,
            message: message,
            duration: 3000

            });
            toastEvent.fire();
        }
        else if(type == 'Error')
        {
            toastEvent.setParams({
                type: type,
                message: message,
                mode: 'sticky',
    
                });
                toastEvent.fire();
        }
    },
    
    getEclient: function (component, event, helper) {
        var eclientId = component.get("v.recordId");
		var action = component.get("c.getEclient");

		action.setParams({
			"eclientId": eclientId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var eClient =  response.getReturnValue();
               
				component.set("v.eClientObj",eClient);
            }
		});
		$A.enqueueAction(action);

    },
    

    upload: function(component, file, fileContents,helper) {
        var eclient = component.get("v.eClientObj");
        var action = component.get("c.saveFile");
   
        component.set("v.Spinner", true);
        component.set("v.uploadStatus",null);
       
        action.setParams({
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type,
            eclientId: eclient.Id,
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                this.setTimeInterval(component, event, helper);
            }
            else
            {    
                helper.displayToast(component, "Error", $A.get("$Label.c.ECM_Upload_Fail_Msg"));
                component.set("v.Spinner", false);
            }
        });

        $A.run(function() {
            $A.enqueueAction(action); 
        });
    },

    setTimeInterval : function(component, event, helper) { 
        var count = 0;
        
        var timeOut = component.get("v.timeOut");

        var interval = window.setInterval(
            $A.getCallback(function() { 
               
                helper.getApexJob(component, event, helper);
                var status = component.get("v.uploadStatus");
 
                if(count > timeOut[0]/timeOut[1])
                {
                    window.clearInterval(interval);
                    helper.displayToast(component, "Error", $A.get("$Label.c.ECM_Upload_Timeout_Msg"));
                    component.set("v.Spinner", false);
                }
                else
                {   
                    if(status != null)
                    {
                        window.clearInterval(interval);
                        component.set("v.Spinner", false);
                    } 
                    if(status != 'Failed')
                    {
                        helper.uploadStatus(component, event, helper);
                        count++;
                    }
                }

                
            }), timeOut[1]
        );      
    },

    uploadStatus : function (component, event, helper) {
        var eclientId = component.get("v.recordId");
        var uploadStatus = component.get("v.uploadStatus");
        var action = component.get("c.getOnlineLog");

		action.setParams({
			"eclientId": eclientId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var onLog =  response.getReturnValue();
                
                if(onLog != null)
                {               
                    if(uploadStatus != 'Success' || uploadStatus != 'Fail')
                    {  
                        if(onLog.RTL_Is_Success__c == true )
                        {                          
                            component.set("v.uploadStatus",'Success');
                            component.set("v.Spinner", false);
                            component.set("v.fileName",'');
                            component.set("v.fileObj",null);
                            helper.displayToast(component, "Success", $A.get("$Label.c.ECM_Upload_Success_Msg"));
                            helper.getEclient(component,event,helper);
                        }
                        else if(onLog.RTL_Is_Success__c == false )
                        {
                            component.set("v.uploadStatus",'Fail');
                            component.set("v.Spinner", false);
                            component.set("v.fileName",'');
                            component.set("v.fileObj",null);
                            helper.displayToast(component, "Error", $A.get("$Label.c.ECM_Upload_Fail_Msg"));
                        }
                    }
                }
            }
            else
            {
                helper.displayToast(component, "Error", $A.get("$Label.c.ECM_Upload_Fail_Msg"));
            }
        });      
		$A.enqueueAction(action);

    },

    getTimeOut : function (component,event,helper)
    {
        var action = component.get("c.ecmTimeOut");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 

                var timeout = response.getReturnValue(); 
                component.set("v.timeOut",timeout);
            }
        });
        $A.enqueueAction(action); 

    },

    getApexJob: function (component, event, helper) {
		var action = component.get("c.getApexJob");

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var apexStatus =  response.getReturnValue();
                
                if(apexStatus.Status != null)
                {
                    if(apexStatus.Status == 'Failed')
                    {
                        helper.displayToast(component, "Error", apexStatus.ExtendedStatus);
                        component.set("v.fileName",'');
                        component.set("v.fileObj",null);
                        component.set("v.uploadStatus",apexStatus.Status);
                        component.set("v.Spinner", false);
                    }
                    else if(apexStatus.Status == 'Processing')
                    {
                        component.set("v.uploadStatus",apexStatus.Status);

                    }
                    else if(apexStatus.Status == 'Completed')
                    {
                        component.set("v.uploadStatus",apexStatus.Status);
                    }

                }
			}
		});
		$A.enqueueAction(action);

    },

    getCurrentUser: function (component, event, helper) {
		var action = component.get("c.getCurrentUser");
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				component.set("v.currentUser", storeResponse);
			}
		});
		$A.enqueueAction(action);
	},

 })