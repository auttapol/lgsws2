public with sharing class RTL_EventTriggerHandler extends TriggerHandler {
    private static String KEY_OBJECT = 'Event';
    
    public RTL_EventTriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(10);
        }
        else{
            this.setMaxLoopCount(1000);
        }
     
        System.Debug( 'TMB: -> RTL_EventTriggerHandler Invoked' );
    }
    
    protected override void beforeInsert(List<sObject> newList) {
        System.Debug('TMB: -> RTL_EventTriggerHandler start of beforeInsert');   
        CXMHandler cxm = new CXMHandler();
        cxm.stampEventForCXM(newList);
        System.Debug('TMB: -> RTL_EventTriggerHandler end of beforeInsert');  
    }
    
    protected override void beforeUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {
        System.Debug('TMB: -> RTL_EventTriggerHandler start of beforeUpdate');   
        CXMHandler.checkCXMSendDuplicate(newMap,oldMap);
        System.Debug('TMB: -> RTL_EventTriggerHandler end of beforeUpdate');  
    }
    
    protected override void afterInsert(map<id,sObject> newMap) {
        System.Debug('TMB: -> RTL_EventTriggerHandler start of afterInsert');   
        Map<Id,SObject> filterList = CXMHandler.filterToCXM(KEY_OBJECT,newMap,null);
        if( filterList.size() > 0 ){
            List<CalloutRequest__c> cr = CXMCalloutHandler.CreateCXMCalloutRequest( QueueableHandler.CALLOUT_TOKEN,KEY_OBJECT , filterList.values() );
            if( cr.size() > 0 && CXMHandler.getQueueAvailable() ){                
                QueueableHandler.startCalloutJob(QueueableHandler.CALLOUT_TOKEN, cr );
            }
        } 
        System.Debug('TMB: -> RTL_EventTriggerHandler end of afterInsert');  
    }
    
    protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {
        System.Debug('TMB: -> RTL_EventTriggerHandler start of beforeUpdate');   
        Map<Id,SObject> filterList = CXMHandler.filterToCXM(KEY_OBJECT,newMap,null);
        if( filterList.size() > 0 ){
            List<CalloutRequest__c> cr = CXMCalloutHandler.CreateCXMCalloutRequest( QueueableHandler.CALLOUT_TOKEN,KEY_OBJECT , filterList.values() );
            
            System.debug(' cr.size = ' +  cr.size()); 
            System.debug(' CXMHandler.getQueueAvailable = ' +  CXMHandler.getQueueAvailable());
            
            if( cr.size() > 0 && CXMHandler.getQueueAvailable() ){                
                QueueableHandler.startCalloutJob(QueueableHandler.CALLOUT_TOKEN, cr );
            }
        } 
        System.Debug('TMB: -> RTL_EventTriggerHandler end of beforeUpdate');  
    }
    
}