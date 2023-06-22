({
    doInit: function (cmp, event, helper) {
        var theme = cmp.get("v.theme");
        var recordId = cmp.get("v.recordId");
        var recordTypeId = cmp.get("v.recordTypeId");
        var userProfile =cmp.get("v.userProfile");
        let button = cmp.find('disablebuttonid');
        let button2 = cmp.find('disablebuttonid2');
        // console.log("userProfile: "+cmp.get("v.userProfile"));

        if (userProfile.match("TMB Retail")) {
            // console.log("TMB Retail true");
            button.set('v.disabled',true);
            button2.set('v.disabled',true);
        }else{
            // console.log("TMB Retail false");
        }
        // console.log("editRecordId : ", recordId);

        if (cmp.get("v.recordId")) {
            cmp.set("v.isEdit", true);
            cmp.set("v.title", "Edit Customer");
            helper.getEditAccountRecord(cmp, event, helper, recordId);
            var a = cmp.get('c.loadDataCustInfo');
            $A.enqueueAction(a);
        }
        
        
    },

    loadDataCustInfo: function (cmp, event, helper){
    var sectionName ="ComPros:Customer Information";
    helper.loadData(cmp, event, helper,sectionName)
    var a = cmp.get('c.loadDataProdInterest');
    $A.enqueueAction(a);
    },

    loadDataProdInterest: function (cmp, event, helper){
    var sectionName ="ComPros:Product Interest";
    helper.loadData(cmp, event, helper,sectionName)
    var a = cmp.get('c.loadDataCustSource');
    $A.enqueueAction(a);
    },

    loadDataCustSource: function (cmp, event, helper){
    var sectionName ="ComPros:Customer Source";
    helper.loadData(cmp, event, helper,sectionName)
    var a = cmp.get('c.loadDataReassCust');
    $A.enqueueAction(a);
    },

    loadDataReassCust: function (cmp, event, helper){
    var sectionName ="ComPros:Re-assignment Customer";
    helper.loadData(cmp, event, helper,sectionName)
    }, 

    handleSubmit: function (cmp, event, helper) {
        event.preventDefault(); // Prevent default submit
        //var fields = event.getParam("fields");
        helper.handleFormSubmit(cmp, event, helper)
    },

    handleCancel: function (cmp, event, helper) {
        var editMode = cmp.get("v.isEdit");
        // console.log(editMode);
        // console.log(cmp.get("v.isEdit"));
        var cancelEvent;
        //Create mode
        if (editMode == false) {
            cancelEvent = $A.get("e.force:navigateToObjectHome");
            cancelEvent.setParams({
                "scope": "Account"
            });
            //Edit mode
        } else {
            cancelEvent = $A.get("e.force:navigateToSObject");
            cancelEvent.setParams({
                "recordId": cmp.get("v.recordId"),
                "slideDevName": "detail"
            });
        }
        cancelEvent.fire();
        helper.closeSubtab(cmp, event, helper);
    },

    handleSuccess: function (cmp, event, helper) {
        // Show toast
        var toastEvent = $A.get("e.force:showToast");
        if (cmp.get("v.recordId") != '') {
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": "Account record has been update successfully."
            });
        } else {
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": "Account record has been create successfully."
            });
        }
        toastEvent.fire();

        //navigate to recently update of created
        var navigateTo = $A.get("e.force:navigateToSObject");
        navigateTo.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navigateTo.fire();
        helper.closeSubtab(cmp,event,helper);

    },

    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections')
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    
    handleError: function (component, event, helper){
        component.set('v.spinner', false);
        var error = event.getParam("error");
        
        if((error != null ||error != '') && JSON.stringify(error) != '{}' && typeof(error) !='undefined'){
            var errorMap = error.body.output;
            //console.log(JSON.stringify(errorMap));
            var errorMessage = '';
            var errorCode = '';
            if(errorMap.errors.length>0){
                errorMessage=errorMap.errors[0].message;
                errorCode = errorMap.errors[0].errorCode;
            }else{
                for (var k in errorMap.fieldErrors) {
                    errorMessage = errorMap.fieldErrors[k][0].message;
                    errorCode = errorMap.fieldErrors[k][0].errorCode;
                    break;
                }
            }
            if(errorCode == "INSUFFICIENT_ACCESS"){
                component.set("v.isAccess",false);
                component.set("v.isError",true);
            } else {
                component.set("v.isError",true);
            }
            
            errorMessage = errorMessage.replace('"', '').replace('"', '');
            // console.log(errorMessage);


            component.set("v.error",errorMessage);

            // var toastEvent = $A.get("e.force:showToast");
            // toastEvent.setParams({
            //     title: "Error!",
            //     message: errorMessage,
            //     type: "error"
            // });
            // toastEvent.fire();
        }        
    },
})