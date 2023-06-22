@isTest
public class UploadTaskControllerTest {

    Static String fileData = 'RecordTypeId,Subject,Main_Task__c,Sub_Task__c,RTL_Task_Subject__c,RTL_Channel__c,Type,Status,Priority,ActivityDate,ReminderDate__c,WhatId,OwnerId,Description,LogACall_External_Id_crmdb__c \n'
                            +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000000682311,02045,Operating Model,380196_2020-06_30_xxx1 \n'
                            +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000000682311,00001,Operating Model,380196_2020-06_30_xxx2 \n'
                            +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000007296135,02476,Operating Model,380196_2020-06_30_xxx3 \n';
    
    
    Static String fileDataError = 'RecordTypeId,Subject,,Sub_Task__c,RTL_Task_Subject__c,RTL_Channel__c,Type,Status,Priority,ActivityDate,ReminderDate__c,WhatId,OwnerId,Description,LogACall_External_Id_crmdb__c \n'
                            +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000000682311,02045,Operating Model,380196_2020-06_30_xxx1\n'
                            +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000000682311,00001,Operating Model,380196_2020-06_30_xxx2\n'
                            +'Retail Task,,,,Portfolio Review,Wealth Management,Visit,Not Started,High,2020-05-28,2020-05-05,001100000000000000000007296135,02476,Operating Model,380196_2020-06_30_xxx3\n';
    
    Static String fileDelete = 'LogACall_External_Id_crmdb__c \n380196_2020-06_30_xxx1\n380196_2020-06_30_xxx2\n380196_2020-06_30_xxx3';
    
    public static String[] csvFileLines;
    public static Blob csvFileBody;

    public static testmethod void testUploadTask(){        
        Test.startTest();
        TestUtils.createAppConfig();
        csvFileBody = Blob.valueOf(fileData);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        List<String> returnfile = UploadTaskController.generateCSVArray(csvFileLines,'Upsert', 'Test load file.csv');
        list<Load_Task_Log__c> logResult = UploadTaskController.getLogFiles();

        Test.stopTest();
    }

    public static testmethod void testUploadTaskError(){        
        Test.startTest();
        TestUtils.createAppConfig();
        csvFileBody = Blob.valueOf(fileDataError);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        List<String> returnfile = UploadTaskController.generateCSVArray(csvFileLines,'Upsert', 'Test load file.csv');

        Test.stopTest();
    }

    public static testmethod void testDeleteTask(){        
        Test.startTest();
        TestUtils.createAppConfig();
        csvFileBody = Blob.valueOf(fileDelete);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        List<String> returnfile = UploadTaskController.generateCSVArray(csvFileLines,'Delete', 'Test load file.csv');        

        Test.stopTest();
    }
    
}