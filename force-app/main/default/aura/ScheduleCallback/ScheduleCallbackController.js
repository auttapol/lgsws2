({
    onInit: function (component, event, helper) {
        //component.set('v.task.Call_Back_Mode__c', 'Strict Agent');
        component.set('v.loaded', true);
        if (component.get('v.onQuickAction')) {
            component.set('v.iconName', 'utility:chevrondown');
            component.set('v.isExpanded', true);
            component.set('v.readonly', false);
        }
        else {
            component.set('v.iconName', 'utility:chevronright');
        }

        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var timeNow = $A.localizationService.formatDate(new Date(), "hh:mm:ss") + '.000';
        // console.log('timeNow:',timeNow);
        component.set('v.todayDate', today);
        component.set('v.timeNow', timeNow);

        helper.getTask(component, event, helper);
    },

    setTask: function (component, event, helper) {
        component.set('v.loaded', true);
        var task = component.get('v.task');
        var currentUser = component.get('v.currentUser');
        var user_language;
        if (task != null) {
            // console.log('currentUser:',currentUser);
            if (currentUser != null) {
                component.set('v.isExpanded', true);
                component.set('v.reschedule', true);
                user_language = currentUser.LanguageLocaleKey;
                // console.log('user_language:',user_language);

                // console.log(':',task);
                component.set('v.original_task', task);

                helper.setDateTime(component, event, helper, task, user_language);

                component.set('v.callback_number', task.Call_Number__c);
                component.set('v.callback_description', task.Description);
                component.set('v.callback_mode', task.Call_Back_Mode__c);

                // console.log('callback_time_label:',component.get('v.callback_time_label'));
                // console.log('callback_date_label:',component.get('v.callback_date_label'));

                component.set('v.loaded', false);
            }
        }
        else {
            component.set('v.loaded', false);
        }
    },

    changeState: function (component) {
        var iconName = component.get('v.iconName');
        if (iconName == 'utility:chevrondown') {
            component.set('v.iconName', 'utility:chevronright');
        }
        else {
            component.set('v.iconName', 'utility:chevrondown');
        }
        component.set('v.isExpanded', !component.get('v.isExpanded'));
    },

    onGroup: function (component, event, helper) {
        var selected = event.getSource().get("v.label");
        // console.log(selected);
    },
    modeChange: function (component, event, helper) {
        // console.log('modeChange', event.currentTarget.value);
        component.set('v.task.Call_Back_Mode__c', event.currentTarget.value);
    },
    handleSubmit: function (component, event, helper) {

        var isExpanded = component.get('v.isExpanded');

        if (isExpanded) {
            // console.log('submit...');
            // console.log(component.get('v.reschedule'))
            // console.log(!component.get('v.requiredFlag'))
            // console.log('reschedule', component.get('v.reschedule'))
            if (!component.get('v.requiredFlag')) {
                if (component.get('v.callback_date') || component.get('v.callback_time')) {
                    // console.log('submit...2');
                    component.set('v.requiredTime', true);
                    component.set('v.requiredDate', true);
                }
            }

            if (component.get('v.reschedule')) {
                // console.log('reschedule', component.get('v.task.Id'))
                helper.rescheduleCallback(component, event, helper)
            }
            else {
                // console.log('no reschedule')
                helper.scheduleCallback(component, event, helper)
            }
        }

    },
    requireAll: function (component, event, helper) {
        component.set('v.requiredDate', true)
        component.set('v.requiredTime', true)
        component.set('v.requiredFlag', true)
    },
    unrequireAll: function (component, event, helper) {
        component.set('v.requiredDate', false)
        component.set('v.requiredTime', false)
        component.set('v.requiredFlag', false)


        component.set('v.callback_date', '');
        component.set('v.callback_time', '');
        component.set('v.callback_number', '');
        component.set('v.callback_description', '');
        //component.set('v.task.Call_Back_Mode__c',''); 
    },
    cancelQuickAction: function (component, event, helper) {
        helper.closeQuickActionWindow(component, event, helper);
    },

    validate: function (component, event, helper) {
        var allValid = component.find('callbackForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allValid;
    },

    validateInput: function (component, event, helper) {

        // var now = new Date();
        // console.log('Time now:',now.getTime());
        // component.set('v.timeNow', now.getTime());

        var allValid = true;

        component.find('callbackForm').forEach(function (element, index) {
            //console.log('index:',index + 'element:',element.get('v.value'));
            if (index == 0 || index == 1 || index == 2) {
                if (element.get('v.value') == null || element.get('v.value') == '' || element.get('v.value') == undefined) {
                    allValid = false
                    helper.displayToast(component, helper, 'Error', 'error', $A.get("$Label.c.RTL_CampaignMemberEdit_CallBack_ErrMsg"));
                    $A.util.addClass(component.find('callbackForm')[index], "slds-has-error");
                }
            }

        });

        if (allValid) {
            allValid = helper.validateDateTime(component, event, helper);
        }

        // console.log('allValid1:',allValid);

        return allValid;
    },

    validateBusinessHour: function (component, event, helper) {
        var params = event.getParam('arguments');
        var callback;
        if (params) {
            callback = params.callback;
        }

        var checkBusinessHours = false;
        var callback_datetime = helper.transformDatetimeUnix(
            helper.transformDateToInput(component.get('v.callback_date')),
            component.get('v.callback_time')
        );

        // console.log('callback_datetime:',callback_datetime);
        // console.log('callback_date:',helper.transformDateToInput(component.get('v.callback_date')));
        // console.log('callback_time:',   component.get('v.callback_time'));
        var action = component.get('c.checkBusinessHours');
        action.setParams({
            "values": {
                "datetime": callback_datetime,
                "number": component.get('v.task.Call_Number__c'),
                "note": component.get('v.task.Description'),
                "mode": component.get('v.task.Call_Back_Mode__c'),
            },
            "businessName": 'CMOB Call Back Hours'
        });
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (state === 'SUCCESS') {
                checkBusinessHours = response.getReturnValue();
                // console.log('response:',response.getReturnValue()); 
                $A.util.removeClass(component.find('callbackForm')[0], "slds-has-error"); // remove red border
                $A.util.addClass(component.find('callbackForm')[0], "hide-error-message");
                $A.util.removeClass(component.find('callbackForm')[1], "slds-has-error"); // remove red border
                $A.util.addClass(component.find('callbackForm')[1], "hide-error-message");
                if (callback) callback(checkBusinessHours);
            }
            else {
                checkBusinessHours = false
                $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                $A.util.addClass(component.find('callbackForm')[2], "slds-has-error");
                let error = response.getError();
                helper.handleErrors(error);
                if (callback) callback(checkBusinessHours);
            }
        });

        $A.enqueueAction(action);
        // helper.checkBusinessHours(component, event, helper).then((res) => {

        // });
    },

    handleCallBackDate: function (component, event, helper) {
        // console.log('callback_date:',component.get('v.callback_date'));
        $A.util.removeClass(component.find('callbackForm')[0], "slds-has-error"); // remove red border
        $A.util.addClass(component.find('callbackForm')[0], "hide-error-message");
    },

    handleCallBackTime: function (component, event, helper) {
        // console.log('callback_date:',component.get('v.callback_time'));
        $A.util.removeClass(component.find('callbackForm')[2], "slds-has-error"); // remove red border
        $A.util.addClass(component.find('callbackForm')[2], "hide-error-message");
    },

    handleReadonly: function (component, event, helper) {
        if (component.get('v.readonly')) {
            component.set('v.callback_date', null);
            component.set('v.callback_time', null);
            component.set('v.callback_number', null);
            component.set('v.callback_description', null);
        }

    },

    clearValidate: function (component, event, helper) {
        component.find('callbackForm').forEach(function (element, index) {
            $A.util.removeClass(component.find('callbackForm')[index], "slds-has-error"); // remove red border
            $A.util.addClass(component.find('callbackForm')[index], "hide-error-message");
        });
    }

})