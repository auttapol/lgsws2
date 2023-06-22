({
    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        }).catch(function(error) {
            // console.log(error);
        });
    },

    clickSave : function(component, event, helper) {
        component.set('v.isLoading', true);
        
        var recordId = component.get('v.recordId');
        //ส่ง v.sllGroupRec ไปแปลงค่าที่ helper
        var sllRec = helper.parseObj(component.get('v.sllGroupRec'));
        //set parameter ค่าเก่า
        var oldsName = sllRec.Name;
        var oldPrimCus = sllRec.Primary_Customer__c;
        var oldPAMId = sllRec.PAM__c;
        var oldRemark = sllRec.Remark__c;
        //set parameter ค่าใหม่
        var selectedName = helper.parseObj(component.get('v.GroupName'));
        var selectedPrimCus = helper.parseObj(component.get('v.primCust'));
        var selectedPAMId = helper.parseObj(component.get('v.pam'));
        var selectedRemark = helper.parseObj(component.get('v.remark'));

        //Check value มีการเปลี่ยนแปลงหรือไม่
        var changeCond = selectedName !== oldsName || selectedPrimCus !== oldPrimCus ||  selectedPAMId !== oldPAMId || selectedRemark !== oldRemark;
        //Check value แต่ล่ะ Field เป็นค่าว่างหรือไม่
        var isNoBlankCond = selectedName && selectedPrimCus != '' && selectedPAMId != '' && selectedRemark;

        if(!changeCond) {
            //value ไม่มีการเปลี่ยนแปลง ให้ปิดแท็บ
            helper.closeAction(component, event, helper);
        } else {
            //value มีการเปลี่ยนแปลง ให้บันทึกข้อมูล
            if(isNoBlankCond){
                //value มีค่า
                //ค่าที่ต้องการจะส่งไป apex class
                let action = component.get("c.editSllG");
                action.setParams({
                    "recordId": recordId,
                    "selectedName": selectedName,
                    "selectedPrimCus": selectedPrimCus,
                    "selectedPAMId": selectedPAMId,
                    "selectedRemark": selectedRemark
                });
                //apex class ส่งค่ากลับมา
                action.setCallback(this, function(response){
                    //get State ที่ส่งมาจาก apex class 
                    let state = response.getState();
                    
                    if(state === "SUCCESS" && component.isValid()) {
                    //Apex Class state === SUCCESS
                        //get ค่า Value ที่ส่งมาจาก apex class
                        var res = response.getReturnValue();
                        if(res == 'active') {
                            //PAM Active
                            component.set('v.isLoading', false);

                            helper.displayToast('success', $A.get("$Label.c.SLLGroupMessage10"));
                            helper.closeAction(component, event, helper);
                        } else {
                            //PAM Not Active
                            component.set('v.isLoading', false);
                            helper.displayToast('error', $A.get("$Label.c.SLLGroupMessage4"));
                        }
                    } else if(state === 'ERROR') {
                    // Apex Class state === ERROR
                        component.set('v.isLoading', false);
                        //get error
                        var errorRes = action.getError();
                        
                        if (errorRes) {
                            
                            if (errorRes[0] && errorRes[0].message) {
                                if(errorRes[0].message.includes('The Primary Customer is already in another SLL Group')) {
                                    helper.displayToast('error', $A.get("$Label.c.SLLGroupMessage13"));
                                } else if(errorRes[0].message.includes("The SLL Group Name is already used in another SLL Group.")){
                                    helper.displayToast('error', $A.get("$Label.c.SLLGroupMessage13"));
                                } else if(errorRes[0].message.includes("This record is currently in an approval process.")){
                                    helper.displayToast('error', $A.get("$Label.c.RequestChangeOwnerMessage2"));
                                } else if(errorRes[0].message.includes("This record is locked. If you need to edit it, contact your admin")){
                                    helper.displayToast('error', $A.get("$Label.c.RequestChangeOwnerMessage2"));
                                } else if(errorRes[0].message.includes("Value does not exist or does not match filter criteria.: [PAM__c]")){
                                    helper.displayToast('error', $A.get("$Label.c.SLLGroupMessage18"));
                                } else {
                                    //Apex Class ERROR อื่นๆ
                                    helper.displayToast('error', errorRes[0].message);
                                }
                            }else{
                                helper.displayToast('error', errorRes);
                            }
                        }else{
                            helper.displayToast('error', errorRes);
                        }
                    } else {
                        component.set('v.isLoading', false);
                        var errorRes = action.getError();

                        helper.displayToast('error', errorRes);
                    }
                });
                $A.enqueueAction(action);
            }else {
                //value ไม่มีค่าตั้งแต่ 1 field
                component.set('v.isLoading', false);
                helper.displayToast('error', $A.get("$Label.c.SLLGroupMessage7"));
            }
         }
    },

    onChangeSllRec : function (component, event, helper) {
        //ส่ง v.sllGroupRec ไปแปลงค่าที่ helper
        var sllRec = helper.parseObj(component.get('v.sllGroupRec'));
        //set ค่าให้กับ component เพื่อไปแสดงที่ ui
        component.set('v.GroupName', sllRec.Name);
        component.set('v.primCust', sllRec.Primary_Customer__c);
        component.set('v.pam', sllRec.PAM__c);
        component.set('v.remark', sllRec.Remark__c);
        component.set('v.isLoading', false);
    },

    clickCancel : function(component, event, helper){
        helper.closeAction(component, event, helper);
    },
})