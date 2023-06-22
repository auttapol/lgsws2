({
    getPicklistValue : function(component,object,field,v) {
        var action = component.get("c.picklist_values");
        action.setParams({ object_name : object,
                          field_name : field});
        action.setCallback(this, function(response) {
            component.set(v,response.getReturnValue().slice(0,5));
            
        });
        $A.enqueueAction(action);
    },
    handleFormSubmit : function(component,event,helper){
        var contact = component.get("v.ContactRec");
        var eventFields = event.getParam("fields");
        var photo = component.find("inputPhoto").get("v.value");
        //console.log("image:",photo);
        //console.log(eventFields["Salutation"]);
        eventFields["Salutation"] = eventFields["Salutation"] ? eventFields["Salutation"] : contact.Salutation;
        eventFields["C_Province_PE__c"] = eventFields["C_Province_PE__c"] ? eventFields["C_Province_PE__c"] : contact.C_Province_PE__c;
        eventFields["C_AddressLine5_PE__c"] = eventFields["C_AddressLine5_PE__c"] ? eventFields["C_AddressLine5_PE__c"] : contact.C_AddressLine5_PE__c;
        eventFields["C_AddressLine4_PE__c"] = eventFields["C_AddressLine4_PE__c"] ? eventFields["C_AddressLine4_PE__c"] : contact.C_AddressLine4_PE__c;
        eventFields["C_Zipcode_PE__c"] = eventFields["C_Zipcode_PE__c"] ? eventFields["C_Zipcode_PE__c"] : contact.C_Zipcode_PE__c;
        eventFields["C_Country_PE__c"] = eventFields["C_Country_PE__c"] ? eventFields["C_Country_PE__c"] : contact.C_Country_PE__c;
        eventFields["Account__c"] = eventFields["Account__c"] ? eventFields["Account__c"] : contact.AccountId;
        eventFields["Last_Name__c"] = eventFields["LastName"] ? eventFields["LastName"] : contact.Last_Name__c;
        eventFields["RecordTypeId"] = eventFields["RecordTypeId"] ? eventFields["RecordTypeId"] : contact.RecordTypeId;
        eventFields["Photo__c"] = photo ? photo : eventFields["Photo__c"];
        //console.log(JSON.parse(JSON.stringify(eventFields)));
        component.find('recordCreateForm').submit(eventFields); 
        
    },
    navigateToObject : function(component,event,helper) {
        var theme = component.get("v.theme");
        if(component.get("v.isEdit") && (theme=="Theme4u") ){
            var _recordId = component.get('v.recordId');
            var workspaceAPI = component.find("workspace");

            workspaceAPI.getEnclosingTabId().then(function (tabId) {
                var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
                workspaceAPI.getTabInfo({
                    tabId: primaryTab
                }).then(function (response) {
                    if (response.recordId == _recordId && !response.isSubtab) {
                        workspaceAPI.refreshTab({
                            tabId: primaryTab,
                            includeAllSubtabs: false
                        });
                    }
        
                    var subtabs = response.subtabs.filter(f => f.pageReference.attributes.recordId == _recordId);
                    subtabs.forEach(e => {
                        workspaceAPI.refreshTab({
                            tabId: e.tabId,
                            includeAllSubtabs: false
                        });
                    })
        
                    setTimeout(() => {
                        workspaceAPI.closeTab({
                            tabId: tabId
                        });
                        
                        $A.get('e.force:refreshView').fire();
                        
                    }, 250);
                });
            
            })
            .catch(function (error) {
                //console.log(error);
            });
        } else {
            
            var navigateTo = $A.get("e.force:navigateToSObject");
            navigateTo.setParams({
                "isredirect":true,
                "recordId": event.getParam("response").id,
                "slideDevName": "detail"
            });
            navigateTo.fire();
        }
        
    },
    closeSubtab : function(component,event,helper){
        //close subtab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            //console.log(error);
        });
    },
    getCountry : function(component,event,helper){
        var action = component.get("c.countries");
        action.setCallback(this, function(response) {
            component.set("v.Country",response.getReturnValue());
            
        });
        $A.enqueueAction(action);
    },
    getProvince : function(component,event,helper,selectedProvince){
        var country = component.get("v.ContactRec.C_Country_PE__c");
        var recordId = component.get("v.recordId");
        if(country != 'Thailand'){
            //console.log('not thai');
            component.set("v.ContactRec.C_Province_PE__c","");
            component.set("v.ContactRec.C_AddressLine5_PE__c","");
            component.set("v.ContactRec.C_AddressLine4_PE__c","");
            component.set("v.ContactRec.C_Zipcode_PE__c","");
        } else {
            var action = component.get("c.provinces");
        	action.setCallback(this, function(response) {
            	component.set("v.Province",response.getReturnValue());
                if(recordId != ""){
                    window.setTimeout(
                    $A.getCallback( function() {
                        // Now set our preferred value
                        component.find("inputProvince").set("v.value", selectedProvince);
                    }));
                }
            });
            $A.enqueueAction(action);
        }
    },
    getDistrict : function(component,event,helper,selectedProvince,selectedDistrict){
        var action = component.get("c.districts");
        var recordId = component.get("v.recordId");
        action.setParams({ selectedProvince : selectedProvince});
        action.setCallback(this, function(response) {
            component.set("v.District",response.getReturnValue());
            
            if(recordId != ""){
                window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
                    component.find("inputDistrict").set("v.value", selectedDistrict);
                }));
            }
        });
        $A.enqueueAction(action);
        if( selectedProvince == ""){
            component.set("v.ContactRec.C_AddressLine5_PE__c","");
            component.set("v.SubDistrict",[]);
            component.set("v.ContactRec.C_AddressLine4_PE__c","");
            component.set("v.PostalCode",[]);
            component.set("v.ContactRec.C_Zipcode_PE__c","");
        }
        
    },
    getSubDistrict : function(component,event,helper,selectedDistrict,selectedSubDistrict){
        var action = component.get("c.subDistricts");
        var recordId = component.get("v.recordId");
        action.setParams({ selectedDistrict : selectedDistrict});
        action.setCallback(this, function(response) {
            component.set("v.SubDistrict",response.getReturnValue());
            if(recordId != ""){
                window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
                    component.find("inputSubDistrict").set("v.value", selectedSubDistrict);
                }));
            }
        });
        $A.enqueueAction(action);
        if(selectedDistrict == ""){
            component.set("v.ContactRec.C_AddressLine4_PE__c","");
            component.set("v.PostalCode",[]);
            component.set("v.ContactRec.C_Zipcode_PE__c","");
        }
        
    },
    getPostalCode : function(component,event,helper,selectedDistrict,selectedSubDistrict,selectedPostalCode){
        var action = component.get("c.postalCode");
        var recordId = component.get("v.recordId");
        action.setParams({ selectedDistrict : selectedDistrict,
            selectedSubDistrict : selectedSubDistrict});
        action.setCallback(this, function(response) {
            
            component.set("v.PostalCode",response.getReturnValue());
            
            if(recordId != ""){
                window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
                    component.find("inputPostalCode").set("v.value", selectedPostalCode);
                }));
            }
        });
        $A.enqueueAction(action);
        if(selectedSubDistrict == ""){
            component.set("v.ContactRec.C_Zipcode_PE__c","");
        }
        
    },
    
    getRecord : function(component,event,helper,recordId){
        var action = component.get("c.getContact");
        action.setParams({ recordId : recordId});
        action.setCallback(this, function(response) {
            var con = response.getReturnValue();
            component.set("v.ContactRec",con);
            //console.log("RecordTypeName",con.RecordType.Name);
            if(con.RecordType.Name == "Core bank"){
                component.set("v.isCoreBank",true);
                //console.log("isCoreBank",component.get("v.isCoreBank"));
                //console.log("isEdit",component.get("v.isEdit"));
            }
            helper.setValue(component,event,helper,con)
            window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
                    component.find("inputCountry").set("v.value", con.C_Country_PE__c);
                    component.find("inputSalutation").set("v.value", con.Salutation);
                    
                }));
        	});
        $A.enqueueAction(action);
        
    },
    setValue : function(component,event,helper,con){
        if(con.C_Country_PE__c == "Thailand"){
            helper.getProvince(component,event,helper,con.C_Province_PE__c);
            helper.getDistrict(component,event,helper,con.C_Province_PE__c,con.C_AddressLine5_PE__c);
            helper.getSubDistrict(component,event,helper,con.C_AddressLine5_PE__c,con.C_AddressLine4_PE__c);
            helper.getPostalCode(component,event,helper,con.C_AddressLine4_PE__c,con.C_Zipcode_PE__c);
        } 
  
    },
    displayToast : function(component,event,helper,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "info",
            "title": "info!",
            "message": message
        });
        toastEvent.fire();
    },
})