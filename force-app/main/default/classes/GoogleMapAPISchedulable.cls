global class GoogleMapAPISchedulable implements Schedulable  {
    global void execute(SchedulableContext sc) {
    	Id jobId = sc.getTriggerId();
    	System.abortJob(jobId);

    	String query = 'SELECT Id,Check_in_Location__c,Retry_Google_Map__c FROM Call_Report__c Where Is_Retry_for_GoogleMap__c = true '
                       +' and Is_Last_Checkin_Location__c = false ORDER BY LastModifiedDate ASC LIMIT 200';
        
    	GoogleExternalAPI batchGoogleMap = new GoogleExternalAPI(query);
    	Id BatchProcessId = Database.ExecuteBatch(batchGoogleMap,50);

    	Integer GoogleMAPInMinute = 60;
        try{
            List<App_Config__mdt> GoogleMapAPIMetaData 
                = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'GoogleMAPInMinute'];

            if (GoogleMapAPIMetaData != null && GoogleMapAPIMetaData.size() > 0) {
                GoogleMAPInMinute = Integer.valueOf(GoogleMapAPIMetaData.get(0).Value__c);
            }      
        }catch( Exception e ){
            System.debug(e);
        }

    	Datetime currenttime = System.now();
    	Datetime nextRuntime = currenttime.addMinutes(GoogleMAPInMinute);

    	String day = string.valueOf(nextRuntime.day());
        String month = string.valueOf(nextRuntime.month());
        String hour = string.valueOf(nextRuntime.hour());
        String minute = string.valueOf(nextRuntime.minute());
        String second = string.valueOf(nextRuntime.second());
        String year = string.valueOf(nextRuntime.year());

        String strJobName = 'Job-GoogleMapAPISchedulable_' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new GoogleMapAPISchedulable());
    }

}