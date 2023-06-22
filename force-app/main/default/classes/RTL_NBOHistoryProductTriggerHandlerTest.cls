@isTest
public with sharing class RTL_NBOHistoryProductTriggerHandlerTest {
    static {
        TestUtils.createAppConfig();  
        
        //Add for Test NBO to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
        
        RTL_TestUtility2.createOpportunityRecordTypeMapping();
    }  
    
    public static testMethod void positive() {     
         Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;

        RTL_Campaign_Running_No__c rn = new RTL_Campaign_Running_No__c( 
            Name ='Local Exclusive Campaign Running No.' , 
            DateValue__c='170717',
            Day__c='17',
            Month__c='07',
            Year__c='17',
            Running_No__c = '01' );
        insert rn;
        
        RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
            Name = 'Campaign Member Running No',
            Running_No__c = '000000'
        );
        
        insert cmrn;
        
        List<Lead> leads = new List<Lead>();
        
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel
        
        List<Account> accList = RTL_TestUtility.createAccounts(1,true);
        Contact con = new Contact(LastName = 'test contact' ,AccountId = accList.get(0).id,TMB_Customer_ID__c= accList.get(0).Id,
                                  Photo__c = '<img alt="User-added image" src="test"></img>');
        insert con;
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        System.runAs(retailUser) {
        	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailUser.Id);
        }
        System.runAs(retailUser) {
            opportunityList = RTL_TestUtility.createOpportunity(accList,true);
        	leads = RTL_TestUtility.createLeads(2,true);
        }
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        camp.RTL_Campaign_Stage__c = 'New';
        camp.Status = 'Open';
        camp.Approvedflag__c = true;
        insert camp;
        
        RTL_TestUtility.createRetailMasterProducts(true);
        RTL_product_master__c product = new RTL_product_master__c(Name='test product1', Product_Group__c='Credit Card & RDC', Product_Sub_group__c='Credit Cards',Active__c=true);
        insert product;

        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = leads.get(0).id;
        cm1.CampaignId = camp.id;
        cm1.ContactId = con.Id;
        
        cm1.RTL_Contact_Status__c = 'Contact';
        
        cm1.RTL_OfferResult_Product_1__c = 'Interested';
        cm1.RTL_Campaign_Product_1__c = product.Id;
        cm1.RTL_Sub_Group_1__c = 'Credit Cards';
        cm1.RTL_Product_Group_1__c = 'Credit Card & RDC';
        
        cm1.RTL_OfferResult_Product_2__c = 'Interested';
        cm1.RTL_Campaign_Product_2__c = product.Id;
        cm1.RTL_Sub_Group_2__c = 'Credit Cards';
        cm1.RTL_Product_Group_2__c = 'Credit Card & RDC';
        
        
        insert cm1;
        
        
        Test.startTest();

        Integer size = 10;
        String externalAccctId = accList.get(0).Id;
        Boolean doInsert = true;
        List<RTL_NBO_History__c> nboHistoryList = new List<RTL_NBO_History__c>();
        List<RTL_NBO_History_Product__c> nboHistoryProductList = new List<RTL_NBO_History_Product__c>();
        RTL_NBO_History__c nboHistory = null;
        RTL_NBO_History_Product__c nbohistoryproduct = null;
        for(Integer i = 0; i<size;i++){
            nboHistory = new RTL_NBO_History__c();
            nboHistory.RTL_Campaign_Name__c = 'NBO test' + i;
            nboHistory.RTL_NBO_ID__c = '001p000000CKy8AAD' + i;
            nboHistory.RTL_TMB_Customer_ID_PE__c = externalAccctId;
            nboHistory.RTL_NBO_Group__c = 'DEPOSIT';
            nboHistory.RTL_NBO_SubGroup__c = 'TRANSACTIONAL';
            nboHistory.RTL_Campaign_Code__c = '001p000000CKy8AAD' + i;
            nboHistory.RTL_Valid_From__c = Date.today();
            nboHistory.RTL_Valid_To__c = Date.today().addDays(30);
            nboHistory.RTL_Smart_Info__c = 'http://nbo_smart_info';
            nboHistory.RTL_Channel__c = 'Branch';
            nboHistory.RTL_Contact_Date__c = Date.today().addDays(10);
            nboHistory.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now();
            nboHistory.RTL_Product_Branch_Latest_Modified_Date__c = DateTime.now(); 
            nboHistory.RTL_Campaign__c = camp.Id;
            nboHistoryList.add(nboHistory);
        }
        if(doInsert){
            insert nboHistoryList;
        }
        RTL_NBO_History__c nboHis = null;
        nboHistoryList = [select RTL_NBO_ID__c from RTL_NBO_History__c where RTL_NBO_ID__c like '001p000000CKy8AAD%'];
        for(Integer i = 0; i<size;i++) {
            nboHis = nboHistoryList.get(i);
            nbohistoryproduct = new RTL_NBO_History_Product__c();
            nbohistoryproduct.RTL_Related_NBO__c = nboHis.Id;          
            nbohistoryproduct.RTL_NBO_ID__c = nboHis.RTL_NBO_ID__c;
            nbohistoryproduct.RTL_Product_Group__c = 'Deposit';
            if (i == 1)  nbohistoryproduct.RTL_Product_SubGroup__c = 'Deposit TestSubgroup';
            if (i == 2) nbohistoryproduct.RTL_Product__c = 'Deposit Product';
            nbohistoryproduct.RTL_NBO_Product_External_ID__c = nboHis.RTL_NBO_ID__c + i;
            nbohistoryproduct.RTL_Offering_Channel__c = 'Branch';
            nbohistoryproduct.RTL_Product__c = 'test product1';
            nbohistoryproduct.RTL_Status__c = 'New';
            nboHistoryProductList.add(nbohistoryproduct);
        }
        if(doInsert){
            insert nboHistoryProductList;
        }        
        
        
        RTL_NBO_History_Product__c nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[2].RTL_NBO_ID__c LIMIT 1];
        nboProduct.RTL_Product__c = 'test product1';
        nboProduct.RTL_Product_Group__c = 'Credit Card & RDC';
        nboProduct.RTL_Product_SubGroup__c = 'Credit Cards';
        nboProduct.RTL_Status__c = 'New';
        nboProduct.RTL_Opportunity__c = opportunityList.get(0).Id;
        update nboProduct;
        
        nboProduct.RTL_Product__c = null;
        update nboProduct;
        
        nboProduct.RTL_Status__c = 'New';
        nboProduct.RTL_Product_SubGroup__c = null;        
        update nboProduct;
        
        nboProduct.RTL_Status__c = 'Pending';  
        update nboProduct;
        
        nboProduct.RTL_Status__c = 'Accepted';
        update nboProduct;

        
        RTL_NBOHistoryProductTriggerHandler.offerResultStatus('Accepted');
        RTL_NBOHistoryProductTriggerHandler.offerResultStatus('Rejected');
        RTL_NBOHistoryProductTriggerHandler.offerResultStatus('Pending');
        RTL_NBOHistoryProductTriggerHandler.offerResultStatus('New');
        
        RTL_NBOHistoryProductTriggerHandler.checkNBOStatusWithCampaignMember('Interested');
        RTL_NBOHistoryProductTriggerHandler.checkNBOStatusWithCampaignMember('Not Interested');
        RTL_NBOHistoryProductTriggerHandler.checkNBOStatusWithCampaignMember(null);
        
        Test.stopTest();  
    }          
}