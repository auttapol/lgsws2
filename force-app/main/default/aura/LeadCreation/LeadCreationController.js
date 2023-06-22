({
    doInit: function (component, event, helper) {
        helper.showSpinner(component);
        var recordId = component.get("v.recordId");
        var recordTypeId = component.get("v.recordTypeId");
        
        //decode customer name
       
        
        helper.getRecordTypeName(component, event, helper, recordTypeId);
        helper.getErrorMessage(component);
        helper.checkBrowser(component);
        //helper.populatedAccount(component, event, helper,eventfields);

        //create mode
        if (!recordId) {
            component.set("v.isEdit", false);
            component.set("v.editFormTextTitle", 'New Lead');
            if(component.get("v.defaultValue.RTL_Referral__c") != ''){
                helper.getReferralRecord(component,event,helper);
            }
            helper.thaiEncode(component,event,helper);
        }
        //edit mode  
        else {
            component.set("v.isEdit", true);
            component.set("v.editFormTextTitle", 'Edit Lead');
            helper.getEditLeadRecord(component, event, helper, recordId);
            helper.isHasAccess(component, event, helper);
            
            if(component.get("v.defaultValue.RTL_Referral__c") != ''){
                var refState = 'Edit'
                helper.getReferralRecord(component,event,helper);
            }
        }

    },
    handleLoad: function (component, event, helper) {
        helper.hideSpinner(component);
        var defaultValue = component.get('v.defaultValue');
        
        // default value
        if (Object.keys(defaultValue).length > 0 && !component.get('v.recordId')) {
            var fields = Object.keys(defaultValue);
            
            component.find('fieldName').forEach(cmp => {
                if (fields.includes(cmp.get('v.fieldName'))) {
                    cmp.set('v.value', defaultValue[cmp.get('v.fieldName')]);
                }
            });
            
        }
    },
    handleSubmit: function (component, event, helper) {
        event.preventDefault(); // Prevent default submit
        helper.showSpinner(component);

        helper.handleFormSubmit(component, event, helper);
    },
    handleCancel: function (component, event, helper) {
        
        if(component.get("v.isEdit") == true){
            helper.closeTab(component);
        }else{
            if(component.get("v.theme") =='Theme4u'){
                
                helper.closeTab(component); 
            }else{
                
                var device = $A.get("$Browser.isAndroid");
                //helper.closeTab(component); 
                //iOS and Android handle
               if(device == true){
                    helper.navHome(component,event,helper);
                }else{
                    helper.closeTab(component);
                }
            }
            
        }
        
    },
    handleSuccess: function (component, event, helper) {
        // Show toast
        component.set('v.errorCheck', true);
        component.set("v.error",false);
        var toastEvent = $A.get("e.force:showToast");
        if (component.get("v.recordId") != '') {
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": "Lead record has been update successfully."
            });
        } else {
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": "Lead record has been create successfully."
            });
        }
        toastEvent.fire();
        //navigate to recently update of created
        component.set('v.recordId', event.getParam("response").id);
        
        //helper.closeAndrefreshTab(component,event,helper)
        // //// Bypass FLS Account Field
        if(component.get("v.AccountIdByPass") !=''){
            helper.linkCustomerBypass(component,event,helper);
        }
        if(component.get("v.CompleteBypass") == true){
            helper.completeBypass(component,event,helper);
            
        }
        
        helper.navigateToObject(component,event,helper,component.get('v.recordId'))
    },
    handleToggle: function (component, event, helper) {
        component.set('v.activeSections', ['A', 'B', 'C', 'D']);
    },
    handleError: function (component, event, helper){
        component.set('v.spinner', false);
        var error = event.getParam("error");
        
        if(typeof(error) =='undefined'){
            
        }
        //mobile Error
        if((error != null ||error != '') && JSON.stringify(error) != '{}' && typeof(error) !='undefined'&& component.get('v.error')== true){
            if(error.body.output.fieldErrors.Mobile_No__c!= null){
                
                var mobileError = error.body.output.fieldErrors.Mobile_No__c[0].message;
                component.set('v.errorCheck', false);
                component.set("v.errorText",mobileError);
            //Id number
            }else if(error.body.output.fieldErrors.ID_Number__c!= null){
                
                var IdNumberError = error.body.output.fieldErrors.ID_Number__c[0].message;
                component.set('v.errorCheck', false);
                component.set("v.errorText",'Errors ID Number: ' +IdNumberError);
            }else if(error.body.output.errors[0] != null){
                var recorderror = JSON.stringify(error.body.output.errors[0].message);
                

                if(recorderror == '\"invalid record type\"'){
                    
                    //helper.navigateToObject(component,event,helper,component.get('v.recordId'))
                }else{
                    component.set("v.AccessPermission", false);
                }
                
                var accesserror = error.body.output.errors[0].message;
                //var toastEvent = $A.get("e.force:showToast");
                var permission = 'Lead cannot be created. Your access is set to \'Read Only \'.(ไม่สามารถ สร้าง Lead ได้ เนื่องจากสิทธิ์เข้าถึงลูกค้าได้เพียง\"ดูได้อย่างเดียว\")'
            
            }else{
                component.set('v.errorCheck', false);
                component.set("v.errorText","An error occurred while trying to update the record");
            }
        }else{

        }
        
        // component.find('LeadMessage').setError(errorMessages);
    },
    salutationChange: function(component, event, helper) {
        var cmp = component.find("inputSalutation");
        component.set("v.salutationValue",cmp.get("v.value"));
        
    },
})