public class AllMutualFundsScheduler implements Schedulable{
    public Integer currentRound;

    public AllMutualFundsScheduler(){
        this.currentRound = 1;
    }
    
    public AllMutualFundsScheduler(Integer currentRound){
        this.currentRound = currentRound;
    }

    public void execute(SchedulableContext ctx) {
        String Retry_SetTimeOut = System.Label.Retry_SetTimeOut;
        String Number_Of_Retry_Times = System.Label.Number_Of_Retry_Times;

        Integer retryTimeout = (!String.isBlank(Retry_SetTimeOut)) ? Integer.valueOf(Retry_SetTimeOut) : 20000;
        Integer maxRetryTime = (!String.isBlank(Number_Of_Retry_Times)) ? Integer.valueOf(Number_Of_Retry_Times)  : 3;

        System.enqueueJob(new AllMutualFundsQueue(retryTimeout, maxRetryTime, this.currentRound));
        RMC_Utility.abortOldJobs(AllMutualFundsQueue.ALL_MUTUAL_FUNDS_JOB);
    }
}