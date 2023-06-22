({
	getCXM : function (component, event , helper){
        var action = component.get('c.getCXM');
        var recordId = component.get('v.recordId');
        action.setParams({
            'AccId':recordId
        });
        action.setCallback(this , function(response){
            var state = response.getState();
            if (state === 'SUCCESS'){
                var returnValues = response.getReturnValue();
                // console.log('CXMOBJ: ',returnValues);
                component.set('v.CXMObj',returnValues);
                component.set('v.hasCXM', true);
                component.set('v.isActiveCXMSection', 'true');
                helper.getCXMMeta(component, event, helper);
            }else if (state === 'ERROR'){

            }
        });
        $A.enqueueAction(action);
    },
    getCXMMeta : function (component, event , helper){
        var action = component.get('c.getCXMMeta');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS'){
                var CXMObj = component.get('v.CXMObj');
                var CXMMeta = response.getReturnValue();
                // console.log('CXMMETA: ',CXMMeta);
                component.set('v.CXMMeta',CXMMeta);

                CXMMeta.forEach(mdt => {
                    if (CXMObj.Survey_Score__c <= mdt.Highest_Score__c && CXMObj.Survey_Score__c >= mdt.Lowest_Score__c){
                        component.set('v.CXMFace',mdt.Emotion_Face__c);
                    }
                });

            }
        });
        $A.enqueueAction(action);
    }
})