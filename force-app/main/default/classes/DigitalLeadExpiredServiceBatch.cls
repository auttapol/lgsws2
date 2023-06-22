global class DigitalLeadExpiredServiceBatch extends DailyBatchAbstract implements Schedulable {

   public String UPDATE_DIGITAL_LEAD_EXPIRED = 'UPDATE_DIGITAL_LEAD_EXPIRED';


   global void execute(SchedulableContext sc){
     List<Digital_Lead_Expire_Batch__c> digitalLst = [SELECT Id,Name,SQL__c 
                                          From Digital_Lead_Expire_Batch__c
                                          Where Active__c = true
                                          LIMIT 20
                                          ];

    for (Digital_Lead_Expire_Batch__c expireBatch : digitalLst) {
        DigitalLeadExpiredServiceBatch digitalLeadExpire = new DigitalLeadExpiredServiceBatch();

        String SQL = expireBatch.SQL__c;

        if(Test.isRunningTest()){
            SQL += ' LIMIT 200';
        }

        DailyScheduleBatch digitalExpiredLead = new DailyScheduleBatch(SQL
                                                    ,true
                                                    ,digitalLeadExpire.UPDATE_DIGITAL_LEAD_EXPIRED+'_'+expireBatch.Name
                                                    ,'Lead'
                                                    ,'CRM Admin 2'
                                                    );

        digitalExpiredLead.setDailyBatchAbstract(digitalLeadExpire);

        Id BatchupdateWealthBatch = Database.ExecuteBatch(digitalExpiredLead);
    }
   }

   public override void doAction(Database.BatchableContext bc
                            , List<sObject> scope
                            ,DailyScheduleBatch dailyBatch) {

        Set<Lead> leadLst = new Set<Lead>();
        dailyBatch.SUCCESSLOG_HEAEDER = 'LeadId,Description\n';
        for (sObject sobj : scope) {
            Lead leadExpired = new Lead(Id=(Id)sobj.get('Lead__c'));
            leadExpired.Status = 'Expired';

            leadLst.add(leadExpired);
        }
        
        if (leadLst != null && leadLst.size() > 0) {
            dailyBatch.updateObjects(new List<Lead>(leadLst),dailyBatch.jobDailyName);

            for (String successId:dailyBatch.sucessIdList) {
              dailyBatch.CSV_LOG_SUCCESS += successId
                              +',Lead_Expired'
                              +'\n';
            }
        }
    }
}