@isTest
public without sharing class OnlineServiceLogUtils_Test {

    @isTest
    private static void Test_saveToOnlineLog() {
        TestUtils.createAppConfig();

        // List<AppConfig__c> listAconfig = new List<AppConfig__c>();
        // AppConfig__c Aconfig = new AppConfig__c();
        // Aconfig.Name = 'runtrigger';
        // Aconfig.Value__c = 'true';
        // listAconfig.add(Aconfig);
        // insert listAconfig;

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        Boolean isSuccess = true;
        String customerName  = 'test';
        String errorMessage = 'test';
        String msLogId = 'test';
        String userName = 'test';
        String rmId = 'test';
        String serviceName = 'test';
        String requestBody = 'test';
        String responseBody = 'test';
        DateTime startTime = DateTime.now();
        DateTime endTime = DateTime.now();
        String base64Data = 'test';
        OnlineServiceLogUtils.saveToOnlineLog(isSuccess, customerName, errorMessage, msLogId, userName, rmId, 
                                serviceName, requestBody, responseBody, listAccount[0], startTime, endTime, base64Data);
    }

    @isTest
    private static void Test_GenerateContentVersions() {
        String filename = 'test';
        String content = 'test';
        List<ContentVersion> cvList = new List<ContentVersion>();
        OnlineServiceLogUtils.GenerateContentVersions(filename, content, cvList);
    }

    @isTest
    private static void Test_GenerateContentDocumentLink() {
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv=new Contentversion();
            cv.title='ABC';
            cv.PathOnClient ='test';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvList.add(cv);
            insert cvList;
        List<ContentDocumentLink> allcdList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> removeCDList = new List<ContentDocumentLink>();
        Id parentId;
        OnlineServiceLogUtils.GenerateContentDocumentLink(cvList, allcdList, removeCDList, parentId);
    }

    @isTest
    private static void Test_GenerateContentDocumentLink2() {
        TestUtils.createAppConfig();
        
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        insert account;
        
		ContentVersion cv=new Contentversion();
            cv.title='ABC';
            cv.PathOnClient ='test';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug(documents);
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId =account.id;
        cdl.ContentDocumentId = documents.get(0).Id;
        cdl.shareType = 'V';
        insert cdl;
                
        Map<Id,Id> cvLogIdMap = new Map<Id,Id>();
        cvLogIdMap.put(cv.id,cdl.LinkedEntityId);
        List<ContentDocumentLink> allcdList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> removeCDList = new List<ContentDocumentLink>();
        OnlineServiceLogUtils.GenerateContentDocumentLink(cvLogIdMap, allcdList, removeCDList);
    }
}