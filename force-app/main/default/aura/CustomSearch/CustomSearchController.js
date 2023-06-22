({
    init : function(component, event, helper) {
        //var recordId = component.get('v.caseId');
        //var searchText = component.get('v.searchText');
        var myPageRef = component.get("v.pageReference");
        var result = myPageRef && myPageRef.state ? myPageRef.state.c__caseId : "";
        component.set("v.caseId", result);
        //console.log('caseId:',result);
        if(result.startsWith("500"))
        {
            helper.setTabNameEmail(component,event,helper,result);
            var action = component.get('c.searchContactFromEmail');
            action.setParams(
                {
                    recordId: result
                });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var recordList = response.getReturnValue();
                    //console.log(recordList);
                    component.set('v.recordList',recordList);                  
                }
            });
            $A.enqueueAction(action);
        }
        if(result.startsWith("570"))
        {
            helper.setTabNameChat(component,event,helper,result);
            var action = component.get('c.searchContactFromChat');
            action.setParams(
                {
                    recordId: result
                });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var recordList = response.getReturnValue();
                    //console.log(recordList);
                    component.set('v.recordList',recordList);
                }
            });
            $A.enqueueAction(action);
        }
        
    }
})