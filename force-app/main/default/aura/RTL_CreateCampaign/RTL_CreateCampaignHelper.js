({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
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
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    closeTab: function (component) {
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
    getRecordTypeCampaignMap: function (component, event, helper) {
        var action = component.get('c.getRecordTypeCampaignMap');
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.recordTypeCampaignMap', result);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    runInit: function (component, event, helper) {
        var recordTypeCampaignMap = component.get('v.recordTypeCampaignMap');
        var campaignObj = component.get('v.campaignObj');
        var userObj = component.get('v.userObj');

        // console.log(helper.parseObj(component.get('v.recordTypeCampaignMap')), helper.parseObj(component.get('v.campaignObj')), helper.parseObj(component.get('v.userObj')));
        // console.log({
        //     RecordTypeId: recordTypeCampaignMap[campaignObj.RTL_Campaign_Type__c],
        //     ParentId: campaignObj.Id,
        //     RTL_Campaign_Code_10_digits__c: campaignObj.RTL_Campaign_Type__c == 'Local Exclusive' ? `${campaignObj.RTL_Campaign_Code_9_digits__c }#` : campaignObj.RTL_Campaign_Code_9_digits__c,
        //     RTL_ContactPerson__c: `${userObj.FirstName} ${userObj.LastName} Tel.${userObj.Phone ? userObj.Phone : '-'}`,
        // });

        // Generate a Link for the Aura Link example
        var navService = component.find('navService');
        var pageRefUtils = component.find('pageRefUtils');
        navService.navigate({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Campaign",
                actionName: "new"
            },
            state: {
                defaultFieldValues: pageRefUtils.encodeDefaultFieldValues({
                    RecordTypeId: recordTypeCampaignMap[campaignObj.RTL_Campaign_Type__c],
                    ParentId: campaignObj.Id,
                    Name: campaignObj.Name,
                    RTL_Campaign_Code_10_digits__c: campaignObj.RTL_Campaign_Type__c == 'Local Exclusive' ? `${campaignObj.RTL_Campaign_Code_9_digits__c }#` : campaignObj.RTL_Campaign_Code_9_digits__c,
                    RTL_ContactPerson__c: `${userObj.FirstName} ${userObj.LastName} Tel.${userObj.Phone ? userObj.Phone : '-'}`,
                }),
                recordTypeId: recordTypeCampaignMap[campaignObj.RTL_Campaign_Type__c],
                useRecordTypeCheck: "1",
                nooverride: "1"
            }
        }, true);
    },
})