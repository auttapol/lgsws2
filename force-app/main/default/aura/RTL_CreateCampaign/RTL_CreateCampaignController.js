({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        helper.getRecordTypeCampaignMap(component, event, helper);
    },
    handlerObj: function (component, event, helper) {
        var recordTypeCampaignMap = component.get('v.recordTypeCampaignMap');
        var campaignObj = component.get('v.campaignObj');
        var userObj = component.get('v.userObj');

        if (recordTypeCampaignMap && campaignObj && userObj) {
            helper.runInit(component, event, helper);
        }
    },
})