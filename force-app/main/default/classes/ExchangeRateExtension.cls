public class ExchangeRateExtension {
    
    public ExchangeRateExtension()
    {
    
    }
    
    public static void afterInsert(list<Exchange_Rate_Of_Thai_FCY__c> listData)
    {
        list<Currency__c> insertData = new list<Currency__c>();
        List<Currency__c> UpdateData = new list<Currency__c>();        
        Map<String , Currency__c> currencyData = new Map<String , Currency__c>();                
        for (Currency__c a : [select Id, name from currency__c])
        {
            currencyData.put(a.name,a);
        }
        for (Exchange_Rate_Of_Thai_FCY__c a: listData)
        {
            // Insert Case
            if (!currencyData.containsKey(a.Name__c)){
                currency__c newData = new currency__c();
                newData.Name = a.Name__c;
                newData.ShortName__c = a.Name__c;
                newData.Exchange_Rate__c = a.id;
                insertData.add(newData);
            }
            // Update Case
            else{
                 Currency__c newData = new Currency__c();
                 newData.Id = (Id)currencyData.get(a.Name__c).Id;
                 newData.Exchange_Rate__c  = a.id;
                 UpdateData.add(newData);
            }
        }
        system.debug(insertData);
        insert insertData;
        update UpdateData;
    }


}