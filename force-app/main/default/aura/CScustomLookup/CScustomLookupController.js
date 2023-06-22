({
	doInit: function (component, event, helper) {
	  var getInputkeyWord = component.get("v.SearchKeyWord");
	  var checkNameLookup = component.get("v.checkNameLookup");
	  var action = component.get("c.getOwnerName");

	  action.setParams({
			  "searchKeyWord": getInputkeyWord
		  });
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
  
				var getUser =  response.getReturnValue();
				if(getUser.length == 0 )
				{     
					if(checkNameLookup == 'FX')
					{
						helper.getCurrentUser(component,event);
						component.set("v.checkInputFX",true);
					}
					if(checkNameLookup == 'RM')
					{
						helper.getAccountOwner(component,event);
						component.set("v.checkInputRM",true);
					}
				}
					
				for (key in getUser) 
				{				
					if(getUser[key].Name != null)
					{
						if(checkNameLookup == 'FX')
						{
							component.set("v.SearchKeyWord",getUser[key].Name);
							helper.searchHelper(component,event,getUser[key].Name);
							component.set("v.checkInputFX",true);
						}
						if(checkNameLookup == 'RM')
						{
							component.set("v.SearchKeyWord",getUser[key].Name);
							helper.searchHelper(component,event,getUser[key].Name);
							component.set("v.checkInputRM",true);
						}
					}
				
				}
			}
		});
	  $A.enqueueAction(action);     
	},
	
	keyPressController : function(component, event, helper) {
		var getInputkeyWord = component.get("v.SearchKeyWord");
 
		if(getInputkeyWord != null)
		{
			if( getInputkeyWord.length > 0 ){
					var forOpen = component.find("searchRes");
					$A.util.addClass(forOpen, 'slds-is-open');
					$A.util.removeClass(forOpen, 'slds-is-close');
					helper.searchHelper(component,event,getInputkeyWord);
			}
			else{  
				component.set("v.listOfSearchRecords", null ); 
					var forclose = component.find("searchRes");
					$A.util.addClass(forclose, 'slds-is-close');
					$A.util.removeClass(forclose, 'slds-is-open');
			}
		}
			
	},

	clear :function(component,event,heplper){
		
		 event.preventDefault();
		 
		   var pillTarget = component.find("lookup-pill");
		   var lookUpTarget = component.find("lookupField"); 
		  
		   $A.util.addClass(pillTarget, 'slds-hide');
		   $A.util.removeClass(pillTarget, 'slds-show');
		  
		   $A.util.addClass(lookUpTarget, 'slds-show');
		   $A.util.removeClass(lookUpTarget, 'slds-hide');
		
		   component.set("v.SearchKeyWord",null);
		   component.set("v.listOfSearchRecords", null );

		   
	  },
	    
	  handleComponentEvent : function(component, event, helper) {
	   
		 var selectedAccountGetFromEvent = event.getParam("accountByEvent");
		 component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
  
		  var forclose = component.find("lookup-pill");
			 $A.util.addClass(forclose, 'slds-show');
			 $A.util.removeClass(forclose, 'slds-hide');
		
		  
		  var forclose = component.find("searchRes");
			 $A.util.addClass(forclose, 'slds-is-close');
			 $A.util.removeClass(forclose, 'slds-is-open');
		  
		  var lookUpTarget = component.find("lookupField");
			  $A.util.addClass(lookUpTarget, 'slds-hide');
			  $A.util.removeClass(lookUpTarget, 'slds-show');  
  
		
	  },

	  hideSpinner : function (component, event, helper) {
		  var spinner = component.find('spinner');
		  var evt = spinner.get("e.toggle");
		  evt.setParams({ isVisible : false });
		  evt.fire();    
	  },

	  showSpinner : function (component, event, helper) {
		  var spinner = component.find('spinner');
		  var evt = spinner.get("e.toggle");
		  evt.setParams({ isVisible : true });
		  evt.fire();    
	  },
	  
  })