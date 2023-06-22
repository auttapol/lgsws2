@isTest
public with sharing class RTL_CampaignChangeStatusConfirmCtrlTest {
    static {
        TestUtils.createAppConfig();
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
        List<Account> accList = RTL_TestUtility.createAccounts(1,true);
        
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
        camp.RTL_Campaign_Stage__c = 'New';
        insert camp;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = leads.get(0).id;
        cm1.CampaignId = camp.id;
        cm1.RTL_TMB_Campaign_Source__c = 'web';     
        cm1.RTL_Contact_Status__c = 'Contact';
        cm1.RTL_Product_Group_1__c = 'Bancassurance';
        cm1.RTL_OfferResult_Product_1__c = 'Interested';
        //cm1.RTL_RelatedOpportunity_1__c = oppList.get(0).Id;
        insert cm1;
        
        Test.startTest();
        System.currentPageReference().getParameters().put('activity','cancel');
        System.currentPageReference().getParameters().put('id',camp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(camp);
        RTL_CampaignChangeStatusConfirmCtrl camPage = new RTL_CampaignChangeStatusConfirmCtrl(sc);       
        
        camPage.setupMessageShowPage('hold');
        camPage.getRecordTypeName();
        camPage.save();               

        System.currentPageReference().getParameters().put('activity','unhold');
        sc = new ApexPages.StandardController(camp);
        camPage = new RTL_CampaignChangeStatusConfirmCtrl(sc);       
        camPage.save();  
        
        
        System.currentPageReference().getParameters().put('activity','hold');
        sc = new ApexPages.StandardController(camp);
        camPage = new RTL_CampaignChangeStatusConfirmCtrl(sc);       
        camPage.setupMessageShowPage('cancel');
        camPage.isCancelStatus = true;
        camPage.save();  

        camPage.cancel();
        
        Test.stopTest();  
    }          
}