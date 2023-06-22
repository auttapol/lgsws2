({
    onInit : function(component, event, helper) {
        helper.getIDTypePickList(component, event, helper);
        //helper.checkDuplicate(component, event, helper);

    },
    
    changeState : function changeState (component){ 
        var iconName = component.get('v.iconName');
        if(iconName == 'utility:chevrondown')
        {
            component.set('v.iconName','utility:chevronright');
        }
        else
        {
            component.set('v.iconName','utility:chevrondown');
        }
        component.set('v.isExpanded',!component.get('v.isExpanded'));
    },
    handleNameChange: function (component, event, helper) {
     
        var customerName = event.getParam("value");
        var customerName_Input = component.find('customerName');
        component.set('v.customerName',customerName);

        $A.util.removeClass(customerName_Input, "slds-has-error"); // remove red border
        $A.util.addClass(customerName_Input, "hide-error-message"); 

        //helper.checkDuplicate(component, event, helper);
    },

    handleIDTypeChange: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected option
       
        var idType_Input = component.find('idType');
        var selectedOptionValue = component.find("idType").get("v.value");
       
        if(selectedOptionValue)
        {
            component.set('v.idType',selectedOptionValue);
        }
        $A.util.removeClass(idType_Input, "slds-has-error"); // remove red border
        $A.util.addClass(idType_Input, "hide-error-message"); 
        //helper.checkDuplicate(component, event, helper);
    },

    handleMobileChange: function(component, event, helper)
    {
       
        var mobileNumber = event.getParam("value");
        var mobileNumber_Input = component.find('mobileNumber');

        component.set('v.mobileValue',mobileNumber);

        $A.util.removeClass(mobileNumber_Input, "slds-has-error"); // remove red border
        $A.util.addClass(mobileNumber_Input, "hide-error-message"); 

        //helper.checkDuplicate(component, event, helper);

    },
    handleIDNoChange: function(component, event, helper)
    {
        var idNo_Input = component.find('idNo');
        
        component.set('v.idNoValue',event.getParam("value"));

        $A.util.removeClass(idNo_Input, "slds-has-error"); // remove red border
        $A.util.addClass(idNo_Input, "hide-error-message"); 
        //helper.checkDuplicate(component, event, helper);

    },

    handleSelected : function(component, event, helper) {
        var currentValue = event.target.value;

        var mapValues = component.get('v.mapPicklistValues');

        var selectDupAcc;
        for(var key in mapValues) {

            if(currentValue == mapValues[key].Id) {
                selectDupAcc = mapValues[key];
                break;
            }
        }

        component.set('v.selectDupAcc', selectDupAcc);

        var compEvent = component.getEvent("selectAccountEvent");
        compEvent.setParams(
        {
            "accObj" : selectDupAcc,
            "isMerge" : component.get('v.isMerge'),
        });

        compEvent.fire(); 
    },

    handleDuplicateAcc : function(component, event, helper)
    {
        var changeValue = event.getParam("value");

        if(changeValue == 'Merge')
        {
            component.set('v.isMerge', true);    
        }
        else if(changeValue == 'Create')
        {
            component.set('v.isMerge', false);  
            component.set('v.selectDupAcc',null);  
            var ele = document.getElementsByName("radiogroup1");
            for(var i=0;i<ele.length;i++)
               ele[i].checked = false;
        }

        var compEvent = component.getEvent("selectAccountEvent");
        compEvent.setParams(
        {
            "accObj" : component.get('v.selectDupAcc'),
            "isMerge" : component.get('v.isMerge'),
        });

        compEvent.fire(); 
        //component.set('v.agent_mode', event.currentTarget.value);    
    },

    getLeadConversionData : function(component, event, helper)
    {      
        var isDuplicate = component.get('v.isDuplicate');
        var customerName = component.get('v.customerName');
        var mobileValue = component.get('v.mobileValue');
        var idNoValue = component.get('v.idNoValue');
        var idType = component.get('v.idType');
        var isMerge = component.get('v.isMerge');

        var customerName_Input = component.find('customerName');
        var mobileNumber_Input = component.find('mobileNumber');
        var idNo_Input = component.find('idNo');
        var idType_Input = component.find('idType');

        var isValid = true;
        //Check Customer Name
        if(!customerName || customerName == null)
        {
            isValid = false;
            $A.util.addClass(customerName_Input, "slds-has-error");
            //document.getElementsByClassName("errorText1").innerHTML = "Please enter customer name";        
        }
        
        //INC0219174 Check Customer Validate FirstName and LastName
        if(customerName){
            var FullNameArr = customerName.split( ' ' );
            if(FullNameArr.length < 2){
                isValid = false;
                $A.util.addClass(customerName_Input, "slds-has-error");
            }else if(FullNameArr[0] == ''){
                isValid = false;
                $A.util.addClass(customerName_Input, "slds-has-error");
            }else if(FullNameArr.length == 2 && FullNameArr[1] == ''){
                isValid = false;
                $A.util.addClass(customerName_Input, "slds-has-error");
            }else if(FullNameArr[1] == '' && FullNameArr[2] == ''){
                isValid = false;
                $A.util.addClass(customerName_Input, "slds-has-error");
            }
        }

        //Check Mobile Number
        if(!mobileValue || mobileValue == null)
        {
            isValid = false;
            $A.util.addClass(mobileNumber_Input, "slds-has-error");
            //document.getElementsByClassName("errorText2").innerHTML = "Please enter 10 digit ex. 0987654321";
        }   
        //Check ID Type
        if(!idType || idType == null)
        {
            isValid = false;
            $A.util.addClass(idType_Input, "slds-has-error");
            //document.getElementsByClassName("errorText3").innerHTML = "Please select ID Type";
        }

        //Check ID No
        if(!idNoValue || idNoValue == null)
        {
            isValid = false;
            $A.util.addClass(idNo_Input, "slds-has-error");
            //document.getElementsByClassName("errorText").innerHTML = 'Please enter at less 4 digit';
        }
 
        if(isDuplicate)
        {
            if(isMerge == null || isMerge == undefined)
            {
                $A.util.addClass(component.find('radioMerge'), "slds-has-error");
                $A.util.addClass(component.find('radioCreate'), "slds-has-error");
                isValid = false;
            }
            else
            {
                if(isMerge == true)
                {
                    if(!component.get('v.selectDupAcc'))
                    {
                        isValid = false;
                    }
                }
            }     
        }
        else
        {         
            component.set('v.isMerge',false);
        }
    
        var compEvent = component.getEvent("selectAccountEvent");
        compEvent.setParams(
        {
            "accObj" : component.get('v.selectDupAcc'),
            "isMerge" : component.get('v.isMerge'),
            "Name" : component.get('v.customerName'),
            "Mobile_Number": component.get('v.mobileValue'),
            "ID_Number" : component.get('v.idNoValue'),
            "ID_Type" : component.get('v.idType')
    });

        compEvent.fire();    
        
        return isValid;
    },

    handleChange : function(component, event, helper)
    {
        helper.checkDuplicate(component, event, helper);
    },

    handleNext : function(component, event, helper)
    {
        var accList = component.get("v.accList");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;

        for(var i = end+1; i < end+pageSize+1; i++)
        {
            if(accList.length > end)
            {
                if(accList[i])
                {
                    paginationList.push(accList[i]);                   
                }
                counter++;
            }
        }
        start = start+counter;
        end = end+counter;
       
        component.set("v.start",start);
        component.set("v.end",end);
        component.set('v.paginationList', paginationList);
    },

    handlePrevious : function(component, event, helper)
    {
        var accList = component.get("v.accList");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");

        var paginationList = [];

        var counter = 0;

        for(var i= start-pageSize; i < start ; i++)
        {
            if(i > -1)
            {
                paginationList.push(accList[i]);
                counter++;
            }
            else 
            {
                start++;
            }

        }
        start = start-counter;
        end = end-counter;

        component.set("v.start",start);
        component.set("v.end",end);
        component.set('v.paginationList', paginationList);
    },



 
})