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
    parseObj: function (objFields) {
        return JSON.parse(JSON.stringify(objFields));
    },
    mapFields: function (params) {
        var tmpObj = {};
        for (var i = 0; i < params.length; i++) {
            var key = params[i].get("v.fieldName");
            var value = params[i].get("v.value");
            tmpObj[key] = value ? value : null;

        }
        return tmpObj;
    },
    setTimeToZero: function (time) {
        // var tmpTIme = time;
        time.setHours(0);
        time.setMinutes(0);
        time.setSeconds(0);
        time.setMilliseconds(0);
        return time;
    },
    addDays: function (dateTmp, days) {
        var date = new Date(dateTmp);
        date.setDate(dateTmp.getDate() + days);
        return date;
    },
    getFieldValuePicklist: function (component, FieldAPIName1st, FieldAPIName2nd) {
        var action = component.get("c.getVisitPlanReportDependencyFieldValues");
        action.setParams({
            'FieldAPIName1st': FieldAPIName1st,
            'FieldAPIName2nd': FieldAPIName2nd,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.subPurposeValues', response.getReturnValue());

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                    // reject(errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    validateField: function (component, helper, callReportObj) {
        var callReportObj = helper.parseObj(callReportObj);
        // console.log('----callReportObj----- : ', callReportObj);
        /* ================= required field cannot empty value ================= */

        // var skipInputField = ['Actual_Visit_Date__c'];
        var validInputField = ['Start_Visit_Time__c', 'Loss_Incomplete_reason__c', 'Date_of_Visit__c', 'Actual_Visit_Date__c', 'Main_purpose__c', 'Sub_Purpose__c', 'Categories__c'];
        var validTimeField = true;
        var validLossOutField = true;
        var allValid_validInputField = component.find('VisitPlanFormInput').reduce((validSoFar, inputCmp) => {

            if (validInputField.indexOf(inputCmp.get("v.fieldName")) != -1 && !inputCmp.get("v.disabled")) {
                var inputFieldName = validInputField[validInputField.indexOf(inputCmp.get("v.fieldName"))];
                var inputFieldValue = callReportObj[inputFieldName];
                var container = component.find(inputFieldName);

                if (inputFieldValue) {
                    $A.util.removeClass(inputCmp, 'slds-has-error');
                    $A.util.removeClass(container, 'slds-has-error');
                    var body = container.get("v.body");
                    body.forEach((element, index) => {
                        if (index != 0 && element.isValid()) {
                            element.destroy();
                        }
                    });

                    /* ================= Loss/ Incomplete reason should be blank when outcome is not Lost Oppty or Cancelled ================= */
                    if (inputFieldName == "Loss_Incomplete_reason__c") {

                        if (callReportObj['Outcome__c'] != "Lost oppty" &&
                            callReportObj['Outcome__c'] != "Incomplete" &&
                            callReportObj['Outcome__c'] != "Lost Deal" &&
                            callReportObj['Outcome__c'] != "Cancelled") {
                            var msgError = '';
                            msgError = 'Loss/ Incomplete reason should be blank when outcome is not Lost Oppty or Cancelled';
                            $A.util.addClass(inputCmp, 'slds-has-error');
                            $A.util.addClass(container, 'slds-has-error');
                            $A.createComponent(
                                "aura:html", {
                                    tag: "div",
                                    HTMLAttributes: {
                                        "id": "errorMessageInputField",
                                        "class": "slds-form-element__help"
                                    },
                                    body: msgError
                                },
                                function (compo) {
                                    if (inputCmp.isValid()) {
                                        var body = container.get("v.body");
                                        body.forEach(element => {
                                            if (element.isValid()) {
                                                body.push(compo);
                                            }
                                        });
                                        container.set("v.body", body);
                                    }
                                }
                            );
                            return validSoFar && false;
                        }


                    }

                    /* ================= Visit Plan Date cannot be earlier than today ================= */
                    if (inputFieldName == 'Date_of_Visit__c') {
                        var dateValue = helper.setTimeToZero(new Date(inputFieldValue));
                        var todayDate = helper.setTimeToZero(new Date());

                        // console.log('inputFieldValue : ', inputFieldValue);
                        // console.log('dateValue : ', dateValue);
                        // console.log('todayDate : ', todayDate);

                        if (dateValue < todayDate) {
                            $A.util.addClass(inputCmp, 'slds-has-error');
                            $A.util.addClass(container, 'slds-has-error');
                            $A.createComponent(
                                "aura:html", {
                                    tag: "div",
                                    HTMLAttributes: {
                                        "id": "errorMessageInputField",
                                        "class": "slds-form-element__help"
                                    },
                                    body: "Visit Plan Date cannot be earlier than today."
                                },
                                function (compo) {
                                    if (inputCmp.isValid()) {
                                        var body = container.get("v.body");
                                        body.forEach(element => {
                                            if (element.isValid()) {
                                                body.push(compo);
                                            }
                                        });
                                        container.set("v.body", body);
                                    }
                                }
                            );
                            return validSoFar && false;
                        }


                    }

                    /* ================= Visit Report must be completed within 3 days after Visit Plan Date ================= */
                    if (inputFieldName == 'Actual_Visit_Date__c') {
                        var dateVisit = helper.setTimeToZero(new Date(callReportObj['Date_of_Visit__c']));
                        var dateActual = helper.setTimeToZero(new Date(inputFieldValue));
                        var todayDate = helper.setTimeToZero(new Date());
                        var ThreeDaysVisit = helper.addDays(dateVisit, 3);
                        var msgError = '';
                        // console.log('inputFieldValue : ', inputFieldValue);
                        // console.log('dateVisit : ', dateVisit);
                        // console.log('dateActual : ', dateActual);
                        // console.log('ThreeDaysVisit : ', ThreeDaysVisit);
                        if ((dateActual > todayDate || dateActual > ThreeDaysVisit || dateActual < dateVisit) && (dateVisit >= todayDate)) {
                            if (dateActual > todayDate) {
                                msgError = "Actual Visit Date cannot be future date";
                            } else if (dateActual < dateVisit) {
                                msgError = "Actual Visit Date must not be less than Visit Plan Date";
                            } else if (dateActual <= ThreeDaysVisit) {
                                msgError = "Visit Report must be completed within 3 days after Visit Plan Date";
                            }
                            // console.log('msgError : ', msgError);
                            $A.util.addClass(inputCmp, 'slds-has-error');
                            $A.util.addClass(container, 'slds-has-error');
                            $A.createComponent(
                                "aura:html", {
                                    tag: "div",
                                    HTMLAttributes: {
                                        "id": "errorMessageInputField",
                                        "class": "slds-form-element__help"
                                    },
                                    body: msgError
                                },
                                function (compo) {
                                    if (inputCmp.isValid()) {
                                        var body = container.get("v.body");
                                        body.forEach(element => {
                                            if (element.isValid()) {
                                                body.push(compo);
                                            }
                                        });
                                        container.set("v.body", body);
                                    }
                                }
                            );
                            return validSoFar && false;

                        }

                    }
                    return validSoFar && true;
                } else {
                    /* skip in these fields if it has value becasuse it isnt required */
                    if (inputFieldName != 'Actual_Visit_Date__c' && inputFieldName != 'Loss_Incomplete_reason__c' && inputFieldName != 'Start_Visit_Time__c' && inputFieldName != 'End_Visit_Time__c' && inputFieldName != 'Sub_Purpose__c') {
                        /* ^^^^^ skip in these fields if it has value becasuse it isnt required ^^^^^*/
                        $A.util.addClass(inputCmp, 'slds-has-error');
                        $A.util.addClass(container, 'slds-has-error');
                        $A.createComponent(
                            "aura:html", {
                                tag: "div",
                                HTMLAttributes: {
                                    "id": "errorMessageInputField",
                                    "class": "slds-form-element__help"
                                },
                                body: "Complete this field."
                            },
                            function (compo) {
                                if (inputCmp.isValid()) {
                                    var body = container.get("v.body");
                                    if (body.length < 2) {
                                        body.push(compo);
                                        container.set("v.body", body);
                                    }
                                }
                            }
                        );
                        return validSoFar && false;
                    }
                }
            }
            return validSoFar;
        }, true);

        component.find('VisitPlanFormInput').find((inputCmp) => {
            if (inputCmp.get('v.fieldName') == 'Loss_Incomplete_reason__c') {
                if (callReportObj['Loss_Incomplete_reason__c'] == null || callReportObj['Loss_Incomplete_reason__c'] == '') {
                    var container = component.find('Loss_Incomplete_reason__c');
                    $A.util.removeClass(inputCmp, 'slds-has-error');
                    $A.util.removeClass(container, 'slds-has-error');
                    var body = container.get("v.body");

                    body.forEach((element, index) => {
                        if (index != 0 && element.isValid()) {
                            element.destroy();
                        }
                    });
                    if (callReportObj['Outcome__c'] == "Lost Deal" || callReportObj['Outcome__c'] == "Lost oppty" || callReportObj['Outcome__c'] == "Cancelled") {
                        $A.util.addClass(inputCmp, 'slds-has-error');
                        $A.util.addClass(container, 'slds-has-error');
                        $A.createComponent(
                            "aura:html", {
                                tag: "div",
                                HTMLAttributes: {
                                    "id": "errorMessageInputField",
                                    "class": "slds-form-element__help"
                                },
                                body: "Loss/ Incomplete reason is required when outcome is Lost Oppty or Cancelled"
                            },
                            function (compo) {
                                if (inputCmp.isValid()) {
                                    var body = container.get("v.body");
                                    body.forEach(element => {
                                        if (element.isValid()) {
                                            body.push(compo);
                                        }
                                    });
                                    container.set("v.body", body);
                                }
                            }
                        );
                        validLossOutField = false;
                        // return  validLossOutField;
                    }
                }


            }
            // validLossOutField = true
            return inputCmp.get('v.fieldName') == 'Loss_Incomplete_reason__c';
        });

        component.find('VisitPlanFormInput').find((inputCmp) => {
            if (inputCmp.get('v.fieldName') == 'Start_Visit_Time__c' || inputCmp.get('v.fieldName') == 'End_Visit_Time__c') {
                // if (inputFieldName == 'Start_Visit_Time__c') {
                var container = component.find('Visit_Time');
                $A.util.removeClass(inputCmp, 'slds-has-error');
                $A.util.removeClass(container, 'slds-has-error');
                var startTime = callReportObj['Start_Visit_Time__c'];
                var endTime = callReportObj['End_Visit_Time__c'];
                var tmpStartTime = new Date(('01-01-1970 ' + startTime + ':00').replace(/-/g, '/'));
                var tmpEndTime = new Date(('01-01-1970 ' + endTime + ':00').replace(/-/g, '/'));
                var msgError = '';
                // console.log('tmpStartTime : ' + tmpStartTime);
                // console.log('tmpEndTime : ' + tmpStartTime);
                // var tmpStartTime__ = tmpStartTime.replace(/-/g, "/");
                // var tmpEndTime__ = tmpEndTime.replace(/-/g, "/");
                // console.log('tmpStartTime__ : ' + tmpStartTime__);
                // console.log('tmpEndTime__ : ' + tmpEndTime__);

                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        element.destroy();
                    }
                });
                if (tmpEndTime < tmpStartTime || !endTime || !startTime) {
                    if (tmpEndTime < tmpStartTime) {
                        msgError = "End Visit Time must not be earlier than Start Visit Time"
                    } else if (endTime) {
                        msgError = "Complete Start Visit Time field"
                    } else if (startTime) {
                        msgError = "Complete End Visit Time field"
                    } else {
                        msgError = "Complete these fields"
                    }
                    // console.log('msgError : ', msgError);
                    // $A.util.addClass(inputCmp, 'slds-has-error');
                    $A.util.addClass(container, 'slds-has-error');
                    $A.createComponent(
                        "aura:html", {
                            tag: "div",
                            HTMLAttributes: {
                                "id": "errorMessageInputField",
                                "class": "slds-form-element__help startTime"
                            },
                            body: msgError
                        },
                        function (compo) {
                            if (inputCmp.isValid()) {
                                var body = container.get("v.body");
                                body.forEach(element => {
                                    if (element.isValid()) {
                                        body.push(compo);
                                    }
                                });
                                container.set("v.body", body);
                            }
                        }

                    );
                    validTimeField = false;
                }
            }
            // validTimeField = true;
            // return inputCmp.get('v.fieldName') == 'Start_Visit_Time__c' || inputCmp.get('v.fieldName') == 'End_Visit_Time__c' ;
        });

        var validSubPurpose = component.find('VisitPlanFormInput').reduce((validSoFar, inputCmp) => {
            if (inputCmp.get('v.fieldName') == 'Sub_Purpose__c') {
                var inputFiledName = inputCmp.get('v.fieldName');
                var inputFiledValue = inputCmp.get('v.value') ? true : false;
                var MainpurposeValue = callReportObj['Main_purpose__c'] ? callReportObj['Main_purpose__c'] : '';
                var subPurposeValuesLength = component.get('v.subPurposeValues')[MainpurposeValue] ? component.get('v.subPurposeValues')[MainpurposeValue].length : 0;

                var container = component.find(inputFiledName);
                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        element.destroy();
                    }
                });

                if (!inputFiledValue && subPurposeValuesLength > 0) {
                    // $A.util.addClass(inputCmp, 'slds-has-error');
                    $A.util.addClass(container, 'slds-has-error');
                    $A.createComponent(
                        "aura:html", {
                            tag: "div",
                            HTMLAttributes: {
                                "id": "errorMessageInputField",
                                "class": "slds-form-element__help"
                            },
                            body: "Complete this field."
                        },
                        function (compo) {
                            if (inputCmp.isValid()) {
                                body.forEach(element => {
                                    if (element.isValid()) {
                                        body.push(compo);
                                    }
                                });
                                container.set("v.body", body);
                            }
                        }
                    );
                    return validSoFar && false;
                } else {
                    // $A.util.removeClass(inputCmp, 'slds-has-error');
                    $A.util.removeClass(container, 'slds-has-error');
                    return validSoFar && true;
                }
            }
            return validSoFar;
        }, true);

        return allValid_validInputField && validLossOutField && validTimeField && validSubPurpose;
    },
    removeInvalidInputField: function (component, event, helper) {
        var validInputField = ['Start_Visit_Time__c', 'End_Visit_Time__c', 'Date_of_Visit__c', 'Actual_Visit_Date__c', 'Main_purpose__c', 'Categories__c', 'Sub_Purpose__c', 'Loss_Incomplete_reason__c'];
        var inputCmp = event.getSource();
        var inputFieldName = inputCmp.get('v.fieldName');
        var inputFieldValue = inputCmp.get('v.value');
        var container = component.find(inputFieldName);
        // console.log('inputFieldName : ' + inputFieldName);
        // console.log('inputFieldValue : ' + inputFieldValue);
        // console.log('onInit : ', component.get('v.onInitValidInputField'));

        if (validInputField.indexOf(inputFieldName) != -1 && component.get('v.onInitValidInputField')) {

            if (inputFieldValue) {
                if (inputFieldName != 'Start_Visit_Time__c' && inputFieldName != 'End_Visit_Time__c') {
                    $A.util.removeClass(inputCmp, 'slds-has-error');
                    $A.util.removeClass(container, 'slds-has-error');
                    var body = container.get("v.body");
                    body.forEach((element, index) => {
                        if (index != 0 && element.isValid()) {
                            element.destroy();
                            body.splice(index, 1);
                        }
                    });
                } else {
                    var container = component.find('Visit_Time');
                    $A.util.removeClass(inputCmp, 'slds-has-error');
                    $A.util.removeClass(container, 'slds-has-error');
                    var body = container.get("v.body");
                    body.forEach((element, index) => {
                        if (index != 0 && element.isValid()) {
                            element.destroy();
                        }
                    });
                }

            } else {
                if (inputFieldName != 'Actual_Visit_Date__c' && inputFieldName != 'Loss_Incomplete_reason__c' && inputFieldName != 'Start_Visit_Time__c' && inputFieldName != 'End_Visit_Time__c') {
                    $A.util.addClass(inputCmp, 'slds-has-error');
                    $A.util.addClass(container, 'slds-has-error');
                    $A.createComponent(
                        "aura:html", {
                            tag: "div",
                            HTMLAttributes: {
                                "id": "errorMessageInputField",
                                "class": "slds-form-element__help"
                            },
                            body: "Complete this field."
                        },
                        function (compo) {
                            if (inputCmp.isValid()) {
                                var body = container.get("v.body");
                                body.forEach(element => {
                                    if (element.isValid()) {
                                        body.push(compo);
                                    }
                                });
                                container.set("v.body", body);
                            }
                        }
                    );
                } else if (inputFieldName == 'Loss_Incomplete_reason__c') {
                    $A.util.removeClass(inputCmp, 'slds-has-error');
                    $A.util.removeClass(container, 'slds-has-error');
                    var body = container.get("v.body");
                    body.forEach((element, index) => {
                        if (index != 0 && element.isValid()) {
                            element.destroy();
                        }
                    });
                } else if (inputFieldName == 'Start_Visit_Time__c' || inputFieldName == 'End_Visit_Time__c') {
                    var container = component.find('Visit_Time');
                    $A.util.removeClass(inputCmp, 'slds-has-error');
                    $A.util.removeClass(container, 'slds-has-error');
                    var body = container.get("v.body");
                    // console.log('body : ', body.length);
                    body.forEach((element, index) => {
                        // console.log('index : ', index);
                        if (index != 0 && element.isValid()) {
                            element.destroy();
                        }
                    });
                }
            }
        } else {
            if (inputFieldName == "Outcome__c") {
                var container = component.find('Loss_Incomplete_reason__c');
                $A.util.removeClass(inputCmp, 'slds-has-error');
                $A.util.removeClass(container, 'slds-has-error');
                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        element.destroy();
                    }
                });
            }

        }

        if (inputFieldName == 'Main_purpose__c') {
            var container = component.find('Sub_Purpose__c');
            if (inputFieldValue == 'Hand over (New RM)' || inputFieldValue == 'Debt collection' || inputFieldValue == '') {
                $A.util.removeClass(container, 'slds-has-error');
                $A.util.removeClass(container, 'customRequiredField');
                var body = container.get("v.body");
                body.forEach((element, index) => {
                    if (index != 0 && element.isValid()) {
                        body.splice(index, 1);
                        element.destroy();
                    }
                });
            } else {
                $A.util.addClass(container, 'slds-has-error');
                $A.util.addClass(container, 'customRequiredField');
                $A.createComponent(
                    "aura:html", {
                        tag: "div",
                        HTMLAttributes: {
                            "id": "errorMessageInputField",
                            "class": "slds-form-element__help"
                        },
                        body: "Complete this field."
                    },
                    function (compo) {
                        var body = container.get("v.body");
                        if (container.isValid() && body.length < 2)  {
                            body.splice(body.length, 0, compo);
                            container.set("v.body", body);
                        }
                    }
                );
            }

        }

       // if (validInputField[validInputField.length - 1] == inputFieldName) {
        if(validInputField.includes(inputFieldName)){
            component.set('v.onInitValidInputField', true);
        }

    },
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    }
})