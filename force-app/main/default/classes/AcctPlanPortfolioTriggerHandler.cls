public class AcctPlanPortfolioTriggerHandler {
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    

        
   /* public static void handlerAfterInsert(List<AcctPlanPortfolio__c> portNew){
        List<AcctPlanPortfolio__c> listNew = checkConditionApprove(portNew,null);
        if( listNew.size() > 0 ){
            System.debug(':::: afterInsert Start ::::');
            Trigger_CSV(listNew,null,STR_INSERT);    
            System.debug(':::: afterInsert End ::::');
        }        
    }
    
    public static void handlerAfterUpdate(List<AcctPlanPortfolio__c> portNew,List<AcctPlanPortfolio__c> portOld){
        List<AcctPlanPortfolio__c> listNew = checkConditionApprove(portNew,portOld);
        if( listNew.size() > 0 ){
            System.debug(':::: afterUpdate Start ::::');
            Trigger_CSV(listNew,portOld,STR_UPDATE);    
            System.debug(':::: afterUpdate End ::::');
        }      
    }
    
    public static List<AcctPlanPortfolio__c> checkConditionApprove(List<AcctPlanPortfolio__c> portNew,List<AcctPlanPortfolio__c> portOld){
        List<AcctPlanPortfolio__c> listReturn = new List<AcctPlanPortfolio__c>();
        Map<Id,AcctPlanPortfolio__c> mapPortOld = new Map<Id,AcctPlanPortfolio__c>();
        if( portOld != null && portOld.size() > 0 ){
            mapPortOld.putAll(portOld);
        }
        
        for(AcctPlanPortfolio__c port : portNew){
            if(port.Status__c.indexOf('Approved') >= 0 ){
                listReturn.add(port);
            }
        }
        
        return listReturn;
    }
    
    
    
    
    
    public static void Trigger_CSV(List<AcctPlanPortfolio__c> portNew,List<AcctPlanPortfolio__c> portOld,String eventMode){
        System.debug(':::: Trigger_CSV Start ::::');
        Map<Id,AcctPlanPortfolio__c> listPortOld = new Map<Id,AcctPlanPortfolio__c>();
        if(eventMode == STR_UPDATE){
            listPortOld.putAll(portOld);
        }
        
        
        
        
    }*/
    public static void handlerBeforeDelete(List<AcctPlanPortfolio__c> portOld){
        System.debug(':::: Size ::::'+portOld.size()); 
        if( portOld.size() > 0 ){
            System.debug(':::: Before Delete Start ::::'); 
            //try{
                String portID = portOld.get(0).Id;
                List<AcctPlanPortfolio__c> portfoliolist = [SELECT id,ownerid,Year__c
                                                            FROM AcctPlanPortfolio__c
                                                            WHERE id=: portID];
                
                List<AcctPlanCompanyPort__c> comportList = [SELECT ID,ownerid
                                                            FROM AcctPlanCompanyPort__c 
                                                            WHERE Account_Plan_Portfolio__c = :portID];
                
                List<AcctPlanGroupPort__c> groupportList = [SELECT ID,ownerid,Account_Plan_Portfolio__c,Year__c
                                                            FROM AcctPlanGroupPort__c 
                                                            WHERE Account_Plan_Portfolio__c = :portID];
          system.debug('portID ='+ portID);
            system.debug('portfoliolist ='+ portfoliolist.size());
            system.debug('comportList ='+ comportList.size());
            system.debug('groupportList ='+ groupportList.size());
                List<AcctPlanCompanyPort__c> comportListDelete = new List<AcctPlanCompanyPort__c>();
                List<AcctPlanGroupPort__c> groupportListDelete = new List<AcctPlanGroupPort__c>();
                
                //Cannot Delete : Old data cannot support
                if(portfoliolist.size() >0){
                    AcctPlanPortfolio__c portfolioItem = portfoliolist.get(0);
                    for(AcctPlanCompanyPort__c item : comportList){
                        if(item.ownerid == portfolioItem.OwnerId){
                            comportListDelete.add(item);
                        }
                    }
                    system.debug('groupportList ='+ groupportList.size());
                    for(AcctPlanGroupPort__c item : groupportList){
                        if(item.ownerid == portfolioItem.OwnerId && item.Year__c == portfolioItem.Year__c){
                            system.debug('item =' + item);
                            groupportListDelete.add(item);
                        }
                    }
                }
                if(comportListDelete.size() >0){
                    delete comportListDelete;
                }
                if(groupportListDelete.size() >0){
                    delete groupportListDelete;
                }
            /*}catch(Exception e){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));  
            }*/
            System.debug(':::: Before Delete End ::::');
        }      
    }
    
    }