@isTest
public with sharing class RTL_CampaignMemberTriggerHandlerTest {

    @testSetup static void setupData(){
        TestUtils.createAppConfig();

         //Add for Test campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();

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
        
        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        bz.isActive__c = true;
        insert bz;

         List<Lead> leads = new List<Lead>();
        
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel
        
        List<Account> accList = RTL_TestUtility.createAccounts(1,true);
        List<Opportunity> oppList = new List<Opportunity>();
        
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            RTL_TestUtility.createRetailMasterProducts(true);
            leads = RTL_TestUtility.createLeads(2,true);
            RTL_TestUtility.createInterestedProducts(leads, true);
            
            RTL_Interested_products_c__c nonPrimaryProduct = [select Is_Primary__c from RTL_Interested_products_c__c where Lead__c = :leads.get(0).Id and Is_Primary__c = false];
            nonPrimaryProduct.Is_Primary__c = true;
            //check result: the update should be failed because no more than one primary interested product is allowed
            boolean errMsgMatch = false;
            try {
                update nonPrimaryProduct;
            } catch (Exception ex) {
                
            }   
        }
        System.runAs(firstUser) {
            insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=firstUser.Id);
        }
        System.runAs(firstUser) {
            oppList = RTL_TestUtility.createOpportunity(accList,true);
        }
        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l.RTL_Branch_Code_Rpt__c = '611';
        insert l;
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;
        

        List<CampaignMember> cmList = new List<CampaignMember>();
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = camp.id;
        cm1.RTL_TMB_Campaign_Source__c = 'Web';     
        cm1.RTL_Product_Name__c = 'product';
        cm1.RTL_Lead_Group__c =  'group';
        cm1.RTL_OfferResult_Product_1__c = 'N/A';
        cmList.add(cm1);
        
        Contact ct = RTL_TestUtility.createContacts(accList.get(0));
        ct.OwnerId = firstUser.id;
        insert ct;

        CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = ct.id;
        cm2.CampaignId = camp.id;
        cm2.RTL_TMB_Campaign_Source__c = 'Web';     
        cm2.RTL_Product_Name__c = 'product';
        cm2.RTL_Lead_Group__c =  'group';
        cm2.RTL_OfferResult_Product_1__c = 'N/A';
        cmList.add(cm2);

        insert cmList;

        for( CampaignMember cm : cmList )
        {
            cm.RTL_Lead_Group__c =  'grouplead';
        }
        update cmList;




        
                        
        RTL_Campaign_Assignment_Rule__c obj = new RTL_Campaign_Assignment_Rule__c();
        obj.RTL_Campaign_Lead_Source__c = 'Web';
        obj.RTL_Start_Date__c = System.today()-10;
        obj.RTL_End_Date__c = System.today()+10;
        obj.RTL_Active__c = true;
        insert obj;

    }
    
    public static testMethod void positive() {     

        Test.startTest();

        Lead l = [SELECT id,Company,LastName,Status,RTL_W2L_Calculated_Amount__c,RTL_INTERESTS__c,RTL_W2L_Calculated_Loan_Period__c,
                RTL_W2L_Calculated_No_of_Installments__c,RTL_W2L_Has_Co_Borrower__c
                FROM LEAD WHERE  LastName = 'Mike' ];

        RTL_CampaignMemberTriggerHandler.settingValueTranformation('xxxxxxxxxxxxxxx');
        RTL_CampaignMemberTriggerHandler.concatProductFeatures(l);
        RTL_CampaignMemberTriggerHandler.checkNBOStatusWithCampaignMember(null);
        RTL_CampaignMemberTriggerHandler.checkNBOStatusWithCampaignMember('Interested');
        RTL_CampaignMemberTriggerHandler.checkNBOStatusWithCampaignMember('Not Interested');
        RTL_CampaignMemberTriggerHandler.checkNBOStatusWithCampaignMember('N/A');
        
        Map<String, String> fieldLabelMap = RTL_CampaignMemberTriggerHandler.fieldLabelMap;
        //Map<ID, String> contactNameMap = RTL_CampaignMemberTriggerHandler.contactNameMap;

        List<RTL_Channel_Code_Mapping__mdt> channelCodeMapping = [SELECT Id, RTL_Lead_Group__c, 
                                  RTL_Campaign_Lead_Source__c, 
                                  RTL_Channel_Code__c, 
                                  RTL_Campaign_Reference__c, 
                                  DeveloperName, 
                                  MasterLabel, Label 
                                  FROM RTL_Channel_Code_Mapping__mdt];

        List<CampaignMember> cmList = new List<CampaignMember>();
        for( CampaignMember campaignMemberObj : [SELECT id,RTL_Register_Date__c,RTL_Product_Name__c,
                                        RTL_Lead_Group__c,RTL_TMB_Campaign_Source__c,RTL_Product_Feature__c,RTL_Reason_1__c
                                        FROM CampaignMember] 
        ) {
            campaignMemberObj.RTL_OfferResult_Product_1__c = 'Interested';
            cmList.add(campaignMemberObj);
            RTL_CampaignMemberTriggerHandler.concatRemark(channelCodeMapping,campaignMemberObj, null);
        }

        update cmList; 
        //RTL_Reason_1__c

        Test.stopTest();  
    }          

    public static testMethod void afterUpdate() {     
        Test.startTest();
            
            CampaignMember cm1 = [SELECT id,RTL_Contact_Status__c,RTL_Assigned_Agent__c,RTL_Assigned_Branch__c
                FROM CampaignMember LIMIT 1];

            User firstUser = [SELECT id FROM User WHERE Email='standarduser-ii@tmbbank.com' ];
            Branch_and_zone__c bz = [SELECT id from Branch_and_zone__c WHERE Branch_Code__c = '611'];

            cm1.RTL_Contact_Status__c = 'Contact';
            cm1.RTL_Assigned_Agent__c = firstUser.id;
            cm1.RTL_Assigned_Branch__c = bz.id;
            update cm1;

            cm1.RTL_Contact_Staff_Name__c = firstUser.id;
            update cm1;
        

        Test.stopTest();
        
    }
    
    public static testMethod void afterUpdate_updateStatusNBOProduct() {   
        
        system.debug('start afterUpdate_updateStatusNBOProduct');
        Test.startTest();
        
        CampaignMember cm1 = [SELECT id,CampaignId,RTL_Contact_Status__c,RTL_Assigned_Agent__c,RTL_Assigned_Branch__c
                FROM CampaignMember LIMIT 1];
        
        List<RTL_product_master__c> productList = new List<RTL_product_master__c>();
        
        RTL_product_master__c product = new RTL_product_master__c(Name='So Smart Test', Product_Group__c='Credit Card & RDC', Product_Sub_group__c='Credit Cards',Active__c=true);
       
        productList.add(product);
        
        RTL_product_master__c product2 = new RTL_product_master__c(Name='Deposit Test', Product_Group__c='Deposit', Product_Sub_group__c='TRANSACTIONAL',Active__c=true);
        productList.add(product2);

        insert productList;
        
        Account acc1 = [Select id from Account limit 1];
        cm1.Customer__c = acc1.id;
        cm1.RTL_Product_Group_1__c = 'Credit Card & RDC';
        cm1.RTL_Sub_Group_1__c = 'Credit Cards';
        cm1.RTL_Campaign_Product_1__c = product.id;
        cm1.RTL_OfferResult_Product_1__c = 'Interested';
        
        cm1.RTL_Product_Group_2__c = 'Deposit';
        cm1.RTL_Sub_Group_2__c = 'TRANSACTIONAL';
        cm1.RTL_Campaign_Product_2__c = product2.id;
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        
        update cm1;
        
        
        Integer size = 10;
        String externalAccctId = acc1.id;
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
           	nboHistory.RTL_Customer_Name__c = acc1.id;
       		nboHistory.RTL_Campaign__c = cm1.CampaignId;
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
            nbohistoryproduct.RTL_Product_Group__c = 'Credit Card & RDC';
            if (i == 1)  nbohistoryproduct.RTL_Product_SubGroup__c = 'Credit Cards';
            if (i == 2) nbohistoryproduct.RTL_Product__c = 'So Smart Test';
            nbohistoryproduct.RTL_NBO_Product_External_ID__c = nboHis.RTL_NBO_ID__c + i;
            nbohistoryproduct.RTL_Offering_Channel__c = 'Branch';
            nbohistoryproduct.RTL_Product__c = 'So Smart Test';
            nbohistoryproduct.RTL_Status__c = 'New';
            nboHistoryProductList.add(nbohistoryproduct);
        }
        if(doInsert){
            insert nboHistoryProductList;
        }        
        
        
        RTL_NBO_History_Product__c nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[2].RTL_NBO_ID__c LIMIT 2];
        nboProduct.RTL_Product__c = null;
        nboProduct.RTL_Status__c = 'Pending';
        update nboProduct;
        
        nboProduct.RTL_Product_SubGroup__c = null;
        nboProduct.RTL_Status__c = 'Pending';
        update nboProduct;
       
        
        cm1.RTL_OfferResult_Product_2__c = 'Interested';
        update cm1;
        
        Test.stopTest();
        
        system.debug('end afterUpdate_updateStatusNBOProduct');
        
    }

    public static testMethod void afterInsertDroplead() {   
        

        Test.startTest();
        
        Campaign camp = [SELECT id FROM Campaign WHERE name = 'Campaign_'];
        User firstUser = [SELECT id FROM User WHERE Email='standarduser-ii@tmbbank.com' ];

            Lead l = new Lead(Company = 'JohnMiller2', LastName = 'Mike2', Status = 'Open');
            l.RTL_Branch_Code_Rpt__c = '611';
            l.RTL_TMB_Campaign_Source__c = 'web';
            l.OwnerId = firstUser.id;
            insert l;

            CampaignMember cm2 = new CampaignMember();
            cm2.LeadId = l.id;
            cm2.CampaignId = camp.id;
            cm2.RTL_TMB_Campaign_Source__c = 'Web';     
            cm2.RTL_Product_Name__c = 'product';
            cm2.RTL_Lead_Group__c =  'group';
            cm2.RTL_Product_Name__c = '1:MM';
            insert cm2;
        
                    
        Test.stopTest();
    }
 
}