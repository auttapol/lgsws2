global without sharing class TagAudioDataBatch implements Database.Batchable<sObject>
                                        , Database.Stateful
                                        , Database.AllowsCallouts {
    
    public List<String> ListcallId = null;
    public String transGroupId = null;
    public String auth_token = '';
                               
    global Datetime batchDate = DateTime.now();
    global Datetime batchStartTime = DateTime.now();
    global Datetime batchEndTime = null;

    public List<RTL_Online_Service_Log__c> logList = new List<RTL_Online_Service_Log__c>();
    public List<Voice_Tagging__c> updateVoiceTagging = new List<Voice_Tagging__c>();     
    
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    public class TagAudioService {
        public List<RTL_Online_Service_Log__c> TaglogList;
        public List<Voice_Tagging__c> voiceTagList;                                    

    }
    public static Integer VERINT_GETTOKEN_TIMEOUT_MILLISECS{
        get{
            Integer DEFAULT_TIMEOUT = 60000;
            if(VERINT_GETTOKEN_TIMEOUT_MILLISECS == null){
                try{
                    VERINT_GETTOKEN_TIMEOUT_MILLISECS = DEFAULT_TIMEOUT;
                    List<App_Config__mdt> verintTokenTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'VERINT_GETTOKEN_TIMEOUT_MILLISECS'];           
                        if (verintTokenTimeOut != null && verintTokenTimeOut.size() > 0) {
                            VERINT_GETTOKEN_TIMEOUT_MILLISECS = Integer.valueOf(verintTokenTimeOut.get(0).Value__c);
                        }           
                        
                    }catch( Exception e ){
                        VERINT_GETTOKEN_TIMEOUT_MILLISECS = DEFAULT_TIMEOUT;
                    }
            }
            return VERINT_GETTOKEN_TIMEOUT_MILLISECS;
            
        }set;
    }
    public TagAudioDataBatch(List<String> switchId) {
        //this.query = query;
        this.ListcallId = switchId;
        //this.transGroupId = transGroupId;
    }
    public TagAudioDataBatch(String transGroupId) {
        //this.query = query;
        //this.ListcallId = switchId;
        this.transGroupId = transGroupId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT id, Unique_Id__c, Call_Log_ID__c, Verint_Call_ID__c, Channel__c, Audio_Start_Time__c,Audio_Channel_Num__c,Audio_Module_Num__c,Audio_End_Time__c, Transaction_Group_Id__c, private_data__c, Import_Result__c,Import_Datetime__c, Error_Message__c, CREATEDDATE FROM Voice_tagging__c ';

        if(ListcallId != null){
            query += 'WHERE Call_Log_ID__c IN: ListcallId AND Import_Result__c = False';
            System.debug('ListcallId :' + ListcallId);
        }else if (transGroupId != null){
            query += 'WHERE Transaction_Group_Id__c =: transGroupId AND Error_Message__c = null';
            System.debug('transGroupId :' + transGroupId);
        }else{
            return null;
        }
        this.auth_token = getAuthToken();
        System.debug('query :' + query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Voice_Tagging__c> scope){
        if(scope != null){
            List<Voice_Tagging__c> listVoiceTagging = scope;
            Decimal roundPerSize = scope.size() < 100 ? 1 : Decimal.valueOf(scope.size()).divide(100, 2);
            Integer num = Integer.valueOf(roundPerSize);
            if(roundPerSize/num != 1){
                num++;
            }
            system.debug('Size/100 = '+ roundPerSize);
            system.debug('Round = ' + num);
            List<RTL_Online_Service_Log__c> oLoglst = new List<RTL_Online_Service_Log__c>();
            for(Integer i = 0 ; i<num ; i++){
                TagAudioService newService = new TagAudioService ();
                List<Voice_Tagging__c> inputlist = new List<Voice_Tagging__c>();
    
                Integer limitSize = 100;
                if(listVoiceTagging.size() < 100){
                    limitSize = listVoiceTagging.size();
                }
                System.debug('listVoiceTagging size :' + limitSize);
                    for(Integer j = 0 ; j < limitSize ; j++){
                        System.debug(j+1 + ' listVoiceTagging : ' + listVoiceTagging[j]);
                        inputlist.add(listVoiceTagging[j]);
                }
                System.debug('end');
                
                    for(Integer j = limitSize-1 ; j >= 0 ; j--){
                        listVoiceTagging.remove(j);
                }
                newService = tagAudioData(auth_token,inputlist);
                logList.addAll(newService.TaglogList);        
                updateVoiceTagging.addAll(newService.voiceTagList);
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        batchEndTime = DateTime.now();
        try {
            System.debug('Voice Update Size' + updateVoiceTagging.size());
            if(updateVoiceTagging != null && updateVoiceTagging.size() > 0){
                update updateVoiceTagging;
            }
            // Insert online log
            if (logList != null && logList.size() > 0) {
                insert logList;
            }    
        } catch (Exception e) {
            system.debug('Cannot insert online log' + e.getMessage());
        }
    }
    public static TagAudioService tagAudioData(String auth_token, List<Voice_Tagging__c> voicetaggingList){
        TagAudioService returnvalue = new TagAudioService();
        datamodelwsVerintCom.BasicHttpBinding_IDataModelWS iad = new datamodelwsVerintCom.BasicHttpBinding_IDataModelWS();
        iad.endpoint_x = 'callout:Telephony_Verint_Import_Audio_Data_API';
        // iad.endpoint_x = 'https://webhook.site/6bc6eecc-44dd-4c46-b834-57fa6e16737a';
        iad.inputHttpHeaders_x = new Map<String, String>{'Impact360AuthToken' => auth_token};

        Boolean isSuccess = false;
        Datetime startDate = null;
        String errorMessage = '';
        Integer allRecords = 0;
        Integer successRecords = 0;
        Integer failRecords = 0;
        RTL_Online_Service_Log__c osLog = null;
        List<RTL_Online_Service_Log__c> osLogList = new List<RTL_Online_Service_Log__c>();
        List<Voice_Tagging__c> LstVoiceTag = new List<Voice_Tagging__c>();          
        if(voicetaggingList.size() > 0){
            allRecords = voicetaggingList.size();
            for(Voice_Tagging__c vt: voicetaggingList)
            {
                //System.debug('dasMap:'+dasMap.get(call_id).get('audio_ch_num'));
            
                schemasMicrosoftCom200310Serializat1.ArrayOfstring envelop = new schemasMicrosoftCom200310Serializat1.ArrayOfstring();
                
                //Real implementation to use after DAS API works
                String[] arrOfString = new String[]{
                        '<Envelope>'+
                            '<Header>'+
                                '<Source>ExternalSource</Source>'+
                                '<Operation>Session Insert</Operation>'+
                                '<Time>'+formatDateTime(DateTime.now())+'</Time>'+
                            '</Header>'+
                            '<Data>'+
                                '<Extensions>'+
                                    '<Extension name="AudioAcquisition">'+
                                        '<Start>'+vt.Audio_Start_Time__c+'</Start>'+
                                        '<End>'+vt.Audio_End_Time__c+'</End>'+
                                        '<Module>'+vt.Audio_Module_Num__c+'</Module>'+
                                        '<TimeOffset>420</TimeOffset>'+
                                        '<Channel>'+vt.Audio_Channel_Num__c+'</Channel>'+
                                    '</Extension>'+
                                    '<Extension name="TelephonyContact">'+
                                        '<ID>'+vt.Verint_Call_ID__c+'</ID>'+
                                    '</Extension>'+ vt.private_data__c +
                                '</Extensions>'+
                            '</Data>'+
                    ' </Envelope>'
                    }; 

                System.debug('Request Body:'+arrOfString);
                System.debug('Request Body:'+JSON.serializePretty(arrOfString));
                envelop.string_x = arrOfString;
                startDate = Datetime.now();
                String errMsg;
                Integer retry = 0;
                try {
                    do{
                        try{
                            iad.ProcessEx(envelop, 'None');
                        }catch (Exception e){
                            System.debug('Retry: ' + retry + ' || Err: ' + e.getMessage());
                            errMsg = e.getMessage();
                            if(errMsg != 'Read timed out'){
                                throw new OtherException(errMsg);
                            }
                            else if(retry == 2 && errMsg == 'Read timed out'){
                                throw new OtherException(errMsg);
                            }
                            retry++;
                        }
                    }while(retry < 3 && errMsg == 'Read timed out');
    
                    isSuccess = true;
                    startDate = Datetime.now();
                    errorMessage = 'Success';
                    successRecords++;
                    vt.Import_Result__c = true;
                    vt.Error_Message__c = null;
                } catch (Exception e) {
                    isSuccess = false;
                    errorMessage = 'Error : ' + e.getMessage();
                    if(errorMessage.length() > 50){
                        errorMessage = errorMessage.left(50);
                    }
                    System.debug('Cannot save to verint :: ' + e.getMessage());
                    failRecords++;
                    vt.Error_Message__c = errorMessage;
                }
                LstVoiceTag.add(vt);
                osLogList.add(createOnlineLog(isSuccess, '', errorMessage, arrOfString.toString(), startDate, Datetime.now()));
            }
        }
        System.debug('All Records :'+ allRecords);
        System.debug('Success Records :'+ successRecords);
        System.debug('Fail Records :'+ failRecords);
        returnvalue.TaglogList = osLogList;
        returnvalue.voiceTagList = LstVoiceTag;
        return returnvalue;
        }
        public static String getAuthToken(){
            Http http = new Http();
            HttpRequest req = new HttpRequest();

            String return_token = '';
            
            req.setEndpoint('callout:Telephony_Verint_getToken');
            // req.setEndpoint('https://wfo.avayacloudthailand.com:9443/wfo/rest/core-api/auth/token');
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setTimeout(VERINT_GETTOKEN_TIMEOUT_MILLISECS);
            String bodyJson = '{"user": "{!$Credential.Username}", "password":"{!$Credential.Password}"}';
            req.setBody(bodyJson);

            HttpResponse res = http.send(req);
            
            if(res.getStatus() == 'OK'){
                Map<String, Object> token_map = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String token = JSON.serialize(token_map.get('AuthToken'));
                Map<String, Object> token_result = (Map<String, Object>)JSON.deserializeUntyped(token);

                return_token = token_result.get('token').toString();
            }

            return return_token;
        }
    public static String formatDateTime(Object dt){
        String payload = JSON.serialize(dt);
        //System.debug(payload);
        String[] firstSplit = payload.remove('"').split('\\.');
        String secondSplit = firstSplit[1].remove('Z');
        //System.debug(firstSplit);
        //System.debug(secondSplit.rightPad(7, '0'));
        
        firstSplit[1] = secondSplit.rightPad(7, '0');
        
        String ms = String.join(firstSplit, '.') + '+00:00';
        //System.debug(ms);
        return ms;
    }
    private static RTL_Online_Service_Log__c createOnlineLog(Boolean isSuccess ,String rmId, String errorMessage, String requestBody, DateTime startTime , DateTime endTime) {
        RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
        osLog.RTL_Is_Success__c = isSuccess;  
        osLog.RTL_Error_Message__c = errorMessage;
        osLog.RTL_RM_ID__c = rmId;
        osLog.RTL_Service_Name__c = 'Telephony Verint : Import Audio Data API';
        osLog.RTL_Start_DateTime__c = startTime;
        osLog.RTL_End_DateTime__c  = endTime;
        osLog.Remark__c = requestBody;
        return osLog;
    }
}