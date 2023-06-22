@isTest

public class IDMUserBatch_Test {
    public static final Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static String sch1 = '0 0 10,15,20 * * ?';  
    public static String jobID = null;
    static{
        getCustomSetting();
    }
    public static testmethod void PositiveTest(){
        //create user
        List<User> userList = new List<User>();
        system.debug('## userList : '+userList);
        userList = TestUtils.createUsers(10, 'testfirstname', 'testlastname', 'test@tmbbank.com', true);
        userList[0].Manager_Employee_ID__c = 'Test1';
        userList[1].Manager_Employee_ID__c = 'MM002';
        userList[2].Manager_Employee_ID__c = '';
        userList[3].Manager_Employee_ID__c = 'ZZZZZ';
        update userList;
        try{
            
            TEST.startTest();
            //run schedule and batch
            UserBatchSchedulable batch = new UserBatchSchedulable();
            jobID = system.schedule('testBatch1', sch1, batch);
            TEST.stopTest();

        }catch(UnexpectedException uex){
            system.assertEquals('No more than one executeBatch can be called from within a test method.  Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.',uex.getMessage());
        }
        System.abortJob(jobID);
    }

    public static testmethod void NegativeTest(){
        List<User> userList = new List<User>();
        userList = TestUtils.createUsers(10, 'testfirstname', 'testlastname', 'test@tmbbank.com', true);
        userList[9].Manager_Employee_ID__c = 'MM010';
        update userList;
        String query = '';
        try{
            
            TEST.startTest();
            //run schedule and batch
            UserBatchSchedulable batch = new UserBatchSchedulable();
            jobID = system.schedule('testBatch2', sch1, batch);
            TEST.stopTest();
            
        }catch(UnexpectedException uex){
            System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
                                'your start method matches the batch size, resulting in one executeBatch invocation.', uex.getMessage());
        }
        System.abortJob(jobID);
        
    }
    
    public static testmethod void bulkTest(){
        AggregateResult[]  buserCount =  [Select Count(ID) total From User where Employee_ID__c != null];        
        if(null != buserCount){
            // System will see all user in db
            system.debug('=> Existing User '+ ((integer)buserCount[0].get('total')) +' Items '); 
        }
        List<User> managerList = new List<User>();
        managerList = TestUtils.createUsers(5, 'testfirstname', 'testlastname', 'test@tmbbank.com', true);
        
        List<User> userList = new List<User>();
        for(Integer i = 100;i<299;i++){
            User newUser = new User(FirstName = 'test'+i , LastName = 'test'+i, 
                                    UserName='test'+i+'@tmbbank.com',
                                    Email='test'+i+'@tmbbank.com', Alias='T'+i,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='test'+i+'_'+'TMBTesttmb'+i,
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MM'+i,Manager_Employee_ID__c = 'MM000');  
            userList.add(newUser);
        }  
        
        try{            
            insert userList; 
            AggregateResult[]  userCount =  [Select Count(ID) total From User where Employee_ID__c != null ];        
            if(null != userCount){
                // System will see all user in db
                system.debug('=> User After Insert 200 Users is  '+ ((integer)userCount[0].get('total')) +' Items '); 
            } 
            
            TEST.startTest();
            system.debug('## userList size '+userList.size());
            // run schedule and batch
            UserBatchSchedulable batch = new UserBatchSchedulable();
            jobID = system.schedule('testBatch3', sch1, batch);
            TEST.stopTest(); 
            
        }catch(UnexpectedException uex){
            system.assertEquals('No more than one executeBatch can be called from within a test method.  Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.',uex.getMessage());
        }
        System.abortJob(jobID);
    }
    
    public static testmethod void BatchUserBatchDispatcherExp(){
        Boolean isError = false; 
        // isError = fasle;
        try{
            UserBatchDispatcher.emode =1 ; //force error case
            UserBatchDispatcher.execute();
        }
         catch(UserBatchDispatcher.UserBatchDispatcherException ex){
            isError = true;
        }
        system.assert(isError);
    }
 
    /*** Create User Test Data ***/
    public static void createUser(Integer size,String managerID,Id profileId){
        
        List<User> userList = new List<User>();
        for(Integer i = 100;i<(100+size);i++){
            User newUser = new User(FirstName = 'test'+i , LastName = 'test'+i, 
                                    UserName='test'+i+'@tmbbank.com',
                                    Email='test'+i+'@tmbbank.com', Alias='T'+i,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='test'+i+'_'+'TMBTesttmb'+i,
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MM'+i,Manager_Employee_ID__c = managerID);
            userList.add(newUser);
        }
        insert userList;
    }
    
    
    /*** Get Custom Setting for HCM Project from AppConfig__c and  HCM&SLOS Messages ***/
    public static void getCustomSetting(){
        List<AppConfig__c> appconfigList = new List<AppConfig__c>();
        AppConfig__c HCM_CRM = new AppConfig__c(Name = 'HCM_CRM',Value__c = 'test1@ii.co.th ; test2@ii.co.th');
        AppConfig__c HCM_ITG = new AppConfig__c(Name = 'HCM_ITG',Value__c = 'test3@ii.co.th;test4@ii.co.th');
        AppConfig__c HCM_OperationTeam = new AppConfig__c(Name = 'HCM_OperationTeam',Value__c = 'test5@ii.co.th');
        AppConfig__c Days_of_Delete_BatchHistory = new AppConfig__c(Name = 'Days_of_Delete_BatchHistory',Value__c = '90');
        AppConfig__c HCM_BatchEndTime = new AppConfig__c(Name = 'HCM_BatchEndTime',Value__c = String.valueOf(System.now().time()));
        appconfigList.add(HCM_CRM);
        appconfigList.add(HCM_ITG);
        appconfigList.add(HCM_OperationTeam);
        appconfigList.add(Days_of_Delete_BatchHistory);
        appconfigList.add(HCM_BatchEndTime);
        insert appconfigList;
        
        List<Host_Status_Code__mdt> statuscode = new List<Host_Status_Code__mdt>([SELECT Id,DeveloperName,Status_Message_EN__c,Status_Message_TH__c 
                                                     FROM Host_Status_Code__mdt 
                                                     WHERE Host_System__c =: 'HCM']);
    }




    //For Wealth RM Batch
    public static testmethod void testForWealthRMBatch(){
        //create user
        TestUtils.createAppConfig();
        List<RTL_Branch_Manager_Title__c> apps = new  List<RTL_Branch_Manager_Title__c>();
        RTL_Branch_Manager_Title__c bmTitle = new RTL_Branch_Manager_Title__c();
        bmTitle.Name = 'Branch Manager';   
        bmTitle.RTL_Value__c = 'Branch Manager (Service and Relationship)';   
        apps.add(bmTitle);

        insert apps;

        List<AppConfig__c> appcfLst = new  List<AppConfig__c>();
        AppConfig__c appcf = new AppConfig__c();
        appcf.Name = 'IS_WEALTH_RM_BATCH';
        appcf.Value__c = 'true';        
        appcfLst.add(appcf);

        AppConfig__c appcf2 = new AppConfig__c();
        appcf2.Name = 'N_LIMIT_FOR_WEALTH_BATCH';
        appcf2.Value__c = '4000';        
        appcfLst.add(appcf2);

        

        insert appcfLst;


        List<User> userList = new List<User>();
        system.debug('## userList : '+userList);
        userList = TestUtils.createUsers(10, 'testfirstname', 'testlastname', 'test@tmbbank.com', true);
        userList[0].Manager_Employee_ID__c = 'Test1';
        userList[0].RTL_Branch_Code__c = '001';
        userList[1].Manager_Employee_ID__c = 'MM002';
        userList[1].RTL_Branch_Code__c = '001';
        userList[2].Manager_Employee_ID__c = '';
        userList[2].RTL_Branch_Code__c = '001';
        userList[3].Manager_Employee_ID__c = 'ZZZZZ';
        userList[3].RTL_Branch_Code__c = '001';
        update userList;

        User newUser = new User(FirstName = 'asdasd' , LastName = 'asdasd', 
                                    UserName='asdasdasd@tmbbank.com',
                                    Email='aaa@aa.com'
                                    , Alias='Testtmb0',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='abcd',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York'
                                    ,isActive = true,
                                    Employee_ID__c ='DDD01'
                                    ,Manager_Employee_ID__c = 'MM002'
                                    ,RTL_Branch_Code__c = '001');
        insert newUser;

        User inactiveUser = new User(FirstName = 'inactiveUser' , LastName = 'inactiveUser', 
                                    UserName='inactiveUser@tmbbank.com',
                                    Email='aaa@aa.com'
                                    , Alias='Tetmb01',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='abc3',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York'
                                    ,isActive = false,
                                    Employee_ID__c ='DDD04'
                                    ,Manager_Employee_ID__c = 'MM002'
                                    ,RTL_Branch_Code__c = '001');
        insert inactiveUser;

         User newUser2 = new User(FirstName = 'asdasd2' , LastName = 'asdasd2', 
                                    UserName='asdasdasd2@tmbbank.com',
                                    Email='aaa@aa.com'
                                    , Alias='Tetmb02',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='abcd2',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York'
                                    ,isActive = true,
                                    Employee_ID__c ='DDD03'
                                    ,Manager_Employee_ID__c = 'MM002'
                                    ,RTL_Branch_Code__c = '002');
        insert newUser2;

        try{
            
            TEST.startTest();
            //run schedule and batch
            RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Retail Customer' Limit 1];

            List<Account> accList = new List<Account>();
            Account accForwealthRMBatch = new Account(Name='Test' 
                                        , recordTypeId=rt.id
                                        , RTL_Wealth_RM__c = null
                                        , RTL_RM_Name__c = 'DDD01'
                                        ,TMB_Customer_ID_PE__c='001100000000000000000006431274');

            Account accForwealthRMBMAssignedSQL = new Account(Name='Test2' 
                                        , recordTypeId=rt.id
                                        , RTL_Wealth_RM__c = userList[1].Id
                                        , RTL_RM_Name__c = '00001'
                                        ,TMB_Customer_ID_PE__c='001100000000000000000006431475');

            Account wealthRMZMAssignedBatch = new Account(Name='Test3' 
                                        , recordTypeId=rt.id
                                        , RTL_Wealth_RM__c = userList[1].Id
                                        , RTL_RM_Name__c = 'DDD01'
                                        ,TMB_Customer_ID_PE__c='001100000000000000000006431476');

            Account handleReorgSQLBatch = new Account(Name='Test3' 
                                        , recordTypeId=rt.id
                                        , RTL_Wealth_RM__c = newUser.Id
                                        , RTL_RM_Name__c = '002'
                                        ,TMB_Customer_ID_PE__c='001100000000000000000006431477');

            Account handleWealthInactiveSQLBatch = new Account(Name='Test3' 
                                        , recordTypeId=rt.id
                                        , RTL_Wealth_RM__c = inactiveUser.Id
                                        , RTL_RM_Name__c = 'DDD04'
                                        ,TMB_Customer_ID_PE__c='001100000000000000000006431478');

            accList.add(accForwealthRMBatch);
            accList.add(accForwealthRMBMAssignedSQL);
            accList.add(wealthRMZMAssignedBatch);

            accList.add(handleReorgSQLBatch);
            accList.add(handleWealthInactiveSQLBatch);

            insert accList;

            UserBatchSchedulable batch = new UserBatchSchedulable();
            jobID = system.schedule('testBatch1', sch1, batch);
            TEST.stopTest();

        }catch(UnexpectedException uex){
            system.assertEquals('No more than one executeBatch can be called from within a test method.  Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.',uex.getMessage());
        }
        System.abortJob(jobID);
    }
    //FOr Wealth RM Batch
}