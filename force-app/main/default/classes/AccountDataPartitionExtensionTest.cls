@isTest
public class AccountDataPartitionExtensionTest {
    
    private static final string SECTION_ACC = 'ComPros:Customer Information';
	private static final string SECTION_ACC2 = 'ComPros:Product Interest';
	private static final string SECTION_ACC3 = 'ComPros:Customer Source';
    
    @testSetup static void setupData() 
	{
		TestUtils.createAppConfig();

        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
		insert branchTitle;
        
		Profile userProfile = [SELECT Id, Name FROM Profile WHERE Name='TMB RM Profile' LIMIT 1];
		RecordType rc = [ SELECT id FROM RecordType WHERE SobjectType = 'Account' AND name = 'Prospect' ];

		User su = TestUtils.createUsers(1,'AccountOwner', 'Ownertest','OwnerIDtest@tmbbank.com', false).get(0);
		su.Employee_ID__c = '11111';
		su.ProfileId = userProfile.Id;
		insert su;

		Account acc1 = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', false).get(0);
		acc1.RTL_Email_2__c = 'test01@tmbbank.com';
		acc1.RecordType = rc;
		acc1.RTL_RM_Name__c = '11111';
		insert acc1;

		Contact cont = TestUtils.createContacts(1, acc1.id, false).get(0);
		cont.Primary_Phone_Ext_PE__c = '0817161233';
		insert cont;
        
		List<Data_Security_Matrix__c> dscList = new List<Data_Security_Matrix__c>();
		Data_Security_Matrix__c  dmc1 = new Data_Security_Matrix__c (
			Profile_Name__c = userProfile.name,
			Section_Name__c = SECTION_ACC,
			Access_Type__c = 'All'
			);

		Data_Security_Matrix__c  dmc2 = new Data_Security_Matrix__c (
			Profile_Name__c = userProfile.name,
			Section_Name__c = SECTION_ACC2,
			Access_Type__c = 'No Access'
			);

		Data_Security_Matrix__c  dmc3 = new Data_Security_Matrix__c (
			Profile_Name__c = userProfile.name,
			Section_Name__c = SECTION_ACC3,
			Access_Type__c = 'Authorize Only'
			);

		

		dscList.add(dmc1);
		dscList.add(dmc2);
		dscList.add(dmc3);
		
		insert dscList;
	}
    
    @isTest 
    static void LoadData_Test_All() 
    {
    	User u = [SELECT id,ProfileId From User where Email = 'OwnerIDtest@tmbbank.com'];
    	Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:u.ProfileId LIMIT 1];

    	Account account = [SELECT id FROM Account WHERE RTL_Email_2__c = 'test01@tmbbank.com'];

    	Id accountId = account.id;

    	system.runAs(u)
    	{
            PageReference pr = Page.CustomerInformationSensitiveData;
            pr.getParameters().put('sectionName',SECTION_ACC);
            pr.getParameters().put('sectionName2',SECTION_ACC2);
            //pr.getParameters().put('hiddenText','aaaaa');
            Test.setCurrentPageReference(pr);

            
            apexpages.StandardController sc = new apexpages.StandardController(account);
            AccountDataPartitionExtension adpe = new AccountDataPartitionExtension(sc);

           	string hiddenText = adpe.hiddenText;
           	Boolean isSF1 = adpe.isSF1;

            adpe.loadData();
			//Boolean isAccessibleCampHist = RTL_AccountUtility.verifyFieldSecurity(SECTION_ACC,userProfile.name,accountId );
		}
    }

   

}