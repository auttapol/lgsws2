public class BCPFXOrderReportScheduler implements Schedulable{
    public void execute(SchedulableContext sc){
        String FX_ADM_EMAIL  = '';
        String FX_BCP_REPORT = '';
        List<String> FX_BCP_TIME_LIST = new List<String>();

        try {
            AppConfig__c cf = AppConfig__c.getValues('FX_Order_Email_Admin');
            FX_ADM_EMAIL = cf.Value__c;
        }catch(Exception e) {}

        try {
            AppConfig__c cf = AppConfig__c.getValues('FX_BCP_Report');
            FX_BCP_REPORT = cf.Value__c;
        }catch(Exception e) {}

        try {
            AppConfig__c cf = AppConfig__c.getValues('FX_BCP_Time');
            FX_BCP_TIME_LIST = cf.Value__c.split('-');
        }catch(Exception e) {
            FX_BCP_TIME_LIST.add('7');
            FX_BCP_TIME_LIST.add('19');
        }

        Datetime now = Datetime.now();

        Integer currentHour = now.hour();

        Integer startBCPTime = Integer.valueOf((String)FX_BCP_TIME_LIST.get(0));
        Integer endBCPTime   = Integer.valueOf((String)FX_BCP_TIME_LIST.get(1));

        if (currentHour > endBCPTime || currentHour < startBCPTime) {
            return;
        }
        
        if (FX_ADM_EMAIL != null && FX_ADM_EMAIL.length() > 0 && FX_BCP_REPORT != null && FX_BCP_REPORT.length() > 0) {
            //query FX_Order_Report_Schedule__c custom setting
            //Send Remaining FX Order Report
            List<String> emailOpsList = new List<String>();
            List<String> emailList = FX_ADM_EMAIL.split(';');

            for (String email:emailList) {
                emailOpsList.add(email);
            }

            String body = 'For BCP (Daily Hour): Please see in the attachment.';
            ReportExportToEmailUtil.exportFuture(FX_BCP_REPORT
                                                ,body
                                                ,ReportExportToEmailUtil.CSV_TYPE
                                                ,FX_BCP_REPORT
                                                ,emailOpsList);

            /*
            System.schedule('Hourly BCP FX Order Job', '0 0 * * * ?', new BCPFXOrderReportScheduler());
            */
        }
    }

}