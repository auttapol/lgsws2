@isTest
global class MockupBatchUpdateCaseProgressSMS implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        Boolean tmpMock = true;
        // String body = '{"service_code":"OTHCRMRTCC","record":[{"sms":{"search":false,"force":true,"endpoint":"0816042672"},"rm_id":null,"params":{"Product_Category__c":"Savings&Deposits","Sub_Category__c":"ATM/ADM/PUM - TMB","Contact_Person_Name__c":"test Contact","Customer_Name__c":null,"CaseNumber":"2020040000284090","template_name":"CRMRBG_012"},"language":"th"}],"office_code":"1096"} {"result": {}, "success": true,"guid": "85e599ee-ecbc-4d9f-a984-4a64d04a32f1","message": "Complete.","status": 200}';
        String body = '{"version":"","token_type":"","status":null,"scope":"","responseBody":"","requestBody":"","jti":"","isSuccess":false,"expires_in":0,"errorMesssage":null,"errorMessage":"","client_id":"","access_token":""}';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatus('OK');
        res.setStatusCode(200);  
        return res;
    }
}