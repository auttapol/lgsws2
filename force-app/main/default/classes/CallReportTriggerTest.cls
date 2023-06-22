@IsTest
public class CallReportTriggerTest {
    public static String STR_POSITIVE = 'positive';
    public static String STR_NEGATIVE = 'negative';
    
    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    }
    
    
    public static testmethod void RunPositiveTestReport(){
        System.debug(':::: RunPositiveTestReport Start ::::');
        //TestInit.createUser(false);
        //User u = TestInit.us;
        
           User newUser = new User(FirstName='callFirst', LastName='callLast', 
                                    UserName='callreportname@tmb.com', 
                                    Email='callreportname@tmbbank.com', Alias='visit',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='visittmb',
                                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
                                   , TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='V0001',Zone__c=
                                  '1001',Segment__c ='AA',Zone_Code__c ='1001');
           
           insert newUser;
        System.runAs(newUser) {
            // Test for T03
            
            Account acct =  TestUtils.createAccounts(1,'callreport','Individual', false).get(0);
        acct.First_Name_PE__c ='Tinnakrit';
        acct.Customer_Name_PE_Eng__c = 'Tinnakrit';
        acct.Last_name_PE__c  ='Kidmai'; 
        acct.ID_Type_PE__c = 'Passport ID';
        acct.ID_Number_PE__c = '13255555';
        insert acct;
            List <Account> acctList = new List<Account>();
            acctList.add(acct);
            TestInit.createTarget(acctList);
            
            TEST.startTest();
            flowTest(STR_POSITIVE);
            DifferentOwnerTest(STR_POSITIVE);
            TEST.stopTest();
            
        }
        System.debug(':::: RunPositiveTestReport End ::::');
    }
    
      public static testmethod void Tier0(){
        TestInit.createAccount(1);
        TestInit.createTarget(TestInit.accountList.values());
        TEST.startTest();
        TargetActualTest(STR_POSITIVE,'Silver',' ');
        TEST.stopTest();
    }    
    
    public static testmethod void Tier1(){
        TestInit.createAccount(1);
        TestInit.createTarget(TestInit.accountList.values());
        TEST.startTest();
        TargetActualTest(STR_POSITIVE,'Gold','Tier 1');
        TEST.stopTest();
    }
    
    public static testmethod void Tier2(){
        TestInit.createAccount(1);
        TestInit.createTarget(TestInit.accountList.values());
        TEST.startTest();
        TargetActualTest(STR_POSITIVE,'Platinum','Tier 2');
        TEST.stopTest();
    }
    
    public static void Tier3(){
        TestInit.createAccount(1);
        TestInit.createTarget(TestInit.accountList.values());
        TEST.startTest();
        TargetActualTest(STR_POSITIVE,'Platinum','Tier 3');
        TEST.stopTest();
    }
    
    public static testmethod void Tier4(){
       TestInit.createAccount(1);
       TestInit.createTarget(TestInit.accountList.values());
        TEST.startTest();
        TargetActualTest(STR_POSITIVE,'Platinum','Tier 4');
        TEST.stopTest();
    }
    
        public static void flowTest(String testMode){
        TestInit.createReport(TestInit.accountList.values());
        List<Target__c> listTarget = [select OwnerId,Monthly_Visit_Actual__c,Zone__c 
                                      from Target__c 
                                      where Id IN :TestInit.targetList.keySet()];
        System.debug('listTarget : '+listTarget);
        //for(Target__c t : listTarget){
        //    System.assertEquals(0,t.Monthly_Visit_Actual__c);    
        //}
        
        Map<Id,Call_Report__c> mapReport = new Map<Id,Call_Report__c>();
        List<Call_Report__c> listForDML = new List<Call_Report__c>();
        Call_Report__c createReport = new Call_Report__c();
        for(Account a : TestInit.accountList.values() ){
             createReport = new Call_Report__c(OwnerId=UserInfo.getUserId(),
                                                             Customer_name__c = a.id,
                                                             Status__c = 'Open',
                                                             Date_of_Visit__c = Date.today(),
                                                            Categories__c  = 'Sell product',
                                                Main_purpose__c = 'Sell product'
                                                            );  
            listForDML.add(createReport);
        }
        
        insert listForDML;
        mapReport.putAll(listForDML);
        
        List<Call_Report__c> listReport = [select Id from Call_Report__c where Id IN :mapReport.keySet()];
        for( Call_Report__c report : listReport ){
            report.Status__c = 'Completed';
            report.Outcome__c = 'Win oppty';
        }
        update listReport;
        //for(Target__c t : listTarget){
         //   System.assertEquals(1,t.Monthly_Visit_Actual__c);    
        //}
    }
    
        public static void TargetActualTest(String testMode,String typeTarget,String VisitClass){
        
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        if(currentYear>2557) currentYear = currentDate.year() - 543;
        
        User u = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        List<RecordType> recordTypeId = [select Id from RecordType where name = 'Activities Target' limit 1];
        Id activitiesId = recordTypeId[0].Id;    
        
        Target__c TG = new Target__c(Monthly_Target_Date__c=currentDate,RecordTypeId =activitiesId,OwnerId =u.Id);

        for(Account a : TestInit.accountList.values() ){
             a.Service_class__c= typeTarget;
             a.Visit_Class__c= VisitClass;
             update a;
         }
        TestInit.createTarget(TestInit.accountList.values());
        TestInit.createReport(TestInit.accountList.values());    

            
        //List<Target__c> listTarget = [ select OwnerId,Monthly_Target_Date__c,Actual_Visit_Silver__c,Actual_Visit_Gold__c,Actual_Visit_Platinum__c from Target__c where OwnerId = : UserInfo.getUserId() and CALENDAR_MONTH(Monthly_Target_Date__c) = : currentMonth and CALENDAR_YEAR(Monthly_Target_Date__c) = : currentYear and RecordTypeId = : activitiesId];                    
        /*for(Target__c t : listTarget){
            if(typeTarget=='Silver'){
            System.assertEquals(1,t.Actual_Visit_Silver__c);  
            System.assertEquals(null,t.Actual_Visit_Gold__c);  
            System.assertEquals(null,t.Actual_Visit_Platinum__c);      
            }else if(typeTarget=='Gold'){
            System.assertEquals(1,t.Actual_Visit_Silver__c);  
            System.assertEquals(1,t.Actual_Visit_Gold__c);  
            System.assertEquals(null,t.Actual_Visit_Platinum__c);      
            }else if(typeTarget=='Platinum'){
            System.assertEquals(1,t.Actual_Visit_Silver__c);  
            System.assertEquals(1,t.Actual_Visit_Gold__c);  
            System.assertEquals(1,t.Actual_Visit_Platinum__c);      
            }
        }*/
            

    }
    
        public static void DifferentOwnerTest(String testMode){
         User AdminUser;
        for(Account a : TestInit.accountList.values() ){
             AdminUser = TestUtils.createUsers(1,'AccountOwner', 'Ownertest','OwnerIDtest@email.com', true).get(0);
             a.OwnerId = AdminUser.id;
             update a;
         }
        TestInit.createTarget(TestInit.accountList.values());
        TestInit.createReport(TestInit.accountList.values());    

            

    }
        
}