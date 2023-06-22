global with sharing class ExchangeRateService{
  // Factory
    private static IExchangeRateService service()   {
        return (IExchangeRateService) new ExchangeRateServiceImpl();
    }   
     
     global static List<Exchange_Rate_Of_Thai_FCY__c> getAllExchangeRates(){
         return service().getAllExchangeRates();
     }
}