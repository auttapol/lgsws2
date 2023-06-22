({
    onInit: function (component, event, helper) {
        var type = component.get('v.type');
        if (type == 'REFERENCE') {
            helper.getReference(component, event, helper)
        } else if (type == 'REFERENCE_ADDON') {
            helper.getReferenceAddon(component, event, helper)
        }
    }
})