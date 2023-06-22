({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        component.set('v.recordId', component.get('v.recordId') ? component.get('v.recordId') : component.get('v.pageReference.state.c__recordId'));
        component.set('v.isReletedList', component.get('v.pageReference') ? component.get('v.pageReference.state.c__isReletedList') : false);
        helper.getOptyRecordType(component, event, helper);
    },
    handlerObj: function (component, event, helper) {
        helper.runInit(component, event, helper);
    },
})