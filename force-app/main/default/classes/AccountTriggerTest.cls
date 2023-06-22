@IsTest
public class AccountTriggerTest {
    //public static String STR_POSITIVE = 'positive';
    //public static String STR_NEGATIVE = 'negative';
    //public static User u;
    //public static User u2;
    
    
    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        //TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();

        Sub_Segment_Mapping__c subsegMap = new Sub_Segment_Mapping__c();
		subsegMap.Sub_Segment_Code__c = '20';
		subsegMap.Zone_Code_Team_Code__c = '';
		insert subsegMap;
    }
    
/*   
    public static testmethod void RunPositiveTestAccount(){
        System.debug(':::: RunPositiveTestAccount Start ::::');
        /*TestInit.createUser(true);
        u = TestInit.us;
        u2 = TestInit.us2;*/
/*        
        insert new Prospect_Owner_Assignment__c(name='name', TMB_Staff_ID__c='staff id');
        insert new Trigger_Msg__c(name='Not_Found_Suggested_Segment', Description__c='error');
        
        u = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        u2 = [SELECT ID,Segment__c,IsActive FROM User WHERE IsActive=:true and ID !=:UserInfo.getUserId() LIMIT 1];
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());    
            System.debug('Current User Id: ' + UserInfo.getUserId()); 
            
            TestInit.createAccount(3);
            TestInit.createOpportunity(TestInit.accountList.values());
            TestInit.createTask(TestInit.accountList.values());
            TestInit.createReport(TestInit.accountList.values());
            TEST.startTest();
            flowTest(STR_POSITIVE);
            TEST.stopTest();
            System.debug(':::: RunPositiveTestAccount End ::::');
        }
        
    }
    
    public static testmethod void RunNegativeTestAccount(){
        System.debug(':::: RunNegativeTestAccount Start ::::');
        /*TestInit.createUser(true);
        u = TestInit.us;
        u2 = TestInit.us2;*/
/*        u = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        u2 = [SELECT ID,Segment__c,IsActive FROM User WHERE IsActive=:true and ID !=:UserInfo.getUserId() LIMIT 1];
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());    
            System.debug('Current User Id: ' + UserInfo.getUserId()); 
            
            TestInit.createAccount(3);
            TestInit.createOpportunity(TestInit.accountList.values());
            TestInit.createTask(TestInit.accountList.values());
            TestInit.createReport(TestInit.accountList.values());
            TEST.startTest();
            flowTest(STR_NEGATIVE);
            TEST.stopTest();
            System.debug(':::: RunNegativeTestAccount End ::::');
        }        
    }
    
    
    
    
    public static testmethod void RunDisqualifiedProspectbyName(){
        System.debug(':::: RunDisqualifiedProspect Start ::::');
        
        u = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            
           
        LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Individual', false);
            Account firstAcct = acct.get(0);
            firstAcct.Name ='TestAcct1';
            firstAcct.Phone = '423432';
            firstAcct.ID_Type_PE__c = 'Citizen ID';
            firstAcct.ID_Number_PE__c = '1209700256444';
            insert firstacct;
             Id [] fixedSearchResults= new Id[1];
           fixedSearchResults[0] = firstacct.id;
           Test.setFixedSearchResults(fixedSearchResults);
            
            
            Account secondAcct = acct.get(1);
            secondAcct.Name = 'TestAcct2';
            secondAcct.Phone = '423432';
            secondAcct.ID_Type_PE__c = '';
            secondAcct.ID_Number_PE__c = '';
            insert secondAcct;
            secondAcct.Name = 'TestAcct1';
            try{
                update secondAcct;
            }catch(Exception e){
                System.assertNotEquals('%Prospect is duplicate in the system by Account Name%',e.getMessage());
 
            }
            
            System.debug(':::: RunDisqualifiedProspect End ::::');
        }        
    }
    
    
    
    
    
    public static testmethod void RunDisqualifiedProspectbyID(){
        System.debug(':::: RunDisqualifiedProspect Start ::::');
        
        u = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            
           
        LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Juristic', false);
            Account firstAcct = acct.get(0);
            firstAcct.ID_Type_PE__c = 'BRN ID';
            firstAcct.ID_Number_PE__c = '15551';
            firstAcct.Phone = '423432';
            insert firstacct;
             Id [] fixedSearchResults= new Id[1];
           fixedSearchResults[0] = firstacct.id;
           Test.setFixedSearchResults(fixedSearchResults);
            
            
            Account secondAcct = acct.get(1);
            secondAcct.ID_Type_PE__c = 'BRN ID';
            secondAcct.ID_Number_PE__c = '15552';
            secondAcct.Phone ='123123';
            insert secondAcct;
            
            secondAcct.ID_Type_PE__c = 'BRN ID';
            secondAcct.ID_Number_PE__c = '15551';
            update secondAcct;
            System.debug(':::: RunDisqualifiedProspect End ::::');
        }        
    }
    
    public static void flowTest(String testMode){
        //Test for T01 , T04
        List<Account> listAcc;
        for(Account a : TestInit.accountList.values() ){
            a = setValueCase_1(a,testMode);
        }
        
        try{
            update TestInit.accountList.values();
        }catch (DmlException e){
            System.debug('error : '+e.getMessage());
        }
        
        listAcc = [select Id,OwnerId,Owner_change_notification__c,Change_to_owner__c,Prospect_Converted_Date__c from Account where Id = :TestInit.accountList.keySet()];
        for(Account a : listAcc){
            if(testMode == STR_POSITIVE){
                //System.assertEquals(u2.Id, a.OwnerId);
                //System.assertEquals(true, a.Owner_change_notification__c);         
                //System.assertEquals(Date.today(), a.Prospect_Converted_Date__c);     
            }else{
                System.assertEquals(UserInfo.getUserId(), a.OwnerId);
                System.assertEquals(false, a.Owner_change_notification__c);
                //System.assertEquals(null, a.Prospect_Converted_Date__c);                   
            }
            
        }
        
        // Test for T05 , T06
        TestInit.accountList = null;
        TestInit.accountList.putAll(listAcc);
        for(Account a : TestInit.accountList.values() ){
            a = setValueCase_2(a,testMode);
        }
        
        try{
            update TestInit.accountList.values();
        }catch (DmlException e){
            System.debug('error : '+e.getDmlStatusCode(0) );
            System.assertEquals('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY',e.getDmlStatusCode(0));  
        }
        
        listAcc = [select Id,OwnerId,Owner_change_notification__c,Change_to_owner__c from Account where Id = :TestInit.accountList.keySet()];
        for(Account a : listAcc){
            if( testMode == STR_POSITIVE ){
                //System.assertEquals(u2.Id, a.OwnerId);
                //System.assertEquals(true, a.Owner_change_notification__c);
            }else{
                System.assertEquals(a.OwnerId, a.OwnerId);
                System.assertEquals(false, a.Owner_change_notification__c);
            }
            
        }
    }
    
    public static Account setValueCase_1(Account a,String testMode){
        if( testMode == STR_POSITIVE ){
            a.Re_assign_prospect__c = 'yes';
            a.Account_Type__c = 'Qualified Prospect';
            a.Suggested_Sub_Segment__c = 'TEST';
        }else{
            a.Re_assign_prospect__c = 'yes';
            a.Account_Type__c = 'Qualified Prospect';
            a.Suggested_Sub_Segment__c = null;
        }
        return a;
    }
    
    public static Account setValueCase_2(Account a,String testMode){
        if( testMode == STR_POSITIVE ){
            a.Account_Approval_Status__c = 'Final Approved';
            a.Change_to_owner__c = u2.Id;
        }else{
            a.Account_Approval_Status__c = 'Final Approved';
            a.Change_to_owner__c = null;
        }
        return a;
    }    
    
    
     public static testmethod void ChangeOwnerAcctPlanTest(){
          //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test AccountPlan Step5' ;
        testAccount1.OwnerId = UserInfo.getUserId();
        testAccount1.Phone ='234123413';
         testAccount1.Mobile_Number_PE__c ='234123413';
        insert testAccount1;
        
        //Create Contact
        Contact cont1 = new Contact();
        cont1.FirstName='AccountPlan';
        cont1.LastName='Step5';
        cont1.Position__c = 'Manager';
        cont1.Accountid= testAccount1.id;
        insert cont1;
        
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        if(currentYear>2557) currentYear = currentDate.year() - 543;
        
        String YearStr = String.ValueOf(currentYear);
        
        //Create Account Plan
        AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
        Company1.Account__c=testAccount1.id;
        //Company1.Name='AccountPlan Step5';
        Company1.Status__c = 'In Progress';
        Company1.ownerId = UserInfo.getUserId();
        Company1.Year__c  = YearStr;
        insert Company1;
        
        User us = [SELECT ID,Segment__c,IsActive FROM User WHERE IsActive=:true and ID !=:UserInfo.getUserId() LIMIT 1];
        testAccount1.Owner = us;
        update testAccount1;
        
        User us2 = [SELECT ID,Segment__c,IsActive FROM User WHERE IsActive=:true and ID !=:us.Id LIMIT 1];
        testAccount1.Owner = us2;

        accountTeamMember atm = new accountTeamMember();
        atm.accountid = testAccount1.ID;
        atm.userid = us2.ID;
        insert atm;
        update testAccount1;
        
     
     }
*/
    static testmethod void testTrigger(){
        Test.startTest();
        User sfextapi = AccountTriggerHandler.sfextapi;
        List<User> u = TestUtils.createUsers(3, 'F', 'L' ,'test@tmbbank.com', true);
        User u1 = u.get(0);
        User u2 = u.get(1);
        User u3 = u.get(2);

        System.runAs(u1)
        {
            TestInit.createAccount( 1 );
            List<Account> accountList = TestInit.accountList.values();
            TestInit.createOpportunity( accountList ); 
            List<Opportunity> opportunityList = TestInit.opportunityList.values();
            TestInit.createReport( accountList ); 
            List<Call_Report__c> reportList = TestInit.reportList.values();

            Id objRecordType = [select id from recordtype where name = 'Commercial Account'].id;
            Lead l = new Lead(ownerid = u1.id,account__c = accountList.get(0).id, recordtypeId = objRecordType
                , firstname = 'fi1', lastname = 'la1', company = 'co1');
            insert l;

            AccountTeamMember atm = new AccountTeamMember(accountid = accountList.get(0).id, UserId = u3.id);
            insert atm;
            AccountShare acs = new AccountShare(accountid = accountList.get(0).id, userOrGroupId = u3.id, accountAccessLevel = 'Read', opportunityAccessLevel = 'Read', caseAccessLevel = 'Read');
            insert acs;
            OpportunityTeamMember otm = new OpportunityTeamMember(opportunityid = opportunityList.get(0).id, UserId = u3.id);
            insert otm;
            OpportunityShare ops = new OpportunityShare(opportunityid = opportunityList.get(0).id, userOrGroupId = u3.id, opportunityAccessLevel = 'Read');
            insert ops;

            Executive_Summary__c es = new Executive_Summary__c(Customer_Name__c = accountList.get(0).id, talk_point__c = 'test');
            insert es;

            update accountList;

            accountList.get(0).ownerId = u2.id; 

            update accountList;
            /*
            for (account ac : accountList)
            {
                ac.Account_Approval_Status__c = 'Final Approved';
                ac.Change_to_owner__c = u1.id;
            }

            update accountList;
            */
        }

        Test.stopTest();
    }    


    static testmethod void testTriggerForRetailAccToCommAccAccFinalApproved(){
        Test.startTest();
        TestUtils.createAppConfigRetailtoComm();

        List<User> u = TestUtils.createUsers(1, 'F', 'L' ,'test@tmbbank.com', true);
        User u1 = u.get(0);
        Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User newUser = new User(FirstName = 'INACTIVE_FNAME' , LastName = 'INACTIVE_LNAME', 
                                    UserName='sfadmrtl@tmbbank.com.test',
                                    Email='aaa@aa.com', Alias='inem',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='In_TMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID
                                    , TimeZoneSidKey='America/New_York'
                                    ,isActive = true,
                                    Employee_ID__c ='MM05');
        insert newUser;

        System.runAs(u1)
        {
            TestInit.createAccount( 1 );
            List<Account> accountList = TestInit.accountList.values();

            for (account ac : accountList)
            {
                ac.Account_Approval_Status__c = 'Final Approved';
                ac.Change_to_owner__c = u1.id;
            }

            update accountList;


            //For RetaiAccToCommAcc
            Account acct = new Account();
            acct.First_Name_PE__c = 'abc';
            acct.Last_Name_PE__c = 'abc';
            acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
            acct.Email_Address_PE__c = 'test@sfdc.com';
            acct.Mobile_Number_PE__c = '0111111111';
            acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
            acct.Account_Type__c = 'Retail Customer';
            acct.ID_Type_PE__c = 'Citizen ID';
            acct.ID_Number_PE__c = '4496799264466';
            acct.Segment_crm__c   = '5';
            acct.OwnerId = newUser.Id;
            acct.RTL_NID__c = '44466';
            acct.TMB_Employee_ID__c ='MM010';
            acct.TMB_Customer_ID_PE__c = '001100000001100000000009399743';                
            insert acct;
            acct.Segment_crm__c = '4';
            acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
            update acct;
            //For RetaiAccToCommAcc
        }

        Test.stopTest();
    }
}