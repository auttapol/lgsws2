({

	openSubtab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var recordId = component.get("v.simpleRecord");
        workspaceAPI.openSubtab({
            url: '#/sObject/' + recordId.Id ,
            focus: true
        });
    },
})