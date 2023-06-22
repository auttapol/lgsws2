@isTest
public with sharing class RTL_CampaignAssignmentRuleTriggerTest {
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
        
        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert l;
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = camp.id;
        cm1.RTL_TMB_Campaign_Source__c = 'web';     
        insert cm1;
        
        Test.startTest();
                
        RTL_Campaign_Assignment_Rule__c obj = new RTL_Campaign_Assignment_Rule__c();
        obj.RTL_Campaign_Lead_Source__c = 'web';
        obj.RTL_Start_Date__c = System.today()-10;
        obj.RTL_End_Date__c = System.today()+10;
        obj.RTL_Active__c = true;
        insert obj;
        
        
        update obj;
        
        Test.stopTest();  
    }          
}