({
    getCampaign : function(component, event, helper){
        component.set('v.loaded',true);
        var action = component.get('c.getCampaign');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result)
                {
                    if(result.Status != 'In Progress')
                    {
                        component.set('v.isExpire',true);
                        component.set('v.showWarning',true);
                        
                    }
                    else
                    {
                        component.set('v.isExpire',false);
                    }
                }              
             
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('Error:',message);
                component.set('v.loaded',false);
                //helper.displayToast(component,helper,'Error','error',message);       
            }
        })

        $A.enqueueAction(action);

    },

    getCampaignMember: function (component,event,helper)
    {
        component.set('v.loaded', true);  
        var recordId = component.get('v.recordId');
     
        var action = component.get('c.getCampaignMember');
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var result =  response.getReturnValue();
                if(result != null)
                {
                    if(result.RTL_Contact_Status__c.includes('Do Not Contact')) 
                    {
                        component.set('v.recordIsClosed',true);
                        component.set('v.showWarning',true);
                    }           
                    helper.getCampaignProductList(component, event, helper, result.RTL_Contact_Status__c);
                    helper.getCampaignMemberOBSellPermission(component, event, helper, result.RTL_Campaign_Channel_formula__c);
                }
                else{
                    component.set('v.recordCanNotSell',true);
                    component.set('v.showWarning',true);
                }
                helper.getExistingCallback(component, event, helper);    
            
                component.set('v.loaded', false);  
            }
            else
            {
                component.set('v.loaded', false);  
            }

        });
        $A.enqueueAction(action);
    },


    getExistingCallback : function(component, event, helper) 
    {
        component.set('v.loaded',true);
        var action = component.get('c.getCallBack');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                
                if(response.getReturnValue().Call_Log_ID__c){
                 
                    component.set('v.task', response.getReturnValue());

                    var datetime = new Date(response.getReturnValue().Call_Start_Datetime__c);
                    var optionsDate = {
                        year: 'numeric', month: 'short', day: 'numeric'
                    };
                    var optionsTime = { hour: '2-digit', minute: '2-digit' };
                    
                    component.set('v.callback_date', helper.transformDateToInput2(datetime.toLocaleDateString()));
                    component.set('v.callback_time', datetime.toLocaleTimeString('th-TH'));     
                    component.set('v.callback_time_label', datetime.toLocaleTimeString('th-TH',optionsTime)+' น.');                                     
                    component.set('v.callback_date_label', datetime.toLocaleString('th-TH', optionsDate));


                    component.set('v.isExpanded_CallBack',true);
                }

                component.set('v.loaded',false);
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('Error:',message);
                component.set('v.loaded',false);
                //helper.displayToast(component,helper,'Error','error',message);       
            }
        })

        //component.set('v.loaded',false);
        $A.enqueueAction(action);

    },

    transformDateToInput2: function(date){
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    
        return [year, month, day].join('-');
    },

    getCampaignProductList: function (component,event,helper,contactStatus)
    {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getCampaignProductWrapper');
        // var isConvert = true;
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {
                var productList =  response.getReturnValue();              
                
                var recordIsClosed = true;
                if(productList != null)
                {                      
                    productList.forEach((product,index) => { 
                        if(!product.viewOfferResult)
                        {             
                            recordIsClosed = false;
                        }  
                    }); 
                    if(contactStatus == 'Contact')
                    {                     
                        if(recordIsClosed)
                        {
                            component.set('v.recordIsClosed',recordIsClosed);
                            component.set('v.showWarning',true);
                        }
                    }    
                }
                helper.getBusinessOutcomeMapping(component,event,helper,productList);
            }

        });
        $A.enqueueAction(action);       
    },

    getBusinessOutcomeMapping : function (component, event, helper, productList)
    {
        var action = component.get('c.getProductInBOM');

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result){
                    var productGroupNotMatch = [];
                    if(productList != null)
                    {                      
                        productList.forEach((product,index) => { 
                          
                            if(!result.includes(product.productGroup.toUpperCase()))
                            {
                                if(productGroupNotMatch.length == 0)
                                {
                                    productGroupNotMatch.push(product.productGroup);
                                }
                                else 
                                {
                                    productGroupNotMatch.forEach((productNotMatch) => {
                                        if(productNotMatch.toUpperCase() != product.productGroup.toUpperCase())
                                        {
                                            productGroupNotMatch.push(' '+product.productGroup);
                                        }
                                     });                               
                                }
                            }                        
                        }); 
                    }
                    if(productGroupNotMatch.length > 0)
                    {
                        var message = productGroupNotMatch + ' ' + $A.get("$Label.c.RTL_CampaignMemberEdit_ProductGroupNotMatch_ErrMsg");
                        component.set('v.productNotMatch_Msg',message);
                        component.set('v.productNotMatch',true);
                        component.set('v.showWarning',true);
                    }
                }                
            }
            else
            {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('Error Message:',message)
            }
        })

        $A.enqueueAction(action);
    },

    getCampaignMemberOBSellPermission: function (component,event,helper,channel) {
        
        var action = component.get('c.getCampaignMemberOBSellPermission');

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();  
                if(result != null)
                {
                    var isPermission = false; 
                    result.forEach(value => {
                        if(value != null && channel != null)
                        {
                            if(value.MasterLabel.toUpperCase() == channel.toUpperCase())
                            {
                                isPermission = value.Allow_To_Sell__c;
                            }        
                        } 
                    });                                  
                    if(!isPermission)
                    { 
                        component.set('v.recordCanNotSell',true); 
                        component.set('v.showWarning',true);
                    }
                    
                }                         
            }         
        });
        
        $A.enqueueAction(action);
    },

})