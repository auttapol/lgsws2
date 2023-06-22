({
    checkDuplicate : function(component, event, helper) {
        var customerName = component.get('v.customerName');
        var mobileNumber = component.get('v.mobileValue');
        var idNo = component.get('v.idNoValue');
        var idType = component.get('v.idType');
        var isValid = true;
        if(!customerName || customerName == null)
        {
            isValid = false;
            component.set('v.isDuplicate',false);
        }
        if(mobileNumber)
        {
            if(!mobileNumber.match(/^(\+\d{1,3}[- ]?)?\d{10}$/))
            {
                isValid = false;
                component.set('v.isDuplicate',false);
            }
        }
        if(!idNo || idNo == null)
        {
            isValid = false;
            component.set('v.isDuplicate',false);
        }
        if(!idType || idType == null)
        {
            isValid = false;
            component.set('v.isDuplicate',false);
        }
        
        if(isValid) 
        {
            var action = component.get('c.checkDuplicate');
            action.setParams({
                "mobileNumber" : mobileNumber,
                "idNo" : idNo,
                "idType" : idType,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS')
                {
                    var result =  response.getReturnValue();
                    
                    if(result != null)
                    {
                        var accountMap = [];
                        if(result.length > 0)
                        {
                    

                            var pageSize = component.get("v.pageSize");
                            var paginationList = []

                            component.set('v.isDuplicate',true);
                            component.set("v.start",0);
                            component.set("v.end",pageSize-1);
                            component.set('v.totalSize',result.length)            
                            component.set('v.accList',result);
                            
                            for(var i = 0;i < pageSize; i++)
                            {
                                if(result[i])
                                {
                                    paginationList.push(result[i]);
                                }
                            }
                            component.set('v.paginationList',paginationList);
                          

                            result.forEach( value => {
                                accountMap.push(value);
                            });
                            component.set('v.mapPicklistValues',accountMap);
                        }
                        else
                        {
                            component.set('v.isDuplicate',false);
                            component.set("v.start",0);
                            component.set("v.end",pageSize-1);
                            component.set('v.totalSize',result.length)          
                            component.set('v.accList',null);
                            component.set('v.paginationList',null);
                            component.set('v.isMerge',false);
                        }
                    }
                    else
                    {
                        var accObj = [{
                        'Name' : customerName,
                        'Mobile_Number_PE__c' : mobileNumber,
                        'ID_Type_PE__c' : idType,
                        'ID_Number_PE__c' : idNo }];                       

                        component.set('v.selectDupAcc',accObj);
                        component.set('v.isMerge',false);
                        component.set('v.isDuplicate',false);
                        component.set('v.accList',null);

                        var compEvent = component.getEvent("selectAccountEvent");
                        compEvent.setParams(
                        {
                            "accObj" : component.get('v.selectDupAcc'),
                            "isMerge" : component.get('v.isMerge'),
                        });
                        compEvent.fire(); 
                    }
                    //helper.getFieldLabel(component, event, helper,result);
                }

            });
            $A.enqueueAction(action);
        }
    },

    getIDTypePickList: function (component,event,helper) {
        
        var action = component.get('c.getPickListValues');
        action.setParams({
            "objectName" : 'Account',
            "fieldName" : 'ID_Type_PE__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  

                var items = [];
                result.forEach(value => {
                    var item = {
                        "label": value.split(',')[0],
                        "value": value.split(',')[1]
                    };
                    items.push(item);
                }); 
                
                component.set("v.option", items);
            }   
            else
            {
                var errors = response.getError();             
                console.log('errors:',errors)
            }                  
        });
        
        $A.enqueueAction(action);
    },
})