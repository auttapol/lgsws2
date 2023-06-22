global without sharing class TagCaseBatch implements Database.Batchable<sObject>
                                        , Database.Stateful
                                        , Database.AllowsCallouts {

    public String query;
    public List<Case> listcase;
    public List<Case> caseModified = new List<Case>();
    public String auth_token = '';
    public Map<String, List<Case>> caseOwners = new Map<String, List<Case>>();
    public Map<String, List<Case>> caseMap = new Map<String, List<Case>>();
    // public Map<String, Map<String,List<Case>>> caseMap_bySwitchCallId = new Map<String, Map<String,List<Case>>> ();
    // public Map<String,List<Case>> caseMap_byCallId = new Map<String,List<Case>>(); 
    public Set<String> callLogIdList = new Set<String>();
    public Map<String, Map<String,Map<String, Object>>>  dasMap = new Map<String, Map<String,Map<String, Object>>> ();
    public Map<String, String> caseErrorMsgMap = new Map<String, String>();
                                            
    global Integer recordsSuccessful = 0;
    global Integer recordsFailed = 0;
    global Datetime batchDate = DateTime.now();
    global Datetime batchStartTime = DateTime.now();
    global Datetime batchEndTime = null;
    private String transGroup;
    private String sobjectName = 'Case';
    private String jobDailyName = 'Error_Summary_Import Audio Data_'+ Datetime.now().format('YYYYMMdd_hh:mm');
    private String CSV_BODY = '';
    private String csvHeaderStr = '';
    private List<String> emailOpsList = new List<String>();
    private List<Voice_Tagging__c> listVoiceTagging = new List<Voice_Tagging__c>();
    static private Map<String,String> private_dataMap = new Map<String,String>();
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    public Integer countAll = 0;
    public Integer countError = 0;
    public Integer countSuccess = 0;
    
	// public Map<Id, Opportunity> opptyErrorMap;
    // public Map<Id, String> opptyErrorMsgMap;
    // public Map<Id, Opportunity> opptySuccessMap;

    List<RTL_Online_Service_Log__c> logList;

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

    
    public TagCaseBatch(List<Case> listcase) {
        //this.query = query;
        this.listcase = listcase;
    }

    //Batchable Section
    global List<Case> start(Database.BatchableContext bc){

        this.auth_token = getAuthToken();

        System.debug(this.auth_token);
       // return Database.getQueryLocator(query);
        return this.listcase;
    }

    global void execute(Database.BatchableContext bc ,List<Case> scope){
       // this.caseModified = scope;
       // List<Case> Lstcase = scope;
        System.debug('Scope Size ' + scope.size());
       List<Case> lst_case = (List<Case>)scope;
        System.debug('lst_case Size ' + lst_case.size());
        for(Case c : lst_case){
            callLogIdList.add(c.Call_Log_ID__c);
        }
        dasMap = dasQuery(
            this.auth_token,
            callLogIdList
        );
        System.debug('dasMap:'+dasMap.size());
        System.debug('dasMap:'+dasMap);

        Map<String,Task> taskMap = new Map<String,Task>();
        List<task> taskList = [SELECT Id, Call_Log_ID__c, Call_Agent_Id__c, Agent_Extension_Number__c FROM Task 
        WHERE Call_Log_ID__c IN: callLogIdList AND Agent_Extension_Number__c != null AND RTL_Channel__c = 'Inbound Call' ORDER BY CreatedDate DESC];
        //Map<String,String> uniqueIdwithCallAgentId = new Map<String,String>();
        for(Task task : taskList)
        {
            if(dasMap.containsKey(task.Call_Log_ID__c))
            {
                for(String call_id: dasMap.get(task.Call_Log_ID__c).keySet())
                {   //call_id = verint Id + extension      
                    System.debug('call_id' + call_id);
                    if(!taskMap.containsKey(task.Call_Log_ID__c+call_id+task.Call_Agent_Id__c))
                    {
                        //uniqueIdwithCallAgentId.put(task.Call_Log_ID__c+call_id,task.Call_Agent_Id__c);
                        if(String.valueOf(dasMap.get(task.Call_Log_ID__c).get(call_id).get('extension')) == String.valueOf(task.Agent_Extension_Number__c))
                        {
                            taskMap.put(task.Call_Log_ID__c+call_id+task.Call_Agent_Id__c,task);
                            System.debug('Put taskmap '+call_id + ' Agentnumber :' + task.Agent_Extension_Number__c);
                        }
                    }            
                }  
            }      
        }
        System.debug('taskMap' + taskMap);
        System.debug('taskMap size ' + taskMap.size());

        for(Case c : scope)
        {
            //System.debug('Case: '+c);
           //System.debug('dasMap:'+dasMap);
       
            if(dasMap.containsKey(c.Call_Log_ID__c))
            {
                for(String call_id: dasMap.get(c.Call_Log_ID__c).keySet())
                { 
                    System.debug('call id :' + call_id);
                    if(dasMap.get(c.Call_Log_ID__c).containsKey(call_id))
                    {
                        if(taskMap.containsKey(c.Call_Log_ID__c+call_id+c.Created_ID__c))
                        {
                            System.debug('Call Log Id : ' + c.Call_Log_ID__c);
                            System.debug('Extension:'+dasMap.get(c.Call_Log_ID__c).get(call_id).get('extension'));
                            System.debug('Agent_Extension_Number__c:'+taskMap.get(c.Call_Log_ID__c+call_id+c.Created_ID__c).Agent_Extension_Number__c);
                            if(String.valueOf(dasMap.get(c.Call_Log_ID__c).get(call_id).get('extension')) == String.valueOf(taskMap.get(c.Call_Log_ID__c+call_id+c.Created_ID__c).Agent_Extension_Number__c))
                            {
                                System.debug('Created_ID__c:'+c.Created_ID__c);
                                System.debug('Employee_ID__c:'+taskMap.get(c.Call_Log_ID__c+call_id+c.Created_ID__c).Call_Agent_Id__c);
                                if(c.Created_ID__c == taskMap.get(c.Call_Log_ID__c+call_id+c.Created_ID__c).Call_Agent_Id__c)
                                {
                                    if(caseMap.containsKey(c.Call_Log_ID__c+call_id+taskMap.get(c.Call_Log_ID__c+call_id+c.Created_ID__c).Agent_Extension_Number__c))
                                    {
                                        if(caseMap.get(c.Call_Log_ID__c+call_id+taskMap.get(c.Call_Log_ID__c+call_id+c.Created_ID__c).Agent_Extension_Number__c).size() < 4)
                                        {
                                            caseMap.get(c.Call_Log_ID__c+call_id+taskMap.get(c.Call_Log_ID__c+call_id+c.Created_ID__c).Agent_Extension_Number__c).add(c);
                                        }
                                    }
                                    else
                                    {
                                        caseMap.put(c.Call_Log_ID__c+call_id+taskMap.get(c.Call_Log_ID__c+call_id+c.Created_ID__c).Agent_Extension_Number__c, new List<Case>{c});
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if(caseOwners.containsKey(c.Created_Email__c)){
                caseOwners.get(c.Created_Email__c).add(c);
            }
            else{
                caseOwners.put(c.Created_Email__c, new List<Case>{c});
            }

            // Insert online service log

        }
        
        System.debug('caseMap:'+caseMap);
        System.debug('caseMap Size:'+caseMap.size());

        for(String call_log_id : callLogIdList)
        {         
                 
            if(dasMap.containsKey(call_log_id))
            {
                if(dasMap.get(call_log_id).size() > 0)
                {
                    System.debug('Do some callouts');
                    tagAudioData(dasMap.get(call_log_id), caseMap, call_log_id);  
                }
            }

        }     
        //String tranGroupId = 'INB_' + batchDate.year() + '-' + batchDate.month() + '-' + batchDate.day() + '_' + batchDate.hour() + ':' + batchDate.second();
        transGroup = batchDate.format('\'INB_\'yyyy-MM-dd\'_\'HH:ss');
        System.debug('transGroupId Date ' + transGroup);
        if(listVoiceTagging.size() > 0){
            for(Voice_Tagging__c vt : listVoiceTagging){
                vt.Transaction_Group_Id__c = transGroup;
                if(vt.Verint_Call_ID__c != null){
                    String mapkey = vt.Call_Log_ID__c + vt.Verint_Call_ID__c + vt.Extension__c;
                    //String callAgentId = uniqueIdwithCallAgentId.get(mapkey);
                    //vt.Unique_Id__c = mapkey + callAgentId;
                        if(private_dataMap.containsKey(mapkey)){
                            vt.private_data__c = private_dataMap.get(mapkey);
                        }else{
                            vt.Error_Message__c = 'Extension Not match';
                        }
                }
            }
            System.debug('listVoiceTagging ' + listVoiceTagging);
            try{
                //listVoiceTagging = checkduplicate(listVoiceTagging);
                upsert listVoiceTagging Unique_Id__c;
            }catch(Exception e){
                System.debug('Upsert listVoiceTagging ' + e);
            }
        }
    }

    global void finish(Database.BatchableContext bc){

        batchEndTime = DateTime.now();
        recordsSuccessful = countAll - countError;
        recordsFailed = countError;

        try {
            // Insert online log
            // if (logList != null && logList.size() > 0) {
            //     insert logList;
            // }
            System.debug('caseErrorMsgMap:'+caseErrorMsgMap);
            if(caseErrorMsgMap.size() > 0)
            {             

                csvHeaderStr = csvHeaderStr + 
                        'Switch Call Id' + ',' +
                        'Error Message';
                List<String> emailOpsList = new List<String>();
                for(String ID : caseErrorMsgMap.keySet()){
                    System.debug(ID + ' : ' + caseErrorMsgMap.get(ID));
                    
                    String errorMsg = caseErrorMsgMap.get(ID); 
                    
                    System.debug(errorMsg);           

                    CSV_BODY = CSV_BODY + 
                        ID + ',' +
                        caseErrorMsgMap.get(ID) + ',' + '\n';
                }

           
                emailOpsList.add('CRM Admin 2');

                RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                                , batchStartTime
                                                                , batchEndTime
                                                                , recordsSuccessful
                                                                , recordsFailed
                                                                , csvHeaderStr
                                                                , jobDailyName
                                                                , sobjectName
                                                                , emailOpsList
                                                                , CSV_BODY);
            }
            TagAudioDataBatch tag = new TagAudioDataBatch(transGroup);
            Database.executeBatch(tag);                

        } catch (Exception e) {
            system.debug('Cannot insert online log' + e.getMessage());
        }
    }
    //End batchable section

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
    
    private Map<String, Map<String,Map<String, Object>>> dasQuery(String auth_token, /*String user_id,*/ Set<String> switchCallIdList){

        Map<String, Map<String,Map<String, Object>>>  returnMap = new Map<String, Map<String,Map<String, Object>>> ();
        Map<String,List<String>> mapCallIdwithSwitchCallId = new Map<String,List<String>>();
        Map<String,Map<String, Object>> callIdMap = new Map<String,Map<String, Object>>();
        Set<String> responseCallId = new Set<String>();

        String requestCallId = '' ;
        Integer count = 0;
        for(String switchcallId : switchCallIdList){
            requestCallId += 'SWITCH_CALL_ID = ' + switchcallId;
            if(count != switchCallIdList.size() - 1){
                requestCallId += ' OR ';
            }
            count++;
        }

        System.debug('switchCallIdList:'+switchCallIdList);
        System.debug('requestCallId : '+ requestCallId);

        countAll += switchCallIdList.size();
        // for(String switch_call_id : switchCallIdList)
        // {
            //Map<String, Object> returnMap = new Map<String, Object>();
            
            // System.debug(JSON.serialize(DateTime.now().addYears(-1)).remove('"'));
            // System.debug(JSON.serialize(DateTime.now()).remove('"'));
            try 
            {
                DataAccessService.PageScrollingStatus pss = new DataAccessService.PageScrollingStatus();
                pss.RequestedPage = 'FirstPage';
                pss.CurrentPageBegin = JSON.serialize(DateTime.now().addYears(-1)).remove('"');
                pss.CurrentPageEnd = JSON.serialize(DateTime.now()).remove('"');
                
                DataAccessService.Period p = new DataAccessService.Period();
                p.BeginPeriod = JSON.serialize(DateTime.now().addYears(-1)).remove('"');
                p.EndPeriod = JSON.serialize(DateTime.now()).remove('"');
                p.Type_x = Voice_Tagging_Setting__c.getValues('Period_Type').Value__c;
                p.Days = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('Period_Days').Value__c);
                
                DataAccessService.Field f = new DataAccessService.Field();
                f.name = Voice_Tagging_Setting__c.getValues('Field_Name').Value__c;
                f.SequentialId = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('Field_SequentialId').Value__c);
                f.AggregationOperator = Voice_Tagging_Setting__c.getValues('Field_AggregationOperator').Value__c;
                
                DataAccessService.Field reqf = new DataAccessService.Field();
                reqf.name = Voice_Tagging_Setting__c.getValues('RequestedData_Field').Value__c;
                reqf.SequentialId = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('RequestedData_SequentialId').Value__c);
                reqf.AggregationOperator = Voice_Tagging_Setting__c.getValues('AggregationOperator').Value__c;
                
                DataAccessService.ArrayOfField aof = new DataAccessService.ArrayOfField();
                aof.Field = new List<DataAccessService.field>{f};
                    
                DataAccessService.ArrayOfField aorf = new DataAccessService.ArrayOfField();
                aorf.Field = new List<DataAccessService.field>{reqf};
                
                DataAccessService.SortOrder so = new DataAccessService.SortOrder();
                so.Direction = Voice_Tagging_Setting__c.getValues('Direction').Value__c;
                so.Fields = aof;
                
                DataAccessService.RestrictionFlags rf = new DataAccessService.RestrictionFlags();
                rf.ETMFilters = 'Inactive';
                rf.MultiChannel = 'Active';
                rf.PersonalTag = 'Active';
                
                DataAccessService.Visibility v = new DataAccessService.Visibility();
                v.Database = Voice_Tagging_Setting__c.getValues('Database').Value__c;
                v.UserRole = Voice_Tagging_Setting__c.getValues('Visibility_UserRole').Value__c;
                v.Application = Voice_Tagging_Setting__c.getValues('Application').Value__c;
                v.QueryPurpose = Voice_Tagging_Setting__c.getValues('QueryPurpose').Value__c;
                v.RestrictionFlagsSet = rf;
                
                DataAccessService.Display disp = new DataAccessService.Display();
                disp.QueryTime = Voice_Tagging_Setting__c.getValues('QueryTime').Value__c;
                disp.PageSize = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('PageSize').Value__c);
                disp.HasEmotion = Boolean.ValueOf(Voice_Tagging_Setting__c.getValues('HasEmotion').Value__c);
                disp.ExtraEvaluationInfo = '';
                disp.RandomSampling = Boolean.ValueOf(Voice_Tagging_Setting__c.getValues('RandomSampling').Value__c);
                disp.QueryPeriod = p;
                disp.SortOrder = so;
                
                DataAccessService.RequestedData rd = new DataAccessService.RequestedData();
                rd.Fields = aorf;
                
                DataAccessService.QueryDefinition qd = new DataAccessService.QueryDefinition();
                qd.GUID = Voice_Tagging_Setting__c.getValues('GUID').Value__c;
                // qd.UserId = Integer.valueOf(user_id);
                qd.UserId = Integer.ValueOf(Voice_Tagging_Setting__c.getValues('UserId').Value__c);
                qd.PresentationProperties = disp;
                qd.Visibility = v;
                //qd.ConditionsStr = 'SWITCH_CALL_ID = '+switch_call_id;
                qd.ConditionsStr = requestCallId;
                qd.RequestedData = rd;
                
                DataAccessService.AgWebServiceSoap awss = new DataAccessService.AgWebServiceSoap();
                awss.endpoint_x = 'callout:Telephony_Verint_DAS_API';
                // awss.endpoint_x = 'https://webhook.site/e7bc8163-3665-4111-bd72-2abb2acb2de0';
    
                awss.inputHttpHeaders_x = new Map<String, String>{'Impact360AuthToken' => auth_token};
                String errMsg;
                Integer retry = 0;
                DataAccessService.ExecuteUnifiedSessionQueryResponse_ExecuteUnifiedSessionQueryResult_diffgram_NewDataSet_Sessions_element[] result = null;
                do{
                    try{
                        result = awss.ExecuteUnifiedSessionQuery_Http(qd, pss).diffgram.newdataset.Sessions;
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


                // System.debug(JSON.serializePretty(qd));
                // System.debug(JSON.serializePretty(pss));
                System.debug('result:'+result);
                System.debug('result size:'+result.size());

                if(result != null)
                {
                    if(result.size() > 0)
                    {
                        for(DataAccessService.ExecuteUnifiedSessionQueryResponse_ExecuteUnifiedSessionQueryResult_diffgram_NewDataSet_Sessions_element r : result)
                        {
                            //System.debug('result:'+r);
                            
                            r.audio_end_time = r.audio_end_time.addHours(-7);
                            // System.debug('sid:'+r.sid);
                            // System.debug('audio_start_time_gmt:'+r.audio_start_time_gmt);
                            // System.debug('audio_end_time:'+r.audio_end_time);
                            // System.debug('audio_module_num:'+r.audio_module_num);
                            // System.debug('audio_ch_num:'+r.audio_ch_num);
                            // System.debug('call_id:'+r.call_id);
                            // System.debug('extension:'+r.extension);
                            // System.debug(formatDateTime(r.audio_start_time_gmt));
                            // System.debug(formatDateTime(r.audio_end_time));
    
                            Map<String, Object> resultMap = new Map<String, Object>();
                            
                            resultMap.put('audio_start_time_gmt', formatDateTime(r.audio_start_time_gmt));
                            resultMap.put('audio_end_time', formatDateTime(r.audio_end_time));
                            resultMap.put('audio_module_num', r.audio_module_num);
                            resultMap.put('audio_ch_num', r.audio_ch_num);
                            resultMap.put('call_id', r.call_id);
                            resultMap.put('extension', r.extension);
                            callIdMap.put(String.valueOf(r.call_id)+String.valueOf(r.extension),resultMap);
                            if(r.switch_call_id != null){
                            if(mapCallIdwithSwitchCallId.containsKey(String.valueOf(r.switch_call_id))){
                                List<String> listcallId =  mapCallIdwithSwitchCallId.get(String.valueOf(r.switch_call_id));
                                listcallId.add(String.valueOf(r.call_id)+String.valueOf(r.extension));
                                mapCallIdwithSwitchCallId.put(String.valueOf(r.switch_call_id),listcallId);

                            }else{
                                List<String> listcallId = new List<String>();
                                listcallId.add(String.valueOf(r.call_id)+String.valueOf(r.extension));
                                mapCallIdwithSwitchCallId.put(String.valueOf(r.switch_call_id),listcallId);

                            }
                                responseCallId.add(String.valueOf(r.switch_call_id));
                            }

                            Voice_Tagging__c vt = new Voice_Tagging__c();
                            vt.Unique_Id__c = String.valueOf(r.switch_call_id) + String.valueOf(r.call_id) + String.valueOf(r.sid);
                            vt.Call_Log_ID__c = String.valueOf(r.switch_call_id);
                            vt.Audio_Start_Time__c = formatDateTime(r.audio_start_time_gmt);
                            vt.Audio_End_Time__c = formatDateTime(r.audio_end_time);
                            vt.Audio_Module_Num__c = String.valueOf(r.audio_module_num);
                            vt.Audio_Channel_Num__c = String.valueOf(r.audio_ch_num);
                            vt.Verint_Call_ID__c = String.valueOf(r.call_id);
                            vt.Channel__c = 'Inbound';
                            vt.Import_Result__c = false;
                            vt.Error_Message__c = null;
                            vt.Import_Datetime__c = Datetime.now();
                            vt.Import_Type__c = 'Case';
                            vt.Extension__c = String.valueOf(r.extension);
                            listVoiceTagging.add(vt);
                        } 
                    }
                    countSuccess++;
                    //returnMap.put(switch_call_id,callIdMap);
                    for(String Id : switchCallIdList){
                        if(!responseCallId.contains(Id)){
                            countError++;
                            Voice_Tagging__c vt = new Voice_Tagging__c();
                            vt.Unique_Id__c = Id;
                            vt.Call_Log_ID__c = Id;
                            vt.Channel__c = 'Inbound';
                            vt.Import_Result__c = false;
                            vt.Import_Datetime__c = Datetime.now();
                            vt.Import_Type__c = 'Case';
                            vt.Error_Message__c = 'Not Found';
                            vt.Extension__c = null;
                            listVoiceTagging.add(vt);
                        }
                    }
                    for(String switchcallId : mapCallIdwithSwitchCallId.keySet()){
                        List<String> verintId = mapCallIdwithSwitchCallId.get(switchcallId);
                        Map<String,Map<String, Object>> newMap = new Map<String,Map<String, Object>>();
                        //System.debug('verintId Size' + verintId.size());
                        for(String vId : verintId){
                            Map<String, Object> mapId = callIdMap.get(vId);
                            newMap.put(vId,mapId);
                        }
                        returnMap.put(switchcallId,newMap) ;
                        //newMap.clear();
                    }
                }
            } catch (Exception e) {
                countError = switchCallIdList.size();
                String errorMsg = '';              
                errormsg = e.getMessage();         
                System.debug('switch_call_id:' + requestCallId + ' Error:'+ errormsg);
                System.debug('Line error = ' + e.getLineNumber());
                for(String switchcallId : switchCallIdList){
                    caseErrorMsgMap.put(switchcallId, errormsg);         
                    Voice_Tagging__c vt = new Voice_Tagging__c();
                    vt.Unique_Id__c = switchcallId;
                    vt.Call_Log_ID__c = switchcallId;
                    vt.Channel__c = 'Inbound';
                    vt.Import_Result__c = false;
                    vt.Import_Datetime__c = Datetime.now();
                    vt.Import_Type__c = 'Case';
                    vt.Error_Message__c = errormsg;
                    vt.Extension__c = null;
                    listVoiceTagging.add(vt);
                }
            }      
            System.debug('returnMap' + returnMap.values());
            return returnMap;
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

    //currently used to replace ampersand (&) in callouts as it cause callout to failed
    //if any field used in callout contains (&) it must be replaced
    private static String replaceSpecialChar(String text){
        String returntxt = text.replace('&', '&amp;');
        return returntxt;
    }

    private static void tagAudioData(Map<String,Map<String, Object>> dasMap, Map<String, List<Case>> caseMap,String swict_call_id/*List<Case> caseList*/){
        // datamodelwsVerintCom.BasicHttpBinding_IDataModelWS iad = new datamodelwsVerintCom.BasicHttpBinding_IDataModelWS();
        // iad.endpoint_x = 'callout:Telephony_Verint_Import_Audio_Data_API';
        // iad.endpoint_x = 'https://webhook.site/6bc6eecc-44dd-4c46-b834-57fa6e16737a';
        
        //iad.inputHttpHeaders_x = new Map<String, String>{'Impact360AuthToken' => auth_token};
        String private_data = '';
		String caseDetail = '';
        Integer pVar = 3;
        Integer pCaseId = 17;

        Boolean isSuccess = false;
        Datetime startDate = null;
        String errorMessage = '';
        RTL_Online_Service_Log__c osLog = null;
        List<RTL_Online_Service_Log__c> osLogList = new List<RTL_Online_Service_Log__c>();
        System.debug('dasMap Size ' + dasMap.size());
        for(String call_id: dasMap.keySet())
        {
            //System.debug('dasMap:'+dasMap.get(call_id).get('audio_ch_num'));
            pVar = 3;
            pCaseId = 17;
            caseDetail = '';
            private_data = '';
            if(caseMap.containsKey(swict_call_id+call_id+dasMap.get(call_id).get('extension')))
            {
                if( caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension')).size() > 0)
                {
                    for(Integer i = 0; i < caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension')).size(); i++)
                    {
                        if(i > 0)
                        {
                            pVar += 3;    
                        }
                        System.debug('caseMap:'+caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i]);
                        caseDetail += +'<P'+(pCaseId+i)+'>'+caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].CaseNumber+'</P'+(pCaseId+i)+'>'+
                            '<P'+pVar+'>'+caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Category__c+'</P'+pVar+'>'+
                            '<P'+(pVar+1)+'>'+caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Sub_Category__c+'</P'+(pVar+1)+'>'+
                            '<P'+(pVar+2)+'>'+replaceSpecialChar(caseMap.get(swict_call_id+call_id+dasMap.get(call_id).get('extension'))[i].Product_Category__c)+'</P'+(pVar+2)+'>';
                    }
                        
                }
                System.debug('caseDetail:'+caseDetail);
                if(caseDetail != '')
                {
                    private_data = '<Extension name="PrivateData">'+ caseDetail + '</Extension>';
                    private_dataMap.put(swict_call_id+call_id,private_data);
                    System.debug('private_dataMap' + private_dataMap);
                }             
            }
            System.debug('private_data:'+private_data);
        }
    }
           
    // private static RTL_Online_Service_Log__c createOnlineLog(Boolean isSuccess ,String rmId, String errorMessage, String requestBody, DateTime startTime , DateTime endTime) {
    //     RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
    //     osLog.RTL_Is_Success__c = isSuccess;  
    //     osLog.RTL_Error_Message__c = errorMessage;
    //     osLog.RTL_RM_ID__c = rmId;
    //     osLog.RTL_Service_Name__c = 'Telephony Verint : Import Audio Data API';
    //     osLog.RTL_Start_DateTime__c = startTime;
    //     osLog.RTL_End_DateTime__c  = endTime;
    //     osLog.Remark__c = requestBody;
    //     return osLog;
    // }
    // private static List<Voice_Tagging__c> checkduplicate (List<Voice_Tagging__c> oldList){
    //     Map<String,Voice_Tagging__c> mapUniquekeywithVoiceTagging = new Map<String,Voice_Tagging__c>();
    //     for(Voice_Tagging__c each : oldList){
    //         if(mapUniquekeywithVoiceTagging.containsKey(each.Unique_Id__c)){
    //             if(each.Audio_End_Time__c > mapUniquekeywithVoiceTagging.get(each.Unique_Id__c).Audio_End_Time__c){
    //                 mapUniquekeywithVoiceTagging.put(each.Unique_Id__c,each);
    //             }
    //         }else{
    //             mapUniquekeywithVoiceTagging.put(each.Unique_Id__c,each);
    //         }
    //     }
    //     return mapUniquekeywithVoiceTagging.values();
    // }
}