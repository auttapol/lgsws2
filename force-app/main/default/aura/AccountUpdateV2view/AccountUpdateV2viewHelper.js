({
	getEditAccountRecord : function(cmp,event,helper) {
		var recordId = cmp.get("v.recordId");
		var action = cmp.get('c.getAccountCustomer');
        action.setParams({ 
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // console.log(result);
                // console.log(result.Name);
                cmp.set("v.acctRec",result);
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    // console.log(error.message);
                });
            }
        });
        $A.enqueueAction(action);
    },
    loadData : function(cmp,event,helper){
        var action = cmp.get(`c.loadData`);
        action.setParams({
            sectionName: cmp.get("v.sectionName"),
            sectionName2: cmp.get("v.sectionName2"),
            sectionName3: cmp.get("v.sectionName3"),
            sectionName4: cmp.get("v.sectionName4"),
            recordId:cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // console.log(result);
                cmp.set("v.canVisible",result)
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    // console.log(error.message);
                });
            }
        });
        $A.enqueueAction(action);
        
    },
	
	handleFormSubmit : function(cmp,event,helper){
        cmp.find('recordCreateForm').submit(); 
	},
	closeSubtab : function(cmp,event,helper){
        //close subtab
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            // console.log(error);
        });
	}
})