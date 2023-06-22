global class AccountPlanConfig {
	// Lazy Load
	private static Map<string,string> mapDepositDemestic;	
	global static Map<string,string> getMapDepositDemestic
	{
		get{
			if(mapDepositDemestic == null){
				mapDepositDemestic  =	new Map<string,string/*label*/>();
				for(Account_Plan_Deposit_Section__c item : [SELECT 	Product_Hierachy_Name__c,Label__c 
				                                            FROM  Account_Plan_Deposit_Section__c 
				                                            WHERE  Section__c ='DepositDemestic']){
				      mapDepositDemestic.put(item.Product_Hierachy_Name__c.toLowerCase(),item.Label__c);  
				 }
			}		
			return mapDepositDemestic;
		}
	}
	// Lazy Load
	private static Map<string,string> mapDepositInterUsd;	
	global static Map<string,string> getMapDepositInterUsd
	{
		get{
			if(mapDepositInterUsd == null){
				mapDepositInterUsd  =	new Map<string,string/*label*/>();
				for(Account_Plan_Deposit_Section__c item : [SELECT 	Product_Hierachy_Name__c,Label__c 
				                                            FROM  Account_Plan_Deposit_Section__c 
				                                            WHERE  Section__c ='DepositInterUsd']){
				      mapDepositInterUsd.put(item.Product_Hierachy_Name__c.toLowerCase(),item.Label__c);  
				 }
			}		
			return mapDepositInterUsd;
		}
	}
		// Lazy Load
	private static Map<string,string> mapDepositInterOther;	
	global static Map<string,string> getMapDepositInterOther
	{
		get{
			if(mapDepositInterOther == null){
				mapDepositInterOther  =	new Map<string,string/*label*/>();
				for(Account_Plan_Deposit_Section__c item : [SELECT 	Product_Hierachy_Name__c,Label__c 
				                                            FROM  Account_Plan_Deposit_Section__c 
				                                            WHERE  Section__c ='DepositInterOther']){
				      mapDepositInterOther.put(item.Product_Hierachy_Name__c.toLowerCase(),item.Label__c);  
				 }
			}		
			return mapDepositInterOther;
		}
	}
}