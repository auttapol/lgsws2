({
    requestToInactiveSLLGroup: function (cmp, recordId, requestComment) {
        let action = cmp.get("c.requestToInactiveSLLGroup");
        action.setParams({
            "recordId": recordId,
            "comment": requestComment
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            cmp.set("v.isLoading", false);
            if (state === "SUCCESS") {
                // let result = response.getReturnValue();
                let dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                this.toastSuccess('Success')
                $A.get("e.force:refreshView").fire();
            } else if(state === 'ERROR') {
                var errorRes = action.getError();
                
                if (errorRes) {
                    if (errorRes[0] && errorRes[0].message) {
                        if(errorRes[0].message.includes("The Primary Customer is already in another SLL Group")) {
                            this.toastError($A.get("$Label.c.SLLGroupMessage13"));
                        } else if(errorRes[0].message.includes("This record is currently in an approval process.") ||
                        errorRes[0].message.includes("This record is locked. If you need to edit it, contact your admin")){
                            this.toastError($A.get("$Label.c.RequestChangeOwnerMessage2"));
                        } else if(errorRes[0].message.includes("Value does not exist or does not match filter criteria.: [PAM__c]")){
                            this.toastError($A.get("$Label.c.SLLGroupMessage18"));
                        } else {
                            this.toastError(errorRes[0].message);
                        }
                    }else{
                        this.toastError(errorRes);
                    }
                }else{
                    this.toastError(errorRes);
                }
            } else {
                var errorRes = action.getError();
                this.toastError(errorRes);
            }
            // component.set('v.isLoading', false);
        }); // prepare callout
        $A.enqueueAction(action)
    },

    toastError: function (errMsg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "message": errMsg
        });
        toastEvent.fire();
    },

    toastSuccess: function (errMsg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": errMsg
        });
        toastEvent.fire();
    }
})