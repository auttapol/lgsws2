({
    getEditAccountRecord: function (cmp, event, helper, recordId) {
        
        var action = cmp.get(`c.getAccountCustomer`);
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // console.log(result);
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

    handleFormSubmit: function (cmp, event, helper) {
        // var account = cmp.get("v.acctRec");
        cmp.find('recordCreateForm').submit();
    },

    loadData: function (cmp, event, helper,sectionName){
        // console.log("Start");
        // console.log(sectionName);
        var recordId=cmp.get("v.recordId");
        var action = cmp.get("c.loadData");
        action.setParams({
            sectionName:sectionName,
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            // console.log("Getin");
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // console.log(result);
                
                    if(sectionName=="ComPros:Customer Information"){ 
                        cmp.set("v.displaySectionCustInfo",result);
                    }else if(sectionName=="ComPros:Product Interest"){
                        cmp.set("v.displaySectionProdInterest",result);
                    }else if(sectionName=="ComPros:Customer Source"){
                        cmp.set("v.displaySectionCustSource",result);
                    }else if(sectionName=="ComPros:Re-assignment Customer"){
                        cmp.set("v.displaySectionReassCust",result);
                    }
                    // console.log(sectionName , result);
                
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    // console.log(error.message);
                });
            }
        });
        
        // console.log("GetOut");
        $A.enqueueAction(action);
    },
    
    closeSubtab: function (cmp, event, helper) {
        //close subtab
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function (error) {
                // console.log(error);
            });
    }
})