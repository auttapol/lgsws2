public class ManageAPIGWTokenSchedulerUtil {
    public static final String JobName = 'getTokenGatewayJob - ';

    public static void setupScheduleDT(DateTime nextScheduleDT){
        System.debug('nextScheduleDT : ' + nextScheduleDT);
        String secondExp =  nextScheduleDT.secondGmt() < 10 ? ( '0' + String.valueOf(nextScheduleDT.secondGmt()) ) : String.valueOf(nextScheduleDT.secondGmt());
        String minuteExp =  nextScheduleDT.minuteGmt() < 10 ? ( '0' + String.valueOf(nextScheduleDT.minuteGmt()) ) : String.valueOf(nextScheduleDT.minuteGmt());
        String hourExp   =  nextScheduleDT.hourGmt()   < 10 ? ( '0' + String.valueOf(nextScheduleDT.hourGmt()) )   : String.valueOf(nextScheduleDT.hourGmt());
        String dayExp    =  nextScheduleDT.dayGmt()    < 10 ? ( '0' + String.valueOf(nextScheduleDT.dayGmt()) )    : String.valueOf(nextScheduleDT.dayGmt());
        String monthExp  =  nextScheduleDT.monthGmt()  < 10 ? ( '0' + String.valueOf(nextScheduleDT.monthGmt()) )  : String.valueOf(nextScheduleDT.monthGmt());
        String yearExp  =   String.valueOf(nextScheduleDT.yearGmt());

        String strSchedule = secondExp + ' ' + minuteExp + ' ' + hourExp + ' ' + dayExp + ' ' + monthExp + ' ' + '? '+ yearExp;
        System.debug('strSchedule : ' + strSchedule);

        String strJobName =  JobName + dayExp + '/' + monthExp + '/' + yearExp + ' '+ hourExp + ':' + minuteExp + ':' + secondExp;
        ManageAPIGWTokenScheduler manageTokenSch = new ManageAPIGWTokenScheduler();
        System.schedule(strJobName, strSchedule, manageTokenSch);
    }

    public static void abortOldJobs() {
        for(CronTrigger job : [SELECT id, CronJobDetail.name FROM CronTrigger WHERE CronJobDetail.name LIKE :JobName + '%']){
            System.abortJob(job.id);
        }
    }
}