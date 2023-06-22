({
    doInit: function (component, event, helper) {
        var expected_submit_date = component.get('v.expected_submit_date');
        var expected_complete_date = component.get('v.expected_complete_date');

        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();

        if (dd < 10) {
            dd = '0' + dd;
        }
        if (mm < 10) {
            mm = '0' + mm;
        }
        var date = yyyy + '-' + mm + '-' + dd;

        component.set('v.expected_submit_date', date);
        component.set('v.today', date);

        var prdMap = [];
        component.set('v.ProductInterestMap', prdMap);

        var action = component.get('c.InitData');
        action.setParams({
            'objleadid': component.get('v.leadRecordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var tmplst;
                var tmpmap = new Map();

                for (var prd in result) {
                    tmplst = [];
                    if (tmpmap.get(result[prd].Host_Product_Mapping__r.Product_Program__c) !== undefined) {
                        tmplst = tmpmap.get(result[prd].Host_Product_Mapping__r.Product_Program__c);
                    }
                    tmplst.push(result[prd]);
                    tmpmap.set(result[prd].Host_Product_Mapping__r.Product_Program__c, tmplst);
                }

                var iteratorKey = tmpmap.keys();

                while (true) {
                    var key = iteratorKey.next().value;
                    if (key === undefined) {
                        break;
                    } else {
                        prdMap.push({
                            programName: key,
                            programList: tmpmap.get(key)
                        });
                    }
                }
                // console.log('prdMap', prdMap);
                component.set('v.ProductInterestMap', prdMap);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        // console.log('errors[0].message: ' + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);

    },

    inputExpected_submit_date: function (component, event, helper) {
        var expected_submit_date = component.get('v.expected_submit_date');
        var expected_complete_date = component.get('v.expected_complete_date');
        component.set('v.expected_complete_date', null);
        expected_submit_date = component.get('v.expected_submit_date');
        expected_complete_date = component.get('v.expected_complete_date');
        // console.log("expected_submit_date", expected_submit_date);
        // console.log("expected_complete_date", expected_complete_date);
    },


    submitConvertLead: function (component, event, helper) {
        var expected_submit_date = component.get('v.expected_submit_date');
        var expected_complete_date = component.get('v.expected_complete_date');
        // console.log("expected_submit_date", expected_submit_date);
        // console.log("expected_complete_date", expected_complete_date);
        var allValid = component.find('convertFormInput').reduce((valid, inputCmp) => {
            // inputCmp.focus();
            inputCmp.showHelpMessageIfInvalid();
            return valid && inputCmp.get('v.validity').valid;
        }, true);

        if (!allValid) {
            helper.displayToast(component, "Error", "Please Input required field(s).");
            // helper.displayToast(component, "Error", $A.get("$Label.c.FXS_Cancel_Success"));
        } else {
            helper.startSpinner(component);

            var action = component.get('c.convertLead');

            var action2 = component.get('c.getStdConvertOpptyId');

            action.setParams({
                'objleadid': component.get('v.leadRecordId'),
                'submit_date': expected_submit_date,
                'complete_date': expected_complete_date,
            });

            action2.setParams({
                'leadId': component.get('v.leadRecordId'),
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // console.log('result: ', state);
                    $A.enqueueAction(action2);
                } else if (state === "ERROR") {
                    helper.stopSpinner(component);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('errors[0].message: ' + errors[0].message);
                            helper.displayToast(component, "Error", errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });

            action2.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log(state);
                    var result = response.getReturnValue();
                    // console.log('opptyObjId :: ', result);
                    component.set('v.opptyObjId', result);

                    helper.toNextStage(component);
                    helper.stopSpinner(component);
                } else if (state === "ERROR") {
                    helper.stopSpinner(component);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('errors[0].message: ' + errors[0].message);
                            helper.displayToast(component, "Error", errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    helper.stopSpinner(component);
                }
            });

            $A.enqueueAction(action);

        }
    }
})