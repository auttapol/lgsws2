public without sharing class CXMHandler {
    
    private static String KEY_RUNNING_NUMBER = 'ReqRunningNumber';
    private static String KEY_RUNNING_DIGIT = 'ReqRunningDigit';
    private static String KEY_FORMAT_DTM = 'ReqFormatDtm';
    
    public static List<CXM_Config__c> confList = [ select Id,Name,Value__c from CXM_Config__c 
                                    where Name IN (:KEY_RUNNING_NUMBER,:KEY_RUNNING_DIGIT,:KEY_FORMAT_DTM) ];
        
    public static Map<String,RTL_CXM_Config__mdt> mapMetaConf {get{
        Map<String,RTL_CXM_Config__mdt> simList = new Map<String,RTL_CXM_Config__mdt>();        
        for( RTL_CXM_Config__mdt conf : [select id,DeveloperName,Value__c from RTL_CXM_Config__mdt ] ){
            simList.put(conf.DeveloperName,conf);
        }        
        return new Map<String,RTL_CXM_Config__mdt>(simList);
    }set;}
    
    

    public String getRequestId(){
        String returnString = '';
        try{
            Map<String,CXM_Config__c> mapConf = new Map<String,CXM_Config__c>();
            for( CXM_Config__c conf : confList ){
                mapConf.put(conf.Name,conf);
            }
            Integer digit = (mapConf.containsKey(KEY_RUNNING_DIGIT)) ? Integer.valueOf(mapConf.get(KEY_RUNNING_DIGIT).Value__c) : 0;
            String formatDTM = (mapConf.containsKey(KEY_FORMAT_DTM)) ? mapConf.get(KEY_FORMAT_DTM).Value__c : null;
            Integer running = (mapConf.containsKey(KEY_RUNNING_NUMBER)) ? Integer.valueOf(mapConf.get(KEY_RUNNING_NUMBER).Value__c)+1 : 0;
            if( String.valueOf(running).length() > digit ){
                running = 0;
            }
            String zero = '';
            for( Integer i = String.valueOf(running).length() ; i < digit ; i++ ){
                zero += '0';
            }
            returnString = System.now().format(formatDTM)+zero+running;  
            /*
            if( mapConf.containsKey(KEY_RUNNING_NUMBER) ){
                //mapConf.get(KEY_RUNNING_NUMBER).value__c = String.valueOf(running);
                //update mapConf.get(KEY_RUNNING_NUMBER);
            }*/
            
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
        }
        
        return returnString;        
    }
    
    public void updateRunningNumber(){
        Map<String,CXM_Config__c> mapConf = new Map<String,CXM_Config__c>();
        for( CXM_Config__c conf : confList ){
            mapConf.put(conf.Name,conf);
        }
        Integer running = (mapConf.containsKey(KEY_RUNNING_NUMBER)) ? Integer.valueOf(mapConf.get(KEY_RUNNING_NUMBER).Value__c)+1 : 0;
        
        if( mapConf.containsKey(KEY_RUNNING_NUMBER) ){
            if( String.valueOf(running).length() > Integer.valueOf(mapConf.get(KEY_RUNNING_DIGIT).Value__c) ){
                running = 0;
            }
            mapConf.get(KEY_RUNNING_NUMBER).value__c = String.valueOf(running);
            update mapConf.get(KEY_RUNNING_NUMBER);
        }
    }
    
    public Static Map<Id,SObject> filterToCXM(String objType,Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        String objectType = '';
        List<SObject> newItemsList = new List<SObject>();
        List<RTL_CXM_Condition__mdt> condList = [ select Id,Value__c,API_Name__c from RTL_CXM_Condition__mdt where Type__c = :objType ];
        Map<Id,SObject> returnList = new Map<Id,SObject>();
        if(objType == 'Task'){
            objectType = 'CXM_Field_Condition_Task';
        }
        List<App_Config__mdt> cxmFieldCondMetadata = [ SELECT Id,Value__c,DeveloperName FROM App_Config__mdt WHERE DeveloperName = :objectType LIMIT 1];
        List<String> fieldsList = cxmFieldCondMetadata.size()>0 && cxmFieldCondMetadata[0].Value__c != null? cxmFieldCondMetadata[0].Value__c .split(',') : new List<String>();
        if(oldItems != null){
            for( SObject eachNew : newItems.values() ){
                SObject eachOld = oldItems.get(eachNew.Id);
                for(String field : fieldsList){
                    if(eachNew.get(field) != eachOld.get(field)){
                        newItemsList.add(eachNew); 
                        break;
                    }
                }
            }
        }else{
            newItemsList.addAll(newItems.values());
        }

        for( SObject each : newItemsList ){
            Map<String,Boolean> mapCond = new Map<String,Boolean>();
            Boolean pass = true;
            for( RTL_CXM_Condition__mdt cond : condList ){
                try{
                    if( mapCond.containsKey(cond.API_Name__c) ){
                        if( String.valueOf(each.get(cond.API_Name__c)) == String.valueOf(cond.Value__c) ){
                            mapCond.put(cond.API_Name__c,true);    
                        }
                    }else{
                        System.debug('cxmcheck '+each.get(cond.API_Name__c));
                        System.debug('cxmcheck '+cond.Value__c);
                        System.debug('cxmcheck '+(String.valueOf(each.get(cond.API_Name__c)) == String.valueOf(cond.Value__c)) );
                        if( String.valueOf(each.get(cond.API_Name__c)) == String.valueOf(cond.Value__c) ){
                            mapCond.put(cond.API_Name__c,true);    
                        }else{
                            mapCond.put(cond.API_Name__c,false);
                        }                        
                    }
                    
                    /*if( each.get(cond.API_Name__c) != cond.Value__c ){
                        pass = false;
                    }*/    
                }catch( Exception e ){
                    each.addError('error field');
                }                
            }
            for( Boolean b : mapCond.values() ){
                if( !b ){
                    pass = b;
                }
            }
            System.debug('mix : id send '+each.get('Id'));
            System.debug('mix : Not_Send_CXM__c '+each.get('Not_Send_CXM__c'));
            if( true == each.get('Not_Send_CXM__c') ){                
                pass = false;
            }
            if(pass){                
                returnList.put(each.Id,each);                
            }
            
        }
        System.debug('filterToCXM : '+returnList);
        return returnList;
    }
    
    public static Boolean getQueueAvailable(){
        List<AsyncApexJob> query = new List<AsyncApexJob>();
        List<String> statusList = new List<String>();
        
        for( RTL_CXM_Status_Queue__mdt eachStatus : [ select Id,DeveloperName from RTL_CXM_Status_Queue__mdt ] ){
            statusList.add(eachStatus.DeveloperName);
        }
        
        try{
            query = [ SELECT ApexClass.Name,ApexClassId ,Status, MethodName, JobType, Id  
                                        FROM AsyncApexJob 
                                        where Status IN :statusList and ((JobType = 'Queueable' and ApexClass.Name = 'QueueableDispatcher') 
                                                                       /*or (JobType = 'Future' and ApexClass.Name = 'QueueableHandler' ('Queued','Preparing','Processing','Holding')
                                                                          and MethodName = 'chainJob')*/ )
                                          limit 1 ]; //
            System.debug('getQueueAvailable : '+query);
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
        }
        /*TEST_CXM__c tcxm = new TEST_CXM__c();
        try{
            if( query.size() > 0 ){
                tcxm.Remark__c = query.get(0).Id+' || '+query.get(0).Status;
            }            
            insert tcxm;
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
        }*/
        
        if( query.size() == 0 ){
            return true;
        }
        
        return false;
    }
    
    public void stampTaskForCXM(List<Task> newItems){
        Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([ select Id,DeveloperName 
                                                             from RecordType 
                                                             where SObjectType = 'Task' and DeveloperName = 'RTL_Retail_Task' ]);
        //Id userId = UserInfo.getUserId();
        //Update 14-02-2019 REQ-2019-3056
        List<Id> userIdList = new List<Id>();
        for( Task each : newItems ){
            //userIdList.add( userId );
            userIdList.add( each.OwnerId );
        }    
        Map<Id,User> userDetail = queryUserData(userIdList);

        for( Task each : newItems ){
            if( mapRecordType.containsKey(each.RecordTypeId) ){
                each.RTL_CXM_Send_Create__c = true;                
                if( userDetail.containsKey( each.OwnerId  ) ){
                    /*
                    each.RTL_Task_Created_Branch_Code__c = userDetail.get( userId ).RTL_Branch_Code__c;
                    each.RTL_Task_Created_Channel__c = userDetail.get( userId ).RTL_Channel__c;
                    each.RTL_Task_Created_Emp_Id__c = userDetail.get( userId ).Employee_Id__c;
                    each.RTL_Task_Created_Zone_Code__c = userDetail.get( userId ).Zone_Code__c;
                    each.RTL_Task_Created_Region_Code__c = userDetail.get( userId ).Region_Code__c;   
                    */             
                    each.RTL_Task_Created_Branch_Code__c = userDetail.get( each.OwnerId  ).RTL_Branch_Code__c;
                    each.RTL_Task_Created_Channel__c = userDetail.get( each.OwnerId  ).RTL_Channel__c;
                    each.RTL_Task_Created_Emp_Id__c = userDetail.get( each.OwnerId ).Employee_Id__c;
                    each.RTL_Task_Created_Zone_Code__c = userDetail.get( each.OwnerId  ).Zone_Code__c;
                    each.RTL_Task_Created_Region_Code__c = userDetail.get( each.OwnerId  ).Region_Code__c;   
                }       
            }
        }

    }
    
    public void stampEventForCXM(List<Event> newItems){
        Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([ select Id,DeveloperName 
                                                                   from RecordType 
                                                                   where SObjectType = 'Event' and DeveloperName = 'RTL_Retail_Events' ]);
        //Id userId = UserInfo.getUserId();
        //Update 14-02-2019 REQ-2019-3056
        List<Id> userIdList = new List<Id>();
        for( Event each : newItems ){
            //userIdList.add( userId );
            userIdList.add( each.OwnerId );
        }    
        Map<Id,User> userDetail = queryUserData(userIdList);
        for( Event each : newItems ){          
            if( mapRecordType.containsKey(each.RecordTypeId) ){
                each.RTL_CXM_Send_Create__c = true;
                if( userDetail.containsKey( each.OwnerId  ) ){
                    /*
                    each.RTL_Event_Created_Branch_Code__c = userDetail.get( userId ).RTL_Branch_Code__c;
                    each.RTL_Event_Created_Channel__c = userDetail.get( userId ).RTL_Channel__c;
                    each.RTL_Event_Created_Emp_Id__c = userDetail.get( userId ).Employee_Id__c;
                    each.RTL_Event_Created_Zone_Code__c = userDetail.get( userId ).Zone_Code__c;
                    each.RTL_Event_Created_Region_Code__c = userDetail.get( userId ).Region_Code__c;  
                    */             

                    each.RTL_Event_Created_Branch_Code__c = userDetail.get( each.OwnerId  ).RTL_Branch_Code__c;
                    each.RTL_Event_Created_Channel__c = userDetail.get( each.OwnerId  ).RTL_Channel__c;
                    each.RTL_Event_Created_Emp_Id__c = userDetail.get( each.OwnerId  ).Employee_Id__c;
                    each.RTL_Event_Created_Zone_Code__c = userDetail.get( each.OwnerId  ).Zone_Code__c;
                    each.RTL_Event_Created_Region_Code__c = userDetail.get( each.OwnerId  ).Region_Code__c;  
                }  
            }
        }
    }
    
    public static void checkCXMSendDuplicate(Map<Id,SObject> newItems,Map<Id,SObject> oldItems){
        for( SObject each : newItems.values() ){
            
            System.debug('mix : Not_Send_CXM__c : '+each.get('Not_Send_CXM__c'));
            System.debug('mix : RTL_CXM_Send_Next__c : '+each.get('RTL_CXM_Send_Next__c'));
            System.debug('mix : RTL_CXM_Send_Create__c : '+each.get('RTL_CXM_Send_Create__c'));
            if( each.get('RTL_CXM_Send_Create__c') == true ){
                each.put('Not_Send_CXM__c',true);
                each.put('RTL_CXM_Send_Next__c',false);
                each.put('RTL_CXM_Send_Create__c',false);
            }else if( each.get('RTL_CXM_Send_Next__c') == true ){
                each.put('Not_Send_CXM__c',true);
                each.put('RTL_CXM_Send_Next__c',false);
            }else if( each.get('RTL_CXM_Send_Next__c') == false ){
                each.put('Not_Send_CXM__c',false);
            }
           
            
        }
    }
    
    public Map<Id,User> queryUserData(List<Id> idList){
        return new Map<Id,User>([ select Id,Name,RTL_Branch_Code__c,RTL_Channel__c,
                                 Employee_Id__c,Zone_Code__c,Region_Code__c
                                 from User where Id IN :idList ]);
    }
    
    public void deleteLogAsyncRequest(){
        Date lastNDay = System.today()-Integer.valueOf( mapMetaConf.get('DELETE_ERROR_LOG_DAYS').Value__c );
        List<SObject> query = [ SELECT Id,CreatedDate  FROM AsyncRequest__c WHERE Aborted__c = false AND IsSuccess__c = true AND CreatedDate < :lastNDay];
        delete query;
    }
    
    public void deleteLogCalloutRequest(){
        Date lastNDay = System.today()-Integer.valueOf( mapMetaConf.get('DELETE_ERROR_LOG_DAYS').Value__c );
        List<SObject> query = [ SELECT Id,CreatedDate  FROM CalloutRequest__c 
                               WHERE Status__c = 'OK' 
                               and AsyncRequest__c IN (SELECT Id  FROM AsyncRequest__c WHERE IsSuccess__c = true AND aborted__c = false)  AND CreatedDate < :lastNDay];
        delete query;
    }
    
    public void deleteErrorLogAsyncRequest(){
        Date lastNDay = System.today()-Integer.valueOf( mapMetaConf.get('DELETE_ERROR_LOG_DAYS').Value__c );
        List<SObject> query = [ SELECT Id,CreatedDate  FROM AsyncRequest__c WHERE Aborted__c = true and IsSuccess__c = false and CreatedDate < :lastNDay ];
        delete query;
    }
    
    public void deleteErrorLogCalloutRequest(){
        Date lastNDay = System.today()-Integer.valueOf( mapMetaConf.get('DELETE_ERROR_LOG_DAYS').Value__c );
        List<SObject> query = [ SELECT Id,CreatedDate  FROM CalloutRequest__c WHERE Status__c = 'Failed' and CreatedDate < :lastNDay ];
        delete query;
    }
    
    public List<CalloutRequest__c> queryCXMErrorLog(){
        List<CalloutRequest__c> query = new List<CalloutRequest__c>();
        query = [ SELECT Id,RequestId__c,Response_Description__c,Status__c,sent__c,
                 Response_Code__c
                                         FROM CalloutRequest__c 
                                         WHERE Status__c = 'Failed' and CalloutHandlerName__c = 'CXMCalloutHandler'
                 and AsyncRequest__c IN (SELECT Id  FROM AsyncRequest__c WHERE IsSuccess__c = false and aborted__c = true) order by RequestId__c asc  ];    
        return query;
    }
    
    public List<CalloutRequest__c> queryCXMErrorLogById(String syncId){
        List<CalloutRequest__c> query = new List<CalloutRequest__c>();
        query = [ SELECT Id,RequestId__c,Response_Description__c,Status__c,sent__c,
                 Response_Code__c
                                         FROM CalloutRequest__c 
                                         WHERE Status__c = 'Failed' and CalloutHandlerName__c = 'CXMCalloutHandler'
                 and AsyncRequest__c IN (SELECT Id  FROM AsyncRequest__c WHERE IsSuccess__c = false and aborted__c = true and Id = :syncId) order by RequestId__c asc  ];    
        return query;
    }
    
    public void CXMSendEmailLog(String asyncId){
        System.debug( mapMetaConf.values() );
        EmailTemplate emailTemplateList = new EmailTemplate();
        try{            
            emailTemplateList = [select Id,Body,Name,developername,htmlValue  from EmailTemplate 
                                 where developername = 'CXM_Notification'];
            List<SObject> query = new List<SObject>(); 
            System.debug('Heap0 : '+Limits.getHeapSize());
            if( asyncId == null ){
                query = queryCXMErrorLog();
            }else{
                query = queryCXMErrorLogById(asyncId);
            }
            
            String lineReplace = '';
            System.debug('Heap1 : '+Limits.getHeapSize());
            for( SObject each : query ){
            
                //Fixed BAU 6780: CRM Retail - CXM notification email display wrong timezone 
                string strSent = string.valueOf(each.get('Sent__c'));                
                TimeZone tz = UserInfo.getTimeZone(); //TimeZone.getTimeZone('Asia/Bangkok');                
                DateTime dtSent_gmtTimeZone = Datetime.valueOf(strSent).addSeconds(+tz.getOffset(Datetime.now())/1000);
                string dtSent_Formatted = dtSent_gmtTimeZone.format('yyyy-MM-dd HH:mm:ss');         
                system.debug('dt now : ' + Datetime.now() + ', dt formatted : ' + dtSent_Formatted);
                
                lineReplace += 'Request ID : '+each.get('RequestId__c');
                lineReplace += '\n';
                //lineReplace += 'Sent : '+each.get('Sent__c');
                lineReplace += 'Sent : '+ dtSent_Formatted;
                lineReplace += '\n';
                lineReplace += 'Code : '+each.get('Response_Code__c');
                lineReplace += '\n';
                lineReplace += 'Description : '+each.get('Response_Description__c');
                lineReplace += '\n';
                System.debug('Heap : '+Limits.getHeapSize());
                lineReplace += 'Link : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+each.get('Id');
                lineReplace += '\n\n';
            }
            String body = emailTemplateList.Body.replaceAll('\\[Data\\]',lineReplace); 
            if( query.size() > 0 ){              
                sendEmail( body );  
            }
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
        }

    }
    
    public void sendEmail(String body){        
        try{
            String[] toAddresses = new String[]{};                 
            toAddresses.addAll( mapMetaConf.get('CXM_Email_Address').Value__c.split(',') );

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
            
            mail.setToAddresses(toAddresses);
            mail.setReplyTo( mapMetaConf.get('CXM_Email_Reply').Value__c );
            mail.setSenderDisplayName( mapMetaConf.get('CXM_Email_DisplayName').Value__c );
            mail.setSubject( mapMetaConf.get('CXM_Email_Subject').Value__c );
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody( body );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
        }catch( Exception e ){
            System.debug(e.getMessage());
        }
        
    }
    
}