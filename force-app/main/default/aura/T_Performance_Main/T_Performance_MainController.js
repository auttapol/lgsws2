({  
    onInitConsent: function(component, event, helper) {
      let hostname = window.location.protocol+'//'+window.location.hostname;
      component.set('v.consentLink',hostname+"/apex/T_Performance_ConsentPage")
      /* var iframe_name = document.getElementById("test");
      iframe_name.scrolling = "no"; */
      // component.set('v.testMsg','test1<br\>test2')
      
     },
    
     selectDecline: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.status", 'Declined');  
        component.set("v.isModalOpen", false);
        component.set("v.declineMessage", true);
        helper.insertTermOfUseLog(component, event ,helper)
          
      //   var textCmp = component.find('test1');

        /* console.log('debug find component',component.find('test1')); */
        var customLabelText = $A.get('$Label.c.T_Performance_Decline_Consent_Message');
        var customLabelTextArr = customLabelText.split(';');
        component.set('v.textList',customLabelTextArr)
     },
    
     selectContinue: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.status", 'Accepted');
        component.set("v.isModalOpen", false);
        helper.insertTermOfUseLog(component, event ,helper)
        helper.onInit(component, event ,helper);
     },
     onCheck: function(component, event,helper) {
       /*  component.set('v.myBool',true);
        console.log('myBool',component.get('v.myBool')) */
       
        /* var checkCmp = component.find("checkbox"); */
        /* var checkCmp =  event.target.getAttribute("checked"); */
        console.log('event',event.target.checked);
     
        component.set('v.myBool',event.target.checked);
        
    },

    returnTperf: function(component, event,helper) {
        component.set("v.declineMessage", false);
        component.set("v.isModalOpen", true);
        component.set('v.myBool',false);

   }
     

    
})