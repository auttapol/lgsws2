({
    onInit: function (component, event, helper) {
        console.log('Run on initail Simplified Opportunity');
        helper.startSpinner(component);
        console.log('Opportunity Id :: ', component.get('v.opptyId'));

        // Set Icon tab and Label tab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            workspaceAPI.getTabInfo({
                tabId: response.tabId
            }).then(function (response) {
                workspaceAPI.setTabLabel({
                    tabId: response.tabId,
                    label: "New Opportunity",
                });
                workspaceAPI.setTabIcon({
                    tabId: response.tabId,
                    icon: "standard:opportunity",
                    iconAlt: "New Opportunity"
                });
            })
        });

        var actionPromise = new Promise(function (resolve, reject) {
            var actionRecordType = component.get("c.getRecordTypeSimplifiedOpportunity");
            actionRecordType.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var getRecordTypeSimplifiedOpportunity = response.getReturnValue();
                    component.set('v.varMapRecordTypeId', getRecordTypeSimplifiedOpportunity);
                    // console.log(component.get('v.varMapRecordTypeId'));

                    resolve();

                } else if (state === "INCOMPLETE") {
                    // do something
                    reject(Error('Invalid value: Current user'));
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                            reject(Error(errors[0].message));
                        }
                    } else {
                        console.log("Unknown error");
                        reject(Error("Unknown error"));
                    }
                }
            });
            $A.enqueueAction(actionRecordType);
        });

        actionPromise.then(
            function () {
                var opptyId = component.get("v.opptyId");
                if (opptyId) {
                    var action = component.get("c.getOpportuniyObjById");
                    action.setParams({
                        "opptyId": opptyId,
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var opptyObj = response.getReturnValue();
                            // console.log("From server: ", opptyObj);
                            component.set('v.opptyObj', opptyObj);

                            helper.setupStage(component);
                            helper.stopSpinner(component);
                        } else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " +
                                        errors[0].message);
                                    helper.displayToast(component, 'Error', errors[0].message);
                                    helper.displayErrorMeassge(component, errors[0].message);
                                }
                            } else {
                                console.log("Unknown error");
                            }
                            helper.stopSpinner(component);
                        }
                    });
                    $A.enqueueAction(action);
                } else {
                    helper.setupStage(component);
                    helper.stopSpinner(component);

                }
            },
            function (error) {
                helper.stopSpinner(component);
                helper.displayToast(component, "Error", error.message);
            }
        );

        var action = component.get("c.getDeepLink");
        action.setCallback(this, function (response) {
            helper.startSpinner(component);
            var state = response.getState();
            if (state === "SUCCESS") {
                var getDeepLink = response.getReturnValue();
                component.set('v.varDeepLink', getDeepLink);
            }
        });
        $A.enqueueAction(action);
    },
    onInitEvent: function (component, event, helper) {
        helper.setupSimplifiedOpportunityProcessStatusEvent(component, event, helper);
    },
    handleSimplifiedOpportunityProcessStageEvent: function (component, event, helper) {
        var data = event.getParams('data').data;
        // component.set('v.simplifiedOpportunityProcessStage', data.results.current);
        // console.log('simplifiedOpportunityProcessStage : ', component.get('v.simplifiedOpportunityProcessStage'));
    },
    redirectToMyCustomer: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/n/My_Customer_Quick_CA',
            // "url": '/one/one.app#/alohaRedirect/apex/SmartBDM_MyCustomer_QuickCA',
            "isredirect": true
        });
        urlEvent.fire();
    },
    redirectToSmartBDM: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get('v.varDeepLink')
        });
        urlEvent.fire();
    },
    onClickSubmitContactPath: function (component, event, helper) {
        // helper.startSpinner(component);

        var actionPromise = new Promise(function (resolve, reject) {
            var visitPlanReportForm = component.find('visitPlanReportForm');
            visitPlanReportForm.onSaveLogVisitOppty(function (result) {
                // console.log("visitPlanReportForm callback for aura:method was executed");
                // console.log("visitPlanReportForm result: ", result);
                if (result) {
                    resolve();
                }
            });
        });
        actionPromise.then(
            function () {
                // helper.stopSpinner(component);

                var compEvent = component.getEvent("varSimplifiedOpportunityProcessStatus");
                compEvent.setParams({
                    "opptyObjId": component.get('v.opptyId'),
                    "simplifiedOpportunityProcessStage": 2,
                    "isAllowSimplifiedOpportunityProcessStage": true,
                });
                compEvent.fire();
            },
            function (error) {
                // helper.stopSpinner(component);
                helper.displayToast(component, "Error", error.message);
            }
        );
    }

})