global without sharing class UpdateToECMController implements Queueable
                                            , Database.AllowsCallouts {


    private static boolean checkLoop = true;
    private Integer BATCHSIZE = 50;
    private String query;
    private List<ECM_Repository__c> scopeQuery = new List<ECM_Repository__c> (); // << Change to Queueable
    private Integer offsetRecord = 0; // << Change to Queueable
    private Integer queueLoopLimit = 50; // << Change to Queueable

    List<ECM_MS_Doctype__c> ecmDocTypeList = new List<ECM_MS_Doctype__c>();
    Map<String,ECM_Repository__c> mapRepoForUpdate = New Map<String, ECM_Repository__c>();
    List<ECM_Repository__c> listRepoForUpdate = New List<ECM_Repository__c>();
    List<String> listObjectID =  New List<String>();
    List<onlinelogProperties> listOnlineLog = new List<onlinelogProperties>();

    public class onlinelogProperties {
		public boolean isSuccess{get;set;}
		public string requestToJSON{get;set;}
		public string responseToJSON{get;set;}
		public string responseDescription{get;set;}
		public DateTime startTime {get;set;}
		public DateTime endTime {get;set;}
        public String base64Data {get;set;}
        public String Reference_ID {get;set;}
    }    

    public UpdateToECMController(){
    }

    public UpdateToECMController(String queryStr, Integer osRecord, Integer limitRecord) {
        this.query = queryStr;
        this.offsetRecord = osRecord;
        this.scopeQuery = Database.query(this.query + ' LIMIT ' + limitRecord + ' OFFSET ' + osRecord);
    }

    public static AppConfig__c appCon_Endpoint {
        get
        { 
            if( appCon_Endpoint == null)
            {
                appCon_Endpoint = AppConfig__c.getValues('ECM_Endpoint');
            }
            return appCon_Endpoint;
        } 
        set; 
    }

    public App_Config__mdt appConMeta_Timeout{
        get{
            if(appConMeta_Timeout==null){
                appConMeta_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'ECM_REQUEST_TIMEOUT']; 
            }
            return appConMeta_Timeout;
        }
        set;
    }

    public static String ecm_retry_backDate {
        get
        { 
            if( ecm_retry_backDate == null)
            {   
                try{
                     ecm_retry_backDate = AppConfig__c.getValues('ECM_Retry_BackDate').Value__c;
                }catch(Exception e){
                    ecm_retry_backDate = '11';
                }
               
            }
            return ecm_retry_backDate;
        } 
        set; 
    }

    public void caseClosedFromTrigger(Map<Id,Case> oldMap,Map<Id,Case> newMap){ 
        //Check to protect double run class
        Integer loops;
        Integer limits;
        Integer totals;
        Integer offset = 0;
        Integer offsetIncrease;
        if(checkLoop){         
            List<String> listCaseID = New List<String>();
            for(ID caseID : newMap.keySet()){
                Case newCase = newMap.get(caseID);
                Case oldCase = oldMap.get(caseID);       
                if(newCase.IsClosed == true && oldCase.IsClosed == False){
                    listCaseID.add(newCase.id);
                }
            }
            if(listCaseID.size() > 0 && checkLoop){
                checkLoop = false;
                String caseID = '(';
                for(Integer i = 0; i < listCaseID.size() ; i++){
                    if (listCaseID.size() == 1){
                        caseID = caseID+ '\''+listCaseID[i]+ '\'';
                    }else {
                        if (i >= 0 && i < listCaseID.size()-1){
                            caseID = caseID+ '\''+listCaseID[i]+ '\''+',';
                        }else {
                            caseID = caseID+ '\''+listCaseID[i]+ '\'';
                        }
                    }
                }
                caseID = caseID + ')';
                //this.query = 'SELECT ID,CaseNumber FROM Case WHERE Id in '+ caseID;

                if (newMap.size() > queueLoopLimit * BATCHSIZE) {
                    // Record > 2500
                    loops = queueLoopLimit;
                    limits = Integer.valueOf(Math.floor(newMap.size()/queueLoopLimit));
                }else {
                    // Record < 2500
                    if (newMap.size() <= BATCHSIZE) {
                        // Record < 2500 & Record <= BATCHSIZE
                        loops = 1;
                        limits = newMap.size();
                    }else {
                        // Record < 2500 & Record > BATCHSIZE
                        loops = Integer.valueOf(Math.floor(newMap.size()/BATCHSIZE));
                        limits = BATCHSIZE;
                    }
                }
                offsetIncrease = limits;
                totals = newMap.size();
                try{
                    for (Integer i=1; i<=loops; i++) {
                        if (limits > (totals-limits)) {
                            limits = totals;
                        }

                        this.query = 'Select ID, Repository__c, ECM_App_ID__c, Object_ID__c,'+
                        'Case_Closed_Datetime__c,  Case__c, ECM_MS_Doctype_Key__c, Archival_Date__c, Disposal_Date__c,'+
                        'Update_ECM_Status__c, Update_ECM_Message__c, Retry_Flag__c from ECM_Repository__c where Case__c in '+ caseID + ' order by Case__c, Id';
                        UpdateToECMController ecm = new UpdateToECMController(this.query, offset, limits);
                        System.enqueueJob(ecm);
                        // Id BatchProcessIdForInt = Database.ExecuteBatch(this,this.BATCHSIZE); // << Change to Queueable

                        totals -= limits;
                        offset += offsetIncrease;
                    }
                        
                }catch(Exception e){
                    onlinelogProperties onlineRecord = new onlinelogProperties();
                    onlineRecord.isSuccess = false; 
                    onlineRecord.responseDescription = e.getMessage(); 
                    onlineRecord.requestToJSON = null; 
                    onlineRecord.responseToJSON = null; 
                    onlineRecord.startTime =  DateTime.Now();
                    onlineRecord.endTime = DateTime.Now();
                    onlineRecord.base64Data = null; 
                    onlineRecord.Reference_ID = null;
                    listOnlineLog.add(onlineRecord);
                    finishQueue();
                    // finish(null); // << Change to Queueable
                }
            } 
        }
    }

    // global Database.QueryLocator start(Database.BatchableContext BC){
    //     try {
    //         System.Debug('query: '+ query);
    //         return Database.getQueryLocator(this.query);
    //     } catch (Exception e) {
    //         system.debug(e.getStackTraceString());
    //         system.debug(e.getMessage());
    //         return null;
    //     }
    // }

    global void execute(QueueableContext context){
    // global void execute(Database.BatchableContext bc, List<ECM_Repository__c> scope){ // << Change to Queueable
        if(this.scopeQuery.size() > 0){
        // if(scope.size() > 0){ // << Change to Queueable
            this.grouppingRepo(this.scopeQuery);
            // this.grouppingRepo(scope); // << Change to Queueable
        }
        finishQueue();
    }

    //Batch daily for retry to send fail record to ECM
    /*global void execute(SchedulableContext sc){
        //Select record that case closed with in N days to retry
            if(ecm_retry_backDate == null){
            ecm_retry_backDate = '11';
        }
        Integer backdate = Integer.valueof(ecm_retry_backDate);
  
        this.query = 'SELECT ID, Repository__c, ECM_App_ID__c, Object_ID__c, Case_Closed_Datetime__c, Case__c, ECM_MS_Doctype_Key__c, Archival_Date__c, Disposal_Date__c,'+
                    'Update_ECM_Status__c, Update_ECM_Message__c, Retry_Flag__c from ECM_Repository__c where Retry_Flag__c = true '+
                    'AND Update_ECM_Status__c != '+ '\''+'200'+ '\''+' AND Case_Closed_Datetime__c = LAST_N_DAYS:'+backdate;
        
        try{
            UpdateToECMController ecm = new UpdateToECMController(this.query, 0);
            System.enqueueJob(ecm);
            finishQueue();
            // Id BatchProcessIdForInt = Database.ExecuteBatch(this,this.BATCHSIZE); // << Change to Queueable
        }catch(Exception e){
            onlinelogProperties onlineRecord = new onlinelogProperties();
            onlineRecord.isSuccess = false; 
            onlineRecord.responseDescription = e.getMessage(); 
            onlineRecord.requestToJSON = null; 
            onlineRecord.responseToJSON = null; 
            onlineRecord.startTime =  DateTime.Now();
            onlineRecord.endTime = DateTime.Now();
            onlineRecord.base64Data = null; 
            onlineRecord.Reference_ID = null;
            listOnlineLog.add(onlineRecord);
            finishQueue();
            // finish(null); // << Change to Queueable
        }
    }*/ // << Change to Queueable

    public void finishQueue() {
    // global void finish(Database.BatchableContext bc){ // << Change to Queueable
        //After sent update closed case date to ECM, update status back to Repository
        if(listRepoForUpdate.size() > 0){
            Database.update(listRepoForUpdate,false);
        }
        
        //Add online log service
        if(listOnlineLog.size() > 0){
             for(onlinelogProperties online : listOnlineLog){
                  this.onlineLog(online.isSuccess, online.responseDescription, online.requestToJSON, online.responseToJSON, online.startTime, online.endTime, online.base64Data, online.Reference_ID);
             }
        }
    }

    private void grouppingRepo(List<ECM_Repository__c> listECMRepo){

        Map<String, Map<ID,ECM_Repository__c>> mapRepo = New Map<String, Map<ID,ECM_Repository__c>>();        
        List<ID> listRepoID = New List<ID>();
        List<String> listGroupRepo = new List<String>();
        
        //Groupping repository to 2 grops Comcercial and Retail
        for(ECM_Repository__c repo : listECMRepo){
            if(mapRepo.containsKey(repo.Repository__c)){
                mapRepo.get(repo.Repository__c).put(repo.ID, repo);
                
            }else{
                mapRepo.put(repo.Repository__c,new Map<ID,ECM_Repository__c>());
                mapRepo.get(repo.Repository__c).put(repo.ID, repo);
                
            }
            listGroupRepo.add(repo.Repository__c); 
            listRepoID.add(repo.ID);
        }

        if(listGroupRepo.size() > 0){
            //Deduplicate repository
            Set<String> setDeDup = new Set<String>();
            setDeDup.addAll(listGroupRepo);
            listGroupRepo.clear(); // reset list           
            listGroupRepo.addAll(setDeDup);                   
        }
       

        if(mapRepo.size() > 0){
             for(integer i = 0; i < mapRepo.size() ; i++){
                String repositoryId = listGroupRepo[i];
                map<ID, ECM_Repository__c> listMapRepo = New map<ID, ECM_Repository__c>();
                List<ECM_Repository__c> listRepo = New List<ECM_Repository__c>();
                listMapRepo = mapRepo.get(listGroupRepo[i]);
                if(listMapRepo.size() > 0 && listRepoID.size() > 0){
                    for(integer j = 0; j < listRepoID.size() ; j++){
                        if(listMapRepo.containsKey(listRepoID.get(j))){
                            listRepo.add(listMapRepo.get(listRepoID.get(j)));
                        } 
                    }
                }
                //List of ECM repo by group
                if(listRepo.size() > 0){
                    prepareDataToECM(listRepo, repositoryId);                    
                }
                
            }            

        } 
    }

    public void prepareDataToECM(list<ECM_Repository__c> listRepoforSend, string repositoryId){
        map<String,ECM_MS_Doctype__c> ecmDocTypeMap = New map<String, ECM_MS_Doctype__c>();
        wsapiEcmClevelCom.dmsPropertiesType properties = new wsapiEcmClevelCom.dmsPropertiesType();
        
        wsapiEcmClevelCom.dmsDocumentIndexGroup[] indexGroups = new wsapiEcmClevelCom.dmsDocumentIndexGroup[]{};

        
        ecmDocTypeList = [SELECT Segment__c,Archival_Period__c,Disposal_Period__c,Expiry_Period__c,Repository__c
                    ,Type_Short_Name__c,Type_Code__c,Doc_Template__c,Doc_Location__c,Channel__c,Type_Name_TH__c
                    ,Source__c,Key__c FROM ECM_MS_Doctype__c Where  Source__c = 'A0291' ];

        if(ecmDocTypeList.size() > 0){
            for(ECM_MS_Doctype__c ecm : ecmDocTypeList){
                ecmDocTypeMap.put(ecm.Key__c, ecm);
            }
        }

        Integer numberOfRepo = 0;
        mapRepoForUpdate.clear();
        listObjectID.clear();

        for(ECM_Repository__c ecmRepo : listRepoforSend){
            wsapiEcmClevelCom.dmsDocumentIndexGroup repoForUpdate = new wsapiEcmClevelCom.dmsDocumentIndexGroup();
            numberOfRepo = numberOfRepo + 1;

            

            if(ecmRepo.ECM_MS_Doctype_Key__c != null){
                Datetime caseClosedDate = ecmRepo.Case_Closed_Datetime__c;
                wsapiEcmClevelCom.dmsPropertyDateTime[] propDatetime = new wsapiEcmClevelCom.dmsPropertyDateTime[]{};
                Integer archivalDay;
                if(Date.isLeapYear(Date.Today().Year()) == true)
                {
                    archivalDay = Integer.valueof(Double.valueof(ecmDocTypeMap.get(ecmRepo.ECM_MS_Doctype_Key__c).Archival_Period__c)*366);
                }
                else if(Date.isLeapYear(Date.Today().Year()) == false)
                {                  
                    archivalDay = Integer.valueof(Double.valueof(ecmDocTypeMap.get(ecmRepo.ECM_MS_Doctype_Key__c).Archival_Period__c)*365);
                }
                Datetime datetime_archivalDay = caseClosedDate.AddDays(archivalDay);
                wsapiEcmClevelCom.dmsPropertyDateTime TMB_ARCHIVAL_DATETIME = insertPropDatetime('TMB_ARCHIVAL_DATETIME',datetime_archivalDay);
                propDatetime.add(TMB_ARCHIVAL_DATETIME);
                Integer DisposalDay;
                if(Date.isLeapYear(Date.Today().Year()) == true)
                {
                    DisposalDay = Integer.valueof(Double.valueof(ecmDocTypeMap.get(ecmRepo.ECM_MS_Doctype_Key__c).Disposal_Period__c)*366);
                }
                else if(Date.isLeapYear(Date.Today().Year()) == false)
                {
                    DisposalDay = Integer.valueof(Double.valueof(ecmDocTypeMap.get(ecmRepo.ECM_MS_Doctype_Key__c).Disposal_Period__c)*365);
                }
                DateTime datetime_DisposalDay = caseClosedDate.AddDays(DisposalDay);
                wsapiEcmClevelCom.dmsPropertyDateTime TMB_DISPOSAL_DATETIME = insertPropDatetime('TMB_DISPOSAL_DATETIME',datetime_DisposalDay);
                propDatetime.add(TMB_DISPOSAL_DATETIME);

                properties.propertyDateTime = propDatetime;

                repoForUpdate.no = numberOfRepo;
                repoForUpdate.objectId = ecmRepo.Object_ID__c;
                repoForUpdate.properties = properties;                
                indexGroups.add(repoForUpdate);

                listObjectID.add(ecmRepo.Object_ID__c);

                ecmRepo.Archival_Date__c = datetime_archivalDay;
                ecmRepo.Disposal_Date__c = datetime_DisposalDay;
                mapRepoForUpdate.put(ecmRepo.Object_ID__c, ecmRepo);
            }
        } 

        updateToECM(repositoryId,indexGroups);
    }
 
    public static wsapiEcmClevelCom.dmsPropertyDateTime insertPropDatetime(String propertyDefinitionId,DateTime value) {
        wsapiEcmClevelCom.dmsPropertyDateTime propDatetime = new wsapiEcmClevelCom.dmsPropertyDateTime();
        propDatetime.propertyDefinitionId = propertyDefinitionId;
        Datetime[] propDatetime_value = new DateTime[]{};
        propDatetime_value.add(value);
        propDatetime.value = propDatetime_value;
        return propDatetime;
    }

    public void updateToECM(string repositoryId,wsapiEcmClevelCom.dmsDocumentIndexGroup[] indexGroups){

        UploadToECMController uploadECM = new UploadToECMController();       
        wsapiEcmClevelCom.ObjectServicePort updateRequest = new wsapiEcmClevelCom.ObjectServicePort();
        wsapiEcmClevelCom.dmsUpdateResponse[] updateResponse = new wsapiEcmClevelCom.dmsUpdateResponse[]{};
        wsapiEcmClevelCom.updateProperties requestUpdate = new wsapiEcmClevelCom.updateProperties();

        onlinelogProperties onlinelogRecord = New onlinelogProperties();

        updateRequest.endpoint_x = appCon_Endpoint.Value__c;
		updateRequest.timeout_x = Integer.valueof(appConMeta_Timeout.Value__c);

        requestUpdate.repositoryId = repositoryId;
        requestUpdate.indexGroups = indexGroups;    

        onlinelogRecord.requestToJSON = JSON.serialize(requestUpdate);
        onlinelogRecord.Reference_ID = repositoryId;
        try{

            onlinelogRecord.startTime = System.Now();
            updateResponse = updateRequest.updateProperties(repositoryId,indexGroups);                    
    		onlinelogRecord.responseToJSON = JSON.serialize(updateResponse);
                  
            Integer successRecord = 0;
            Integer failRecord = 0;
            for(integer i = 0 ; i < updateResponse.size() ; i++){

                wsapiEcmClevelCom.dmsUpdateResponse responeECM  = updateResponse[i];
                ECM_Repository__c ecmUpdate = New ECM_Repository__c();
                ecmUpdate = mapRepoForUpdate.get(responeECM.objectId);
				system.debug('Testxxx responeECM.code = '+ responeECM.code);
                if(responeECM.code == '200'){
                    successRecord = successRecord + 1;
                    ecmUpdate.Retry_Flag__c =  false;
                }else{
                    failRecord = failRecord + 1;
                    ecmUpdate.Retry_Flag__c =  true;
                }                
                ecmUpdate.Update_ECM_Status__c = responeECM.code;
                ecmUpdate.Update_ECM_Message__c = responeECM.description;
                listRepoForUpdate.add(ecmUpdate);
            }
            onlinelogRecord.endTime = System.Now();
            onlinelogRecord.isSuccess = true;
            onlinelogRecord.responseDescription = 'Total record for send update = '+ updateResponse.size() + 
                                                ' , successRecord = '+ successRecord +' , failRecord = '+ failRecord;

        }catch(Exception e){
	        onlinelogRecord.responseDescription = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
    		system.debug('Test error = '+ e.getMessage());
            onlinelogRecord.isSuccess = false;
            onlinelogRecord.endTime = System.Now();

            for(integer i = 0; i < listObjectID.size() ; i++){
                ECM_Repository__c ecmUpdate = New ECM_Repository__c();
                ecmUpdate = mapRepoForUpdate.get(listObjectID[i]);
                ecmUpdate.Update_ECM_Status__c = 'FAIL_For_RETRY';
                ecmUpdate.Retry_Flag__c =  true;
                ecmUpdate.Update_ECM_Message__c = e.getMessage();
                listRepoForUpdate.add(ecmUpdate);
            }
        }
        listOnlineLog.add(onlinelogRecord);
    }

    //Create online log                    
    private void onlineLog(Boolean isSuccess,String errorMessage,String requestBody,String responseBody,DateTime startTime,DateTime endTime,String base64Data, String Reference_ID){

        //String customerName = '';
        String msLogId = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
       // String rmId = '';
        String serviceName = 'UpdateClosedCaseDateTOECM';
        Account acc;
        OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,Reference_ID, errorMessage, msLogId , userName, Reference_ID , serviceName ,requestBody ,responseBody , acc , startTime , endTime, base64Data );
    }   
}