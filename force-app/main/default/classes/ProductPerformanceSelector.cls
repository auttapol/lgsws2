public  without sharing  class ProductPerformanceSelector {
    public static string sqlProductPerformance(){
        return          
                 '   SELECT Account__c,Ending_OS_YTD__c, Product_Description__c, Product_Domain__c, Product_Hierachy_Code__r.Name , Product_Hierachy_Code__c, Product_Name__c, Rate__c, ISO_CURRENCY_CD__c '
                +'   FROM Product_Performance__c '
                +'   WHERE Product_Domain__c = \'Deposit & Investment\' AND ISO_CURRENCY_CD__c = : code  '
                +'         AND Account__c = : accountId ';
    }
    public static List<Product_Performance__c> getProductPerformanceTHB(id accountId){ 	
        string code ='THB';
        if(accountId == null)
            throw new ProductPerformanceSelectorException('accountId Cannot be null'); 
        
        string sql = sqlProductPerformance(); 
        return (List<Product_Performance__c>) Database.query(sql); 
    }
    public static List<Product_Performance__c> getProductPerformanceUSD(id accountId){ 	
        string code ='USD';
        if(accountId == null)
            throw new ProductPerformanceSelectorException('accountId Cannot be null'); 
        
        string sql = sqlProductPerformance(); 
        return (List<Product_Performance__c>) Database.query(sql); 
    }
    
    public static string sqlProductPerformanceOther(){
        return          
                 '   SELECT Account__c,Ending_OS_YTD__c, Product_Description__c, Product_Domain__c, Product_Hierachy_Code__r.Name , Product_Hierachy_Code__c, Product_Name__c, Rate__c, ISO_CURRENCY_CD__c '
                +'   FROM Product_Performance__c '
                +'   WHERE Product_Domain__c = \'Deposit & Investment\' AND ISO_CURRENCY_CD__c !=  \'THB\'   '
                +'         AND Account__c = : accountId ';
    }
    public static List<Product_Performance__c> getProductPerformanceOther(id accountId){ 	
        if(accountId == null)
            throw new ProductPerformanceSelectorException('accountId Cannot be null'); 
        
        string sql = sqlProductPerformanceOther(); 
        return (List<Product_Performance__c>) Database.query(sql); 
    }
    
    public class ProductPerformanceSelectorException extends Exception{   
    }
    
}