public without sharing class ExchangeRateServiceImpl implements  IExchangeRateService{ 
    public List<Exchange_Rate_Of_Thai_FCY__c> getAllExchangeRates(){         
         return ExchangeRateSelector.getAllExchangeRates();
     }
}