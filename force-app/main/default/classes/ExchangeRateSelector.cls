public without sharing class ExchangeRateSelector {
     public static string sqlExchangeRateAll(){
        return   'SELECT  Id, Name , Currency_Full_Name__c ,ExchangeRateOfTHB__c FROM Exchange_Rate_Of_Thai_FCY__c Limit 500';
        
    }
    
     public static List<Exchange_Rate_Of_Thai_FCY__c> getAllExchangeRates(){        
        string sql = sqlExchangeRateAll();
        system.debug('::: sql' + sql);
        return (List<Exchange_Rate_Of_Thai_FCY__c>) Database.query(sql);
    }

}