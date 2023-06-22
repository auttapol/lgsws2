@isTest
public class reassignBRCCustomerCTLTest {
    public static testmethod void testContactCreation(){
        Test.startTest();

        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   

        Branch_and_Zone__c branch = New Branch_and_Zone__c();
        branch.Branch_Code__c = '999';
        branch.Name = 'ทหารไทยใหญ่';
        branch.Branch_Name__c = 'ทหารไทยใหญ่';
        branch.IsActive__c = true;
        insert branch;

        ID SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        List<User> userInsert = New List<user>();
        User newUser1 = new User(FirstName = 'User1' , LastName = 'LastName1', 
                                    UserName='testuser1@tmbbank.com.test',
                                    Email='test1@email.com', Alias='Test11',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='xxx1@@0022M',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='EM019', RTL_Branch_Code__c = '999');

        userInsert.add(newUser1);                            
        User newUser2 = new User(FirstName = 'User2' , LastName = 'LastName2', 
                                    UserName='testuser2@tmbbank.com.test',
                                    Email='test2@email.com', Alias='Test22',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='xxx2@@0022M',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='EM018', RTL_Branch_Code__c = '999');
        userInsert.add(newUser2);
        insert userInsert;
        
        Account acct = new Account();
        acct.First_Name_PE__c = 'Test';
        acct.Last_Name_PE__c = 'Customer';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0998877665';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.RTL_NID__c = '44466';
        acct.TMB_Customer_ID_PE__c = '001100000001100000000009399743';
        acct.RTL_Most_Operating_Branch__c = branch.id;
        acct.RTL_Assigned_BRC__c   = userInsert[0].id;       
        
        insert acct;

        Main_Bank_List_View__c mainB = New Main_Bank_List_View__c();
        mainB.Customer_ID__c = '001100000001100000000009399743';
        mainB.Has_Call_List__c = 'Yes';
        mainB.Customer__c = acct.id;
        mainB.Listview_Filter001__c = 'FT001';
        mainB.Listview_Filter002__c = 'FT002';
        mainB.Listview_Filter003__c = 'FT003';
        mainB.Listview_Filter004__c = 'FT004';
        mainB.Listview_Filter005__c = 'FT005';
        insert mainB;

        System.runAs(userInsert[0]){
           
            List<Account> accList = reassignBRCCustomerCTL.getBRCCustomerList();
            String result = reassignBRCCustomerCTL.recordReassign(accList,userInsert[1].id);
            List<sobject> soj = reassignBRCCustomerCTL.findBRCUserRecords('User1' ,'User');

        }

        Test.stopTest();

    }
}