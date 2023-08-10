@isTest
public with sharing class RTL_CampaignMemberExtensionTest {
    static {
        TestUtils.createAppConfig();

        //Add for Test Campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
    }  
    
    public static testMethod void positive() {     
        //TestUtils.createForCXMToSales();
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
        
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = leads.get(0).id;
        cm1.CampaignId = camp.id;
        cm1.RTL_TMB_Campaign_Source__c = 'web';     
        cm1.RTL_Contact_Status__c = 'Contact';
        cm1.RTL_Product_Group_1__c = 'Bancassurance';
        cm1.RTL_OfferResult_Product_1__c = 'Interested';
        cm1.RTL_RelatedOpportunity_1__c = oppList.get(0).Id;
        insert cm1;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cm1);
        RTL_CampaignMemberExtension camPage = new RTL_CampaignMemberExtension(sc);       
        for( Integer i = 1 ; i <= 1 ; i++ ){
            camPage.createOppList.add( new RTL_CampaignMemberExtension.CampaignProductInterestedWrapper(i++,
                                                                            'RTL_Product_Group_'+i+'__c',
                                                                            'RTL_Sub_Group_'+i+'__c',
                                                                            'RTL_Campaign_Product_'+i+'__c',
                                                                            'RTL_Campaign_Product_'+i+'__r.Name',
                                                                            oppList.get(0),
                                                                            true,
                                                                            true,
                                                                            'RTL_Campaign_Product_'+i+'__r.Name'                            
                                                                           )  );
        }
        camPage.createInterestedProduct(leads.get(0));
        camPage.updateCampaignMember();
        camPage.getOpportunityList();
        //camPage.queryFulfillment('1','1');
        camPage.getNID('123');
        
        camPage.apexSave();
        camPage.redirectAfterSave();
        camPage.apexCreateOpportunity();
        camPage.requestCampaignData();
        camPage.processResponse();
        cm1.RTL_RelatedOpportunity_1__c = null;
        update cm1;
        camPage.nextPageCreateOpportunity();
        camPage.getCampaignProductInterested();
        camPage.runQuery();
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        // cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Contact_Status__c = 'New';
        cm1.RTL_Memo__c = 'test only';
        update cm1;
        camPage.apexSave();
        camPage.redirectAfterSave();
                
        
        camPage.backPageEditCampaignMember();
        camPage.nextPageViewOpportunity();
        camPage.defaultContactStatus();
        camPage.editCampaignMemberButton();
        camPage.closeWithSalesApp();
        camPage.canceltoview();
        camPage.getCampaignProduct();
        
        camPage.isCampaignActive = true;
        camPage.editCampaignMemberButton();
        

        Test.stopTest();  
    }          
}