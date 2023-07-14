({
    doInit : function(component, event, helper) {
        console.log('Start!');
        component.set("v.totalWeight", 100)
        component.set("v.LeadList",[]);
		var recordId = component.get("v.recordId");
        if(recordId){
            component.set("v.loaded", true);
        }else{
            helper.createfirst(component, event, helper);
        }
        // helper.getScoringList(component, event, helper)
        
        var action = component.get("c.getFieldName");
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var result = response.getReturnValue();
                // console.log('Map : ' +  JSON.stringify(result.mapfieldNamewithtype));
                // component.set("v.readonly",false);
                component.set("v.mapfieldList", result.fieldList);
                // console.log('mapfieldList '+ JSON.stringify( result.fieldList));
                component.set("v.mapfieldtype", result.mapfieldNamewithtype);
                console.log('mapfieldtype '+ JSON.stringify( result.mapfieldNamewithtype));
                component.set("v.mapfieldLength", result.mapfieldNamewithLength);
                component.set("v.mapfieldLabel", result.mapfieldAPIwithLabel);
                component.set("v.mapWrapperLabel",result.newMapAPiNameLabel);
                component.set("v.mapfieldAPI", result.newAPiNameWithLabel);
                //  console.log("API/Label "+ JSON.stringify(result.newMapAPiNameLabel) )
                // component.set("v.loaded",false);
                helper.getScoringList(component, event, helper)
                console.log("LeadList "+ JSON.stringify(component.get("v.LeadList")))
            }else{
        
                console.log('err ' + JSON.stringify(response.getError()));
                component.set("v.loaded",false);
            }
        });
        $A.enqueueAction(action);

        // var ScoringList = component.get("v.level1Rec");
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function(response) {
        //     var focusedTabId = response.tabId;
        //     workspaceAPI.setTabLabel({
        //         tabId: focusedTabId,
        //         label: ScoringList.Name
        //     });
        // })
        // .catch(function(error) {
        //     console.log(error);
        // });     
    },
    removeDeletedRow: function (component, event, helper) {
		var index = event.getParam("indexVar");
		var AllRowsList = component.get("v.LeadList");
		AllRowsList.splice(index, 1);
		component.set("v.LeadList", AllRowsList);
	},
	addNewRow: function (component, event, helper) {
		helper.createfirst(component, event, helper);
	},
    onSave: function (component, event, helper) { 
        var result = component.get("v.LeadList")
        var recordId = component.get("v.recordId");
        var totalWeight;
        if(recordId){
            totalWeight = component.get("v.level1Rec.Total_Weight__c");
        }else{
            totalWeight = component.get("v.totalWeight");
        }
        console.log('Before filter : '+ JSON.stringify(result));
        result = result.filter(x => x.APIName != '');
        // result = result.filter(elements => {
        //     return elements !== null;
        // });
        var myObjectKeys = Object.keys(result);
        if(result.length > 0 ){
           if(myObjectKeys.length > 0 ){
                var sumWeight = 0;

                for(var i=0;i<=(myObjectKeys.length - 1) ; i++){
                    
                    if(result[i].hasOwnProperty("APIName")){
                        if(!result[i].APIName){
                            // console.log(parseInt(result[i].Weight));
                            helper.displayToast(component, 'Error', 'Field Name is required.');
                            return null;
                        }if(result[i].hasOwnProperty("Weight")){
                            if(isNaN(parseInt(result[i].Weight))){
                                // console.log(parseInt(result[i].Weight));
                                helper.displayToast(component, 'Error', 'Weight value is required.');
                                return null;
                            }else{
                                sumWeight = parseInt(sumWeight) + parseInt(result[i].Weight);
                            }
                        }
                    }
                }
                console.log('Total weight : '+ totalWeight);
                console.log('Summary Weight : '+ sumWeight);
                if(totalWeight == sumWeight){
                    component.set("v.isActiveShowed", true); 
                }else{
                    component.set("v.isActiveShowed", false); 
                }
            }
            
        }
        helper.parseRecord(component, helper)      
	},
    // onchangeTotalWeight: function (component, event, helper) {
    //     var inputValue = event.getParam("value");
    //     var recordId = component.get("v.recordId")
    //     if(recordId){
    //         component.set("v.v.level1Rec.Total_Weight__c", inputValue);
    //     }
    //     component.set("v.totalWeight", inputValue);
    //     console.log('Total Weight --> '+ inputValue)
	// },
    onActive: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var totalWeight;
        if(recordId){
            totalWeight = component.get("v.level1Rec.Total_Weight__c");
        }else{
            totalWeight = component.get("v.totalWeight");
        }
        // helper.displayToast(component, 'Success', 'Active.');
        var result = component.get("v.LeadList");
        result = result.filter(x => x.APIName !== '');
        var myObjectKeys = Object.keys(result);
        
        if(myObjectKeys.length > 0 ){
            var sumWeight = 0;

            for(var i=0;i<=(myObjectKeys.length - 1) ; i++){
                if(result.length > 0 ){
                    if(result[i].hasOwnProperty("APIName")){
                        console.log(result[i].APIName)
                        if(!result[i].APIName){
                            // console.log(parseInt(result[i].Weight));
                            helper.displayToast(component, 'Error', 'Field Name is required.');
                            return null;
                        }
                        if(result[i].hasOwnProperty("Weight")){
                            if(!isNaN(parseInt(result[i].Weight))){
                                // console.log(parseInt(result[i].Weight));
                                sumWeight = parseInt(sumWeight) + parseInt(result[i].Weight);
                                // console.log('sumWeight = '+sumWeight);
                            }else{
                                console.log(parseInt(result[i].Weight));
                                helper.displayToast(component, 'Error', 'Weight value is required.');
                                return null;
                            } 
                        }
                    }  
                }
            }
            if(totalWeight == sumWeight){
                component.set("v.isEdit", true);
                component.set("v.sumWeight", sumWeight); 
                if(recordId){
                    component.set("v.level1Rec.IsActive__c", true);
                }else{
                    component.set("v.isActive",true);
                }

            }else{
                var errMessage = $A.get("$Label.c.LGS_Warning_messages");
                helper.displayToast(component, 'Error', errMessage)
                
            }
        }
        
        helper.parseRecord(component, helper)
        // helper.displayToast(component, 'Success', 'Save Success.');
        // console.log('LeadList --> '+ JSON.stringify(component.get("v.LeadList")))
	},
    onDeactive: function (component, event, helper) {
        var recordId = component.get("v.recordId")
        component.set("v.isEdit", false);
        if(recordId){
            component.set("v.level1Rec.IsActive__c", false);
        }else{
            component.set("v.isActive",false);
        }
        helper.parseRecord(component, helper)
        // component.set("v.isActive",false);
        console.log(JSON.stringify(component.get("v.level1Rec")));
        helper.displayToast(component, 'Success', 'Inactive.');
	},

    handleRefresh: function(component, event, helper) {
        // handle the refresh event
        console.log('Tab has been refreshed.');
        
        // refresh the tab manually
        var workspaceAPI = component.find("workspace");
        workspaceAPI.refreshTab({
            includeAllSubtabs: true
        });
    },
    onConfirm: function (component, event, helper){
        component.set("v.showModal",true);
    },
    onCancel: function (component, event, helper){
        component.set("v.showModal",false);
    },
})