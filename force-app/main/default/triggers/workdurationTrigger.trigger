trigger workdurationTrigger on SLA_Per_Owner__c (before insert) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true'; 
    
     // Before insert record to database
     if(Trigger.isBefore && Trigger.isInsert) 
     {              
        if(RunTrigger || Test.isRunningTest()){            
            slaByHopCtl slaByHop = new slaByHopCtl();
            slaByHop.calculateAgingHop(trigger.New);
        }
    }

}