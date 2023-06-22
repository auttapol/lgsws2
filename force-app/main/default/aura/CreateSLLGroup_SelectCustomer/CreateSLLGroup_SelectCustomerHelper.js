({
    getReasonList: function(cmp) {
        let action = cmp.get("c.getReasonList");
        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state == "SUCCESS") {
                let result = response.getReturnValue();
                if (result.length > 0) {
                    cmp.set('v.reasonList', result);
                }
            }

        })
        $A.enqueueAction(action)
    },
})