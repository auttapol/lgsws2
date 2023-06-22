({
	searchHelper : function(component,event,getInputkeyWord) {
    // call the apex class method 
    var queryType = component.get('v.queryType');
    if(queryType == 'SOQL')
    { 
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'nameField' : component.get("v.nameField"),
            'condition' : component.get("v.condition"),
            'extraField' : component.get("v.extraField"),
            'extraSearchField' : component.get("v.extraSearchField"),
            'customNameField' : component.get("v.customNameField"),
            'hasLastViewedDate' : component.get("v.hasLastViewedDate"),
            'isSortNameField' : component.get("v.isSortNameField")
          });
        // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                //console.log('storeResponse: ' + storeResponse);
            }
 
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    }
    else if(queryType == 'SOSL')
    {    
        var action = component.get("c.fetchLookUpValuesSOSL");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'nameField' : component.get("v.nameField"),
            'condition' : component.get("v.condition"),
            'extraField' : component.get("v.extraField"),
          });
        // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                //console.log('storeResponse: ' + storeResponse);
            }
 
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    }
    
  },
  clearValue: function(component, event, helper) {
    var pillTarget = component.find("lookup-pill");
    var lookUpTarget = component.find("lookupField");

    $A.util.addClass(pillTarget, 'slds-hide');
    $A.util.removeClass(pillTarget, 'slds-show');

    $A.util.addClass(lookUpTarget, 'slds-show');
    $A.util.removeClass(lookUpTarget, 'slds-hide');

    var searchIcon = component.find("search-icon");
    $A.util.addClass(searchIcon, 'slds-show');
    $A.util.removeClass(searchIcon, 'slds-hide');

    var selectedRecord = component.get("v.selectedRecord");
    var oldLookupVal = (selectedRecord !== null && selectedRecord !== undefined)? JSON.parse(JSON.stringify(selectedRecord)) : null;
    var dependentString = component.get('v.dependentString');

    component.set("v.SearchKeyWord", null);
    component.set("v.listOfSearchRecords", null);
    component.set("v.selectedRecord", null);
    component.getEvent('onchange').setParams({ "record": {Id: '', Name: ''}, "lookupVal": '', "oldLookupVal": oldLookupVal,"dependentString": dependentString, "index": {} }).fire();
  }
  
  // test by kevin to get sales name by project


  // kevin test end here
})