({
    getRecord: function (component, event, helper) {
        var accountId = component.get("v.accountId");
        var action = component.get("c.getAcctRec");
        action.setParams({
            accountId: accountId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.acctRec", result.acctRec);
                component.set("v.checkApprove", result.checkApprove);
                component.set("v.requestPermission", result.permission);
                component.set("v.isThrowError" , (result.checkApprove || !result.permission));
                helper.setSegmentTypeSelect(component, event, helper);
            } else {
                var errors = response.getError();
                errors.forEach((error) => {
                    console.log(error.message);
                });
                component.set("v.isThrowError", true);
                component.set("v.ThrowErrorMessage", errors[0].message);
                component.set("v.onInit", false);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    
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

    handleFormSubmit: function (component, event, helper) {
        var accountId = component.get("v.accountId");
        var newSegment = component.find("toBeSegment").get("v.value");
        var remark = component.find("remark").get("v.value");
        var action = component.get("c.saveRecord");
        action.setParams({
            accountId: accountId,
            newSegment: newSegment,
            remark: remark
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.hideSpinner(component, event, helper);
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
                helper.displayToast('Success', 'Send request success.');
            } else {
                var errors = response.getError();
                if (errors) {
                    component.set("v.isError", true);
                    if (newSegment == "" || newSegment == null) {
                        component.set("v.errMsg", "Please select new segment.");
                    } else if (errors[0].message != null) {
                        component.set("v.errMsg", errors[0].message);
                        console.log(errors);
                    }
                } else {
                    // console.error(response);
                }
                helper.hideSpinner(component);
            }
        });
        if (remark && remark.length > 100000) {
            component.set("v.isError", true);
            component.set(
                "v.errMsg",
                "Record can not be submitted due to Remark field has more than 100000 Characters."
            );
            helper.hideSpinner(component);
            return;
        } else {
            $A.enqueueAction(action);
        }
    },
    
    closeSubtab: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        
        //close subtab
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function(response) {
        //     var focusedTabId = response.tabId;
        //     workspaceAPI.closeTab({tabId: focusedTabId});
        // })
        // .catch(function(error) {
        // });
    },

    setSegmentTypeSelect: function (component, event, helper) {
        var segmentType = ["SE", "BB", "MB", "CB"];
        segmentType = segmentType.filter((e) => e !== component.get("v.acctRec.Core_Banking_Suggested_Segment__c"));
        component.set("v.segmentType", segmentType);
        component.set("v.onInit", false);
        component.set("v.isLoading", false);
    },

    showSpinner: function (component) {
        // make Spinner attribute true for displaying loading spinner
        component.set("v.isLoading", true);
    },
    
    hideSpinner: function (component) {
        // make Spinner attribute to false for hiding loading spinner
        component.set("v.isLoading", false);
    }
});