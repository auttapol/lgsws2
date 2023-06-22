({
    doInit : function(component, event, helper) {
      var record = component.get("v.oRecord");
      var extraSearchField = component.get("v.extraSearchField");
      // console.log(extraSearchField);
      // console.log(JSON.stringify(record));
      if(extraSearchField !== "" && extraSearchField !== undefined && extraSearchField !== null && 
      record.extraValue !== null && record.extraValue[extraSearchField] !== undefined) {
        component.set("v.extraField", record.extraValue[extraSearchField]);
        //console.log(record.extraValue[extraSearchField]);
      }
    },
     selectRecord : function(component, event, helper){      
      // get the selected record from list  
        var getSelectRecord = component.get("v.oRecord");
      // call the event   
        var compEvent = component.getEvent("oSelectedRecordEvent");
      // set the Selected sObject Record to the event attribute.  
           compEvent.setParams({"recordByEvent" : getSelectRecord });  
      // fire the event  
           compEvent.fire();
      },
  })