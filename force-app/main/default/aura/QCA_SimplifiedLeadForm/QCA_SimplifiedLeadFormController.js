({
    onInit: function (component, event, helper) {
        console.log('Run on initail Simplified Lead');
        helper.startSpinner(component);

        // var leadrecordId = component.get("v.pageReference").state.leadrecordId;
        // component.set("v.leadrecordId", leadrecordId);

        // Set Icon tab and Label tab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            workspaceAPI.getTabInfo({
                tabId: response.tabId
            }).then(function (response) {
                workspaceAPI.setTabLabel({
                    tabId: response.tabId,
                    label: "New Lead",
                });
                workspaceAPI.setTabIcon({
                    tabId: response.tabId,
                    icon: "standard:lead",
                    iconAlt: "New Lead"
                });
            })
        });

        var actionPromise = new Promise(function (resolve, reject) {
            var actionRecordType = component.get("c.getRecordTypeSimplifiedLead");
            actionRecordType.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var getRecordTypeSimplifiedLead = response.getReturnValue();
                    component.set('v.varMapRecordTypeId', getRecordTypeSimplifiedLead);
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
                var leadRecordId = component.get("v.leadRecordId");
                if (leadRecordId) {
                    var actionLeadObj = component.get("c.getMyLeadInforamtion");
                    actionLeadObj.setParams({
                        "leadObjId": leadRecordId,
                    });
                    actionLeadObj.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var getLeadObj = response.getReturnValue();
                            component.set('v.leadObj', getLeadObj);
                            // component.set('v.varMapRecordTypeId.RecordTypeLead', getLeadObj.RecordTypeId);
                            // console.log(getLeadObj);

                            helper.getOpportunityId(component, event, helper);
                            helper.setupStage(component);
                            helper.stopSpinner(component);
                            // component.set("v.simplifiedLeadProcessStage", 0);
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
                            helper.stopSpinner(component);
                        }
                    });
                    $A.enqueueAction(actionLeadObj);
                } else {
                    helper.setupStage(component);
                    helper.stopSpinner(component);
                    // component.set("v.simplifiedLeadProcessStage", 0);
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
        helper.setupSimplifiedLeadProcessStatusEvent(component, event, helper);
    },
    handleSimplifiedLeadProcessStageEvent: function (component, event, helper) {
        var data = event.getParams('data').data;
        // var simplifiedLeadProcessStage = component.get('v.simplifiedLeadProcessStage');
    },
    onClickSubmitContactPath: function (component, event, helper) {
        // helper.startSpinner(component);
        var visitPlanReportForm = component.find('visitPlanReportForm');
        var logACallForm = component.find('logACallForm');

        var isValidVisitForm = visitPlanReportForm.onValidLogVisitHandler();
        var isValidLogACallForm = logACallForm.onValidFieldHandler();

        if (isValidVisitForm && isValidLogACallForm) {
            logACallForm.onSavingLogACall(function (result) {
                // console.log("logACallForm callback for aura:method was executed");
                // console.log("logACallForm result: ", result);
            });

            visitPlanReportForm.onSaveLogVisit(function (result) {
                // console.log("visitPlanReportForm callback for aura:method was executed");
                // console.log("visitPlanReportForm result: ", result);
                var compEvent = component.getEvent("varSimplifiedLeadProcessStatus");
                compEvent.setParams({
                    "leadObjId": component.get('v.leadRecordId'),
                    "simplifiedLeadProcessStage": 2,
                    "isAllowSimplifiedLeadProcessStage": true,
                });
                compEvent.fire();
            });
        }

    },
    redirectToMyLead: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/n/My_Lead_Quick_CA',
            // "url": '/one/one.app#/alohaRedirect/apex/SmartBDM_MyLead_QuickCA',
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
    }
})