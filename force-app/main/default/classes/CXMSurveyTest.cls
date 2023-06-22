@isTest
public class CXMSurveyTest {
    
    static testMethod void runTestClass() { 
        Test.startTest();
            Service_Type_Matrix__c serviceType = New Service_Type_Matrix__c();
            serviceType.Segment__c = 'SBG';
            serviceType.Service_Level1__c = 'Service Level1';
            serviceType.Service_Level2__c = 'Service level2';
            serviceType.Service_Level3__c = 'Service level3';
            serviceType.Service_Level4__c = 'Service level4';
            serviceType.SLA__c = 7;
            serviceType.Severity__c = '1';
            serviceType.Responsible_BU__c = 'Test_Queue_SE';
            serviceType.active__c = true;
            serviceType.Service_issue_EN__c = 'english version';
            serviceType.Validate_Code__c = 'xxxx1';
            serviceType.Responsible_BU_Hop_2__c = 'RMC';
            serviceType.Responsible_BU_Hop_3__c ='test queue';
            serviceType.Closed_By_BU__c = 'REGISTER';
            serviceType.SLA_Hop_1_Day__c = 1;
            serviceType.SLA_Hop_2_Day__c = 1;
            serviceType.SLA_Hop_3_Day__c = 1;
            serviceType.SLA_Closed_By_BU_Day__c = 1;
            serviceType.Service_Template__c = 'CreditService';
            insert serviceType;

            List<CXM_Survey__c> cxmList = New List<CXM_Survey__c>();

            CXM_Survey__c cxmsurvey1 = new CXM_Survey__c();
            cxmsurvey1.Customer_ID__c = '001100000001102200000006823105';
            cxmsurvey1.Source__c = 'CRM-CCRP';
            cxmsurvey1.Survey_Score__c = 51;
            cxmsurvey1.Survey_Datetime__c = system.now();
            cxmsurvey1.ComplaintIssue__c = 'xxxx1';        
            cxmList.add(cxmsurvey1);

            CXM_Survey__c cxmsurvey2 = new CXM_Survey__c();
            cxmsurvey2.Customer_ID__c = '001100000001102200000006823105';
            cxmsurvey2.Source__c = 'Finesse';
            cxmsurvey2.Survey_Score__c = 61;
            cxmsurvey2.Survey_Datetime__c = system.now();
            cxmsurvey2.ActivityDesc__c = 'test comment';        
            cxmList.add(cxmsurvey2);

            CXM_Survey__c cxmsurvey3 = new CXM_Survey__c();
            cxmsurvey3.Customer_ID__c = '001100000001102200000006823105';
            cxmsurvey3.Source__c = 'Finesse';
            cxmsurvey3.Survey_Score__c = 81;
            cxmsurvey3.Survey_Datetime__c = system.now();
            cxmsurvey3.parentBusinessOutcome__c = 'test comment';        
            cxmList.add(cxmsurvey3);

            insert cxmList;
        Test.stopTest();

    }

}