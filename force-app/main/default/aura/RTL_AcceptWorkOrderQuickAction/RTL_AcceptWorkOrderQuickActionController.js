({  
    onInit: function (component, event, helper) {
        // var recordId = component.get('v.recordId');
        // component.set('v.recordId',recordId);
       
        helper.startSpinner(component);
       
    },

    workOrderHandler: function (component, event, helper) {
        helper.getCurrentUser(component, event, helper);
        // helper.accpetWorkOrder(component, event, helper);
        // helper.accpetWorkOrder(component, event, helper);
    },

    userHandler: function (component, event, helper) {
        helper.getCurrentUser(component, event, helper);
        // helper.accpetWorkOrder(component, event, helper);
        // helper.accpetWorkOrder(component, event, helper);
    }
  
})