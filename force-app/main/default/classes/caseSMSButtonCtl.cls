public class caseSMSButtonCtl {
    
    public Case caseObj {get;set;}
    private Map<Id,UserRecordAccess> recordAccessMap;
	private List<Profile> profile;
	private User currentUser;

    public Boolean stopPolling {get;set;}
    final Long start = Datetime.now().getTime();
    List<AppConfig__c> pollingTimeout = new  List<AppConfig__c>();
    
	private String BRANCH_CHANNEL = 'Branch';    
    private List<Case> caseList {get;set;}
    private SMSServiceHandler smsService;
    
    //check static variable 
    private static Boolean checkForPreventLoop = true;
    //check static variable
     
    private Boolean isBulk = false;
   
    public integer getTimeout(){
        pollingTimeout = [Select value__c from AppConfig__c where name = 'SMS_Timeout' limit 1];
        if(pollingTimeout.size() > 0 && pollingTimeout[0].Value__c != null){
            return integer.valueof(pollingTimeout[0].Value__c);
        }else{
            return 30; //Default timeout value 30 seconds
        }
    }
    
    public Boolean getIsEnabled() { 
        if(stopPolling){
            return true;
        }else{
            return Datetime.now().getTime() - start < getTimeout() * 1000;
         }
    }
   
    public caseSMSButtonCtl(){
        caseList = new list<case>();

        checkForPreventLoop = true;
        smsService = new SMSServiceHandler('SMS_CASE_Notification','Send_SMS_Details__c');
    }
    
    public caseSMSButtonCtl(ApexPages.StandardController crd) {
        checkForPreventLoop = true;
        smsService = new SMSServiceHandler('SMS_CASE_Notification','Send_SMS_Details__c');

		caseObj = (Case)crd.getRecord();        
        ID caseId = caseObj.id;
        DescribeSObjectResult describeResult = Case.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );       
        String query = 'SELECT ' +
            String.join( fieldNames, ',' ) +
            ' FROM ' +
            describeResult.getName()  +
            ' Where id = :caseId '
            ;
        caseObj = (Case)Database.query( query );        
		stopPolling = false;	
    }

    //This method for case trigger after insert
    public void checkSendSMSAfterInsert(List<Case> casemap){
        for(Case caseRecord : casemap){
            if(caseRecord.Bulk_Send_SMS__c == true && caseRecord.SMS_Mobile_Endpoint__c != null){
                caseList.add(caseRecord);
            }
        }
        if(caseList.size() > 0){
            isBulk = true;
            validateSendSMS();
        }
    }

    //This method for case trigger after update
    public void checkSendSMS(Map<Id,Case> oldMap,Map<Id,Case> newMap){
        for(Id caseID : newMap.keySet()){
            Case oldCase = oldMap.get(caseID);
            Case newCase = newMap.get(caseID);
            if(oldCase.Bulk_Send_SMS__c == false && newCase.Bulk_Send_SMS__c == true){
                caseList.add(newCase);
            }
        }

        if(caseList.size() > 0){
            isBulk = true;
            validateSendSMS();
        }
    }

    
 public void validateSendSMS(){
        
        stopPolling = true;
        list<Case_SMS_Code_Mapping__c> smsCodemapping = [Select ID, Case_Status__c,Field_SMS_Code_API__c
                                                          from Case_SMS_Code_Mapping__c];
        Map<String,String> StatusCodeMapping = new Map<String,String>();
        if(smsCodemapping.size() > 0){
            for(Case_SMS_Code_Mapping__c caseSMS : smsCodemapping){
                if(caseSMS.Case_Status__c != null){
                   StatusCodeMapping.put(caseSMS.Case_Status__c,caseSMS.Field_SMS_Code_API__c); 
                }
            }
        }

		profile = [SELECT Id, Name FROM Profile WHERE Id =: System.UserInfo.getProfileId()];
		currentUser = [SELECT Id,RTL_Channel__c  FROM User WHERE Id =:  System.UserInfo.getUserId() ];
 
        Map<String,Map<ID,String>> recordTemplateMap = new Map<String,Map<ID,String>>(); // <Status,<CaseID,SMSCode>>
        Map<Sobject,String> mapError = new Map<Sobject,String>();

        Map<Id,String> IdErrorMap = new Map<Id,String>();
       
        if(caseList == null){   
               caseList = New List<case>();
               caseList.add(caseObj);
        }

        Set<Id> recordIdSet = new Set<Id>();

        for (Case caseRecord : caseList){
            recordIdSet.add(caseRecord.Id);
        }

        Map<Id,UserRecordAccess> userRecordAccessMap = RTL_Utility.queryRecordAccess(recordIdSet,System.UserInfo.getUserId());
        
        for (Case caseRecord : caseList){
            String ownerId = String.ValueOf(caseRecord.OwnerId);
            //recordAccessMap = RTL_Utility.queryRecordAccess(new Set<Id>{caseRecord.id},System.UserInfo.getUserId());
            //UserRecordAccess recordAccess = recordAccessMap.containsKey(caseRecord.id)?recordAccessMap.get(caseRecord.id):null; 
            UserRecordAccess recordAccess = userRecordAccessMap.get(caseRecord.id);
            
            SObject sobj = (SObject)caseRecord;
            stopPolling = false; //Set start waiting in page screen
            
            if(((currentUser.RTL_Channel__c != BRANCH_CHANNEL && recordAccess != null && recordAccess.HasEditAccess == false)||
               ( currentUser.RTL_Channel__c == BRANCH_CHANNEL && caseRecord.Is_My_Branch__c == false)) && 
               caseRecord.Is_User_Resolved__c == false)
            {
                //ไม่มีสิทธิ์ส่ง SMS
                mapError.put(sobj,Label.Case_ERR012);

                IdErrorMap.put(sobj.Id,Label.Case_ERR012);

                continue;
                
            }            
            else if(caseRecord.IsClosed == true){
                //เคสปิดแล้วไม่สามารถส่ง SMS ได้
                mapError.put(sobj,Label.Case_ERR008);
                IdErrorMap.put(sobj.Id,Label.Case_ERR008);
                continue;
                
            }else{                
                
                if(smsService.getEnableToSentSMS(sobj,caseRecord.Status,false) == smsService.SMS_SERVICE_UNAVAILABLE){
                    //SMS service not available
                    mapError.put(sobj,Label.Case_ERR025);
                    IdErrorMap.put(sobj.Id,Label.Case_ERR025);
                    continue;
                    
                }else if(smsService.getEnableToSentSMS(sobj,caseRecord.Status,false) == smsService.SMS_SENT_SUCESS){
                    //เคสนี้ส่ง SMS ไปแล้ว ไม่สามารถส่งซ้ำได้
                    mapError.put(sobj,Label.Case_ERR010);
                    IdErrorMap.put(sobj.Id,Label.Case_ERR010);
                    continue;
                    
                }else if(StatusCodeMapping.containsKey(caseRecord.Status) && 
                         smsService.getEnableToSentSMS(sobj,caseRecord.Status, false) != smsService.SMS_IN_PROCESS){
                    
                    String smsCode = (String)sobj.get(StatusCodeMapping.get(caseRecord.Status));
                    
                    if(caseRecord.Status == 'Resolved'){            
                        if(caseRecord.SMS_Code_Resolved__c == null && caseRecord.SMS_Code_Resolution_1__c == null && caseRecord.SMS_Code_Resolution_2__c == null){
                            //เคสนี้ไม่สามารถส่ง SMS
                            mapError.put(sobj,Label.Case_ERR009);
                            IdErrorMap.put(sobj.Id,Label.Case_ERR009);
                            continue;
                            
                        }else{
                            if(caseRecord.Resolution_LIst__c == caseRecord.SMS_Resolution_1__c && caseRecord.SMS_Code_Resolution_1__c != null){
                                 smsCode = caseRecord.SMS_Code_Resolution_1__c;
    
                            }else if(caseRecord.Resolution_LIst__c == caseRecord.SMS_Resolution_2__c && caseRecord.SMS_Code_Resolution_2__c != null){
                                 smsCode = caseRecord.SMS_Code_Resolution_2__c;
                                
                            }else if(caseRecord.SMS_Code_Resolved__c != null){
                                 smsCode = caseRecord.SMS_Code_Resolved__c;
                            }
                        }  
                    }
                    if(smsCode == null || smsService.getEnableToSentSMS(sobj,caseRecord.Status,false) == smsService.NOT_ALLOWED_TO_SMS ||
                      caseRecord.SMS_Mobile_Endpoint__c == null){
                        //เคสนี้ไม่สามารถส่ง SMS
                        mapError.put(sobj,Label.Case_ERR009);
                        IdErrorMap.put(sobj.Id,Label.Case_ERR009);
                        continue;
                        
                    }else{ 
                        if(recordTemplateMap.containsKey(caseRecord.Status)){
                            recordTemplateMap.get(caseRecord.Status).put(caseRecord.ID,smsCode);
                        }else{
                            recordTemplateMap.put(caseRecord.Status,new Map<ID,String>());
                            recordTemplateMap.get(caseRecord.Status).put(caseRecord.ID,smsCode);
                        } 
                    }  
                }
            }
        }

        if (checkForPreventLoop == false) {
            return;
        }
        checkForPreventLoop = false;

        if(recordTemplateMap.size() > 0){    
            smsService.sendSMS(recordTemplateMap); 
        }
     
        if(mapError.size() > 0){
             if(isBulk == false){
                 for(Sobject caseErr : mapError.keySet()){
                    stopPolling = true; 
                 	caseErr.addError(mapError.get(caseErr));
                 }
             }else{
                 //Call function mapping error attached to email
                 smsService.setMapBulkError(IdErrorMap); 
            } 
        } 
        smsService.endCall();
    }

    public PageReference getSMSStatus() {  
        
        SObject sobj = (SObject)caseObj;    

          if(smsService.getEnableToSentSMS(sobj,String.valueOf(sobj.get('Status')),true) == smsService.SMS_SENT_SUCESS){               
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,Label.Case_ERR015));
              stopPolling = true;
              return null;
          }else if(smsService.getEnableToSentSMS(sobj,String.valueOf(sobj.get('Status')),true) == smsService.SMS_FAIL_SENT){
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_ERR014));
              stopPolling = true;
              return null;
          }else if(Datetime.now().getTime() - start >= getTimeout() * 1000){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_ERR013));
              stopPolling = true;
              return null;           
         }                  
        return null;    
    }   
}