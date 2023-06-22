({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    startSpinner: function (component) {
        component.set('v.isRerender', true);
    },
    stopSpinner: function (component) {
        component.set('v.isRerender', false);
    },
    getPicklist: function(component, event, helper){
        var action = component.get('c.getPicklist');
        action.setCallback(this, function (response) {
            var returnValues = response.getReturnValue();
            console.log('getPicklist: ',returnValues);
            component.set('v.StatusPicklist',returnValues);
            
        });
        $A.enqueueAction(action);
    },
    userRecordAccess: function (component, event, helper) {
        var action = component.get('c.getCheckPermissionRecord')
        action.setParams({
            'recordId': component.get('v.recordId')
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var isRecordAccess = response.getReturnValue();
                console.log(isRecordAccess);
                component.set('v.isCaseRecordAccess', isRecordAccess);
                if (!isRecordAccess) {
                    var label = $A.get("{!$Label.c.Case_Edit_NotAuthorizedMsg}");
                    helper.displayErrorMeassge(component, event, [{
                        header: 'ข้อผิดพลาด',
                        message: label,
                    }], true);
                    helper.stopSpinner(component);
                }
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    displayErrorMeassge: function (component, event, errors, isDisplay) {
        if (isDisplay) {
            component.set('v.errorsDisplay.errors', errors.reduce((list, error) => {
                list.push({
                    'errorHeader': error.header,
                    'errorMessage': error.message,
                });
                return list;
            }, []));
        }
        component.set('v.errorsDisplay.isDisplay', isDisplay);
    },
    displayErrorMeassge2: function (component, event, errors, isDisplay) {
        if (isDisplay) {
            component.set('v.errorsDisplay2.errors', errors.reduce((list, error) => {
                list.push({
                    'errorHeader': error.header,
                    'errorMessage': error.message,
                });
                return list;
            }, []));
        }
        component.set('v.errorsDisplay2.isDisplay', isDisplay);
    },
    getClosedCaseWarningMessage: function(component, event, helper){
        var action = component.get("c.getClosedCaseWarningMessage");
        action.setCallback(this, function (response) {
            var state = response.getState();
            var returnValues = response.getReturnValue();
            console.log('returnValues: ',returnValues);
            
            if (state === 'SUCCESS' && returnValues != null){
                component.set('v.warningMessageMap',returnValues);
            }
        });
        $A.enqueueAction(action);
    },
    isAllowEdit: function(component, event, helper){
        var action = component.get('c.isAllowEdit');
        var recordId = component.get('v.recordId');
        var label = $A.get("{!$Label.c.Case_Edit_NotAuthorizedMsg}");
        action.setParams({
            'caseId':recordId
        });
        action.setCallback(this , function(response){
            var returnValues = response.getReturnValue();
            if (returnValues){
                component.set('v.isAllowEdit',returnValues);
                helper.displayErrorMeassge2(component, event, [{
                    header: 'มีสิทธิในการใช้งานไม่เพียงพอ',
                    message: label,
                }], true);
            }
        });
        $A.enqueueAction(action);
    },
    

})