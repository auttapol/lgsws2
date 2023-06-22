@isTest
public class LeadLightningExtensionTest {
    static List<RTL_Referral__c> referralList2;
    static List<Account> acctList;
    static {
        TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createDateOfBirth();
        TestUtils.CreateProceBookAccess();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
    }
    @testSetup static void setup() {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        
        User testuser = userTest();
        List<User> user = new List<User>();
        user.add(testuser);
        insert user;

        System.runAs(testuser){
            Account acc = new Account (Name='TestAcc',Mobile_Number_PE__c ='0987654321' ,ID_Type_PE__c='Citizen ID',ID_Number_PE__c='8551589046855');
            insert acc;
           
            Lead testLead = CreateValidLead(testuser.id,acc.id);
            insert testLead;
        }
    }
    
    
    
    public static RecordType CommercialLeadRecordType {
        get{
            if(CommercialLeadRecordType ==null){
                CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                        WHERE Name='Commercial Lead' 
                                        AND sObjectType='Lead' LIMIT 1];
            }
            return CommercialLeadRecordType;
        }
        set;
    }

    public static Lead CreateValidLead(Id OwnerID,Id accId){
        Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = OwnerID;
        leadRec.Account__c = accId;
        return leadRec;
    }

    public static Lead CreateValidLeadNoAcc(Id OwnerID){
        Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = OwnerID;
        
        return leadRec;
    }

        @isTest 
        static void createMethodTest() {
            User testuser1 = [Select Id FROM User WHERE user.Username = 'test@tmbbank.com' ];
            Lead testLead1 = [Select Id,Customer_Type__c,ID_Type__c,ID_Number__c,Parent_Company__c,
                                RecordTypeId,RTL_Referral__c,Account__c,isBypassDuplicateCheck__c,Exception_Flag__c,OwnerId
                                FROM Lead LIMIT 1 ];
            //referralList = TestUtility_Referral.createReferralsWithoutAccount(2,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            //testLead1.RTL_Referral__c = referralList[0].id;
            testLead1.Account__c =null;
            System.runAs(testuser1){
                test.startTest();
                
                RecordType CompletedRecordType = LeadLightningExtension.CompletedRecordType;
                RecordType AccountRecordType = LeadLightningExtension.AccountRecordType;
                RecordType CommercialLeadType = LeadLightningExtension.CommercialLeadType;
                Boolean isFindDuplicate = LeadLightningExtension.isFindDuplicate;
                string afterId = LeadLightningExtension.afterId;
                string beforeId = LeadLightningExtension.beforeId;
                //LeadLightningExtension.getLeadRecordByFields(testLead1,testLead1.Id);
                
                LeadLightningExtension.getLeadRecord(testLead1.Id);
                LeadLightningExtension.getRecordTypeName(testLead1.RecordTypeId);
                //LeadLightningExtension.checkReferralCondition(testLead1,testLead1);
                LeadLightningExtension.getErrorMessage();
                LeadLightningExtension.getReferralErrorMessage();
                LeadLightningExtension.getBypassDuplicateCheck();
                LeadLightningExtension.getLeadCreateRecordByFields(testLead1);

                test.stopTest();
            }
        }

        @isTest 
        static void editMethodTestNoID() {
            User testuser1 = [Select Id FROM User WHERE user.Username = 'test@tmbbank.com' ];
            Lead testLead1 = [Select Id,Customer_Type__c,ID_Type__c,ID_Number__c,Parent_Company__c,RecordTypeId,RTL_Referral__c,isBypassDuplicateCheck__c,Account__c,Exception_Flag__c,OwnerId FROM Lead LIMIT 1 ];
            Lead testLead2 = testLead1.clone(true,true,true,true);
            testLead2.ID_Type__c='Citizen ID';
            testLead2.ID_Number__c='5511773508161';
            System.runAs(testuser1){
                test.startTest();
                LeadLightningExtension.getLeadRecordByFields(testLead2,testLead1.Id);
                test.stopTest();                
            }
        }
        @isTest 
        static void editMethodTest() {
            User testuser1 = [Select Id FROM User WHERE user.Username = 'test@tmbbank.com' ];
            Lead testLead1 = [Select Id,Customer_Type__c,ID_Type__c,ID_Number__c,Parent_Company__c,RecordTypeId,isBypassDuplicateCheck__c FROM Lead LIMIT 1 ];
            System.runAs(testuser1){
                test.startTest();

                LeadLightningExtension.afterEditLead = testLead1;
                LeadLightningExtension.beforeEditLead = testLead1;
                LeadLightningExtension.afterEditLead.ID_Type__c = 'Citizen ID';
                LeadLightningExtension.beforeEditLead.ID_Number__c = '5511773508161';
                String displayAction = LeadLightningExtension.displayAction;
                displayAction ='Update';
                LeadLightningExtension.checkCondition();
                test.stopTest();                
            }

        }
        @isTest 
        static void createMethodTestNoDuplicate() {
            User testuser1 = [Select Id FROM User WHERE user.Username = 'test@tmbbank.com' ];
            Lead testLead1 = [Select Id,Customer_Type__c,ID_Type__c,ID_Number__c,Parent_Company__c,
            RecordTypeId,RTL_Referral__c,Account__c,isBypassDuplicateCheck__c,Exception_Flag__c,OwnerId
            FROM Lead LIMIT 1 ];
            List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
            Lead Lead1 = CreateValidLeadNoAcc(usList.get(0).id);
            //referralList = TestUtility_Referral.createReferralsWithoutAccount(2,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            //testLead1.RTL_Referral__c = referralList[0].id;
            System.runAs(testuser1){
                test.startTest();
                
                RecordType CompletedRecordType = LeadLightningExtension.CompletedRecordType;
                RecordType AccountRecordType = LeadLightningExtension.AccountRecordType;
                RecordType CommercialLeadType = LeadLightningExtension.CommercialLeadType;
                Boolean isFindDuplicate = LeadLightningExtension.isFindDuplicate;
                string afterId = LeadLightningExtension.afterId;
                string beforeId = LeadLightningExtension.beforeId;
                LeadLightningExtension.getLeadCreateRecordByFields(Lead1);
                LeadLightningExtension.getLeadRecordByFields(testLead1,testLead1.Id);
                LeadLightningExtension.getLeadRecord(testLead1.Id);
                LeadLightningExtension.getRecordTypeName(testLead1.RecordTypeId);
                //LeadLightningExtension.checkReferralCondition(testLead1,testLead1);
                LeadLightningExtension.getErrorMessage();
                LeadLightningExtension.getReferralErrorMessage();
                LeadLightningExtension.getBypassDuplicateCheck();
                

                test.stopTest();
            }
        }


        //referral test//
        @isTest 
        static void leadWithReferral() {
            List<Branch_And_Zone__c> branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
            List<RTL_Referral__c> referralList = TestUtility_Referral.createReferralsWithoutAccount(2,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
            Lead Lead1 = CreateValidLeadNoAcc(usList.get(0).id);
            Lead Lead2 = CreateValidLeadNoAcc(usList.get(0).id);
            Lead1.RTL_Referral__c=referralList[0].id;
            Lead2.RTL_Referral__c=referralList[1].id;
            test.startTest();
            LeadLightningExtension.afterEditLead = Lead1;
            LeadLightningExtension.beforeEditLead = Lead2;
            LeadLightningExtension.displayAction ='Create';
            LeadLightningExtension.checkCondition();
            LeadLightningExtension.checkReferralCondition(Lead1,Lead2);
            LeadLightningExtension.getReferralErrorMessage();
            RTL_Referral__c referral = LeadLightningExtension.populateReferralInfo(referralList[0].id);
            test.stopTest();
        }

        @isTest 
        static void leadWithReferralClosed() {
            List<Branch_And_Zone__c> branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
            List<RTL_Referral__c> referralList = TestUtility_Referral.createReferralsWithoutAccount(2,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
            Lead Lead1 = CreateValidLeadNoAcc(usList.get(0).id);
            Lead Lead2 = CreateValidLeadNoAcc(usList.get(0).id);
            Lead testLead1 = [Select Id,Customer_Type__c,ID_Type__c,ID_Number__c,Parent_Company__c,RecordTypeId,RTL_Referral__c,isBypassDuplicateCheck__c,Account__c,OwnerId FROM Lead LIMIT 1 ];
            referralList[0].RTL_Stage__c = 'Closed (Unable to contact)';
            referralList[0].RTL_Reason__c = 'Busy Line';
            update referralList;
            testLead1.RTL_Referral__c = referralList[0].id;
            Lead1.RTL_Referral__c=referralList[0].id;
            Lead2.RTL_Referral__c=referralList[1].id;

            test.startTest();
            LeadLightningExtension.afterEditLead = Lead1;
            LeadLightningExtension.beforeEditLead = Lead2;
            LeadLightningExtension.displayAction ='Create';
            LeadLightningExtension.checkCondition();
            LeadLightningExtension.checkReferralCondition(Lead1,Lead2);
            LeadLightningExtension.checkReferralCondition(testLead1,testLead1);
            LeadLightningExtension.getReferralErrorMessage();
            test.stopTest();
        }
        @isTest
        public static void testCreateLeadWithReferralWithAccount(){
            Account testAccount = [Select Id From Account LIMIT 1];
            List<Branch_And_Zone__c> branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
            List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
            List<RTL_Referral__c> referralList = TestUtility_Referral.createReferralsWithoutAccount(2,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            referralList[0].RTL_Account_Name__c = testAccount.id;
            Lead Lead1 = CreateValidLeadNoAcc(usList.get(0).id);
            Lead Lead2 = CreateValidLeadNoAcc(usList.get(0).id);
            Lead1.RTL_Referral__c=referralList[0].id;
            Lead2.RTL_Referral__c=referralList[0].id;

            test.startTest();
            LeadLightningExtension.afterEditLead = Lead1;
            LeadLightningExtension.beforeEditLead = Lead2;
            LeadLightningExtension.displayAction ='Create';
            LeadLightningExtension.checkCondition();
            LeadLightningExtension.checkReferralCondition(Lead1,Lead2);
            LeadLightningExtension.getReferralErrorMessage();
            test.stopTest();
        
        }
        @isTest
        public static void testhelpermethod(){
            User testuser1 = [Select Id FROM User WHERE user.Username = 'test@tmbbank.com' ];
            Lead testLead1 = [Select Id,Customer_Type__c,ID_Type__c,ID_Number__c,Parent_Company__c,RecordTypeId,RTL_Referral__c,isBypassDuplicateCheck__c,Account__c,Exception_Flag__c,OwnerId FROM Lead LIMIT 1 ];
            Lead testLead2 = testLead1.clone(true,true,true,true);
            System.runAs(testuser1){
                test.startTest();
                LeadLightningExtension.completeBypass(testLead1.Id);
                LeadLightningExtension.checkAccess(testLead1.Id);
                test.stopTest();                
            }
        }

        public static User userTest(){
            Profile testprofile = [SELECT Id, Name FROM Profile Where Name ='System Administrator' LIMIT 1];
            User user = new User();
            user.Username = 'test@tmbbank.com';
            user.LastName ='test';
            user.Email ='test@tmbbank.com';
            user.Alias ='test';
            user.TimeZoneSidKey ='Asia/Bangkok';
            user.LocaleSidKey ='th_TH';
            user.EmailEncodingKey ='UTF-8';
            user.ProfileId = testprofile.Id;
            user.LanguageLocaleKey ='en_US';
            user.Employee_ID__c = '177777';
            return user ;
        }

}