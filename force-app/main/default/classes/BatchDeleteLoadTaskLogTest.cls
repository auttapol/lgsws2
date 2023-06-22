@isTest
public class BatchDeleteLoadTaskLogTest {
    public static testmethod void testRunBatch(){  
        
    Test.startTest();

    List<AppConfig__c> apps = new  List<AppConfig__c>();
    AppConfig__c Aconfig1 = new AppConfig__c();
    Aconfig1.Name = 'runtrigger';
    Aconfig1.Value__c = 'True';        
    apps.add(Aconfig1);
    
    AppConfig__c Aconfig2 = new AppConfig__c();
    Aconfig2.Name = 'CRM Admin';
    Aconfig2.Value__c = 'test1@tmbbank.com.uat;test2@tmbbank.com.uat';        
    apps.add(Aconfig2);

    insert apps;

    List<Load_Task_Log__c> resultLogList = New List<Load_Task_Log__c>();
    Load_Task_Log__c resultLog1 = New Load_Task_Log__c();
    resultLog1.name = 'File name test1.csv';
    resultLog1.Total_Record__c = 20;
    resultLog1.Success_Record__c = 20;
    resultLog1.Failed_Record__c = 0;
    resultLog1.Load_Type__c = 'Upload Task';
    resultLogList.add(resultLog1);

    Load_Task_Log__c resultLog2 = New Load_Task_Log__c();
    resultLog2.name = 'File name test2.csv';
    resultLog2.Total_Record__c = 20;
    resultLog2.Success_Record__c = 20;
    resultLog2.Failed_Record__c = 0;
    resultLog2.Load_Type__c = 'Upload Task';
    resultLogList.add(resultLog2);

    insert resultLogList;


    String fileData = 'RecordTypeId,Subject,Main_Task__c,Sub_Task__c,RTL_Task_Subject__c,RTL_Channel__c,Type,Status,Priority,ActivityDate,ReminderDate__c,WhatId,OwnerId,Description,LogACall_External_Id_crmdb__c \n'
    +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000000682311,02045,Operating Model,380196_2020-06_30_xxx1 \n'
    +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000000682311,00001,Operating Model,380196_2020-06_30_xxx2 \n'
    +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000007296135,02476,Operating Model,380196_2020-06_30_xxx3 \n';

    String fileName = 'Test fiel.csv';
    ContentVersion ContVerFile = new ContentVersion();
    ContVerFile.VersionData = Blob.valueOf(fileData);
    ContVerFile.Title = fileName; 
    ContVerFile.ContentLocation= 's';
    ContVerFile.PathOnClient= fileName+'.csv';
    insert ContVerFile;

    List<ContentVersion> conver = [select id, ContentDocumentId from ContentVersion where id =: ContVerFile.id];

    ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
    contentDocumentLink.ContentDocumentId = conver[0].ContentDocumentId;
    contentDocumentLink.LinkedEntityId = resultLogList[0].id;
    contentDocumentLink.ShareType = 'V'; // Inferred permission
    contentDocumentLink.Visibility = 'InternalUsers';
    insert contentDocumentLink;        

    String hour = String.valueOf(Datetime.now().hour());
    String min = String.valueOf(Datetime.now().addMinutes(10).minute()); 
    String ss = String.valueOf(Datetime.now().second());

    String min1 = String.valueOf(Datetime.now().addMinutes(15).minute());
    String min2 = String.valueOf(Datetime.now().addMinutes(20).minute());  
    String nextFireTime1 = ss + ' ' + min1 + ' ' + hour + ' * * ?';
    String nextFireTime2 = ss + ' ' + min2 + ' ' + hour + ' * * ?';
    BatchDeleteLoadTaskLog batch1 = new BatchDeleteLoadTaskLog(); 
    System.schedule('Job Started At ' + nextFireTime1, nextFireTime2, batch1);
    batch1.execute(null, resultLogList);

    Test.stopTest();
    }
}