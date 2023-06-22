public class TargetNITriggerHandler {
    
    public static Id niTargetId;
    
    public static void handlerBeforeUpdate(List<Target__c> newList,List<Target__C> oldlist){
        /*00001 Code    
         * Create a trigger on Target Object to update AccPortProfile to rollup 
         * Target IN for each Group if there is a record that match year and RM. */
    }
    
    public static void handlerAfterInsert(List<Target__c> newList){        
        SummarizingTargetNIMonthly(newList);        
    }
    
    public static void handlerAfterUpdate(List<Target__c> newList){        
        SummarizingTargetNIMonthly(newList);        
    }

    private static void SummarizingTargetNIMonthly(List<Target__c> newList){
                
        List<Id> listOwnerId = new List<Id>();
        List<Integer> listYear = new List<Integer>();
        List<String> strListYear = new List<String>();
        
        for( Target__c newTarget : newList ){
                if(newTarget.OwnerId != null){
                    listOwnerId.add(newTarget.OwnerId);
                } 
                
                System.debug(':::: target.OwnerId ::::'+newTarget.OwnerId);
               
                if( newTarget.Monthly_Target_Date__c != null ){
                    listYear.add(Integer.valueOf(String.valueOf(newTarget.Monthly_Target_Date__c).substring(0,4)));                    
                    strListYear.add(String.valueOf(newTarget.Monthly_Target_Date__c).substring(0,4));
                }
            }
            
            //System.debug(':::: strListYear= ::::'+strListYear);
        
         //1. Perform only when Record Type = TargetNI record Type (The new record type created in BL00012)
         List<RecordType> recordTypeId = [select Id from RecordType where name = 'NI Target' limit 1];
            niTargetId = recordTypeId[0].Id;
              
         List<Target__c> queryTarget = [ select Id,OwnerId, Monthly_Target_Date__c, NI_Target_Monthly__c 
                                        from Target__c 
                                        where RecordTypeId =: niTargetId 
                                        and CALENDAR_YEAR(Monthly_Target_Date__c)  IN:listYear
                                        and OwnerId  IN :listOwnerId ];
        
         //System.debug(':::: queryTarget= ::::'+queryTarget); 
                
         //2. Check if any AcctPlanPortfolio is created for this RM and Year
         List<AcctPlanPortfolio__c> queryAcctPlanPortfolio = [ select Id,OwnerId,SalesOwner__c,
                                                             Year__c,TargetNI__c
                                                             from AcctPlanPortfolio__c
                                                             where SalesOwner__c IN :listOwnerId 
                                                             and Year__c IN :strListYear ];
        
         System.debug(':::: queryAcctPlanPortfolio = ::::' + queryAcctPlanPortfolio);
        
         //3. If no, Trigger will do nothing
         //4. If yes, update Target NI on AcctplanPortfolio 
         //   by summarizing Target NI Monthly (on Target) object based on Year and Customer.   
         for(AcctPlanPortfolio__c acctPlanPortfolio : queryAcctPlanPortfolio){
            
            Decimal niTargetMonthly = 0;
            for(Target__c target : queryTarget){    
                String year = String.valueOf(target.Monthly_Target_Date__c).substring(0,4);            
                if(year == acctPlanPortfolio.Year__c && target.OwnerId == acctPlanPortfolio.SalesOwner__c){
                
                if(target.NI_Target_Monthly__c == null) target.NI_Target_Monthly__c = 0;
                    
                    niTargetMonthly += target.NI_Target_Monthly__c; 
                }
            } 
            
            acctPlanPortfolio.TargetNI__c = niTargetMonthly;
                         
            System.debug(':::: Sum of TargetNI ::::' + acctPlanPortfolio.TargetNI__c);
             
            update acctPlanPortfolio;                 
         }
    }    
}