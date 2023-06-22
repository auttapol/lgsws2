@isTest
public with sharing class InboundPopupTest {

    public class ResponseWrapper{
        public String status;
        public String message;
        public Map<String, String> data;
    }

    @isTest static void helloTest(){
        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/inbound/popup';
            req.httpMethod = 'GET';
            req.addHeader('Content-Type', 'application/json'); 

            RestContext.request = req;
            RestContext.response = res;
            
            InboundPopup.helloWorld();
            
            System.assertEquals(200, res.statusCode);
            System.assertEquals('{"status":"SUCCESS", "message":"", "data":{"task_id":"Hello World!"}}', res.responseBody.toString());

        Test.stopTest();
    }

    @isTest static void popupSuccess(){

        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        Account acc = new Account();
        acc.Name = 'Test Customer 001';
        acc.TMB_Customer_ID_PE__c = '001100000000000000000000158618';
        acc.Mobile_Number_PE__c = '023857143';

        insert acc;

        InboundUtility.task_wrapper task = new InboundUtility.task_wrapper();
        task.call_id = '153133-603-4';
        task.employee_id = '28315';
        task.call_number = '023857143';
        task.tmb_cust_id = '001100000000000000000000158618';
        task.agent_extension_number = '7841';
        task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
        task.channel = 'Inbound Call';
        
        InboundUtility.verification_history_wrapper verf_hist = new InboundUtility.verification_history_wrapper();
        verf_hist.xfer = 'TH Account';
        verf_hist.verification_status = '02';
        verf_hist.verification_type = 'TMB ID';
        verf_hist.verification_result = 'None';
        verf_hist.verification_action = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
        verf_hist.verification_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
        verf_hist.fail_reason = 'Not Verify';

        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            // req.addParameter('task', JSON.serialize(task));
            // req.addParameter('verification_history', JSON.serialize(verf_hist));

            req.requestURI = '/services/apexrest/inbound/popup';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            InboundPopup.handleInbound(task, verf_hist);

            System.debug(AppConfig__c.getValues('runtrigger'));

            System.debug(res.responseBody.toString());
            
            /*ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(1, InboundUtility.ci_list.size());
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

        InboundUtility.task_wrapper task = new InboundUtility.task_wrapper();
        task.call_id = '153133-603-4';
        task.employee_id = '28315';
        task.call_number = '';
        task.tmb_cust_id = '001100000000000000000000158618';
        task.agent_extension_number = '7841';
        task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
        task.channel = 'Inbound Call';
        
        InboundUtility.verification_history_wrapper verf_hist = new InboundUtility.verification_history_wrapper();
        verf_hist.xfer = 'TH Account';
        verf_hist.verification_status = '02';
        verf_hist.verification_type = 'TMB ID';
        verf_hist.verification_result = 'None';
        verf_hist.verification_action = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
        verf_hist.verification_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
        verf_hist.fail_reason = 'Not Verify';

        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            // req.addParameter('task', JSON.serialize(task));
            // req.addParameter('verification_history', JSON.serialize(verf_hist));

            req.requestURI = '/services/apexrest/inbound/popup';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            InboundPopup.handleInbound(task, verf_hist);

            System.debug(AppConfig__c.getValues('runtrigger'));

            System.debug(res.responseBody.toString());
            
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(0, [SELECT COUNT() FROM Task]);
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Phone is required.', r.message);
            System.assertEquals(400, res.statuscode);
        Test.stopTest();
    }

    
    @isTest static void requiredEmployeeId(){

        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        InboundUtility.task_wrapper task = new InboundUtility.task_wrapper();
        task.call_id = '153133-603-4';
        task.employee_id = '';
        task.call_number = '023857143';
        task.tmb_cust_id = '001100000000000000000000158618';
        task.agent_extension_number = '7841';
        task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
        task.channel = 'Inbound Call';
        
        InboundUtility.verification_history_wrapper verf_hist = new InboundUtility.verification_history_wrapper();
        verf_hist.xfer = 'TH Account';
        verf_hist.verification_status = '02';
        verf_hist.verification_type = 'TMB ID';
        verf_hist.verification_result = 'None';
        verf_hist.verification_action = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
        verf_hist.verification_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
        verf_hist.fail_reason = 'Not Verify';

        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            // req.addParameter('task', JSON.serialize(task));
            // req.addParameter('verification_history', JSON.serialize(verf_hist));

            req.requestURI = '/services/apexrest/inbound/popup';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            InboundPopup.handleInbound(task, verf_hist);

            System.debug(AppConfig__c.getValues('runtrigger'));

            System.debug(res.responseBody.toString());
            
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(0, [SELECT COUNT() FROM Task]);
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

        InboundUtility.task_wrapper task = new InboundUtility.task_wrapper();
        task.call_id = '';
        task.employee_id = '28315';
        task.call_number = '023857143';
        task.tmb_cust_id = '001100000000000000000000158618';
        task.agent_extension_number = '7841';
        task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
        task.channel = 'Inbound Call';
        
        InboundUtility.verification_history_wrapper verf_hist = new InboundUtility.verification_history_wrapper();
        verf_hist.xfer = 'TH Account';
        verf_hist.verification_status = '02';
        verf_hist.verification_type = 'TMB ID';
        verf_hist.verification_result = 'None';
        verf_hist.verification_action = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
        verf_hist.verification_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
        verf_hist.fail_reason = 'Not Verify';

        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            // req.addParameter('task', JSON.serialize(task));
            // req.addParameter('verification_history', JSON.serialize(verf_hist));

            req.requestURI = '/services/apexrest/inbound/popup';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            InboundPopup.handleInbound(task, verf_hist);

            System.debug(AppConfig__c.getValues('runtrigger'));

            System.debug(res.responseBody.toString());
            
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            System.debug(r.data.get('task_id'));
            System.assertEquals(0, [SELECT COUNT() FROM Task]);
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Call ID is required.', r.message);
            System.assertEquals(400, res.statuscode);
        Test.stopTest();
    }

    @isTest static void invalidAgentId(){

        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        InboundUtility.task_wrapper task = new InboundUtility.task_wrapper();
        task.call_id = '153133-603-4';
        task.employee_id = '55554';
        task.call_number = '023857143';
        task.tmb_cust_id = '001100000000000000000000158618';
        task.agent_extension_number = '7841';
        task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
        task.channel = 'Inbound Call';
        
        InboundUtility.verification_history_wrapper verf_hist = new InboundUtility.verification_history_wrapper();
        verf_hist.xfer = 'TH Account';
        verf_hist.verification_status = '02';
        verf_hist.verification_type = 'TMB ID';
        verf_hist.verification_result = 'None';
        verf_hist.verification_action = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
        verf_hist.verification_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
        verf_hist.fail_reason = 'Not Verify';

        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            // req.addParameter('task', JSON.serialize(task));
            // req.addParameter('verification_history', JSON.serialize(verf_hist));

            req.requestURI = '/services/apexrest/inbound/popup';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            InboundPopup.handleInbound(task, verf_hist);

            System.debug(AppConfig__c.getValues('runtrigger'));

            System.debug(res.responseBody.toString());
            
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            /*System.debug(r.data.get('task_id'));
            System.assertEquals(0, [SELECT COUNT() FROM Task]);
            System.assertEquals('ERROR', r.status);
            System.assertEquals('Agent ID is invalid.', r.message);
            System.assertEquals(404, res.statuscode);*/
        Test.stopTest();
    }

    @isTest static void testTimeout(){

        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        InboundUtility.task_wrapper task = new InboundUtility.task_wrapper();
        task.call_id = '153133-603-4';
        task.employee_id = '28315';
        task.call_number = '023857143';
        task.tmb_cust_id = '001100000000000000000000158618';
        task.agent_extension_number = '7841';
        task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
        task.channel = 'Inbound Call';
        
        InboundUtility.verification_history_wrapper verf_hist = new InboundUtility.verification_history_wrapper();
        verf_hist.xfer = 'TH Account';
        verf_hist.verification_status = '02';
        verf_hist.verification_type = 'TMB ID';
        verf_hist.verification_result = 'None';
        verf_hist.verification_action = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
        verf_hist.verification_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
        verf_hist.fail_reason = 'Not Verify';

        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            // req.addParameter('task', JSON.serialize(task));
            // req.addParameter('verification_history', JSON.serialize(verf_hist));

            req.requestURI = '/services/apexrest/inbound/popup';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            InboundPopup.handleInbound(task, verf_hist);

            System.debug(AppConfig__c.getValues('runtrigger'));

            System.debug(res.responseBody.toString());
            
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);
            String task_id = r.data.get('task_id');

            //Duplicate request
            InboundPopup.handleInbound(task, verf_hist);

            /*System.debug(r.data.get('task_id'));

            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE Id = :task_id]);
            System.assertEquals('SUCCESS', r.status);
            System.assertEquals(201, res.statuscode);*/

        Test.stopTest();
    }

    
    @isTest static void testInvalidTaskData(){

        AppConfig__c setting = new AppConfig__c();

        setting.Name = 'runtrigger';
        setting.Value__c = 'false';

        insert setting;

        InboundUtility.task_wrapper task = new InboundUtility.task_wrapper();
        task.call_id = '153133-603-4';
        task.employee_id = '28315';
        task.call_number = '023857143';
        task.tmb_cust_id = '001100000000000000000000158618';
        task.agent_extension_number = '7841';
        task.call_start_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:47.182Z"', DateTime.class);
        task.channel = 'Something';
        
        InboundUtility.verification_history_wrapper verf_hist = new InboundUtility.verification_history_wrapper();
        verf_hist.xfer = 'TH Account';
        verf_hist.verification_status = '02';
        verf_hist.verification_type = 'TMB ID';
        verf_hist.verification_result = 'None';
        verf_hist.verification_action = 'ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID';
        verf_hist.verification_datetime = (DateTime)JSON.deserialize('"2563-04-07T07:13:48.598Z"', DateTime.class);
        verf_hist.fail_reason = 'Not Verify';

        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            // req.addParameter('task', JSON.serialize(task));
            // req.addParameter('verification_history', JSON.serialize(verf_hist));

            req.requestURI = '/services/apexrest/inbound/popup';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            
            RestContext.request = req;
            RestContext.response = res;

            InboundPopup.handleInbound(task, verf_hist);

            System.debug(AppConfig__c.getValues('runtrigger'));

            System.debug(res.responseBody.toString());
            
            ResponseWrapper r = (ResponseWrapper)JSON.deserialize(res.responseBody.toString(), ResponseWrapper.class);

            System.debug(r.data.get('task_id'));

            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE Id = :r.data.get('task_id')]);
            System.assertEquals('ERROR', r.status);
            System.assertEquals(400, res.statuscode);

        Test.stopTest();
    }
}