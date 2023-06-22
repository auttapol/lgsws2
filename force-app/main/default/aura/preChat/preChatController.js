({
    /**
     * On initialization of this component, set the prechatFields attribute and render pre-chat fields.
     * 
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
	onInit: function(cmp, evt, hlp) {

        // Get pre-chat fields defined in setup using the prechatAPI component
		var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        // Get pre-chat field types and attributes to be rendered
        var prechatFieldComponentsArray = hlp.getPrechatFieldAttributesArray(prechatFields,cmp);
        //console.log('prechatFieldComponentsArray',prechatFieldComponentsArray);
        // Make asynchronous Aura call to create pre-chat field components
        $A.createComponents(
            prechatFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    cmp.set("v.prechatFieldComponents", components);
                }
            }
        );
        
        hlp.getRountingList(cmp,hlp,evt);

    },
    
    /**
     * Event which fires when start button is clicked in pre-chat
     * 
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
    handleStartButtonClick: function(cmp, evt, hlp) {
        hlp.onStartButtonClick(cmp,evt,hlp);
    },
    
    inputOnchange: function(cmp, evt, hlp) 
    {
      	var validateFirstName = hlp.validateInputFirstName(cmp,evt,hlp);
        var validateLastName = hlp.validateInputLastName(cmp,evt,hlp);
        var validateEmail = hlp.validateInputEmail(cmp,evt,hlp);
        var validatePhone = hlp.validateInputPhone(cmp,evt,hlp);	
        var validateSubject = hlp.validateInputSubject(cmp,evt,hlp)
        
        if(validateFirstName && validateLastName && validateEmail &&validatePhone && validateSubject)
        {
            cmp.set("v.validate",true);
        }
    	else
        {
            cmp.set("v.validate",false);
        }
    },
    
    selectOnchange: function(cmp, evt, hlp) 
    {
        var validateFirstName = hlp.validateInputFirstName(cmp,evt,hlp);
        var validateLastName = hlp.validateInputLastName(cmp,evt,hlp);
        var validateEmail = hlp.validateInputEmail(cmp,evt,hlp);
        var validatePhone = hlp.validateInputPhone(cmp,evt,hlp);		
        var validateSubject = hlp.validateInputSubject(cmp,evt,hlp)
        
        if(validateFirstName && validateLastName && validateEmail &&validatePhone && validateSubject)
        {
            cmp.set("v.validate",true);
        }
		else
        {
            cmp.set("v.validate",false);
        }        
    }
});