public  without sharing  class ProductSelector {	
	public static string sqlProductForAccountPlanWallet(){
        return
				'SELECT Id, Name, Product_Domain__c, Product_Level__c,                                   '
				+'	ProductCode, SF_Product_Key__c, SF_Parent_Product__c, SF_Parent_Product_Name__c      '
				+'FROM Product2 where Product_Level__c = \'4\'                                           '
				+'	and Product_domain__c =\'Deposit & investment\'                                      ';
    }     
    public static List<Product2> getProductForAccountPlanWallet(){ 		 
		return (List<Product2>) Database.query(sqlProductForAccountPlanWallet()); 
    }
	public class ProductSelectorException extends Exception{   
    }
	
}