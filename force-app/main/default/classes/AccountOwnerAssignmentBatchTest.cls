@isTest
public class AccountOwnerAssignmentBatchTest {
    // public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    // public static final Id RPSPEC_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Commercial Report Specialist Profile' LIMIT 1].Id;
    // public static final Id TH_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Team Head Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
    // public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;

    static{
        TestUtils.createAppConfig();
        // TestUtils.createAccounts(1, 'name', 'Qualified Prospect', true);

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Zone_Code_SE__c = '9999';
        bz.Branch_Code__c = '001';
        insert bz;

        List<User> userlst = new List<User>();

        AppConfig__c ac = AppConfig__c.getValues('sfadm Account Name');

        User User01 = RTL_TestUtility.createUsers(1, 'testuser1', 'testuser2', 'sfadm@tmbbank.com', false).get(0);
        User01.FirstName = 'sfadm'; 
        User01.LastName = 'System Account';
		User01.ProfileId = SEZM_PROFILE_ID;
		User01.isActive = true;
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '111111';
		User01.Zone__c = 'SE-ChiangMai';
		User01.Zone_Code__c = '9999';
		User01.Region__c = 'SE1-North1';
		User01.Region_Code__c = '1111';
        User01.Segment__c = 'SE';
        userlst.add(User01);

        insert userlst;

        List<Account> existingAccts = TestUtils.createAccounts(3, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = User01.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'SE'; 
        existingAccts.get(0).RTL_Created_Branch__c = bz.Id;

        existingAccts.get(1).OwnerId = User01.Id;
        existingAccts.get(1).Account_Type__c = 'Existing Customer';
        existingAccts.get(1).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(1).Stamp_Owner_Region_Code_Group_Code__c = '2222';
        existingAccts.get(1).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(1).Stamp_Owner_Zone_Code_Team_C__c = '99998';
        existingAccts.get(1).Stamp_Owner_Segment__c = 'SE';
        existingAccts.get(1).RTL_Created_Branch__c = bz.Id;
        
        existingAccts.get(2).OwnerId = User01.Id;
        existingAccts.get(2).Account_Type__c = 'Existing Customer';
        existingAccts.get(2).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(2).Stamp_Owner_Region_Code_Group_Code__c = '22222';
        existingAccts.get(2).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(2).Stamp_Owner_Zone_Code_Team_C__c = '99998';
        existingAccts.get(2).Stamp_Owner_Segment__c = 'SE';
        existingAccts.get(2).RTL_Created_Branch__c = bz.Id;

        insert existingAccts;
		
        List<Owner_Assignment_Rule__c> ownerAssignRulelst = new List<Owner_Assignment_Rule__c>();
        
        Owner_Assignment_Rule__c ownerAssignRule = new Owner_Assignment_Rule__c();
        ownerAssignRule.Active_Flag__c = true;
        ownerAssignRule.Assigned_Object__c = 'Account';
        ownerAssignRule.Entry_Criteria_Field_1__c = 'Stamp_Owner_Segment__c';
        ownerAssignRule.Entry_Criteria_Field_2__c = 'Stamp_Owner_Region_Group__c';
        ownerAssignRule.Entry_Criteria_Field_3__c = 'Stamp_Owner_Region_Code_Group_Code__c';
        ownerAssignRule.Entry_Criteria_Field_4__c = 'Stamp_Owner_Zone_Team__c';
        ownerAssignRule.Entry_Criteria_Field_5__c = 'Stamp_Owner_Zone_Code_Team_C__c';
        ownerAssignRule.Criteria_Field_Value_1__c = 'SE';
        ownerAssignRule.Criteria_Field_Value_2__c = 'SE1-North1';
        ownerAssignRule.Criteria_Field_Value_3__c = '1111';
        ownerAssignRule.Criteria_Field_Value_4__c = 'SE-ChiangMai';
        ownerAssignRule.Criteria_Field_Value_5__c = '9999';
        ownerAssignRule.Destination_Field__c = 'Owner';
        ownerAssignRule.Mapped_to_field__c = 'ID';
        ownerAssignRule.Mapped_to_table__c = 'Branch_and_Zone__c';
        ownerAssignRule.Object_field_to_Map__c = 'RTL_Created_Branch__c';
        ownerAssignRule.Priority__c = 2;
        ownerAssignRule.Record_Type__c = 'Existing Customer';
        ownerAssignRule.Result_field__c = 'Zone_Code_SE__c';
        ownerAssignRule.User_mapping_condition__c = 'Zone_Code__c';
        ownerAssignRule.User_mapping_profile__c = 'TMB SE Zone Manager Profile';
        ownerAssignRulelst.add(ownerAssignRule);

        Owner_Assignment_Rule__c ownerAssignRule2 = new Owner_Assignment_Rule__c();
        ownerAssignRule2.Active_Flag__c = true;
        ownerAssignRule2.Assigned_Object__c = 'Account';
        ownerAssignRule2.Entry_Criteria_Field_1__c = 'Stamp_Owner_Segment__c';
        ownerAssignRule2.Entry_Criteria_Field_2__c = 'Stamp_Owner_Region_Group__c';
        ownerAssignRule2.Entry_Criteria_Field_3__c = 'Stamp_Owner_Region_Code_Group_Code__c';
        ownerAssignRule2.Entry_Criteria_Field_4__c = 'Stamp_Owner_Zone_Team__c';
        ownerAssignRule2.Entry_Criteria_Field_5__c = '';
        ownerAssignRule2.Criteria_Field_Value_1__c = 'SE';
        ownerAssignRule2.Criteria_Field_Value_2__c = 'SE1-North1';
        ownerAssignRule2.Criteria_Field_Value_3__c = '2222';
        ownerAssignRule2.Criteria_Field_Value_4__c = 'SE-ChiangMai';
        ownerAssignRule2.Criteria_Field_Value_5__c = '';
        ownerAssignRule2.Destination_Field__c = 'Owner';
        ownerAssignRule2.Mapped_to_field__c = 'ID';
        ownerAssignRule2.Mapped_to_table__c = 'Branch_and_Zone__c';
        ownerAssignRule2.Object_field_to_Map__c = 'RTL_Created_Branch__c';
        ownerAssignRule2.Priority__c = 1;
        ownerAssignRule2.Record_Type__c = 'Existing Customer';
        ownerAssignRule2.Result_field__c = 'Zone_Code_SE__c';
        ownerAssignRule2.User_mapping_condition__c = 'Zone_Code__c';
        ownerAssignRule2.User_mapping_profile__c = 'TMB SE Sales Management Profile';
        ownerAssignRulelst.add(ownerAssignRule2);

        Owner_Assignment_Rule__c ownerAssignRule3 = new Owner_Assignment_Rule__c();
        ownerAssignRule3.Active_Flag__c = true;
        ownerAssignRule3.Assigned_Object__c = 'Account';
        ownerAssignRule3.Entry_Criteria_Field_1__c = 'Stamp_Owner_Segment__c';
        ownerAssignRule3.Entry_Criteria_Field_2__c = 'Stamp_Owner_Region_Group__c';
        ownerAssignRule3.Entry_Criteria_Field_3__c = 'Stamp_Owner_Region_Code_Group_Code__c';
        ownerAssignRule3.Entry_Criteria_Field_4__c = 'Stamp_Owner_Zone_Team__c';
        ownerAssignRule3.Entry_Criteria_Field_5__c = '';
        ownerAssignRule3.Criteria_Field_Value_1__c = 'SE';
        ownerAssignRule3.Criteria_Field_Value_2__c = 'SE1-North1';
        ownerAssignRule3.Criteria_Field_Value_3__c = '3333';
        ownerAssignRule3.Criteria_Field_Value_4__c = 'SE-ChiangMai';
        ownerAssignRule3.Criteria_Field_Value_5__c = '';
        ownerAssignRule3.Destination_Field__c = 'Owner';
        ownerAssignRule3.Mapped_to_field__c = 'ID';
        ownerAssignRule3.Mapped_to_table__c = 'Branch_and_Zone__c';
        ownerAssignRule3.Object_field_to_Map__c = 'Business_Type_Code__c';
        ownerAssignRule3.Priority__c = 3;
        ownerAssignRule3.Record_Type__c = 'Existing Customer';
        ownerAssignRule3.Result_field__c = 'Zone_Code_SE__c';
        ownerAssignRule3.User_mapping_condition__c = 'Zone_Code__c';
        ownerAssignRule3.User_mapping_profile__c = 'TMB SE Sales Management Profile';
        ownerAssignRulelst.add(ownerAssignRule3);
        
        insert ownerAssignRulelst;
    }

    @isTest
    public static void testFlow() {

		Test.startTest();
        Database.executebatch(new AccountOwnerAssignmentBatch());
        Test.stopTest();
    }

    @isTest
    public static void testInsertAppconfig() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'sfadm Account Name';
        Aconfig.Value__c = 'sfadm System Account';        
        insert Aconfig;

		Test.startTest();
        Database.executebatch(new AccountOwnerAssignmentBatch());

        String jobId = System.schedule('test',  '0 0 0 15 3 ? *', new AccountOwnerAssignmentBatchScheduled());
        Test.stopTest();
    }
}