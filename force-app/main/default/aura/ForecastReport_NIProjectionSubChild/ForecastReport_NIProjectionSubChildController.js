({
    rowName : function(component, event, helper) {
        helper.setNewDeal(component, event, helper);
    },

    setShow: function(component, event, helper) {
        var attr = event.target.getAttribute('data-value');
        var target = component.find(attr);
        var target2 = component.find(attr+'Arrow');

        target.get('v.isTrue') ? target.set('v.isTrue',false) : target.set('v.isTrue',true);
        target2.get('v.isTrue') ? target2.set('v.isTrue',false) : target2.set('v.isTrue',true);
    },
})