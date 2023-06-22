({
    onInit: function (component, event, helper) {
        var accid = component.get("v.accid");
        var recordId = component.get("v.recordId");
        var recordTypeId = component.get("v.recordTypeId");
        var theme = component.get("v.theme");
        //alert(window.innerWidth + " | " + screen.width + " | " + theme +" | #Test42");
       	//console.log(theme);
        //console.log(recordId);
        //console.log(recordTypeId);
        //console.log(accid);
        
        helper.getPicklistValue(component,"Contact","Salutation","v.Salutation");
        helper.getCountry(component,event,helper);
        
        // if(accid!="" && theme == "Theme4t"){
        //     var lookup = component.find("lookupCmpAccount");
        //     lookup.set("v.value",accid);
        // }
        
        if(!recordId){
            component.set("v.isEdit",false);
            component.set("v.ContactRec.C_Country_PE__c","Thailand");
            component.set("v.ContactRec.Account__c",accid);
            helper.getProvince(component,event,helper);
        } else {
            component.set("v.Title","Edit Contact");
            component.set("v.isEdit",true);
            helper.getRecord(component,event,helper,recordId);
        }
       
    },
    handleSubmit : function(component, event, helper) {
        var con = component.get("v.ContactRec");
        var theme = component.get("v.theme");
 
        component.set("v.ContactRec.AccountId",component.get("v.accid"));
        var acc = component.get("v.ContactRec.AccountId");
        var lastname = component.get("v.ContactRec.Last_Name__c");
        var idType = component.get("v.ContactRec.ID_Type_PE__c");
        var idNumber = component.get("v.ContactRec.ID_Number_PE__c");
  
        component.set("v.ContactRec.AccountId",acc);
        component.set("v.ContactRec.LastName",lastname);
       	event.preventDefault(); // Prevent default submit

        if( (( idType!="" && idType!=undefined ) && (idNumber=="" || idNumber==undefined)) || ( acc=="" || acc== undefined )  ){
            
        } else {
            helper.handleFormSubmit(component,event,helper)
        }
        
        //console.log('handleSubmit');
        
        
    },
    
    handleCancel : function(component, event, helper) {
        var editMode = component.get("v.isEdit");
        //console.log(editMode);
        //console.log(component.get("v.isEdit"));
        var cancelEvent;
        var theme = component.get("v.theme");

        //Create mode
        if(editMode == false && theme=="Theme4u"){
            helper.closeSubtab(component,event,helper);
        } else if( theme=="Theme4t" ){
            var navService = component.find('navService');
            navService.navigate({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/PreviousPage'
                }
            }, true);
        } else {
            cancelEvent = $A.get("e.force:navigateToSObject");
            cancelEvent.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
            cancelEvent.fire();
        }
        
        
        helper.closeSubtab(component,event,helper);
    },	
    handleSuccess: function(component, event, helper) {
        
        // Show toast
        var toastEvent = $A.get("e.force:showToast");
        var idType = component.get("v.ContactRec.ID_Type_PE__c");
        var idNumber = component.get("v.ContactRec.ID_Number_PE__c");
		var acc = component.get("v.ContactRec.AccountId");
        if( (( idType!="" && idType!=undefined ) && (idNumber=="" || idNumber==undefined)) || ( acc=="" || acc== undefined )  ){
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "ID Number can not be empty ."
            });
            toastEvent.fire();

        }
        else if(component.get("v.recordId")!=''){
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": "Contact record has been update successfully."
            });
            toastEvent.fire();
        	helper.navigateToObject(component, event, helper);
        }else{
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": "Contact record has been create successfully."
            });
            toastEvent.fire();
        	helper.navigateToObject(component, event, helper);
        }
        
   		
    },
    salutationChange: function(component, event, helper) {
        var cmp = component.find("inputSalutation");
        component.set("v.ContactRec.Salutation",cmp.get("v.value"));
    },
    
    countryChange: function(component, event, helper) {
        var cmp = component.find("inputCountry");
        component.set("v.ContactRec.C_Country_PE__c",cmp.get("v.value"));
        helper.getProvince(component, event, helper);
    },
    provinceChange: function(component, event, helper) {
        var cmp = component.find("inputProvince");
        component.set("v.ContactRec.C_Province_PE__c",cmp.get("v.value"));
        var selectedProvince = component.get("v.ContactRec.C_Province_PE__c");
        helper.getDistrict(component,event,helper,selectedProvince);
        component.set("v.ContactRec.C_AddressLine5_PE__c","");
        component.set("v.SubDistrict",[]);
        component.set("v.ContactRec.C_AddressLine4_PE__c","");
        component.set("v.PostalCode",[]);
        component.set("v.ContactRec.C_Zipcode_PE__c","");
    },
    districtChange: function(component, event, helper) {
        var cmp = component.find("inputDistrict");
        component.set("v.ContactRec.C_AddressLine5_PE__c",cmp.get("v.value"));
        var selectedDistrict = component.get("v.ContactRec.C_AddressLine5_PE__c");
        helper.getSubDistrict(component,event,helper,selectedDistrict);
        component.set("v.PostalCode",[]);
        component.set("v.ContactRec.C_Zipcode_PE__c","");
    },
    subdistrictChange: function(component, event, helper) {
        var cmp = component.find("inputSubDistrict");
        component.set("v.ContactRec.C_AddressLine4_PE__c",cmp.get("v.value"));
        var selectedSubDistrict = component.get("v.ContactRec.C_AddressLine4_PE__c");
        var selectedDistrict = component.get("v.ContactRec.C_AddressLine5_PE__c");
        helper.getPostalCode(component,event,helper,selectedDistrict,selectedSubDistrict);
    },
    postalChange: function(component, event, helper) {
        var cmp = component.find("inputPostalCode");
        component.set("v.ContactRec.C_Zipcode_PE__c",cmp.get("v.value"));
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
            //console.log(errorCode," : ",errorMessage);

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