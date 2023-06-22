({
    doInit : function(component, event, helper) {
        component.set('v.recordLimit', component.get('v.collapseSize'))
        helper.initTimeline(component, event, helper, false);
    },    
    changeState : function(component, event, helper){
        var iconName = component.get('v.iconName');
        if(iconName === 'utility:chevrondown')
        {
            component.set('v.iconName','utility:chevronright');
        }
        else
        {
            component.set('v.iconName','utility:chevrondown');
        }
        component.set('v.isExpanded', !component.get('v.isExpanded'));
    },
    viewMoreTask : function(component, event, helper){

        var spinner = component.find("apexSpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        component.set('v.recordLimit', component.get('v.expandSize'));

        var isViewMore = true;
        helper.initTimeline(component, event, helper, isViewMore);
    },
    viewLessTask : function(component, event, helper){

        var spinner = component.find("apexSpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        component.set('v.recordLimit', component.get('v.collapseSize'));

        var isViewMore = false;
        helper.initTimeline(component, event, helper, isViewMore);
    }
})