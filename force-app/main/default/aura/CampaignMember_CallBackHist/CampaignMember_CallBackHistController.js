({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        component.set('v.recordLimit', component.get('v.collapseSize'))
        if(recordId != null && recordId != '' )
        {
            helper.initTimeline(component, event, helper, false);
        }
        else
        {
            component.set("v.display" , null); 
            component.set('v.marketingCode', null)
            component.set('v.isViewMore', false);

            component.set('v.loaded',false);
        }

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
        var recordId = component.get('v.recordId');
        component.set('v.loaded',true);

        component.set('v.recordLimit', component.get('v.expandSize'));

        var isViewMore = true;
        if(recordId != null && recordId != '' )
        {
            helper.initTimeline(component, event, helper, isViewMore);
        }
        else
        {
            component.set('v.loaded',false);
            component.set('v.isViewMore', isViewMore);
        }
    },
    viewLessTask : function(component, event, helper){
        var recordId = component.get('v.recordId');
        component.set('v.loaded',true);

        component.set('v.recordLimit', component.get('v.collapseSize'));

        var isViewMore = false;
        if(recordId != null && recordId != '' )
        {
            helper.initTimeline(component, event, helper, isViewMore);
        }
        else
        {
            component.set('v.loaded',false);
            component.set('v.isViewMore', isViewMore);
        }
    }
})