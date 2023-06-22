public class AsyncApexFramework implements Schedulable{ 
    public static final String JobName = 'AsyncApexFramework - ';

    public void execute(SchedulableContext SC) { 
        Integer jobMins = 5;

        Commercial_Forecast_App_Config__mdt asyncApexJobMins = [SELECT Id, DeveloperName, Value__c, Description__c FROM Commercial_Forecast_App_Config__mdt WHERE DeveloperName = 'AsyncApexFramework_Recurring_Job_Mins' LIMIT 1];

        if(asyncApexJobMins != null && asyncApexJobMins.Value__c != null){
            jobMins = Integer.valueOf(asyncApexJobMins.Value__c);
        }

        Datetime nextScheduleDT = Datetime.now().addHours(7).addMinutes(jobMins);

        String secondExp =  String.valueOf(nextScheduleDT.secondGmt());
        String minuteExp =  String.valueOf(nextScheduleDT.minuteGmt());
        String hourExp   =  String.valueOf(nextScheduleDT.hourGmt());
        String dayExp    =  String.valueOf(nextScheduleDT.dayGmt());
        String monthExp  =  String.valueOf(nextScheduleDT.monthGmt());
        String yearExp  =   String.valueOf(nextScheduleDT.yearGmt());

        String strSchedule = secondExp + ' ' + minuteExp + ' ' + hourExp + ' ' + dayExp + ' ' + monthExp + ' ' + '? '+ yearExp;

        String strJobName =  JobName + dayExp + '/' + monthExp + '/' + yearExp + ' '+ hourExp + ':' + minuteExp + ':' + secondExp;

        try{
            List<AsyncQueue__c > lstBatch_StatusUpdate = new List<AsyncQueue__c >();
            lstBatch_StatusUpdate = AsyncApexFrameworkUtil.collectJobInfo(lstBatch_StatusUpdate); 
            lstBatch_StatusUpdate = AsyncApexFrameworkUtil.saveAsyncRecords(lstBatch_StatusUpdate);
            lstBatch_StatusUpdate = AsyncApexFrameworkUtil.startBatchJobs(lstBatch_StatusUpdate);
            lstBatch_StatusUpdate = AsyncApexFrameworkUtil.saveAsyncRecords(lstBatch_StatusUpdate);
            
            AsyncApexFramework asyncApexFramwork = new AsyncApexFramework();
            System.schedule(strJobName, strSchedule, asyncApexFramwork);
            
            List<CronTrigger> jobIdList = new List<CronTrigger>();

            jobIdList = [SELECT id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE :JobName + '%' AND CronJobDetail.JobType = '7' AND NextFireTime = NULL LIMIT 100];

            for(CronTrigger job : jobIdList){
                System.abortJob(job.id);
            }

        }catch(Exception e){
            system.debug('catch access : ' +  e);
            AsyncApexFramework asyncApexFramwork = new AsyncApexFramework();
            System.schedule(strJobName, strSchedule, asyncApexFramwork);
        }
    }
}