({
    doInit: function (component, evnet, helper) {
        // helper.startSpinner(component);
        var leadRecordId = component.get('v.leadObjId');
        var taskObj = component.get('v.taskObj');

        // console.log(helper.parseObj(component.get('v.leadObj')));
        console.log('leadRecordId :: ', leadRecordId);
        // console.log(helper.parseObj(taskObj));

        var actionPromise = new Promise(function (resolve, reject) {
            var action = component.get("c.getTaskValues");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var taskFieldValues = response.getReturnValue();
                    component.set('v.MainTaskValues', taskFieldValues.mainTaskValues);
                    component.set('v.SubTaskMap', taskFieldValues.subjectTaskValues);
                    component.set('v.Status', taskFieldValues.statusValues);
                    component.set('v.Priority', taskFieldValues.priorityValues);
                    resolve(taskFieldValues);

                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    reject(Error('Invalid value: Task Object'))
                }
            });
            $A.enqueueAction(action);

        });
        actionPromise.then(
            function (taskFieldValues) {
                if (leadRecordId) {
                    var action = component.get("c.getMyTaskLastedInforamtion");
                    action.setParams({
                        "leadObjId": leadRecordId,
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var taskObj = response.getReturnValue();

                            if (!taskObj) {
                                helper.setDefaultValue(component);
                                // helper.stopSpinner(component);
                            } else {

                                component.set('v.SubTaskValues', taskFieldValues.subjectTaskValues[taskObj.Main_Task__c]);
                                component.set('v.isSubTaskValues', true);
                                component.set('v.taskObj', taskObj);
                                component.set('v.isDisabledField', true);
                                // helper.stopSpinner(component);
                            }

                        } else if (state === "ERROR") {
                            helper.stopSpinner(component);

                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " +
                                        errors[0].message);
                                }
                                helper.displayToast(component, 'Error', errors[0].message);
                            } else {
                                console.log("Unknown error");
                            }
                        }
                    });
                    $A.enqueueAction(action);
                }
            },
            function (error) {
                // helper.stopSpinner(component);
                helper.displayToast(component, "Warning", error.message);
            });
    },
    onRenderSubTask: function (component, event, helper) {
        var isSubTaskValues = component.get('v.isSubTaskValues');
        if (isSubTaskValues) {
            component.set('v.isSubTaskValues', false);
            component.set('v.taskObj', component.get('v.taskObj'));
        }
    },
    onChangeMainTask: function (component, event, helper) {
        var Main_Task__c = event.getSource().get("v.value");
        var SubTaskMap = component.get('v.SubTaskMap');
        component.set('v.SubTaskValues', SubTaskMap[Main_Task__c]);
        // console.log(SubTaskMap[Main_Task__c]);
    },
    onValidFieldHandler: function (component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            return helper.validateField(component, event, helper);
        }
    },
    onSavingLogACall: function (component, event, helper) {
        var taskObj = component.get('v.taskObj');
        // console.log(helper.parseObj(taskObj));

        var params = event.getParams().arguments;
        var callback;
        if (params) callback = params.callback;

        if (helper.validateField(component, event, helper)) {
            var action = component.get("c.UpdateTaskRecord");
            action.setParams({
                "taskObj": taskObj,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var getReturnValue = response.getReturnValue();
                    component.set('v.isDisabledField', true);
                    callback(getReturnValue);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
        // else {
        //     if (callback) callback(taskObj);
        // }
    },

})