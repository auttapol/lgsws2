({
    displayToast: function (component, helper, title, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        toastEvent.fire();
    },

    getTask: function (component, event, helper) {
        component.set('v.loaded', true);
        var currentUser = component.get('v.currentUser');
        var action = component.get('c.searchExistingCallback');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                if (response.getReturnValue().Call_Log_ID__c) {

                    var task = response.getReturnValue();
                    var user_language;
                    // console.log('currentUser:',currentUser);
                    if (currentUser != null) {
                        user_language = currentUser.LanguageLocaleKey;
                        // console.log('user_language:',user_language);
                        component.set('v.original_task', task);
                        component.set('v.task', task);

                        component.set('v.reschedule', true);
                        component.set('v.isExpanded', true);
                        // console.log('task:',task);

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
                    component.set('v.reschedule', false);
                    component.set('v.loaded', false);
                }

            }

        })
        $A.enqueueAction(action);
    },

    setDateTime: function (component, event, helper, task, user_language) {
        var datetime = new Date(task.Call_Start_Datetime__c);

        var optionsDate = {
            year: 'numeric', month: 'short', day: 'numeric'
        };
        var optionsTime = { hour: '2-digit', minute: '2-digit' };

        if (user_language == 'th') {
            component.set('v.callback_date', helper.transformDateToInput2(datetime.toLocaleDateString()));
            component.set('v.callback_time', datetime.toLocaleTimeString('th-TH'));

            component.set('v.callback_time_label', datetime.toLocaleTimeString('th-TH', optionsTime) + ' น.');
            component.set('v.callback_date_label', datetime.toLocaleString('th-TH', optionsDate));
        }
        else if (user_language == 'en_US') {
            component.set('v.callback_date', helper.transformDateToInput2(datetime.toLocaleDateString()));
            // component.set('v.callback_time', datetime.toLocaleTimeString('en-US'));     

            // component.set('v.callback_time_label', datetime.toLocaleTimeString('en-US',optionsTime));                                     
            // component.set('v.callback_date_label', datetime.toLocaleString('en-US', optionsDate));
            component.set('v.callback_time', datetime.toLocaleTimeString('th-TH'));

            component.set('v.callback_time_label', datetime.toLocaleTimeString('th-TH', optionsTime));
            component.set('v.callback_date_label', datetime.toLocaleString('en-US', optionsDate));
        }
        else if (user_language == 'en_GB') {
            component.set('v.callback_date', helper.transformDateToInput2(datetime.toLocaleDateString()));
            // component.set('v.callback_time', datetime.toLocaleTimeString('en-GB'));     

            // component.set('v.callback_time_label', datetime.toLocaleTimeString('en-GB',optionsTime));                                     
            // component.set('v.callback_date_label', datetime.toLocaleString('en-GB', optionsDate));
            component.set('v.callback_time', datetime.toLocaleTimeString('th-TH'));

            component.set('v.callback_time_label', datetime.toLocaleTimeString('th-TH', optionsTime));
            component.set('v.callback_date_label', datetime.toLocaleString('en-GB', optionsDate));
        }
    },

    scheduleCallback: function (component, event, helper) {

        var onQuickAction = component.get('v.onQuickAction');
        var allValid;
        if (onQuickAction) {
            allValid = component.find('callbackForm').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                allValid = helper.validateDateTime(component, event, helper);
            }
        }
        else {
            allValid = true;
        }

        // console.log('Sc allValid:',allValid);
        if (allValid) {
            let callback_datetime = helper.transformDatetimeUnix(
                component.get('v.callback_date'),
                component.get('v.callback_time')
            );
            let action = component.get('c.insertTask');
            action.setParams({
                "recordId": component.get('v.recordId'),
                "values": {
                    "datetime": callback_datetime,
                    "date": component.get('v.callback_date'),
                    "number": component.get('v.callback_number'),
                    "note": component.get('v.callback_description'),
                    "mode": component.get('v.callback_mode'),
                },
                "marketingCode": component.get('v.marketingCode'),
                "businessName": 'CMOB Call Back Hours'
            });
            action.setCallback(this, function (response) {

                let state = response.getState();
                if (state === 'SUCCESS') {
                    // console.log(response.getReturnValue());
                    let task_id = response.getReturnValue();
                    helper.displayToast(component, helper, 'Success', 'success', 'Save Call Back Success');
                    // helper.calloutCallback(component, event, helper, callback_datetime, task_id);
                    $A.get('e.force:refreshView').fire();
                    helper.closeQuickActionWindow(component, event, helper);
                }
                else {
                    let error = response.getError();
                    helper.handleErrors(error);
                }
            });

            $A.enqueueAction(action);
        }
    },
    transformDatetimeUnix: function (date, time) {
        return Date.parse(date + ' ' + time);
    },
    transformDateToInput: function (date) {
        var date_comp = date.split('/');
        date_comp = date_comp.reverse();
        return date_comp.join('/');
    },

    transformDateToInput2: function (date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;

        return [year, month, day].join('-');
    },

    calloutCallback: function (component, event, helper, dt, task_id) {

        let action = component.get('c.scheduleCallback');
        action.setParams({
            "values": {
                "datetime": dt,
                "number": component.get('v.callback_number'),
                "note": component.get('v.callback_description'),
                "mode": component.get('v.callback_mode'),
                "task_id": task_id,
            }
        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                console.log('schedule success');
            }
            else {
                console.log('schedule failed');
            }

        })

        $A.enqueueAction(action);
    },
    handleErrors: function (errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    rescheduleCallback: function (component, event, helper) {
        var onQuickAction = component.get('v.onQuickAction');
        var allValid;
        if (onQuickAction) {
            allValid = component.find('callbackForm').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                allValid = helper.validateDateTime(component, event, helper);
            }
        }
        else {
            allValid = true;
        }
        if (allValid) {
            let callback_datetime = helper.transformDatetimeUnix(
                helper.transformDateToInput(component.get('v.callback_date')),
                component.get('v.callback_time')
            );
            // console.log('original_task:',component.get('v.original_task'));
            var action = component.get('c.rescheduleCallback');
            action.setParams({
                "values": {
                    "task_id": component.get('v.original_task').Id,
                    "callback_id": component.get('v.original_task').Call_Log_ID__c,
                    "recordId": component.get('v.recordId'),
                    "datetime": callback_datetime,
                    "number": component.get('v.callback_number'),
                    "note": component.get('v.callback_description'),
                    "mode": component.get('v.callback_mode'),
                },
                "businessName": 'CMOB Call Back Hours'
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    // console.log(response.getReturnValue());
                    let task_id = response.getReturnValue();
                    helper.displayToast(component, helper, 'Success', 'success', 'Save Call Back Success');
                    // helper.calloutCallback(component, event, helper, callback_datetime, task_id);
                    $A.get('e.force:refreshView').fire();
                    helper.closeQuickActionWindow(component, event, helper);
                }
                else {
                    let error = response.getError();
                    helper.handleErrors(error);
                }

            })


            $A.enqueueAction(action)

        }

    },
    closeQuickActionWindow: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    validateDateTime: function (component, event, helper) {
        var onQuickAction = component.get('v.onQuickAction');
        var allValid = true;
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if (dd < 10) {
            dd = '0' + dd;
        }
        // if month is less then 10, then append 0 before date    
        if (mm < 10) {
            mm = '0' + mm;
        }

        // console.log('Date:',component.find('callbackForm')[0].get('v.label'));
        // console.log('Date:',component.find('callbackForm')[1].get('v.label'));
        // console.log('Time:',component.find('callbackForm')[2].get('v.label'));
        // console.log('Date:',component.find('callbackForm')[3].get('v.label'));

        var todayFormattedDate = yyyy + '-' + mm + '-' + dd;
        var nowTime = today.getHours() * 60 + today.getMinutes();

        var selectedYear;
        var selectedMonth;
        var selectedDay;
        var selectedHour;
        var selectedMinute;
        var selectedDateTime;
        var selectedTime;

        if (onQuickAction) {
            selectedYear = component.find('callbackForm')[0].get('v.value').split('-')[0];
            selectedMonth = component.find('callbackForm')[0].get('v.value').split('-')[1];
            selectedDay = component.find('callbackForm')[0].get('v.value').split('-')[2];
            selectedHour = component.find('callbackForm')[1].get('v.value').split(':')[0];
            selectedMinute = component.find('callbackForm')[1].get('v.value').split(':')[1];
            selectedDateTime = new Date(selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute);
            selectedTime = selectedDateTime.getHours() * 60 + selectedDateTime.getMinutes();

            if (component.find('callbackForm')[0].get('v.value') != '') {
                if (component.find('callbackForm')[0].get('v.value') < todayFormattedDate) {
                    allValid = false;
                    $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                    helper.displayToast(component, helper, 'Error', 'error', $A.get("$Label.c.CallBack_BusinessHours_ErrorMsg"));
                }

                if (component.find('callbackForm')[0].get('v.value') <= todayFormattedDate && component.find('callbackForm')[1].get('v.value') != ''
                    && selectedTime <= nowTime) {
                    helper.displayToast(component, helper, 'Error', 'error', $A.get("$Label.c.CallBack_BusinessHours_ErrorMsg"));
                    allValid = false;
                    $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                    $A.util.addClass(component.find('callbackForm')[1], "slds-has-error");
                }

            }
        }
        else {
            selectedYear = component.find('callbackForm')[0].get('v.value').split('-')[0];
            selectedMonth = component.find('callbackForm')[0].get('v.value').split('-')[1];
            selectedDay = component.find('callbackForm')[0].get('v.value').split('-')[2];
            selectedHour = component.find('callbackForm')[2].get('v.value').split(':')[0];
            selectedMinute = component.find('callbackForm')[2].get('v.value').split(':')[1];
            selectedDateTime = new Date(selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute);
            selectedTime = selectedDateTime.getHours() * 60 + selectedDateTime.getMinutes();
            // console.log('currentDate:',todayFormattedDate);
            // console.log('currentTime:',nowTime);
            // console.log('selectedDateTime:',selectedDateTime.getHours()*60+selectedDateTime.getMinutes());
            // console.log('Date:',component.find('callbackForm')[0].get('v.value'));
            // console.log('Time:',component.find('callbackForm')[2].get('v.value'));

            if (component.find('callbackForm')[0].get('v.value') != '') {
                if (component.find('callbackForm')[0].get('v.value') < todayFormattedDate) {
                    allValid = false;
                    $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                    helper.displayToast(component, helper, 'Error', 'error', $A.get("$Label.c.CallBack_BusinessHours_ErrorMsg"));
                }

                if (component.find('callbackForm')[0].get('v.value') <= todayFormattedDate && component.find('callbackForm')[2].get('v.value') != ''
                    && selectedTime <= nowTime) {
                    helper.displayToast(component, helper, 'Error', 'error', $A.get("$Label.c.CallBack_BusinessHours_ErrorMsg"));
                    allValid = false;
                    $A.util.addClass(component.find('callbackForm')[0], "slds-has-error");
                    $A.util.addClass(component.find('callbackForm')[2], "slds-has-error");
                }

            }
        }
        return allValid;
    },
})