({
    myAction : function(component, event, helper) {

    },
    toggleAcitivity: function (component, event, helper) {
        var icon = component.find('icon-chevron');
        if (icon.get('v.iconName') === 'utility:chevronright') {
            icon.set('v.iconName', 'utility:chevrondown');
        }
        else {
            icon.set('v.iconName', 'utility:chevronright');
        }
        $A.util.toggleClass(component.find('cardItem'), 'slds-is-open');
    },
})