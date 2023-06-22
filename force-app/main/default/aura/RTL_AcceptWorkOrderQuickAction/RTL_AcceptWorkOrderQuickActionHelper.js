({
    displayToast: function (component, type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },

    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },

    getCurrentUser: function (component, event, helper) {

        var action = component.get('c.getCurrentUser');

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null)
                {
                    // component.set('v.userObj',result);      
                    console.log('userObj:',result); 
                    helper.accpetWorkOrder(component, event, helper,result);     
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    
    },

    accpetWorkOrder: function (component, event, helper,userObj) {
        var recordId = component.get('v.recordId');
        console.log('recordId:',recordId);
        var isOnce = component.get('v.isOnce');
        var workOrderObj = component.get('v.workOrderObj');
              
        console.log('workOrderObj:',workOrderObj);
        console.log('OwnerId', workOrderObj.OwnerId);  


        var isBranchInQueue = component.get('v.isBranchInQueue');

        if (workOrderObj && isOnce) {
            component.set('v.isOnce', !isOnce);
            // helper.stopSpinner(component);
            console.log('isBranchInQueue', isBranchInQueue);            
          
            if(workOrderObj.OwnerId == userObj.Id)
            {
                helper.displayToast(component, 'Error', $A.get("$Label.c.WorkOrder_Accept_AlreadyOwner"));
                helper.stopSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (workOrderObj.OwnerId.startsWith('00G'))
            {
                
                helper.getGroupMember(component, event, helper,userObj);

                
            }          
            else{
                helper.displayToast(component, 'Error', $A.get("$Label.c.WorkOrder_Accept_Error"));
                helper.stopSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
            }      
        }
    },

    getGroupMember: function (component, event, helper,userObj) {

        var workOrderObj = component.get('v.workOrderObj');

        var action = component.get('c.getGroupMember');
        action.setParams({
            groupId: workOrderObj.OwnerId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null)
                {
                    component.set('v.groupMember',result.DeveloperName);            
                }
                console.log('groupMember result:',result);
                if(result)
                {
                    if(result.length > 0)
                    {
                        helper.checkRoleId(component, event, helper,result,userObj);
                    }
                    else
                    {
                        helper.getBranchDevName(component, event, helper,userObj);
                    }
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    
    },

    getBranchDevName: function (component, event, helper,userObj) {
        // var recordId = component.get('v.recordId');
        var workOrderObj = component.get('v.workOrderObj');
        var action = component.get('c.checkBranch');
        action.setParams({
            ownerId: workOrderObj.OwnerId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null)
                {
                    var inQueue = false
                    console.log('Branch:',result);
                    result.forEach(group => {
                        if(group.includes(userObj.RTL_Branch_Code__c))
                        {
                            inQueue = true
                        }
                    }); 
                    
                    if(inQueue)
                    {
                        helper.checkBranch(component, event, helper);
                    }
                    else
                    {
                        helper.displayToast(component, 'Error', $A.get("$Label.c.WorkOrder_Accept_Error_NotAllowed"));
                        helper.stopSpinner(component);
                        $A.get("e.force:closeQuickAction").fire();     
                    }
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);  
    },

    checkRoleId : function(component,event,helper,groupList,userObj){
        var recordId = component.get('v.recordId');
        // var userObj = component.get('v.userObj');
        console.log('checkRoleId');
        console.log('IngroupList',groupList.includes(userObj.UserRole.DeveloperName));
        if(groupList.includes(userObj.UserRole.DeveloperName))
        {
            var action = component.get('c.acceptWorkOrder');
            action.setParams({
                workOrderId: recordId,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    console.log('result:',result);
                    if (result == "Success") {
                        helper.displayToast(component, 'Success', $A.get("$Label.c.WorkOrder_Accept_Success"));             
                        $A.get('e.force:refreshView').fire();
                    } else {
                        helper.displayToast(component, 'Error', $A.get("$Label.c.WorkOrder_Accept_Error_NotAllowed"));
                        helper.stopSpinner(component);
                        $A.get("e.force:closeQuickAction").fire();;
                    }

                    helper.stopSpinner(component);
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    var errors = response.getError();
                    errors.forEach(error => console.log(error.message));
                    helper.stopSpinner(component);
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            helper.displayToast(component, 'Error', $A.get("$Label.c.WorkOrder_Accept_Error_NotAllowed"));
            helper.stopSpinner(component);
            $A.get("e.force:closeQuickAction").fire();     
        }
    },

    checkBranch : function(component,event,helper)
    {   
        var recordId = component.get('v.recordId');
        var action = component.get('c.acceptWorkOrder');
        action.setParams({
            workOrderId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (result == "Success") {
                    helper.displayToast(component, 'Success', $A.get("$Label.c.WorkOrder_Accept_Success"));
                    $A.get('e.force:refreshView').fire();
                } else {
                    helper.displayToast(component, 'Error', result);
                    $A.get("e.force:closeQuickAction").fire();;
                }

                helper.stopSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);  
    }
    

})