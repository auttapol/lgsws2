@isTest
public class RTL_AL_NotificationToOwnerTest {
    static {
        TestUtils.createAppConfig();

        Id ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User User = new User(FirstName='Test',LastName='Test', 
                                    UserName='TestTMB@tmb.com',
                                    Email='Test@tmbbank.com', Alias='Test',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='TestNickname',
                                    ProfileId = ADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='11111');
        insert User;
        
        Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
        system.debug(recordTypeId);
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = recordTypeId;
        insert camp;
        
        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l.RTL_Branch_Code_Rpt__c = '611';
        insert l;

        Campaignmember cm = new Campaignmember();
        // cm.RTL_Contact_Method__c = 'AL Sales';
        cm.CampaignId = camp.Id;
        cm.LeadId = l.Id;
        cm.RTL_Assigned_Agent__c = User.Id;
        insert cm;
    }
    @isTest
    static void testRTL_AL_NotificationToOwner() {

        Test.startTest();
        CampaignMember campaignmember = [SELECT Id,Name,CampaignId,Campaign.Name,RTL_CampHis_Phone__c,RTL_AL_car_brand__c,RTL_AL_car_subtype__c,RTL_AL_car_year__c,RTL_AL_car_plate_no__c,RTL_AL_max_set_up_amount__c,RTL_AL_CAMP_EXP_DTE__c,RTL_AL_wanted_amount__c,RTL_AL_installment_periods__c,RTL_AL_installment_amount__c,RTL_Assigned_Agent__c,RTL_Contact_Staff_Name__c,RTL_Assigned_Agent__r.Email,RTL_Assigned_Agent__r.Name,RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Email,RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Name,LeadOrContactOwner.Name FROM CampaignMember LIMIT 1];
        RTL_AL_NotificationToOwner notification = new RTL_AL_NotificationToOwner(campaignmember);
        notification.run();
        Test.stopTest();
        
    }
    
}