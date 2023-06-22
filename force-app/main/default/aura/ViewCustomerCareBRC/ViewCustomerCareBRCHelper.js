({
	getDevice : function() {
		var device = $A.get("$Browser.formFactor");
        return device;
	},

    getReportId : function(component, event, helper) {
		var action = component.get('c.getReportId');
        var reportName = component.get('v.reportName');
		console.log('--- Do getReportId ---'); 
        action.setParams({
            reportName: reportName
        });
        action.setCallback(this, function (response) {
        	var state = response.getState();

			if(component.isValid() && state === 'SUCCESS'){
				var result = response.getReturnValue();
				if(result != null){
					console.log('Current reportId: ', result); 
					component.set('v.reportId', result);
				}
				else {
					var errors = response.getError();
					errors.forEach(error => console.log(error.message));
					$A.get("e.force:closeQuickAction").fire();
				}
			}
        });
        $A.enqueueAction(action);
	},

	getCurrentUser: function (component, event, helper) {
        var action = component.get('c.getCurrentUser');
		console.log('--- Do getCurrentUser ---'); 
        action.setCallback(this, function (response) {
        	var state = response.getState();

			if(component.isValid() && state === 'SUCCESS'){
				var result = response.getReturnValue();
				if(result != null){
					console.log('userObj: ', result); 
					component.set('v.userObj', result);
					
					helper.getGroupId(component, event, helper);
					//helper.getGroupMember(component, event, helper, result); 
				}
				else {
					var errors = response.getError();
					errors.forEach(error => console.log(error.message));
					$A.get("e.force:closeQuickAction").fire();
				}
				
			}
        });

        $A.enqueueAction(action);
    
    },

	getGroupId: function (component, event, helper) {
        var action = component.get('c.getGroupId');
		var groupName = component.get('v.groupNameBRC');
		console.log('--- Do getGroupId ---'); 
        action.setParams({
            groupName: groupName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null)
                {
					console.log('groupObj: ', result); 
					component.set('v.groupObj', result);    
					helper.getGroupMember(component, event, helper, result);       
                }

            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                $A.get("e.force:closeQuickAction").fire();
            }
        });

        $A.enqueueAction(action);
    
    },

	getGroupMember: function (component, event, helper) {
		var groupObj = component.get('v.groupObj');
		var userObj = component.get('v.userObj');
        var reportId = component.get('v.reportId');
        var device = helper.getDevice();
        component.set('v.deviceType', device);

		console.log('--- Do getGroupMember ---'); 
        
        if(device == "DESKTOP"){
            var action = component.get('c.getGroupMemberIdList');
            action.setParams({
                groupId: groupObj.Id,
                userObj: userObj,
                userRoleId: userObj.UserRoleId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if(result == true)
                    {
                        //open report  
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/lightning/r/Report/"+reportId+"/view?fv2="+userObj.FirstName+" "+userObj.LastName
                        });
                        urlEvent.fire();
                    
                        //close sub tab
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({tabId: focusedTabId});
                        });
                        
                    } else {
                        component.set('v.isNotAccess', true);
                    }

                } else {
                    var errors = response.getError();
                    errors.forEach(error => console.log(error.message));
                    $A.get("e.force:closeQuickAction").fire();
                }
            });

            $A.enqueueAction(action);
        }
        
    
    }

})