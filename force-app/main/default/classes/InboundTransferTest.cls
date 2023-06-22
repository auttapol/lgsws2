@isTest
public with sharing class InboundTransferTest {

    public class ResponseWrapper{
        public String status;
        public String message;
        public Map<String, String> data;
    }
    
    @isTest static void helloTest(){
        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'GET';
            req.addHeader('Content-Type', 'application/json'); 

            RestContext.request = req;
            RestContext.response = res;
            
            InboundTransfer.helloWorld();
            
            System.assertEquals(200, res.statusCode);
            System.assertEquals('{"status":"SUCCESS", "message":"", "data":{"task_id":"Use POST Instead!"}}', res.responseBody.toString());

        Test.stopTest();
    }

    @isTest static void transferSuccess(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Account a = new Account();
        a.Name = 'Test Test';
        a.TMB_Customer_ID_PE__c = '001100000000000000000000158618';
        a.Mobile_Number_PE__c = '023857143';

        insert a;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            t.WhatId = a.Id;
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            
            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = t.Id;
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '33150';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Inbound Call';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);

            System.debug(res.responseBody.toString());
            /*ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(1, InboundUtility.ct_list.size());
            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE Id = :r.data.get('task_id')]);
            System.assertEquals('SUCCESS', r.status);
            System.assertEquals(201, res.statuscode);*/
        Test.stopTest();
    }
    @isTest static void requiredPhone(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            
            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = t.Id;
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '33150';
            transfer_task.call_number = '';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Inbound Call';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);

            System.debug(res.responseBody.toString());
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(1, [SELECT COUNT() FROM Task]);
            System.assertEquals(0, InboundUtility.ct_list.size());
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Call Number is required.', r.message);
            System.assertEquals(400, res.statuscode);
        Test.stopTest();
    }
    @isTest static void requiredEmployeeId(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            
            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = t.Id;
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Inbound Call';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);

            System.debug(res.responseBody.toString());
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(1, [SELECT COUNT() FROM Task]);
            System.assertEquals(0, InboundUtility.ct_list.size());
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Employee ID is required.', r.message);
            System.assertEquals(400, res.statuscode);
        Test.stopTest();
    }
    @isTest static void requiredCallId(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            
            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = t.Id;
            transfer_task.call_id = '';
            transfer_task.employee_id = '33150';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Inbound Call';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);

            System.debug(res.responseBody.toString());
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(1, [SELECT COUNT() FROM Task]);
            System.assertEquals(0, InboundUtility.ct_list.size());
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Call ID is required.', r.message);
            System.assertEquals(400, res.statuscode);
        Test.stopTest();
    }
    @isTest static void invalidTaskId(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            
            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = 'hello';
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '33150';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Inbound Call';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);

            System.debug(res.responseBody.toString());
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(1, [SELECT COUNT() FROM Task]);
            System.assertEquals(0, InboundUtility.ct_list.size());
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Task ID is invalid.', r.message);
            System.assertEquals(404, res.statuscode);
        Test.stopTest();
    }
    @isTest static void invalidAgentId(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            
            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = t.Id;
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '55554';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Inbound Call';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);

            System.debug(res.responseBody.toString());
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            /*System.assertEquals(1, [SELECT COUNT() FROM Task]);
            System.assertEquals(0, InboundUtility.ct_list.size());
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Agent ID is invalid.', r.message);
            System.assertEquals(404, res.statuscode);*/
        Test.stopTest();
    }
    @isTest static void invalidTaskData(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            
            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = t.Id;
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '33150';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Something';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);
            System.debug(transfer_task);
            System.debug(res.responseBody.toString());
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(1, [SELECT COUNT() FROM Task]);
            System.assertEquals(0, InboundUtility.ct_list.size());
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Cannot Create Task', r.message);
            System.assertEquals(400, res.statuscode);
        Test.stopTest();
    }
    @isTest static void testTimedOut(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;
        Account a = new Account();
        a.Name = 'Test Test';
        a.TMB_Customer_ID_PE__c = '001100000000000000000000158618';
        a.Mobile_Number_PE__c = '023857143';

        insert a;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            t.WhatId = a.Id;
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = t.Id;
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '33150';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Inbound Call';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);

            String task_id = r.data.get('task_id');

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);
            System.debug(transfer_task);
            System.debug(res.responseBody.toString());
            /*r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(2, [SELECT COUNT() FROM Task]);
            System.assertEquals(2, InboundUtility.ct_list.size());
            System.assertEquals('SUCCESS', r.status);
            System.assertEquals(task_id, r.data.get('task_id'));
            System.assertEquals(200, res.statuscode);*/
        Test.stopTest();
    }

    
    @isTest static void testTimedOutInvalidTask(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Test.startTest();
            Task t = new Task();
            t.Call_Log_ID__c = '153133-603-4';
            t.Call_Agent_Id__c = '28315';
            t.Call_Number__c = '023857143';
            t.RTL_TMB_Customer_ID_PE__c = '001100000000000000000000158618';
            // t.agent_extension_number = '7841';
            t.Call_Start_Datetime__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            t.CallType = 'Inbound';
            
            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert t;
            insert verf_hist;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = t.Id;
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '33150';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Inbound Call';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);

            String task_id = r.data.get('task_id');

            
            InboundUtility.task_wrapper transfer_task2 = new InboundUtility.task_wrapper();
            transfer_task2.task_id = '00T1s000001oFb0EAE';
            transfer_task2.call_id = '153133-603-4';
            transfer_task2.employee_id = '33150';
            transfer_task2.call_number = '023857143';
            transfer_task2.tmb_cust_id = '001100000000000000000000158618';
            transfer_task2.agent_extension_number = '7841';
            transfer_task2.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task2.channel = 'Inbound Call';

            InboundTransfer.handleTransfer(transfer_task2,transfer_verhist);
            System.debug(transfer_task);
            System.debug(res.responseBody.toString());
            /*r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(2, [SELECT COUNT() FROM Task]);
            System.assertEquals(1, InboundUtility.ct_list.size());
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Task ID is invalid.', r.message);
            System.assertEquals(404, res.statuscode);*/
        Test.stopTest();
    }

    @isTest static void requiredTaskId(){
        
        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Test.startTest();
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            Verification_History__c verf_hist = new Verification_History__c();
            verf_hist.Xfer__c = 'TH Account';
            verf_hist.Verification_Status__c = '02';
            verf_hist.Verification_Type__c = 'TMB ID';
            verf_hist.Verification_Result__c = 'None';
            verf_hist.Verification_Action__c = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
            verf_hist.Verification_Date_Time__c = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
            verf_hist.Fail_Reason__c = 'Not Verify';
            verf_hist.Call_ID__c = '153133-603-4';
            verf_hist.Employee_ID__c = '28315';

            insert verf_hist;

            // req.requestURI = '/services/apexrest/inbound/popup';
            // req.httpMethod = 'POST';
            // req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            // InboundPopup.handleInbound(task, verf_hist);

            // ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            // System.debug(res.responseBody.toString());
            InboundUtility.verification_history_wrapper transfer_verhist = new InboundUtility.verification_history_wrapper();
            transfer_verhist.id = verf_hist.Id;
            transfer_verhist.xfer = verf_hist.Xfer__c;
            transfer_verhist.customer_type = 'Test';
            transfer_verhist.verification_status = verf_hist.Verification_Status__c;
            transfer_verhist.verification_type = verf_hist.Verification_Type__c;
            transfer_verhist.verification_result = verf_hist.Verification_Result__c;
            transfer_verhist.verification_action = verf_hist.Verification_Action__c;
            transfer_verhist.verification_datetime = verf_hist.Verification_Date_Time__c;
            transfer_verhist.fail_reason = verf_hist.Fail_Reason__c;

            
            InboundUtility.task_wrapper transfer_task = new InboundUtility.task_wrapper();
            transfer_task.task_id = '';
            transfer_task.call_id = '153133-603-4';
            transfer_task.employee_id = '33150';
            transfer_task.call_number = '023857143';
            transfer_task.tmb_cust_id = '001100000000000000000000158618';
            transfer_task.agent_extension_number = '7841';
            transfer_task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
            transfer_task.channel = 'Something';


            req.requestURI = '/services/apexrest/inbound/transferred';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            InboundTransfer.handleTransfer(transfer_task,transfer_verhist);
            System.debug(transfer_task);
            System.debug(res.responseBody.toString());
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(0, [SELECT COUNT() FROM Task]);
            System.assertEquals(0, InboundUtility.ct_list.size());
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Task ID is required.', r.message);
            System.assertEquals(400, res.statuscode);
        Test.stopTest();
    }
}