({
    onInit: function (component, event, helper) {
        helper.checkProfileAssign(component, event, helper);
    },
    myAction: function (component, event, helper) {

    },
    navigate: function (component, event, helper) {
        const activity = JSON.parse(JSON.stringify(component.get('v.activity')));
        const recordId = activity.id;
        var checkProfileAssign = component.get('v.checkProfileAssign');
        if (checkProfileAssign) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:CampaignMember_Main",
                componentAttributes: {
                    recordId: recordId,
                    "mode": 'Edit'
                }
            });
            evt.fire();
        }
        else {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/" + recordId
            });
            urlEvent.fire();
        }
    },
    toggleAcitivity: function (component, event, helper) {
        var icon = component.find('icon-chevron');
        if (icon.get('v.iconName') === 'utility:chevronright') {
            icon.set('v.iconName', 'utility:chevrondown');
        }
        else {
            icon.set('v.iconName', 'utility:chevronright');
        }
        $A.util.toggleClass(component.find('campaignItem'), 'slds-is-open');
    },
})