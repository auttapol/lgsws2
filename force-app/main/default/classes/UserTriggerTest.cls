@IsTest
public class UserTriggerTest {
    public static integer n;

    static{
        List<Title_and_Product_Group_Mapping__c> titleProductList = new List<Title_and_Product_Group_Mapping__c>();
        Title_and_Product_Group_Mapping__c eachTitle1 = new Title_and_Product_Group_Mapping__c(Title__c = 'Investment Specialist',Product_Group__c = 'Investment');
        Title_and_Product_Group_Mapping__c eachTitle2 = new Title_and_Product_Group_Mapping__c(Title__c = 'Senior Investment Specialist',Product_Group__c = 'Bancassurance');
        
        titleProductList.add(eachTitle1);
        titleProductList.add(eachTitle2);
        insert titleProductList;

    }

    public static testmethod void positiveTest() {
        System.debug(':::: positiveTest Start ::::');
        Test.startTest();
        TestUtils.createObjUserPermission();
        TestUtils.createAppConfig();
        Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runUserTrigger' LIMIT 1];
        Aconfig.Value__c ='true';
        update Aconfig;
        TestUtils.CreateTriggerMsg();
        TestInit.createUser(true);  //  Create User by User Run Test
        User u = TestInit.us;
        user u2 = TestInit.us2;
        
       System.runAs(u) { // User in List
            // Insert
            n = 1;
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            System.debug('Current User Id: ' + UserInfo.getUserId());
            //TestUtils.createUsers(1,'TestUtilTest', 'Utiltest','testUtil@TestUtil.com', true);  //  Test Create User
            try{
                //userTest = createUsers(n,'TestUtil', 'Utiltest','testUtil@TestUtil.com', true);  //  Test Create User
                userTest = createUsers(n,'TestUtil', 'Utiltest','testUtil@tmbbank.com', true);  //  Test Create User
            }
            catch (Exception e){
                System.assert(e.getMessage().contains('You are not allowed to insert user information.'));
            }
            
            // Update
            //List<User> usr = [select Id,FirstName,LastName,UserName,Email,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey,CommunityNickname,ProfileId,TimeZoneSidKey,isActive,Employee_ID__c from User];
            List<User> UpUsr1 = new List<User>();
            for(User usr1 : [select Id,FirstName,LastName,UserName,Email,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey,CommunityNickname,ProfileId,TimeZoneSidKey,isActive,Employee_ID__c from User]) {
                //if(usr1.Email == n + 'testUtil@TestUtil.com') {
                if(usr1.Email == n + 'testUtil@tmbbank.com') {
                    usr1.Title='Investment Specialist';
                    UpUsr1.add(usr1);
                }
            }
            try{
                update UpUsr1;
            }
            catch (Exception e){
                System.assert(e.getMessage().contains('You are not allowed to change user information.'));
            }
        }
        
        System.runAs(userTest) { // User Not in List
            // Insert
            n = 2;
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            System.debug('Current User Id: ' + UserInfo.getUserId());
            //TestUtils.createUsers(2,'TestUtil', 'Utiltest','testUtil@TestUtil.com', true);  //  Test Create User
            try{
                //userTest = createUsers(n,'TestUtil', 'Utiltest','testUtil@TestUtil.com', true);  //  Test Create User
                userTest = createUsers(n,'TestUtil', 'Utiltest','testUtil@tmbbank.com', true);  //  Test Create User
            }
            catch (Exception e){
                System.assert(e.getMessage().contains('You are not allowed to insert user information'));
            }
            
            // Update
            n = 1;
            //List<User> usr = [select Id,FirstName,LastName,UserName,Email,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey,CommunityNickname,ProfileId,TimeZoneSidKey,isActive,Employee_ID__c from User];
            List<User> UpUsr2 = new List<User>();
            for(User usr2 : [select Id,FirstName,LastName,UserName,Email,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey,CommunityNickname,ProfileId,TimeZoneSidKey,isActive,Employee_ID__c from User]) {
                //if(usr2.Email == n + 'testUtil@TestUtil.com') {
                if(usr2.Email == n + 'testUtil@tmbbank.com') {
                    UpUsr2.add(usr2);
                }
            }
            try{
                update UpUsr2;
            }
            catch (Exception e){
                System.debug(e.getMessage());
                System.assert(e.getMessage().contains('You are not allowed to change user information'));
            }
        }

        Test.stopTest();
        System.debug(':::: positiveTest End ::::');
    }
    
    public static testMethod void updateUserTestByIDM(){
        system.debug('## updateUserTestByIDM  ##');
        User sfadm = [SELECT Id FROM User WHERE Name = 'sfadm System Account'];
        List<User> updatebyIDMUserList = new List<User>();
        System.runAs(sfadm){ 
        //User manager = createUsers(1,'FName','LName','email@email.com',true);
        User manager = createUsers(1,'FName','LName','email@tmbbank.com',true);
        List<User> userList = createTestUser(150,null);
            TEST.startTest();
            for(User user : userList){
                user.ManagerId = manager.Id;
                updatebyIDMUserList.add(user);
            }
            update updatebyIDMUserList;
            system.debug('## updatebyIDMUserList '+updatebyIDMUserList);
            TEST.stopTest();
       
        }
    }
    
    
    public static User userTest {
        get
        {
            if(userTest == null){
                userTest = new User();
            }
            return userTest;
            
        }set;
    }
    
    public static User createUsers(Integer no,String FName,String LName,String Email,Boolean doInsert) {
        List<User> userToCreate = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
        User newUser = new User(FirstName=FName+no, LastName=LName, Title='Senior Investment Specialist',
                                UserName=FName+no+LName+'TestTMB@tmbbank.com', 
                                Email=no+Email, Alias='Testtmb'+no,RTL_Branch_Code__c='001',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                CommunityNickname=Fname+LName+no+'Testtmb',
                                ProfileId = p.Id, TimeZoneSidKey='America/New_York',isActive = true,
                                Employee_ID__c ='Test'+no);
        userToCreate.add(newUser);

        userTest = newUser;
        if(doInsert){
            insert newUser;
        }

        return newUser;
    }
    
    public static User createSfadm(){

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User sfadm = new User(FirstName='sfadm', LastName='System Account', 
                                UserName='sfadm@tmbbank.com', 
                                Email='sfadm@tmbbank.com',Alias='sfadm',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                CommunityNickname='qqqqq',
                                ProfileId = p.Id, TimeZoneSidKey='America/New_York',isActive = true,
                                Employee_ID__c ='sfadm');
        insert sfadm;
        return sfadm;
    }
    
    public static List<User> createTestUser(Integer size,String managerId){
        List<User> userToCreate = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1];
        for(Integer i = 100 ; i < size ; i++){
            User testuser = new User(FirstName='test', LastName='user'+i, 
                                    UserName='testuser'+i+'@tmbbank.com', 
                                    Email='testuser'+i+'@tmbbank.com',Alias='t'+i,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='t'+i,FederationIdentifier = 'testuser'+i+'@tmbbank.com',
                                    ProfileId = p.Id, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='tu'+i,Manager_Employee_ID__c = managerId);
            userToCreate.add(testuser);
        }
        insert userToCreate;
        return userToCreate;
    }
}