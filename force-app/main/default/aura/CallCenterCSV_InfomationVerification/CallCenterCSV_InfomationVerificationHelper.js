({
    parseObj: function (objfieldsVerify) {
        return objfieldsVerify ? JSON.parse(JSON.stringify(objfieldsVerify)) : null;
    },
    startSpinner: function (component) {
        component.set('v.isRerender', true);
    },
    stopSpinner: function (component) {
        component.set('v.isRerender', false);
    },
    runInit: function (component, event, helper) {

        var url = component.get('v.CXMURL');
        var CXMId = component.get('v.CXMId');
        url = '/lightning/r/CXM_Survey__c/' + CXMId + '/view';
        url = '/lightning/r/CXM_Survey__c/' + 'a411m000000069OAAQ' + '/view';
        url = '/a411m000000069OAAQ';


        component.set('v.CXMURL', url);

        helper.getCXM(component, event, helper);
        helper.getComplaint(component, event, helper);
    },
    actionVerification: function (component, verId) {
        var helper = this;
        helper.startSpinner(component);
        var action = component.get('c.getVerification');
        //var action2 = component.get('c.getVerStatusColorCode');
        var action3 = component.get('c.getVerResultColorCode');

        action.setParams({
            "Id": verId
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Type').value = result.Customer_Type__c;
                    component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verify_By').value = result.Verification_Type__c;
                    component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Result').value = result.Verification_Result__c;
                    component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Xfer_Label').value = result.Xfer__c;
                    //component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Status').value = result.Verification_Status__c;
                    component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_FailReason').value = result.Fail_Reason__c;
                    // component.get('v.fieldsVerify').find(f => f.name == 'Verification_Action').value = result.Verification_Action__c ? result.Verification_Action__c.replace(/[,gr]\w/, '') : '';
                    
                    // component.get('v.fieldsVerify').find(f => f.name == 'Verification_Action').style = result.Verification_Action__c ? (result.Verification_Action__c.includes(',g') ? 'color: green;' : (result.Verification_Action__c.includes(',r') ? 'color: red;' : '')) : '';
                    
                    if (result.Verification_Status__c) {
                        component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Status').value = result.Verification_Status__c ? result.Verification_Status__c.split(',')[0] : '';                        

                        if (result.Verification_Status__c.split(',').length > 1) {
                    		component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Status').style = result.Verification_Status__c ? 'color: #' + result.Verification_Status__c.split(',')[1] + ';': '';
                        } else {
                            component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Status').style = result.Verification_Action__c ? 'color: #080707;': '';    
                        }
                    }
                    
                    if(result.Verification_Action__c) {
                        component.get('v.fieldsVerify').find(f => f.name == 'Verification_Action').value = result.Verification_Action__c ? result.Verification_Action__c.split(',')[0] : '';

                        if (result.Verification_Action__c.split(',').length > 1) {
                    		component.get('v.fieldsVerify').find(f => f.name == 'Verification_Action').style = result.Verification_Action__c ? 'color: #' + result.Verification_Action__c.split(',')[1] + ';': '';    
                        } else {
                            component.get('v.fieldsVerify').find(f => f.name == 'Verification_Action').style = result.Verification_Action__c ? 'color: #080707;': '';    
                        }
                    }

                    component.set('v.fieldsVerify', component.get('v.fieldsVerify'));
                    component.set('v.isActiveVerifySection', 'true');
/*
                    action2.setParams({
                        "Verification_Status": result.Verification_Status__c
                    });
*/
                    action3.setParams({
                        "Verification_Result": result.Verification_Result__c
                    });

                    //$A.enqueueAction(action2);
                    $A.enqueueAction(action3);
                }
            } else {
                console.error(response);
            }
            helper.stopSpinner(component);
        });
/*
        action2.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Status').value = Object.keys(result)[0];
                    var color = 'color: #' + result[(Object.keys(result)[0])] + ';';
                    // console.log('result ver action', result);
                    component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Status').style = color;
                    component.set('v.fieldsVerify', component.get('v.fieldsVerify'));
                }
            } else {
                console.error(response);
            }
        });
*/
        action3.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    var color = 'color: ' + result + ';';
                    component.get('v.fieldsVerify').find(f => f.name == 'CCPIN_Verification_Result').style = color;
                    component.set('v.fieldsVerify', component.get('v.fieldsVerify'));
                }
            } else {
                console.error(response);
            }
        });

        $A.enqueueAction(action);
    },
    getCXM: function (component, event, helper) {
        var action = component.get('c.getCXM');
        var recordId = component.get('v.recordId');
        action.setParams({
            'AccId': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValues = response.getReturnValue();
                console.log('CXMOBJ: ', returnValues);
                component.set('v.CXMObj', returnValues);
                component.set('v.hasCXM', true);
                component.set('v.isActiveCXMSection', 'true');
                helper.getCXMMeta(component, event, helper);
            } else if (state === 'ERROR') {

            }
        });
        $A.enqueueAction(action);
    },
    getCXMMeta: function (component, event, helper) {
        var action = component.get('c.getCXMMeta');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var CXMObj = component.get('v.CXMObj');
                var CXMMeta = response.getReturnValue();
                console.log('CXMMETA: ', CXMMeta);
                component.set('v.CXMMeta', CXMMeta);

                CXMMeta.forEach(mdt => {
                    if (CXMObj.Survey_Score__c <= mdt.Highest_Score__c && CXMObj.Survey_Score__c >= mdt.Lowest_Score__c) {
                        component.set('v.CXMFace', mdt.Emotion_Face__c);
                    }
                });

            }
        });
        $A.enqueueAction(action);
    },
        getComplaint: function (component, event, helper) {
        var action = component.get('c.getComplaint');
        var recordId = component.get('v.recordId');
        action.setParams({
            'accRecordId': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValues = response.getReturnValue();
                if(returnValues.length > 0){

                    component.set('v.complaintObj', returnValues);
                    component.set('v.hasComplaint', true);
                    component.set('v.isActiveComplaintSection', 'true');

                }
               // console.log('complaintObj: ', returnValues);
               

               /* returnValues.forEach(mdt => {
                    if (CXMObj.Survey_Score__c <= mdt.Highest_Score__c && CXMObj.Survey_Score__c >= mdt.Lowest_Score__c) {
                        component.set('v.CXMFace', mdt.Emotion_Face__c);
                    }
                }); */

            } else if (state === 'ERROR') {

            }
        });
        $A.enqueueAction(action);
    }
})