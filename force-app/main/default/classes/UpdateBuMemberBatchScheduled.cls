global class UpdateBuMemberBatchScheduled implements Schedulable{
    global void execute(SchedulableContext sc) {

        // 1) Get Config Batchsize from Custom Meta data        
        String className = UpdateBUMember.class.getName();
        Integer defaultBatchSize = 2000;
        Integer configBatchSize = 0;
        
        List<BatchSizeSetting__mdt> buMemberSize = Database.query('Select ApexClassName__c,BatchSize__c from BatchSizeSetting__mdt WHERE ApexClassName__c = :className');
        for( BatchSizeSetting__mdt size  : buMemberSize){
            configBatchSize =  size.BatchSize__c.intValue();
        }

        // 1.1) Set Correct Value to Batch Size
        configBatchSize = (configBatchSize == 0 || configBatchSize > 2000)? defaultBatchSize : configBatchSize;

        //2) Call Batch
        UpdateBUMember bat = new UpdateBUMember();
        database.executebatch(bat,configBatchSize);

    }
}