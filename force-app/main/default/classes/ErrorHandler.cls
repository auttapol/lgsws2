public with sharing class ErrorHandler {
    
    public static String statusMessage {get;set;}
    public static Status_Code__c statusCode;
    public static final String SUCCESS_CODE = '0000';
    public static final String MORE_THAN_30_RECORDS = '0005';
    public static final String DML_EXCEPTION_CODE = '1000';
    public static final String QUERY_EXCEPTION_CODE = '1001';
    public static final String CALLOUT_EXCEPTION_CODE = '1002';
    public static final String WEBSERVICE_ERROR_CODE = '1003';
    public static final String FOUND_DUP_ALLOW_CREATE = '1010';
    public static final String FOUND_DUP_NOT_ALLOW_CREATE = '1011';
    public static Map<String,Status_Code__c> StatusCodeMap {get;set;}
    public static ApexPages.Message Messagehandler(String status,String message){
    	statusCode = [SELECT Name,isError__c,Status_message__c FROM Status_Code__c WHERE Name=:status LIMIT 1];
    	ApexPages.Message apexmessage;
    
        if(status == DML_EXCEPTION_CODE || status ==QUERY_EXCEPTION_CODE
           || status == CALLOUT_EXCEPTION_CODE||status== FOUND_DUP_NOT_ALLOW_CREATE){
            apexmessage = ERRORMESSAGE(statusCode.Status_Message__c);
        }
            
        if(status == WEBSERVICE_ERROR_CODE){
            apexmessage = FATALMESSAGE(statusCode.Status_Message__c);
        }
        
        if(status == FOUND_DUP_ALLOW_CREATE){
            apexmessage = WARNINGMESSAGE(statusCode.Status_Message__c);
        }
        if(status ==MORE_THAN_30_RECORDS){
             apexmessage = ERRORMESSAGE(statusCode.Status_Message__c);
        }
        statusMessage = statusCode.Status_Message__c;
        return apexmessage;
    }
    
	public static ApexPages.Message Messagehandler(String status,String totalrecord,String message){
    	statusCode = [SELECT Name,isError__c,Status_message__c FROM Status_Code__c WHERE Name=:status LIMIT 1];
    	ApexPages.Message apexmessage;
    
        if(status == '0001'||status=='0002'||status=='0003'){
            apexmessage = ERRORMESSAGE(statusCode.Status_Message__c + message);
            statusMessage = statusCode.Status_Message__c+message;
        }
            
        else if(status == '0000'){
            apexmessage = INFOMESSAGE(statusCode.Status_Message__c);
            statusMessage = statusCode.Status_Message__c;
        }else if(status == '0004') {
            apexmessage = CONFIRMMESSAGE(message);
            statusMessage = statusCode.Status_Message__c;
        }else if(status =='0005'){
			apexmessage = ERRORMESSAGE(statusCode.Status_Message__c + message);
            statusMessage = statusCode.Status_Message__c+message;
        }   
        return apexmessage;
    }
    
    public static Boolean isAllowToCreate(TMBServiceProxy.SearchResultDTO searchResult){
        
       
       
        TMBServiceProxy.ArrayOfSearchDataDTO arrayOfSearch = searchResult.Datas;
        TMBServiceProxy.SearchDataDTO[] searchArr = arrayOfSearch.SearchDataDTO;
        for(TMBServiceProxy.SearchDataDTO search : searchArr){
            if((search.ID_TYPE==null)&&search.ID_NUMBER!=null){
                return false;
            }
        }
        
        return true;
    }
    
    public static ApexPages.Message ERRORMESSAGE(String message){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
        return myMsg;
    }
    
    public static ApexPages.Message INFOMESSAGE(String message){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, message);
    	return myMsg;
    }
    
    public static ApexPages.Message FATALMESSAGE(String message){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, message);
        return myMsg;
    }
    
    public static ApexPages.Message CONFIRMMESSAGE(String message){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, message);
        return myMsg;
    }
    
    public static ApexPages.Message WARNINGMESSAGE(String message){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, message);
        return myMsg;
    }
}