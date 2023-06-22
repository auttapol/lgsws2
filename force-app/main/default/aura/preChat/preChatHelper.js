({
    /**
	 * Map of pre-chat field label to pre-chat field name (can be found in Setup)
	 */
    fieldLabelToName: {
        "First Name": "FirstName",
        "Last Name": "LastName",
        "Email": "Email",
        "Phone": "Phone",
        "Fax": "Fax",
        "Mobile No.": "MobilePhone",
        "Home Phone": "HomePhone",
        "Other Phone": "OtherPhone",
        "Asst. Phone": "AssistantPhone",
        "Title": "Title",
        "Lead Source": "LeadSource",
        "Assistant": "AssistantName",
        "Department": "Department",
        "Subject": "Subject",
        "Case Reason": "Reason",
        "Type": "Type",
        "Web Company": "SuppliedCompany",
        "Web Phone": "SuppliedPhone",
        "Priority": "Priority",
        "Web Name": "SuppliedName",
        "Web Email": "SuppliedEmail",
        "Company": "Company",
        "Industry": "Industry",
        "Rating": "Rating",
        "ชื่อจริง": "FirstName",
        "นามสกุล": "LastName",
        "โทรศัพท์มือถือ" : "MobilePhone",
        "ชื่อเรื่อง" : "Subject",
        "อีเมล" : "Email",
        "Contact Person Name" : 'Contact_Person_Name__c',
        "Contact Person Email" : 'Contact_Person_Email__c',
        "Contact Person Phone" : 'Contact_Person_Phone__c',
        "อีเมล์ (เพื่อติดต่อกลับ)" : 'Contact_Person_Email__c',
        "เบอร์โทรศัพท์ (เพื่อติดต่อกลับ)" : 'Contact_Person_Phone__c'

                
    },
    
    /**
	 * Event which fires the function to start a chat request (by accessing the chat API component)
	 *
	 * @param cmp - The component for this state.
	 */
    onStartButtonClick: function(cmp,evt,hlp) {
        var prechatFieldComponents = cmp.find("prechatField");
        var fields;
        var validation = cmp.get("v.validate");
		//console.log(validation);
        // Make an array of field objects for the library
        if(validation)
        {
            fields = this.createFieldsArray(prechatFieldComponents);
            
            // If the pre-chat fields pass validation, start a chat       
            if(cmp.find("prechatAPI").validateFields(fields).valid) {
                var event = new CustomEvent(
                    "setLabel",
                    {
                        detail: {
                            callback: cmp.find("prechatAPI").startChat.bind(this, fields),
                            FirstName: prechatFieldComponents[0].get("v.label"),
                            LastName: prechatFieldComponents[1].get("v.label"),
                            Email: prechatFieldComponents[2].get("v.label"),
                            Mobile: prechatFieldComponents[3].get("v.label"), 

                            FirstName_value: prechatFieldComponents[0].get("v.value"),
                            LastName_value: prechatFieldComponents[1].get("v.value"),
                            Email_value: prechatFieldComponents[2].get("v.value"),
                            Mobile_value: prechatFieldComponents[3].get("v.value"),
                            Subject_value: prechatFieldComponents[4].get("v.value").split(',')[0]
                                                       
                        }
                    }
                );
                // Dispatch the event.
                document.dispatchEvent(event);
            } else {
                console.warn("Prechat fields did not pass validation!");
            }
        }
        else
        {
            var validateFirstName = hlp.validateInputFirstName(cmp,evt,hlp);
            var validateLastName = hlp.validateInputLastName(cmp,evt,hlp);
            var validatePhone = hlp.validateInputPhone(cmp,evt,hlp);
            var validateEmail = hlp.validateInputEmail(cmp,evt,hlp);
            var validateSubject = hlp.validateInputSubject(cmp,evt,hlp)
            
            hlp.validateAtButton(cmp,evt,hlp);
            
            if(validateFirstName && validateLastName && validateEmail &&validatePhone && validateSubject)
            {
                cmp.set("v.validate",true);
            }
        }
    },
    
    /**
	 * Create an array of field objects to start a chat from an array of pre-chat fields
	 * 
	 * @param fields - Array of pre-chat field Objects.
	 * @returns An array of field objects.
	 */
    createFieldsArray: function(fields) {
        if(fields.length) {
            return fields.map(function(fieldCmp) {
                if(fieldCmp.get("v.label") == 'Contact Person Name'){
                    return {
                        label: fieldCmp.get("v.label"),
                        value: fields[0].get("v.value")+' '+fields[1].get("v.value"),
                        name: this.fieldLabelToName[fieldCmp.get("v.label")]
                    };
                }
                if(fieldCmp.get("v.label") == 'Contact Person Email' || fieldCmp.get("v.label") == 'อีเมล์ (เพื่อติดต่อกลับ)'){
                    return {
                        label: fieldCmp.get("v.label"),
                        value: fields[2].get("v.value"),
                        name: this.fieldLabelToName[fieldCmp.get("v.label")]
                    };
                }
                if(fieldCmp.get("v.label") == 'Contact Person Phone' || fieldCmp.get("v.label") == 'เบอร์โทรศัพท์ (เพื่อติดต่อกลับ)'){
                    return {
                        label: fieldCmp.get("v.label"),
                        value: fields[3].get("v.value"),
                        name: this.fieldLabelToName[fieldCmp.get("v.label")]
                    };
                }
                if(fieldCmp.get("v.label") == 'Subject' || fieldCmp.get("v.label") == 'ชื่อเรื่อง'){
                    return {
                        label: fieldCmp.get("v.label"),
                        value: fieldCmp.get("v.value").split(',')[0],
                        name: this.fieldLabelToName[fieldCmp.get("v.label")]
                    };
                }
                return {
                    label: fieldCmp.get("v.label"),
                    value: fieldCmp.get("v.value"),
                    name: this.fieldLabelToName[fieldCmp.get("v.label")]
                };
            }.bind(this));
        } else {
            return [];
        }
    },
    
    /**
     * Create an array in the format $A.createComponents expects
     * 
     * Example:
     * [["componentType", {attributeName: "attributeValue", ...}]]
     * 
	 * @param prechatFields - Array of pre-chat field Objects.
	 * @returns Array that can be passed to $A.createComponents
     */
    getPrechatFieldAttributesArray: function(prechatFields,cmp) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];
        
        // For each field, prepare the type and attributes to pass to $A.createComponents
        prechatFields.forEach(function(field) {
            if(field.label != 'ชื่อเรื่อง' && field.label != 'Subject')
            {
                var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
                var componentInfoArray = ["ui:" + 'inputText'];
                var attributes = {
                    "aura:id": "prechatField",
                    required: field.required,
                    label: field.label,
                    disabled: field.readOnly,
                    maxlength: field.maxLength,
                    class: field.className,
                    value: field.value,
                    keyup: cmp.getReference("c.inputOnchange"),
                	updateOn: "keyup"
                };
                
                if(field.label === "Contact Person Name" || field.label === "Contact Person Email" || field.label === "Contact Person Phone"
                || field.label === "อีเมล์ (เพื่อติดต่อกลับ)" || field.label === "เบอร์โทรศัพท์ (เพื่อติดต่อกลับ)") {
                    attributes.class = 'hide';
                    attributes.labelClass = 'hide';
                }

                // Special handling for options for an input:select (picklist) component
                if(field.type === "inputSelect" && field.picklistOptions) attributes.options = field.picklistOptions;
                
                // Append the attributes Object containing the required attributes to render this pre-chat field
                componentInfoArray.push(attributes);
                
                // Append this componentInfoArray to the fieldAttributesArray
                prechatFieldsInfoArray.push(componentInfoArray);
            }
            else
            {
                var componentInfoArray = ["ui:" + 'inputSelect'];
                var attributes = {
                    "aura:id": "prechatField",
                    required: field.required,
                    label: field.label,
                    disabled: field.readOnly,
                    maxlength: field.maxLength,
                    class: field.className,
                    value: field.value,
                    change: cmp.getReference("c.selectOnchange")
                    //updateOn: "keyup"
                };

                // Special handling for options for an input:select (picklist) component
                //attributes.options = opts;//field.picklistOptions;
                
                // Append the attributes Object containing the required attributes to render this pre-chat field
                componentInfoArray.push(attributes);
                
                // Append this componentInfoArray to the fieldAttributesArray
                prechatFieldsInfoArray.push(componentInfoArray);
            }
            
            var componentInfoArray = ["span"];          
            var attributes = {
                class: "errorText"                
            };
            
            componentInfoArray.push(attributes);
            
            prechatFieldsInfoArray.push(componentInfoArray); 
        });
        
        return prechatFieldsInfoArray;
    },
    
    validateInputFirstName: function(cmp,evt,hlp)
    {
        var validateFields = cmp.find('prechatField');
        var valid = false;  
        if(validateFields[0].get("v.value"))
        {            
            if(!validateFields[0].get("v.value").match(/^\s+/))
            {                  
                $A.util.removeClass(validateFields[0], 'validate');                
                document.getElementsByClassName("errorText")[0].innerHTML = '';
                valid = true;
            }
            else
            {
                $A.util.addClass(validateFields[0], 'validate'); 	               
                document.getElementsByClassName("errorText")[0].innerHTML = $A.get("$Label.c.LiveChat_FirstName_Error_Msg");
                valid = false;
            }
        }
                
        return valid;
    },
    
    validateInputLastName: function(cmp,evt,hlp)
    {
        var validateFields = cmp.find('prechatField');
        var valid = false; 
        if(validateFields[1].get("v.value"))
        {
            if(!validateFields[1].get("v.value").match(/^\s+/))
            {                  
                $A.util.removeClass(validateFields[1], 'validate');                
                document.getElementsByClassName("errorText")[1].innerHTML = '';
                valid = true;
            }
            else
            {
                $A.util.addClass(validateFields[1], 'validate');                 
                document.getElementsByClassName("errorText")[1].innerHTML = $A.get("$Label.c.LiveChat_LastName_Error_Msg");
                valid = false;
            }
        }
        return valid;
    },
    
    validateInputEmail: function(cmp,evt,hlp)
    {
        var validateFields = cmp.find('prechatField');
        var valid = false;
        //var emailPattern = /^\S[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;   
		var emailPattern = /^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@((?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}?|(((?:[0-9]{0,3})?\.)+[0-9]{3,3}?))$/g;
                                                          
        if(validateFields[2].get("v.value"))
        {                
            if(validateFields[2].get("v.value").match(emailPattern) && !validateFields[2].get("v.value").match(/^\s+/))
            {                           
                $A.util.removeClass(validateFields[2], 'validate');               
                document.getElementsByClassName("errorText")[2].innerHTML = '';
                valid = true;
            }           
            else
            {
                
               	$A.util.addClass(validateFields[2], 'validate');                
                document.getElementsByClassName("errorText")[2].innerHTML = $A.get("$Label.c.LiveChat_Email_Error_Msg");
                valid = false;
            }
        }
        return valid;
    },
    
    validateInputPhone: function(cmp,evt,hlp)
    {
        var validateFields = cmp.find('prechatField');
        var valid = false;
        if(validateFields[3].get("v.value"))
        {               
       
            if(validateFields[3].get("v.value").match(/^((06|08|09)([0-9]{8}){1,10})$/) && !validateFields[3].get("v.value").match(/^\s+/))
            {            
                $A.util.removeClass(validateFields[3], 'validate');               
                document.getElementsByClassName("errorText")[3].innerHTML = '';
                valid = true;
            }

            else
            {
               	$A.util.addClass(validateFields[3], 'validate');                
                document.getElementsByClassName("errorText")[3].innerHTML = $A.get("$Label.c.LiveChat_Phone_Error_Msg");
                valid = false;
            }
        }

        return valid;
    },
    
    validateInputSubject: function(cmp,evt,hlp)
    {
        var validateFields = cmp.find('prechatField');
        var valid = false;
        if(validateFields[4].get("v.value"))
        {                                    
            $A.util.removeClass(validateFields[4], 'validate');               
            document.getElementsByClassName("errorText")[4].innerHTML = '';
            valid = true;
        }

        return valid;
    },

    validateAtButton: function(cmp,evt,hlp)
    {
        var validateFields = cmp.find('prechatField');

        for(var i = 0; i < validateFields.length-4; i++)
        {
            if(!validateFields[i].get("v.value"))
            {	
                $A.util.addClass(validateFields[i], 'validate'); 	               
                document.getElementsByClassName("errorText")[i].innerHTML = $A.get("$Label.c.LiveChat_InputEmpty_Error_Msg");
            }
        }
        if(!validateFields[4].get("v.value"))
        {	
            $A.util.addClass(validateFields[4], 'validate'); 	               
            document.getElementsByClassName("errorText")[4].innerHTML = $A.get("$Label.c.LiveChat_Subject_Error_Msg");
        }
    },
    
    getRountingList: function (cmp, hlp, evt) {
		var action = cmp.get("c.getSubjectList");
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
                    
                //console.log('Result:',result)
                result.sort(function (a,b) {return a.Priority__c-b.Priority__c;});
                
                var opts = [{ label: $A.get("$Label.c.LiveChat_PickList_Msg"), value: ''}]
            	
      			result.forEach(function(index){
                    //console.log('index:',index);   
                    opts.push({ label: index.Subject__c , value: index.Subject__c + ',' + index.Chat_Button_Id__c});
                });

                cmp.find("prechatField")[4].set("v.options", opts);
            }
		});
		$A.enqueueAction(action);
	},
        
        
        
});