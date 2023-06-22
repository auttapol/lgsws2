global with sharing class InboundUtility {

    //Currently used for testing purpose only : store event to this list when successfully publish event
    @testVisible private static List<Customer_Inbound__e> ci_list = new List<Customer_Inbound__e>();
    @testVisible private static List<Customer_Transfer__e> ct_list = new List<Customer_Transfer__e>();

    public static final Integer HTTP_OK = 200;
    public static final Integer HTTP_CREATED = 201;
    public static final Integer HTTP_BAD_REQUEST = 400;
    public static final Integer HTTP_NOT_FOUND = 404;

    global class task_wrapper{
        global String task_id {get;set;}
        global String call_id {get;set;}
        global String employee_id {get;set;}
        global String call_number {get;set;}
        global String tmb_cust_id {get;set;}
        global String agent_extension_number {get;set;}
        global DateTime call_start_datetime {get;set;}
        global DateTime call_end_datetime {get;set;}
        global String channel {get;set;}
        global String marketing_code {get;set;}
    }
    global class verification_history_wrapper{
        global String id {get;set;}
        global String xfer {get;set;}
        global String customer_type {get;set;}
        global String verification_status {get;set;}
        global String verification_type {get;set;}
        global String verification_result {get;set;}
        global String verification_action {get;set;}
        global DateTime verification_datetime {get;set;}
        global String fail_reason {get;set;}
    }

    public static String publishCustomerInbound(task_wrapper task, verification_history_wrapper verf_hist){
        
        //Start Trigger Platform Events
        System.debug(task.task_id);
        Popup_Information__c popupInfo = new Popup_Information__c(
            Task_ID__c = task.task_id,
            Call_ID__c = task.call_id,
            Employee_ID__c = task.employee_id,
            Call_Number__c = task.call_number,
            TMB_Cust_ID__c = task.tmb_cust_id,
            Agent_Extension_Number__c = task.agent_extension_number,
            Call_Start__c = task.call_start_datetime,
            Type__c = task.channel,
            Xfer__c = verf_hist.xfer,
            Verification_Status__c = verf_hist.verification_status,
            Verification_Type__c = verf_hist.verification_type,
            Verification_Result__c = verf_hist.verification_result,
            Verification_Action__c = verf_hist.verification_action,
            Verification_Date__c = verf_hist.verification_datetime,
            Fail_Reason__c = verf_hist.fail_reason,
            Customer_Type__c = verf_hist.customer_type,
            Channel__c = 'Popup'
        );

        Database.SaveResult results = database.insert(popupInfo);
        
        if(results.isSuccess()){
            System.debug('Successfully published event.');
            if(Test.isRunningTest()){
               // ci_list.add(popupInfo);
            }
            //Stop Trigger Platform Events : Success
            return results.id;
        }
        else{
            System.debug('Error returned: ' +
                        results.getErrors()[0].getStatusCode() +
                        ' - ' +
                        results.getErrors()[0].getMessage());

            //Stop Trigger Platform Events : Error
            return 'Error '+results.getErrors()[0].getStatusCode() +
            ' - ' +
            results.getErrors()[0].getMessage();
        }

        // Customer_Inbound__e c = new Customer_Inbound__e(
        //     Task_ID__c = task.task_id,
        //     Call_ID__c = task.call_id,
        //     Employee_ID__c = task.employee_id,
        //     Call_Number__c = task.call_number,
        //     TMB_Cust_ID__c = task.tmb_cust_id,
        //     Agent_Extension_Number__c = task.agent_extension_number,
        //     Call_Start__c = task.call_start_datetime,
        //     Type__c = task.channel,
        //     Xfer__c = verf_hist.xfer,
        //     Verification_Status__c = verf_hist.verification_status,
        //     Verification_Type__c = verf_hist.verification_type,
        //     Verification_Result__c = verf_hist.verification_result,
        //     Verification_Action__c = verf_hist.verification_action,
        //     Verification_Date__c = verf_hist.verification_datetime,
        //     Fail_Reason__c = verf_hist.fail_reason,
        //     Customer_Type__c = verf_hist.customer_type
        // );

        // Database.SaveResult results = EventBus.publish(c);
        
        // if(results.isSuccess()){
        //     System.debug('Successfully published event.');
        //     if(Test.isRunningTest()){
        //         ci_list.add(c);
        //     }
        //     //Stop Trigger Platform Events : Success
        //     return EventBus.getOperationId(results);
        // }
        // else{
        //     System.debug('Error returned: ' +
        //                 results.getErrors()[0].getStatusCode() +
        //                 ' - ' +
        //                 results.getErrors()[0].getMessage());

        //     //Stop Trigger Platform Events : Error
        //     return 'Error '+results.getErrors()[0].getStatusCode() +
        //     ' - ' +
        //     results.getErrors()[0].getMessage();
        // }

    }
    //Platform event permission
    // public static String publishCustomerTransfer(String new_task_id, String task_id, String agent_id, String verf_hist_id, String call_number){
    public static String publishCustomerTransfer(String new_task_id, task_wrapper task, String verf_hist_id){
        
        //Start Trigger Platform Events
        System.debug(verf_hist_id);
        Popup_Information__c popupInfo = new Popup_Information__c(
            New_Task_ID__c = new_task_id,
            Task_ID__c = task.task_id,
            Employee_ID__c = task.employee_id,
            Verification_History_ID__c = verf_hist_id,
            Call_ID__c = task.call_id,
            Call_Number__c = task.call_number,
            Call_Start__c = task.call_start_datetime,
            Type__c = task.channel,
            Channel__c = 'Transfer'
        );

        Database.SaveResult results = database.insert(popupInfo);
        
        if(results.isSuccess()){
            System.debug('Successfully published event.');
            if(Test.isRunningTest()){
                //ci_list.add(popupInfo);
            }
            //Stop Trigger Platform Events : Success
            return results.id;
        }
        else{
            System.debug('Error returned: ' +
                        results.getErrors()[0].getStatusCode() +
                        ' - ' +
                        results.getErrors()[0].getMessage());

            //Stop Trigger Platform Events : Error
            return 'Error '+results.getErrors()[0].getStatusCode() +
            ' - ' +
            results.getErrors()[0].getMessage();
        }
        
        // Customer_Transfer__e ct = new Customer_Transfer__e(
        //     New_Task_ID__c = new_task_id,
        //     Task_ID__c = task_id,
        //     Target_Agent_ID__c = agent_id,
        //     Verification_History_ID__c = verf_hist_id,
        //     Call_Number__c = call_number
        // );
        
        // Database.SaveResult results = EventBus.publish(ct);
        
        // if(results.isSuccess()){
        //     //Stop Trigger Platform Events : id
        //     if(Test.isRunningTest()){
        //         ct_list.add(ct);
        //     }
        //     System.debug('Successfully published event.');
        //     System.debug(EventBus.getOperationId(results));
        //     return EventBus.getOperationId(results);
        // }
        // else{
        //     //Stop Trigger Platform Events : Error message
        //     System.debug('Error returned: ' +
        //                 results.getErrors()[0].getStatusCode() +
        //                 ' - ' +
        //                 results.getErrors()[0].getMessage());
        //     return 'Error '+results.getErrors()[0].getStatusCode() +
        //     ' - ' +
        //     results.getErrors()[0].getMessage();
        // }
    }

    public static String insertTask(task_wrapper task, String ownerId){
        //Start Create Log a call    
        try{                            
            Task newTask = new Task();

            newTask.Call_Log_ID__c = task.call_id;
            newTask.Call_Agent_Id__c = task.employee_id;
            newTask.Call_Number__c = task.call_number;
            newTask.RTL_TMB_Customer_ID_PE__c = task.tmb_cust_id;
            //newTask.Call_Start_Datetime__c = standardizedTimezone(task.call_start_datetime);
            newTask.Call_Start_Datetime__c = task.call_start_datetime;
            // newTask.Call_Start_Datetime__c = DateTime.now();
            // newTask.CallType = task.type;
            newTask.RTL_Channel__c = task.channel;
            newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
            newTask.TaskSubtype = 'Call';
            newTask.Type = 'Call';
            newTask.Subject = 'Call';
            newTask.OwnerId = ownerId;
            newTask.Agent_Extension_Number__c = task.agent_extension_number;
            newTask.Status = 'In Progress';

            insert newTask;

            //Stop Create Log a call    
            //Success

            //Error : log exception

            // Map<String, String> result = new Map<String, String>();
            // result.put('task_id', newTask.Id);
            return newTask.Id;
        }
        catch(System.DmlException e){
            return 'Error ' + e.getDmlMessage(0);
        }
    }

    public static String restRespond(Integer status_code, String message, String data){

        Map<String, String> result = new Map<String, String>();
        String status = '';

        if(status_code == HTTP_OK || status_code == HTTP_CREATED){
            status = 'SUCCESS';
            if(data != '' && data.length() > 0){
                result.put('task_id', data);
            }
        }
        else if(status_code == HTTP_BAD_REQUEST || status_code == HTTP_NOT_FOUND){
            status = 'ERROR';
            if(data != '' && data.length() > 0){
                result.put('error_meesage', data);
            }
        }


        String reponseString = '{"status":"'+status+'", "message":"'+message+'", "data":'+JSON.serialize(result)+'}';

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = status_code;
        RestContext.response.responseBody = Blob.valueOf(reponseString);

        return reponseString;
    }

    public static DateTime standardizedTimezone(DateTime dt){
        TimeZone tz = UserInfo.getTimeZone();
        System.debug(tz.getDisplayName());
        Integer timezoneOffset = (tz.getOffset(dt)/3600000)*(-1);
        System.debug(timezoneOffset);

        DateTime gmtZeroDt = dt.addHours(timezoneOffset);
        System.debug(gmtZeroDt);

        return gmtZeroDt;
    }
}