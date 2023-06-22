public class UpdateWealthTaskBatch extends DailyBatchAbstract {

   public String UPDATE_TASK_NOT_STARTED = 'UPDATE_TASK_NOT_STARTED';

   public String SQL_WEALTH_TASK = 'SELECT Id, Owner.Id,What.Id,Description ' 
                                        +' FROM Task '
                                        +' Where Status = \'Not Started\' And Owner.Id != null '
                                        +' and CreatedBy.Name = \'TMB Administrator\''
                                        +' and RTL_Channel__c = \'Wealth Management\'' 
                                        +' and Type = \'Visit\'' 
                                        +' and Priority = \'High\'' 
                                        +' and RecordType.DeveloperName = \'RTL_Retail_Task\''
                                        +' and RTL_Task_Subject__c = \'Portfolio Review\''
                                        //+' and (CreatedDate = LAST_MONTH OR CreatedDate = THIS_MONTH)'
                                        +' and ActivityDate > TODAY ';

    


   public UpdateWealthTaskBatch(){}


   public override void doAction(Database.BatchableContext bc
                            , List<sObject> scope
                            ,DailyScheduleBatch dailyBatch) {

      if (dailyBatch.jobDailyName == UPDATE_TASK_NOT_STARTED) {
        Map<Id,sObject> taskMap = new Map<Id,sObject>();

        for (sObject sobj : scope) {
            String description = String.valueOf(sobj.get('Description'));
            if (description.containsIgnoreCase('[Operating Model:')) {
                Id accId = Id.valueOf((String)sobj.get('WhatId'));
                taskMap.put(accId,sobj);
            }
        }


        //Query Account 
        List<Account> accLst = [SELECT Id,RTL_Wealth_RM__c FROM Account 
                                  Where 
                                  Id in: taskMap.keyset()
                                  AND RTL_Wealth_RM__c <> null];

        List<SObject> taskLst = new List<SObject>();
        Map<String,String> successMap = new Map<String,String>();
        dailyBatch.SUCCESSLOG_HEAEDER = 'Id,What.Id,Old Owner.Id,New Owner.Id\n';
        for (Account acc : accLst) {
            SObject sobj = taskMap.get(acc.Id);
            Id wealthId = Id.valueOf((String)sobj.get('OwnerId'));

            if (acc.RTL_Wealth_RM__c != null 
                  && acc.RTL_Wealth_RM__c != wealthId) {

              sobj.put('OwnerId',String.valueOf(acc.RTL_Wealth_RM__c));

              String log = sobj.get('Id')
                                    +','
                                    +sobj.get('WhatId')
                                    +','
                                    +wealthId
                                    +','
                                    +String.valueOf(acc.RTL_Wealth_RM__c);

              successMap.put(sobj.Id,log);

              taskLst.add(sobj);
            }
        }

        if (taskLst != null && taskLst.size() > 0) {
            dailyBatch.updateObjects(taskLst,dailyBatch.jobDailyName);
            for (String successId:dailyBatch.sucessIdList) {
                if (successMap.get(successId) != null) {
                    dailyBatch.CSV_LOG_SUCCESS += successId
                              +','+successMap.get(successId)
                              +'\n';
                }
            }
        }
        
      }

   }


}