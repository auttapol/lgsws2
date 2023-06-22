public with sharing class CampaignMemberCallBackCtrl {

    @AuraEnabled
    public static Boolean checkBusinessHours(Map<String, Object> values,String businessName){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name =: businessName];
        DateTime dt;
        if(values.get('datetime') != null)
        {
            dt = DateTime.newInstance(long.valueOf(values.get('datetime')+''));
        }
        else 
        {
            throw new AuraHandledException(Label.CallBack_BusinessHours_ErrorMsg);
        }
        
        System.debug(BusinessHours.isWithin(bh.Id, dt));
        System.debug(dt <= datetime.now());
        if(!BusinessHours.isWithin(bh.Id, dt)){
            throw new AuraHandledException(Label.CallBack_BusinessHours_ErrorMsg);
        }

        return true;     
    }
    @AuraEnabled
    public static String insertTask(String recordId, Map<String, Object> values,String marketingCode,String businessName){

        Boolean checkBusinessHours = checkBusinessHours(values,businessName);

        // recordId = '00v1s000000iBkqAAE';
        if(checkBusinessHours)
        {
            DateTime dt = DateTime.newInstance(long.valueOf(values.get('datetime')+''));
            System.debug('DateTime:'+dt);
            System.debug('Number:'+values.get('number'));
            System.debug('Note:'+values.get('note'));
            System.debug('Mode:'+values.get('mode'));
            Id object_id = Id.valueOf(recordId);
            String remark = '';
            if(values.get('note') != null)
            {
                remark = String.valueOf(values.get('note'));
            }

            List<User> currentUser = [SELECT Id, Employee_Id__c FROM User WHERE Id = :UserInfo.getUserId()];

            Task newTask = new Task();
            newTask.IsReminderSet = true;
            newTask.ReminderDateTime = dt.addMinutes(-15);
            newTask.TaskSubtype = 'Call';
            newTask.Type = 'Outbound';
            newTask.Subject = 'Call Back';
            newTask.Call_Number__c = values.get('number')+'';
            newTask.Description = remark;
            newTask.Call_Back_Mode__c = values.get('mode')+'';
            newTask.Call_Start_Datetime__c = dt;
            newTask.OwnerId = currentUser.get(0).Id;
            newTask.Call_Agent_Id__c = currentUser.get(0).Employee_Id__c;
            newTask.Related_Object__c = recordId;
            newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Back').getRecordTypeId();
            //For testing while Avaya API is not working
            newTask.Call_Log_ID__c = '000000';
            newTask.ActivityDate = dt.date();
            newTask.Marketing_Code__c = marketingCode;

            if(object_id.getSObjectType().getDescribe().getName() == 'CampaignMember'){

                List<CampaignMember> member = [SELECT Id, LeadId, ContactId, Customer__r.Id FROM CampaignMember WHERE Id = :recordId LIMIT 1];
                if(!member.isEmpty()){

                    //Campaign Member related to account
                    if(!String.isBlank(member.get(0).ContactId)){
                        newTask.WhatId = member.get(0).Customer__r.Id;
                    }
                    //Campaign Member related to lead
                    else if(!String.isBlank(member.get(0).LeadId)){
                        newTask.WhoId = member.get(0).LeadId;
                    }
                    //Somrthing else
                    else {

                    }
                }
            }
            else if(object_id.getSObjectType().getDescribe().getName() == 'RTL_Referral__c'){
                newTask.WhatId = object_id;
            }

            insert newTask;

            return newTask.Id;
        }
        return null;

    }

    public static String transformDateTime(String unix_timestamp){

        DateTime dt = Datetime.newInstance(long.valueOf(unix_timestamp));
        String dt_str = dt.format('yyyy/MM/dd HH:mm');

        return dt_str;
    }

    /*@AuraEnabled
    public static Map<String, Object> scheduleCallback(Map<String, Object> values){

        Map<String, Object> result_map = new Map<String, Object>();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Telephony_Avaya_Schedule_Callback');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-Requested-With', 'rest');
        request.setBody('{'+
                            '"userContactID": "201",'+
                            '"contactListName": "MIS",'+
                            '"campaignName": "TestCampaign",'+
                            '"startTime": "'+transformDateTime(''+values.get('datetime'))+'",'+
                            '"endTime": "",'+
                            '"timeZone": "GMT+07:00",'+
                            '"address": "'+values.get('number')+'",'+
                            '"notes": "'+values.get('note')+'",'+
                            '"callbackType": "'+values.get('mode')+'",'+
                            '"agentID": "6600010",'+
                            '"handlerState": "initial",'+
                            '"actionName": "Call_100"'+
                    '}');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        
        System.debug(response.getBody());
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug(result_map.get('callbackID'));

            List<Task> cbTask = [SELECT Id, Call_Log_ID__c 
                                    FROM Task
                                    WHERE Id = :values.get('task_id')+'' 
                                    AND RecordType.Name = 'Call Back' 
                                    LIMIT 1];

            cbTask.get(0).Call_Log_ID__c = result_map.get('callbackID')+'';

            update cbTask;

        }
        else {
            result_map.put('error', response.getStatusCode());
            System.debug(result_map);
            List<Task> searchTask = [SELECT Id, Call_Log_ID__c
                                     FROM Task
                                    WHERE Id = :values.get('task_id')+''
                                    AND RecordType.Name = 'Call Back'
                                    LIMIT 1];

            // if(searchTask.size() > 0){
            //     searchTask.get(0).Call_Log_ID__c = '00000';
            //     update searchTask;
            // }
        }

        return result_map;

    }

    @future(callout=true)
    public static void cancelCallbackAsync(String calllog_id){

        // terminateCallback(calllog_id);
        // deleteCallback(calllog_id);

    }
    @future(callout=true)
    public static void scheduleCallbackAsync(String jsonString){

        Map<String, Object> values = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        // scheduleCallback(values);

    }*/

    @AuraEnabled
    public static void rescheduleCallback(Map<String, Object> values,String businessName){

        System.debug(values);

        try{
            List<Task> searchTask = [SELECT Id, Status, Call_Log_ID__c, Marketing_Code__c FROM Task WHERE Id = :values.get('task_id')+'' LIMIT 1];
            if(searchTask.size() > 0){
    
                // String calllog_id = searchTask.get(0).Call_Log_ID__c;
                // String newTaskId = insertTask(values.get('recordId')+'', values, searchTask.get(0).Marketing_Code__c);
    
                // values.put('task_id', newTaskId);
    
                // String jsonString = JSON.serialize(values);
    
                // cancelCallbackAsync(calllog_id);
                // scheduleCallbackAsync(jsonString);
    
                // searchTask.get(0).Status = 'Cancelled';
    
                Boolean checkBusinessHours = checkBusinessHours(values,businessName);
                // recordId = '00v1s000000iBkqAAE';
                if(checkBusinessHours)
                {
                    DateTime dt = DateTime.newInstance(long.valueOf(values.get('datetime')+''));
                    System.debug('DateTime:'+dt);
                    System.debug('Number:'+values.get('number'));
                    System.debug('Note:'+values.get('note'));
                    System.debug('Mode:'+values.get('mode'));
                    String remark = '';
                    if(values.get('note') != null)
                    {
                        remark = String.valueOf(values.get('note'));
                    }
    
                    List<User> currentUser = [SELECT Id, Employee_Id__c FROM User WHERE Id = :UserInfo.getUserId()];
    
                    Task updateTask = new Task(Id = searchTask.get(0).Id);
                    updateTask.IsReminderSet = true;
                    updateTask.ReminderDateTime = dt.addMinutes(-15);
                    updateTask.Call_Number__c = values.get('number')+'';
                    updateTask.Description = remark;
                    updateTask.Call_Back_Mode__c = values.get('mode')+'';
                    updateTask.Call_Start_Datetime__c = dt;
                    updateTask.ActivityDate = dt.date();
    
                    update updateTask;
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Error:'+e);
            throw new AuraHandledException(Label.CallBack_BusinessHours_ErrorMsg);
        }
       
    }

    /*@AuraEnabled
    public static Map<String, Map<String, Object>> terminateCallback(String callback_id){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Telephony_Avaya_Terminate_Callback');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-Requested-With', 'rest');
        request.setBody('{"callbackIdList":[20048,20052]}');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        
        System.debug(response);
        
        Map<String, Object> result_map = new Map<String, Object>();
        Map<String, Map<String, Object>> return_map = new Map<String, Map<String, Object>>();

        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug(result_map);
            
            for(String key : result_map.keySet()){
                
                return_map.put(key, (Map<String, Object>)result_map.get(key));
            }
            
            System.debug(return_map);
            
        }
        else{
            return_map.put('error', new Map<String, Object>{'error_code' => response.getStatusCode()});
        }

        return return_map;

    }

    @AuraEnabled
    public static Map<String, Map<String, Object>> deleteCallback(String callback_id){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Telephony_Avaya_Delete_Callback');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-Requested-With', 'rest');
        request.setBody('{"callbackIdList":[20048,20052]}');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        
        System.debug(response);

        Map<String, Object> result_map = new Map<String, Object>();
        Map<String, Map<String, Object>> return_map = new Map<String, Map<String, Object>>();
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            result_map = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug(result_map);
            
            for(String key : result_map.keySet()){
                
                return_map.put(key, (Map<String, Object>)result_map.get(key));
            }
            
            System.debug(return_map);
            
        }
        else{
            return_map.put('error', new Map<String, Object>{'error_code' => response.getStatusCode()});
        }

        return return_map;

    }*/

    @AuraEnabled
    public static Task searchExistingCallback(String recordId){

        Task returnTask = new Task();
        List<Task> searchTask = [SELECT Id, Call_Start_Datetime__c, Call_Number__c, Call_Back_Mode__c, Call_Log_ID__c, Description
                                    FROM Task 
                                    WHERE Related_Object__c = :recordId
                                    AND RecordType.Name = 'Call Back'
                                    AND Status != 'Completed' AND Status != 'Cancelled'
                                    ORDER BY CreatedDate DESC];

        if(searchTask.size() > 0){
            returnTask = searchTask.get(0);
        }
        
        return returnTask;
    }

}