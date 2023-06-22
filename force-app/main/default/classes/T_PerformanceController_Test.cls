@isTest
public with sharing class T_PerformanceController_Test {
    // public T_PerformanceController_Test() {
        // }
    @isTest static void testGetUserInfo(){
        T_PerformanceController.getUserInfo();
    }
    @isTest static void testGetUserInfoAsLandingPapge(){
        //     String []userId = new String[]{'00590000003xjVfAAI'};
        
        String roleName = 'Head of Small Business Sales1';
        String profileName = 'TMB SE Group Head Profile';

        // T_Performance_Team_List__c teamList = new T_Performance_Team_List__c(Channel__c = 'Branch', Region_Code__c ='1800', Zone_Code__c = '1820' );
        // insert teamList;
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = roleName);
        insert r;
        
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName  LIMIT 1];
        
        User myUser = TestUtils.createUsers(1, 'mockuser1', 'mockuser1', 'mockuser1@test.com', true).get(0);
        // User myUser = new User(FirstName='mockuser1',LastName='mockuser1',Region_Code__c='1800',Zone_Code__c='1820',IsActive=true, Username='mockuser1@test.com', Email='mockuser1@test.com', Alias='mockusr', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        myUser.ProfileId = p.Id;
        myUser.UserRoleId = r.Id;
        myUser.Region_Code__c = '1800';
        myUser.Zone_Code__c = '1820';
        myUser.IsActive = true;
        update myUser;
        
        System.runAs(myUser) {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            T_PerformanceController.getUserInfo();
        }
        
    }
    @isTest static void testGetUserInfoAsP4(){
        // String []userId = new String[]{'00590000006TzFcAAK'};
        String roleName = 'WM-TL 1-5-9535';
        String profileName = 'TMB Retail Wealth Management';
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = roleName);
        insert r;

        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName  LIMIT 1];

        User myUser = TestUtils.createUsers(1, 'mockuser1', 'mockuser1', 'mockuser1@test.com', true).get(0);
        // User myUser = new User(FirstName='mockuser1',LastName='mockuser1',Region_Code__c='1800',Zone_Code__c='1820',IsActive=true, Username='mockuser1@test.com', Email='mockuser1@test.com', Alias='mockusr', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        myUser.ProfileId = p.Id;
        myUser.UserRoleId = r.Id;
        myUser.Region_Code__c = '1800';
        myUser.Zone_Code__c = '1820';
        myUser.IsActive = true;
        update myUser;
 
        System.runAs(myUser) {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            T_PerformanceController.getUserInfo();
        }
    }
         @isTest static void testGetUserInfoAsP1(){
        // String []userId = new String[]{'0050o00000WhsYNAAZ'};
        String roleName = 'WM-RM 1-5';
        String profileName = 'TMB Retail Wealth Management';
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = roleName);
        insert r;

        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName  LIMIT 1];

        User myUser = TestUtils.createUsers(1, 'mockuser1', 'mockuser1', 'mockuser1@test.com', true).get(0);
        // User myUser = new User(FirstName='mockuser1',LastName='mockuser1',Region_Code__c='1800',Zone_Code__c='1820',IsActive=true, Username='mockuser1@test.com', Email='mockuser1@test.com', Alias='mockusr', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        myUser.ProfileId = p.Id;
        myUser.UserRoleId = r.Id;
        myUser.Region_Code__c = '1800';
        myUser.Zone_Code__c = '1820';
        myUser.IsActive = true;
        update myUser;
 
        System.runAs(myUser) {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            T_PerformanceController.getUserInfo();
        }
    }
    @isTest static void testGetChannel(){
        T_Performance_Team_List__c t1 = new T_Performance_Team_List__c();
        t1.Name = '058';
        t1.Branch_Team_Code__c = '058';
        t1.Branch_Team_Name__c = 'สาขาบางนา';
        t1.Branch_Team_Manager__c ='น.ส.อทิยา  ตู้ดำ';
        t1.Channel__c = 'Branch';
        t1.Region_Code__c = '1800';
        t1.Zone_Code__c = '1880';
        t1.Region_Name__c = 'BANGNA';
        t1.Zone_Name__c = 'RH1';
        insert t1;
        System.debug('Zone_Code_and_Name1: '+t1.Zone_Code_and_Name__c);
        System.debug('Region_Code_and_Nam1e: '+t1.Region_Code_and_Name__c);

        T_Performance_Team_List__c t3 = new T_Performance_Team_List__c();
        t3.Name = '3301';
        t3.Branch_Team_Code__c = '3301';
        t3.Branch_Team_Name__c = 'สาขาบางทีก็ดีสักทีเถอะ';
        t3.Branch_Team_Manager__c ='นายบางรัก ซอยเก้า';
        t3.Channel__c = 'Mortgage Loan Sales';
        t3.Region_Code__c = '3300';
        t3.Zone_Code__c = '3301';
        t3.Region_Name__c = 'Mortgage Loan Sales 1-1';
        t3.Zone_Name__c = 'Mortgage Loan Sales 1';
        System.debug('Region_Code_and_Name3: '+t3.Region_Code_and_Name__c);
        System.debug('Zone_Code_and_Name3: '+t3.Zone_Code_and_Name__c);
        insert t3;
        
        T_PerformanceController.getChannel();
    }

    @isTest static void testGetRegionCodeAndName(){
        T_Performance_Team_List__c t1 = new T_Performance_Team_List__c();
        t1.Name = '058';
        t1.Branch_Team_Code__c = '058';
        t1.Branch_Team_Name__c = 'สาขาบางนา';
        t1.Branch_Team_Manager__c ='น.ส.อทิยา  ตู้ดำ';
        t1.Channel__c = 'Branch';
        t1.Region_Code__c = '1800';
        t1.Zone_Code__c = '1880';
        t1.Region_Name__c = 'BANGNA';
        t1.Zone_Name__c = 'RH1';
        System.debug('Region_Code_and_Nam1e: '+t1.Region_Code_and_Name__c);
        System.debug('Zone_Code_and_Name1: '+t1.Zone_Code_and_Name__c);
        insert t1;
        
        T_Performance_Team_List__c t2 = new T_Performance_Team_List__c();
        t2.Name = '050';
        t2.Branch_Team_Code__c = '050';
        t2.Branch_Team_Name__c = 'สาขาบางทีก็ท้อ';
        t2.Branch_Team_Manager__c ='นายกิตติศักดิ์ ลำน้อย';
        t2.Channel__c = 'Branch';
        t2.Region_Code__c = '7400';
        t2.Zone_Code__c = '7470';
        t2.Region_Name__c = 'AYUTTHAYA';
        t2.Zone_Name__c = 'RH5';
        System.debug('Region_Code_and_Name2: '+t2.Region_Code_and_Name__c);
        System.debug('Zone_Code_and_Name2: '+t2.Zone_Code_and_Name__c);
        insert t2;

        T_PerformanceController.getRegionCodeAndName('Branch');
    }
    @isTest static void testGetRegionCodeAndName_Catch(){
        T_PerformanceController.getRegionCodeAndName(null);
    }
    @isTest static void testGetZoneCodeAndName(){
        T_Performance_Team_List__c t1 = new T_Performance_Team_List__c();
        t1.Name = '058';
        t1.Branch_Team_Code__c = '058';
        t1.Branch_Team_Name__c = 'สาขาบางนา';
        t1.Branch_Team_Manager__c ='น.ส.อทิยา  ตู้ดำ';
        t1.Channel__c = 'Branch';
        t1.Region_Code__c = '1800';
        t1.Zone_Code__c = '1880';
        t1.Region_Name__c = 'BANGNA';
        t1.Zone_Name__c = 'RH1';
        System.debug('Region_Code_and_Nam1e: '+t1.Region_Code_and_Name__c);
        System.debug('Zone_Code_and_Name1: '+t1.Zone_Code_and_Name__c);
        insert t1;
        
        T_Performance_Team_List__c t4 = new T_Performance_Team_List__c();
        t4.Name = '050';
        t4.Branch_Team_Code__c = '050';
        t4.Branch_Team_Name__c = 'สาขาบางทีก็ท้อ';
        t4.Branch_Team_Manager__c ='นายกิตติศักดิ์ ลำน้อย';
        t4.Channel__c = 'Branch';
        t4.Region_Code__c = '1800';
        t4.Zone_Code__c = '7470';
        t4.Region_Name__c = 'BANGNA';
        t4.Zone_Name__c = 'RH5';
        System.debug('Region_Code_and_Name2: '+t4.Region_Code_and_Name__c);
        System.debug('Zone_Code_and_Name2: '+t4.Zone_Code_and_Name__c);
        insert t4;

        T_PerformanceController.getZoneCodeAndName('Branch','(1800) BANGNA');
    }
    @isTest static void testGetBranchCodeAndName(){
        T_Performance_Team_List__c t1 = new T_Performance_Team_List__c();
        t1.Name = '058';
        t1.Branch_Team_Code__c = '058';
        t1.Branch_Team_Name__c = 'สาขาบางนา';
        t1.Branch_Team_Manager__c ='น.ส.อทิยา  ตู้ดำ';
        t1.Channel__c = 'Branch';
        t1.Region_Code__c = '1800';
        t1.Zone_Code__c = '1880';
        t1.Region_Name__c = 'BANGNA';
        t1.Zone_Name__c = 'RH1';
        System.debug('Team_Code_and_Name1: '+t1.Team_Code_and_Name__c);
        System.debug('Region_Code_and_Name1: '+t1.Region_Code_and_Name__c);
        System.debug('Zone_Code_and_Name1: '+t1.Zone_Code_and_Name__c);
        insert t1;
        
        T_Performance_Team_List__c t5 = new T_Performance_Team_List__c();
        t5.Name = '059';
        t5.Branch_Team_Code__c = '059';
        t5.Branch_Team_Name__c = 'สาขาบางทีก็ท้อ';
        t5.Branch_Team_Manager__c ='นายกิตติศักดิ์ ลำน้อย';
        t5.Channel__c = 'Branch';
        t5.Region_Code__c = '1800';
        t5.Zone_Code__c = '1880';
        t5.Region_Name__c = 'BANGNA';
        t5.Zone_Name__c = 'RH1';
        System.debug('Team_Code_and_Name5: '+t5.Team_Code_and_Name__c);
        System.debug('Region_Code_and_Name5: '+t5.Region_Code_and_Name__c);
        System.debug('Zone_Code_and_Name5: '+t5.Zone_Code_and_Name__c);
        insert t5;

        T_Performance_Team_List__c t6 = new T_Performance_Team_List__c();
        t6.Name = '030';
        t6.Branch_Team_Code__c = '030';
        t6.Branch_Team_Name__c = 'สาขาปู่เจ้าสมิงพราย';
        t6.Branch_Team_Manager__c ='น.ส.พัชรินทร์ จารุแพทย์';
        t6.Channel__c = 'Branch';
        t6.Region_Code__c = '1800';
        t6.Zone_Code__c = '1880';
        t6.Region_Name__c = 'BANGNA';
        t6.Zone_Name__c = 'RH1';
        insert t6;
        System.debug('Team_Code_and_Name1: '+t6.Team_Code_and_Name__c);
        System.debug('Region_Code_and_Name1: '+t6.Region_Code_and_Name__c);
        System.debug('Zone_Code_and_Name1: '+t6.Zone_Code_and_Name__c);
        
        T_PerformanceController.getBranchCodeAndName('Branch','(1800) BANGNA', '(1880) RH1');
    }
    @isTest static void testSearchPerformanceTeamList(){
        T_PerformanceController.searchPerformanceTeamList('Branch','(1800) BANGNA', '(1800) RH1','(058) สาขาบางนา','บางนา');
    }

    @isTest static void testInsertTermOfUseLog(){
        T_PerformanceController.insertTermOfUseLog('Accepted');
    }

}