({
    myAction: function (component, event, helper) {

    },
    navigate: function (component, event) {
        const activity = JSON.parse(JSON.stringify(component.get('v.activity')));
        var evt = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": `/lightning/r/Case/${activity.id}/view`,
        });
        evt.fire();
    },
    toggleAcitivity: function (component, event, helper) {
        var icon = component.find('icon-chevron');
        if (icon.get('v.iconName') === 'utility:chevronright') {
            icon.set('v.iconName', 'utility:chevrondown');
        }
        else {
            icon.set('v.iconName', 'utility:chevronright');
        }
        $A.util.toggleClass(component.find('caseItem'), 'slds-is-open');
    },
})