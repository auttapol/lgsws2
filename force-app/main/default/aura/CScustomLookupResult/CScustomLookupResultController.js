({
	doInit: function (component, event, helper) 
	{
		var getSelectAccount = component.get("v.oAccount");
		var checkInput = component.get("v.checkInput");
		var getLookup = component.get("v.lookupName");
		var checkInputRM = component.get("v.checkInputRM");
		var checkInputFX = component.get("v.checkInputFX");
 
		if(checkInput == undefined)
		{			
			if(getLookup == "FX" && checkInputFX == true)
			{	
				var compEvent = component.getEvent("oSelectedAccountEvent");
	
				compEvent.setParams({"accountByEvent" : getSelectAccount });  
				compEvent.setParams({"lookupName" : getLookup });  

				compEvent.fire();	
				component.set("v.checkInputFX",false);
			}
			if(getLookup == "RM" && checkInputRM == true)
			{
				
				var compEvent = component.getEvent("oSelectedAccountEvent");

				compEvent.setParams({"accountByEvent" : getSelectAccount });  
				compEvent.setParams({"lookupName" : getLookup });  
	
				compEvent.fire();
				component.set("v.checkInputRM",false);
			}
		}
	},
  
	selectAccount : function(component, event, helper)
	{      

		var getSelectAccount = component.get("v.oAccount");
		var getLookup = component.get("v.lookupName");
 
		var compEvent = component.getEvent("oSelectedAccountEvent");

			compEvent.setParams({"accountByEvent" : getSelectAccount });  
			compEvent.setParams({"lookupName" : getLookup });  

			compEvent.fire();
	},
})