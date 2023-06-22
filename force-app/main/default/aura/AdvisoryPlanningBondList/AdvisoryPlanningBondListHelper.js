({
    showComponent: function (component, className) {
        $A.util.removeClass(component.find(className), "slds-hide");
    },

    hideComponent: function (component, className) {
        $A.util.addClass(component.find(className), "slds-hide");
    },
})