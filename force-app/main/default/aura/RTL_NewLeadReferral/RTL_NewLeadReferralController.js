({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        helper.getLeadByReferralId(component, event, helper)
        component.set('v.isReletedList', component.get('v.pageReference') ? component.get('v.pageReference.state.c__isReletedList') : false);
    },
    handlerObj: function (component, event, helper) {
        helper.runInit(component, event, helper);
    },
})