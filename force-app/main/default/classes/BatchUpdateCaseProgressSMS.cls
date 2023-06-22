global without sharing class BatchUpdateCaseProgressSMS implements Schedulable
                                                                , Database.Batchable<SObject>
                                                                , Database.Stateful
                                                                , Database.AllowsCallouts {

    private Integer BATCHSIZE = 50;
    private String query; 
    private SMSServiceHandler smsService;
    map<id,Case> mapCaseForUpdateUpdate = new map<id,Case>();

    map<id,string> mapAllSMSResult = new map<id,string>();

   public static String smsDuration {
    get
    { 
        if( smsDuration == null)
        {   
            try{
                smsDuration = AppConfig__c.getValues('SMS_Update_Duration').Value__c;
            }catch(Exception e){
                smsDuration = '5';
            }
           
        }
        return smsDuration;
    } 
    set; 
}     

    public BatchUpdateCaseProgressSMS() {
         
    }

    global void execute(SchedulableContext sc){   
        smsService = new SMSServiceHandler('SMS_CASE_Notification','SMS_update_progress_details__c');       
        Id BatchProcessIdForInt = Database.ExecuteBatch(this,this.BATCHSIZE); 

    }


    global Database.QueryLocator start(Database.BatchableContext BC){
        //Query Open case that SLA >= 7, Not over SLA and have SMS Code for send update progress
        this.query = 'SELECT ID, Casenumber,Status, CreatedDate,SLA_Day__c,PTA_Segment__c, SMS_Code_for_Update_Progress__c, SMS_Update_Progress_Count__c, SMS_Mobile_Endpoint__c,'; 
            query = query + 'SMS_update_progress_details__c,AccountId, Customer_ID__c, Account.Name, SMS_Auto_Completed__c,Customer_Name__c,Send_SMS_Details__c,';
            query = query + 'Sub_Category__c, Product_Category__c, Contact_Person_Name__c, SMS_Last_time_update_progress__c ';
            query = query + 'FROM Case WHERE IsClosed = false AND SLA_Day__c >= 7 AND Is_Over_SLA__c = 0 AND SMS_Code_for_Update_Progress__c != \'\''; 
        
       // system.debug('Test query = '+ query);
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope){

        List<Sobject> caseForSendSMS = New List<Sobject>();
        List<String> idLst = new List<String>();
        Map<String,String> mapSMSCode = new Map<String,String>();
        Integer duration = Integer.valueof(smsDuration);

        map<id,string> sentSMSResult = new map<id,string>();

        Boolean isServiceAvailable = true;

        if(scope.size() > 0){
                      
            for(Case caseRecord : scope){

                Date myDate = date.newinstance(caseRecord.CreatedDate.year(), caseRecord.CreatedDate.month(), caseRecord.CreatedDate.day());
                Integer numberDays = myDate.daysBetween(System.Today());
                Integer remainder = math.mod(numberDays, duration);
                if(remainder == 0 && caseRecord.SMS_Mobile_Endpoint__c != ''){

                    SObject CaseSobj = (SObject)caseRecord;

                    caseForSendSMS.add(CaseSobj);
                    idLst.add(caseRecord.id);
                    mapSMSCode.put(String.valueOf(caseRecord.id), caseRecord.SMS_Code_for_Update_Progress__c);

                    mapCaseForUpdateUpdate.put(caseRecord.id, caseRecord);
                }   
            }
            if(caseForSendSMS.size() > 0){ 
                try{ 
                    sentSMSResult = smsService.sendSMSCallOut(idLst,caseForSendSMS, mapSMSCode);
                    mapAllSMSResult.putAll(sentSMSResult);
                }
                catch(exception e){
                    system.debug(e.getMessage());
                    system.debug(e.getStackTraceString());
                } 
                
            }

        }

       
    }

    global void finish(Database.BatchableContext bc){

        if(mapAllSMSResult.size() > 0){
            List<case> caseForUpdate = new List<Case>();
            for(ID idRecord : mapAllSMSResult.keySet()){

                Case caseRecord = mapCaseForUpdateUpdate.get(idRecord);
                if(caseRecord.SMS_Update_Progress_Count__c == null){
                    caseRecord.SMS_Update_Progress_Count__c = 1;
                }else{
                    caseRecord.SMS_Update_Progress_Count__c = caseRecord.SMS_Update_Progress_Count__c + 1;
                }
                caseRecord.SMS_Last_time_update_progress__c = system.now();

                if(caseRecord.SMS_update_progress_details__c == null){
                    caseRecord.SMS_update_progress_details__c = system.now() + ' : '+mapAllSMSResult.get(idRecord);
                }else{
                    caseRecord.SMS_update_progress_details__c = system.now() + ' : '+ mapAllSMSResult.get(idRecord) +  '\n' +  caseRecord.SMS_update_progress_details__c ;
                }
                
                caseForUpdate.add(caseRecord);


            }
            if(caseForUpdate.size() > 0){
                //Partail update
                Database.update(caseForUpdate,false);

            }

        }

    }
}