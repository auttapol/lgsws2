({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    displayToast: function (type, message) {
        var duration = 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },

    checkRequestPermission : function(component, helper){
        var recordId = component.get('v.recordId');
        var action = component.get('c.getRequestPermission');
        var action2 = component.get('c.getApprover');

        action.setParams({
            "AccId": recordId,
        });

        action2.setParams({
            "AccId": recordId,
        });

        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    component.set('v.account', result);
                    $A.enqueueAction(action2);
                }
            }else if (response.getState() === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.isError', true);
                        component.set('v.errorMessage', errors[0].message);
                    }
                }
                helper.hideSpinner(component);
            }else {
                console.error(response);
                helper.hideSpinner(component);
            }
        });

        action2.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    result.forEach(element => {
                        if(element.Approver.FirstName == 'BI Team'){
                            element.Approver.Name = element.Approver.FirstName;
                        }
                    });
                    component.set('v.approverlst', result);
                    component.set('v.requestPermission', true);
                }
            }else if (response.getState() === "ERROR") {
                var errors = action2.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.requestPermission', false);
                        component.set('v.isError', true);
                        component.set('v.errorMessage', errors[0].message);
                    }
                }
            }else {
                console.error(response);
            }
            helper.hideSpinner(component);
        });

        if(recordId) $A.enqueueAction(action);
    },

    submitRequest : function(component, helper){
        helper.showSpinner(component);
        var action = component.get('c.submitRequest');

        var recordId = component.get('v.recordId');
        var remark = component.get('v.remark');
        var approvelst = component.get('v.approverlst');

        action.setParams({
            "accId": recordId,
            "remark": remark,
            "approvelst": approvelst,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                helper.displayToast('Success', 'Send request success.');
            }else if (state === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.isError', true);
                        component.set('v.errorMessage', errors[0].message);
                    }
                }
            } else {
                console.error(response);
            }
            component.set('v.requestPermission', false);
            helper.hideSpinner(component);
        });

        if(remark && remark.length > 100000){
            component.set('v.isError', true);
            component.set('v.errorMessage', 'Record can not be submitted due to Remark field has more than 100000 Characters.');
            helper.hideSpinner(component);
            return;
        }else{
            $A.enqueueAction(action);
        }
    },

    showSpinner : function(component) {
        component.set('v.isLoading', true); 
    },
     
    hideSpinner : function(component){
        component.set('v.isLoading', false);
    },
})