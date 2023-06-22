({
    initTimeline : function(component, event, helper, isViewMore) {

        var action = component.get("c.getCallBackHist");
        action.setParams({
            recordId: component.get('v.recordId'),
            recLimit: component.get('v.recordLimit')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var resultList =  response.getReturnValue();  
                resultList.forEach(result => {
                    if(result.Call_Start_Datetime__c)
                    {    
                        var cbHour = result.Call_Start_Datetime__c.split('T')[1].split('.')[0].split(':')[0];
                        var cbMinute = result.Call_Start_Datetime__c.split('T')[1].split('.')[0].split(':')[1];
                        var cbDateTime = new Date(0, 0, 0, cbHour, cbMinute ,0);
                        var h = cbDateTime.getHours()+7
                    	if(h < 10)
                    	{
                           h = '0'+h;  
                        }
                        var m = cbDateTime.getMinutes();
                    	if(m == 0)
                    	{
                           m = '00';  
                        }

                        //console.log('callBackDate:',result.Call_Start_Datetime__c.split('T')[0]);
                        result.callBackDate = result.Call_Start_Datetime__c.split('T')[0];
                        result.callBackTime = h+':'+m+':'+'00';

                        console.log('result:',result);

                    }
                });
                
                console.log('resultList:',resultList);         
                component.set("v.display" , resultList); 
                // component.set('v.marketingCode', response.getReturnValue().marketing_code)
                component.set('v.isViewMore', isViewMore);

                var spinner = component.find("apexSpinner");
                $A.util.toggleClass(spinner, "slds-hide");
               
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})