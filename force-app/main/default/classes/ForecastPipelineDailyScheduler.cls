global class ForecastPipelineDailyScheduler implements Schedulable{
    public static Integer batSize{
        get{
            if(batSize == null){
                batSize = 1000;

                Commercial_Forecast_App_Config__mdt mc = Commercial_Forecast_App_Config__mdt.getInstance('Forecast_Long_Term_Repayment_Batch_size');

                if(mc != null && mc.Value__c != null){
                    batSize = Integer.valueOf(mc.Value__c);
                }
            }
            return batSize;
        }set;
    }

    global void execute(SchedulableContext sc) {
        updateLongtermRepaymentBatch instance = new updateLongtermRepaymentBatch();
        AsyncQueue__c job = AsyncApexFrameworkUtil.CreateBatchQueue(instance, batSize,'updateLongtermRepaymentBatch',null);
        insert job;
        // database.executebatch(new updateLongtermRepaymentBatch(), batSize);
    }
}