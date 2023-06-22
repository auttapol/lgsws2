({
    doInit: function(component, event, helper) {
      
    },
    selectedRecordChanged : function(component, event, helper) {
      var record = component.get("v.selectedRecord");
      var extraShowField = component.get("v.extraShowField");
      // console.log(extraShowField);
      // console.log(JSON.stringify(component.get("v.objectAPIName")));
      if(record !== "" && record !== null && extraShowField !== '' && extraShowField !== null && extraShowField !== undefined 
      && record.extraValue !== null && record.extraValue !== undefined && record.extraValue[extraShowField] !== undefined) {
        component.set("v.extraShowFieldLabel", record.extraValue[extraShowField]);       
      }
     
    },
    onfocus: function (component, event, helper) {
      $A.util.addClass(component.find("mySpinner"), "slds-show");
      var forOpen = component.find("searchRes");
      $A.util.addClass(forOpen, 'slds-is-open');
      $A.util.removeClass(forOpen, 'slds-is-close');
      // Get Default 5 Records order by createdDate DESC  
      var searchKeyword = component.get("v.SearchKeyWord");
      var getInputkeyWord = (searchKeyword !== null && searchKeyword !== undefined)? searchKeyword:'';
      var getSalesName = '';
      helper.searchHelper(component, event, getInputkeyWord);
      //helper.searchSalesHelper(component, event, getSalesName);
  
    },
    onblur: function (component, event, helper) {
      component.set("v.listOfSearchRecords", null);
      var forclose = component.find("searchRes");
      $A.util.addClass(forclose, 'slds-is-close');
      $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController: function (component, event, helper) {
      // get the search Input keyword   
      var getInputkeyWord = component.get("v.SearchKeyWord");
      // check if getInputKeyWord size id more then 0 then open the lookup result List and 
      // call the helper 
      // else close the lookup result List part.   
      if (getInputkeyWord.length > 0) {
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        helper.searchHelper(component, event, getInputkeyWord);
      }
      else {
        component.set("v.listOfSearchRecords", null);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
      }
    },
    doClearValue: function(component, event, helper) {
      helper.clearValue(component, event, helper);
    },
    // function for clear the Record Selaction 
    clear: function (component, event, helper) {
      var shouldDispatchBeforeRemoved = component.get("v.dispatchBeforeRemoved");
      if(shouldDispatchBeforeRemoved) {
        var selectedRecord = component.get("v.selectedRecord");
        var oldLookupVal = (selectedRecord !== null && selectedRecord !== undefined)? JSON.parse(JSON.stringify(selectedRecord)) : null;
        var dependentString = component.get('v.dependentString');
        component.getEvent('onBeforeRemoved').setParams({ "record": {Id: '', Name: ''}, "lookupVal": '', "oldLookupVal": oldLookupVal,"dependentString": dependentString, "index": {} }).fire();
        return;
      }
      helper.clearValue(component, event, helper);
    },
  
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent: function (component, event, helper) {
      // get the selected Account record from the COMPONETN event 	 
      var selectedAccountGetFromEvent = event.getParam("recordByEvent");
      var selectedRecord = component.get("v.selectedRecord");
      var oldLookupVal = (selectedRecord !== null && selectedRecord !== undefined)? JSON.parse(JSON.stringify(selectedRecord)) : null;
      var dependentString = component.get('v.dependentString');
      component.set("v.selectedRecord", selectedAccountGetFromEvent);
      component.getEvent('onchange').setParams({ "record": selectedAccountGetFromEvent, "lookupVal": '', "oldLookupVal": oldLookupVal,"dependentString": dependentString, "index": {} }).fire();

      var forclose = component.find("lookup-pill");
      $A.util.addClass(forclose, 'slds-show');
      $A.util.removeClass(forclose, 'slds-hide');
  
      var forclose = component.find("searchRes");
      $A.util.addClass(forclose, 'slds-is-close');
      $A.util.removeClass(forclose, 'slds-is-open');
  
      var lookUpTarget = component.find("lookupField");
      $A.util.addClass(lookUpTarget, 'slds-hide');
      $A.util.removeClass(lookUpTarget, 'slds-show');
      var searchIcon = component.find("search-icon");
      $A.util.addClass(searchIcon, 'slds-hide');
      $A.util.removeClass(searchIcon, 'slds-show');
  
    },
    onRender: function(component, event, helper) {
      var record = component.get("v.selectedRecord");
      var extraShowField = component.get("v.extraShowField");
      if(record !== undefined && record !== "" && record !== null && extraShowField !== '' && extraShowField !== null && extraShowField !== undefined 
      && record.extraValue !== null && record.extraValue !== undefined && record.extraValue !== undefined && record.extraValue[extraShowField] !== undefined) {
        component.set("v.extraShowFieldLabel", record.extraValue[extraShowField]);
      }
      // console.log("customLookup render");
      // console.log(JSON.stringify(selectedRecord));
      // if(selectedRecord !== null && selectedRecord !== 'null' && selectedRecord !== undefined) {
      //   var forclose = component.find("lookup-pill");
      //   $A.util.addClass(forclose, 'slds-show');
      //   $A.util.removeClass(forclose, 'slds-hide');
  
      //   var forclose = component.find("searchRes");
      //   $A.util.addClass(forclose, 'slds-is-close');
      //   $A.util.removeClass(forclose, 'slds-is-open');
  
      //   var lookUpTarget = component.find("lookupField");
      //   $A.util.addClass(lookUpTarget, 'slds-hide');
      //   $A.util.removeClass(lookUpTarget, 'slds-show');
  
      //   var searchIcon = component.find("search-icon");
      //   $A.util.addClass(searchIcon, 'slds-hide');
      //   $A.util.removeClass(searchIcon, 'slds-show');
      // }
    },
    
  })