({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.fields.inputField', [{
                fileName: 'Status',
                required: true,
                value: 'Completed',
            },
            {
                fileName: ''
            },
            {
                fileName: 'Root_Cause_List__c',
                required: true,
            },
            {
                fileName: 'Resolution_LIst__c',
                required: true,
            },
            {
                fileName: 'Root_Cause__c',
            },
            {
                fileName: 'Resolution__c',
            },
        ]);

        component.set('v.fields.outputField', [{
                fileName: 'AccountId',
            },
            {
                fileName: 'Subject',
            },
            {
                fileName: 'PTA_Segment__c',
            },
            {
                fileName: 'Category__c',
            },
            {
                fileName: 'Sub_Category__c',
            },
            {
                fileName: 'Product_Category__c',
            },
            {
                fileName: 'Issue__c',
            },
            {
                fileName: 'Description',
            },
        ]);
        component.set('v.errorsDisplay', {
            isDisplay: false,
            errors: [],
        })
        console.log('test2');
        
        helper.userRecordAccess(component, event, helper);
        helper.getClosedCaseWarningMessage(component, event, helper);
        helper.isAllowEdit(component, event, helper);
        helper.getPicklist(component, event, helper);
        
        // component.set('v.fields', component.get('v.fields').reduce((list, value) => {
        //     if (value.fileName)
        //         list.push(value.fileName);
        //     return list;
        // }, []));
    },
    onCloseTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function (error) {
                console.log(error);
            });
    },
    onLoad: function (component, event, helper) {
        helper.stopSpinner(component);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
                workspaceAPI.getTabInfo({
                    tabId: response.tabId
                }).then(function (response) {
                    if (response.isSubtab) {
                        workspaceAPI.setTabLabel({
                            tabId: response.tabId,
                            label: $A.get('$Label.c.Closed_Case') + ': ' + component.get('v.case.CaseNumber'),
                        });
                        workspaceAPI.setTabIcon({
                            tabId: response.tabId,
                            icon: "standard:case",
                            iconAlt: component.get('v.case.CaseNumber')
                        });
                    } else if (response.subtabs && response.subtabs.length > 0) {
                        workspaceAPI.setTabLabel({
                            tabId: response.subtabs[response.subtabs.length - 1].tabId,
                            label: $A.get('$Label.c.Closed_Case') + ': ' + component.get('v.case.CaseNumber'),
                        });
                        workspaceAPI.setTabIcon({
                            tabId: response.subtabs[response.subtabs.length - 1].tabId,
                            icon: "standard:case",
                            iconAlt: component.get('v.case.CaseNumber')
                        });
                    }
                });
            })
            .catch(function (error) {
                console.log(error);
            });
            component.set('v.statusChoose','Completed');
    },
    onSubmit: function (component, event, helper) {
        var fields = event.getParam('fields');
        var caseObj = component.get('v.case');
        var status = component.get('v.statusChoose');
        var currentFields = helper.parseObj(fields);
        var keyWord = caseObj.Category__c + currentFields.Status;
        var warningMessageMap = component.get('v.warningMessageMap');
        var warningMessage = warningMessageMap[keyWord];
        var isWarning = component.get('v.isWarning');
        var oldStatus = component.get('v.oldStatus');
        event.preventDefault();
        if (currentFields.Status == 'Completed' || currentFields.Status == 'Cancel'){
            if (warningMessage != null && warningMessage != undefined && oldStatus != currentFields.Status){
                oldStatus = currentFields.Status;
                component.set('v.isWarning',true);
                component.set('v.oldStatus',oldStatus);
                component.set('v.warningMessage',warningMessage.Message__c);
                helper.stopSpinner(component);
            }
            else {
                helper.startSpinner(component);
                component.set('v.isWarning',false);
                component.set('v.isClosed',true);
                var fields = event.getParam('fields');
                component.find('recordEditForm').submit(fields);
            }
        }else {
            helper.startSpinner(component);
            component.set('v.isWarning',false);
            component.set('v.isClosed',true);
            var fields = event.getParam('fields');
            component.find('recordEditForm').submit(fields);
        }
            
    },
    onSuccess: function (component, event, helper) {
        helper.stopSpinner(component);
        var isClosed = component.get('v.isClosed');
        if (isClosed){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                    $A.get('e.force:refreshView').fire();
                })
                .catch(function (error) {
                    console.log(error);
            });
        }
    },
    onError: function (component, event, helper) {
        helper.stopSpinner(component);
    },
})