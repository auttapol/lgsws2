trigger RecommendedProductTrigger on Product_Interest__c (before insert, before update) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    
    if (Trigger.isBefore && Trigger.isInsert)
    {
        system.debug('RecommendedProductTrigger before insert ');
        if( RunTrigger || Test.isRunningTest() )
        {
            RecommendedProductTriggerHandler.checkProductPricebook(Trigger.new, new list<product_interest__c>());
            RecommendedProductTriggerHandler.checkDuplicateRecommendedProduct(Trigger.new, new list<product_interest__c>());
        }
    } 
    
    if (Trigger.isBefore && Trigger.isUpdate)
    {
        system.debug('RecommendedProductTrigger before update');
        if( RunTrigger || Test.isRunningTest() )
        {
            RecommendedProductTriggerHandler.checkProductPricebook(Trigger.new, Trigger.old);
            RecommendedProductTriggerHandler.checkDuplicateRecommendedProduct(Trigger.new, Trigger.old);
        }
    } 

}