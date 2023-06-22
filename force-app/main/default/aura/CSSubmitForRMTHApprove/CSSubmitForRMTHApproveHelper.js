({
    displayToast: function (type, message) {
        var duration = 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },

    showSpinner : function(component) {
        component.set('v.isLoading', true);
    },

    hideSpinner : function(component){
        component.set('v.isLoading', false);
    },

    getRecordInfo : function(component, helper){
        var recordId = component.get('v.recordId');
        var action = component.get('c.getRecordInfo');

        action.setParams({
            "eSuitId": recordId,
        });

        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    component.set('v.e_client_suit', result);
                    if (result.CS_Stamped_Customer_Segment__c == 'CB'
                        || result.CS_Stamped_Customer_Segment__c == 'MB'
                        || result.CS_Stamped_Customer_Segment__c == 'FI'
                       ) {
                        component.set('v.isShowSelectRmTh', true);
                    }
                }
            }else if (response.getState() === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.isError', true);
                        component.set('v.errorMessage', errors[0].message);
                    }
                }
                // helper.hideSpinner(component);
            }else {
                console.error(response);
                // helper.hideSpinner(component);
            }

            // helper.hideSpinner(component);
        });

        if(recordId) $A.enqueueAction(action);
    },

    submitRequest : function(component, helper){
        // helper.showSpinner(component);
        var action = component.get('c.submitRequest');

        var recordId = component.get('v.recordId');
        var selectApproverId = component.get('v.selectedRecord.Id');
        var remark = component.get('v.remark');
        var isRequireRMTH = component.get('v.isShowSelectRmTh');

        if (isRequireRMTH && (selectApproverId == null || selectApproverId == '')){
            helper.displayToast('Error', 'Please select RM TH for approve!');
        }
        else{

            action.setParams({
                "eClientId": recordId,
                "selectApproverId": selectApproverId,
                "remark": remark,
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    if (result == true){
                        helper.displayToast('Success', 'Send request success.');
                    }
                    else{
                        helper.displayToast('Error', 'Send Request Failed, please contact your administrator!!!');
                    }
                }else if (state === "ERROR") {
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set('v.isError', true);
                            component.set('v.errorMessage', errors[0].message);
                        }
                    }
                } else {
                    console.error(response);
                }
                // helper.hideSpinner(component);
            });

            if(remark && remark.length > 100000){
                component.set('v.isError', true);
                component.set('v.errorMessage', 'Record can not be submitted due to Remark field has more than 100000 Characters.');
                // helper.hideSpinner(component);
                return;
            }else{
                $A.enqueueAction(action);
            }
        }
    },

    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method
        var action = component.get('c.fetchUser');
        // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord,
        });
        // set a callBack
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
            // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", 'Search Result...');
                }

                // set searchResult list with return value from server.
                component.set("v.listOfSearchUsers", storeResponse);
            }
        });
        // enqueue the Action
        $A.enqueueAction(action);
    },
})