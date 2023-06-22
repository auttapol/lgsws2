public class ManageAPIGWTokenScheduler implements Schedulable{
    public void execute(SchedulableContext ctx) {
        System.enqueueJob(new ManageAPIGWTokenQueue());
        ManageAPIGWTokenSchedulerUtil.abortOldJobs();
    }
}