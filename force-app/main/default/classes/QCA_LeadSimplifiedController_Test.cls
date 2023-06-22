@isTest
public class QCA_LeadSimplifiedController_Test {
    public static final Id BDM_PROFILE_ID {
        get{
            if (BDM_PROFILE_ID == null)
            {
                BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
            }
            return BDM_PROFILE_ID;
        }
        set;
    }   
    public static final Id COMMERCIAL_ACCOUNT_ID = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId();
    public static final Id COMMERCIAL_LEAD_ID = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
    public static final Id PROSPECT_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();

    public static final User UserBDMPROFILE { 
        get {
            if(UserBDMPROFILE == null){
                UserBDMPROFILE = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
            }
            return UserBDMPROFILE;
        }
        set; 
    }
    
    public static final RecordType VisitType {
        get{
            if(VisitType == null){
                VisitType = [SELECT id, Name FROM RecordType WHERE Name = 'Visit Plan for Lead' AND sObjectType = 'Call_Report__c' LIMIT 1];
            }
            return VisitType;
        }
        set;
    }

    @testSetup static void setup() {

        TestUtils.createAppConfig();        
		List<AppConfig__c> mc = new List<AppConfig__c> {
            new AppConfig__c(Name = 'runtrigger', Value__c = 'true')
        };
        insert mc;
        insert new status_code__c(name = '6003', Status_Message__c = 'Lead Duplicate');

        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
		insert branchTitle;

		Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;

        Datetime myDateTime = DateTime.Now();
        String dateInString = myDateTime.format('MMddyyyyhhmmss');
		
        List<User> UserList = RTL_TestUtility.createUsers(2, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false);
        User User01 = UserList.get(0);
		User01.ProfileId = BDM_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;
        
        User User02 = UserList.get(1);
		User02.ProfileId = BDM_PROFILE_ID;
        User02.isActive = true;
        insert User02;

        Account acct = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
		acct.Customer_Type__c = 'Individual';
		acct.OwnerID = User01.Id;
		acct.RecordTypeId = PROSPECT_ID;
        acct.Customer_Type__c = 'Juristic';
        acct.ID_Type_PE__c = 'BRN ID';
        acct.ID_Number_PE__c = dateInString + '99901';
		insert acct;
        List<Lead> leadList = RTL_TestUtility.createLeads(2, false);
        Lead Lead01 = leadList.get(0);
        Lead01.RecordTypeId = COMMERCIAL_ACCOUNT_ID;
        Lead01.OwnerID = User01.Id;
        Lead01.Account__c = acct.Id;
        Lead01.Customer_Type__c = 'Juristic';
        Lead01.ID_Type__c = 'BRN ID';
        Lead01.ID_Number__c = dateInString + '99901';
        insert Lead01;
        Lead01.Status = 'Passed Prescreening';
        Lead01.Pre_screening_Result__c = 'Passed';
        update Lead01;        
        Call_Report__c  cr = new Call_Report__c(
            RecordTypeId = VisitType.Id,
            OwnerId = User01.Id,
            // Customer_name__c = a.id,
            Lead__c = Lead01.Id,
            Status__c = '1 - Open',
            Start_Visit_Time__c = '9:00',
            End_Visit_Time__c = '10:00',
            Date_of_Visit__c = Date.today(),
            Categories__c  = 'Initiatives',
            Main_purpose__c = 'SE.',
            Sub_Purpose__c  = 'Selling',
            Outcome__c = 'Pending'
        );
        insert cr;
        Opportunity oppty = TestUtils.createOpportunity(1, acct.Id, false).get(0);
        oppty.OwnerId = User01.Id;
        oppty.Converted_Lead_ID__c = Lead01.Id;
        insert oppty;

        Lead Lead02 = leadList.get(1);
        Lead02.RecordTypeId = COMMERCIAL_LEAD_ID;
        Lead02.OwnerID = User02.Id;
        Lead02.Customer_Type__c = 'Juristic';
        Lead02.ID_Type__c = 'BRN ID';
        Lead02.ID_Number__c = dateInString + '99902';
        insert Lead02;
        Lead02.Status = 'Passed Prescreening';
        Lead02.Pre_screening_Result__c = 'Passed';
        update Lead02;
        
    }

    public static List<Account> getAccountList(){
        return [SELECT Id FROM Account];
    }

    public static List<Lead> getLeadList(){
        return [SELECT Id FROM Lead];
    }

    @isTest
    static void test_QCA_LeadSimplifiedController_positive_1() {
        List<Lead> leadlist = getLeadList();
        List<Account> accountlist = getAccountList();

        Lead tmplead1 = leadlist.get(0);
        QCA_LeadSimplifiedController.getRecordTypeSimplifiedLead();
        QCA_LeadSimplifiedController.getDeepLink();
        QCA_LeadSimplifiedController.getLeadFieldValues('Province__c');
        QCA_LeadSimplifiedController.getUserCurrent();
        QCA_LeadSimplifiedController.updateTrackStatus(tmplead1.Id, '1');
        QCA_LeadSimplifiedController.getMyOpportunityId(tmplead1.Id);
        tmplead1 = QCA_LeadSimplifiedController.getMyLeadInforamtion(tmplead1.Id);
        
        Lead tmplead2 = leadlist.get(1);
        tmplead2 = QCA_LeadSimplifiedController.getMyLeadInforamtion(tmplead2.Id);
        tmplead2.Customer_Type__c = tmplead1.Customer_Type__c;
        tmplead2.ID_Type__c = tmplead1.ID_Type__c;
        tmplead2.ID_Number__c = tmplead1.ID_Number__c;
     
        Test.startTest();
        Test.setFixedSearchResults(new Id[] { tmplead1.Id, tmplead2.Id, accountlist.get(0).Id });
        QCA_LeadSimplifiedController.LeadUpdateRecordWrapper leadupdateRecordWrapper2 = QCA_LeadSimplifiedController.validateDuplicateLeadAndAccount(tmplead2);
        Boolean tmpisOwner = leadupdateRecordWrapper2.isOwner;
        QCA_LeadSimplifiedController.updateLeadDetail(leadupdateRecordWrapper2.leadObj);
        Test.stopTest();
    }   

    @isTest
    static void test_QCA_LeadSimplifiedController_positive_2() {
        List<Lead> leadlist = getLeadList();
        List<Account> accountlist = getAccountList();
        Lead tmpLead2 = QCA_LeadSimplifiedController.getMyLeadInforamtion(leadlist.get(1).Id);
        Test.startTest();
        Test.setFixedSearchResults(new Id[] { tmpLead2.Id, accountlist.get(0).Id });
        
        Lead tmplead3 = QCA_LeadSimplifiedController.getMyLeadInforamtion(tmpLead2.Id).clone(false, false, false, false);
        tmplead3.OwnerId = UserBDMPROFILE.Id;
        tmplead3.Customer_Type__c = tmpLead2.Customer_Type__c;
        tmplead3.ID_Type__c = tmpLead2.ID_Type__c;
        tmplead3.ID_Number__c = tmpLead2.ID_Number__c;

        System.debug(tmplead3);
        QCA_LeadSimplifiedController.LeadUpdateRecordWrapper leadupdateRecordWrapper3 = QCA_LeadSimplifiedController.validateDuplicateLeadAndAccount(tmplead3);
        Test.stopTest();
    }

    @isTest
    static void test_QCA_LeadSimplifiedController_negative() {
        List<Lead> leadlist = getLeadList();
        Lead tmplead2 = leadlist.get(1);
        QCA_LeadSimplifiedController qca_lead = new QCA_LeadSimplifiedController();
        // QCA_LeadSimplifiedController.getRecordTypeSimplifiedLead();
        // QCA_LeadSimplifiedController.getDeepLink();
        QCA_LeadSimplifiedController.getMyLeadInforamtion((Id)'00Q0l000005PjZD');
        // QCA_LeadSimplifiedController.getMyOpportunityId((Id)'00Q0l000005PjZD');

        QCA_LeadSimplifiedController.LeadUpdateRecordWrapper leadupdateRecordWrapper = new QCA_LeadSimplifiedController.LeadUpdateRecordWrapper();
        Boolean tmpisOwner = leadupdateRecordWrapper.isOwner;

        SmartBDM_PicklistDescriber.describe(tmplead2.Id, 'SmartBDM_QuickCA_ProcessStatus__c');
        SmartBDM_PicklistDescriber.describe('Lead', COMMERCIAL_LEAD_ID, 'ID_Type__c');
        SmartBDM_PicklistDescriber.describe('Opportunity', 'Commercial Lead', 'ID_Type__c');
        Test.startTest();
        try {
            QCA_LeadSimplifiedController.updateLeadDetail(new Lead(Id = '00Q0l000005PjZD'));
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();


    }

    @isTest
    static void test_QCA_LeadSimplifiedController_picklistDescController1() {
        List<Lead> leadlist = getLeadList();
        Lead tmplead2 = leadlist.get(1);

        Test.startTest();
        try {
            
            Test.setCurrentPageReference(new PageReference('Page.SmartBDM_PicklistDesc'));
            System.currentPageReference().getParameters().put('id', tmplead2.Id);
            System.currentPageReference().getParameters().put('recordTypeId', '');
            System.currentPageReference().getParameters().put('recordTypeName', 'Commercial_Lead');
            System.currentPageReference().getParameters().put('sobjectType', 'Lead');
            System.currentPageReference().getParameters().put('picklistFieldName', 'ID_Type__c');
            SmartBDM_PickListDescController pd = new SmartBDM_PickListDescController();

        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void test_QCA_LeadSimplifiedController_picklistDescController2() {
        Test.startTest();
        try {
            List<Lead> leadlist = getLeadList();
            Lead tmplead2 = leadlist.get(1);
            
            Test.setCurrentPageReference(new PageReference('Page.SmartBDM_PicklistDesc'));
            System.currentPageReference().getParameters().put('id', tmplead2.Id);
            System.currentPageReference().getParameters().put('recordTypeId', COMMERCIAL_LEAD_ID);
            System.currentPageReference().getParameters().put('recordTypeName', 'Commercial Lead');
            System.currentPageReference().getParameters().put('sobjectType', null);
            System.currentPageReference().getParameters().put('picklistFieldName', 'ID_Type__c');
            SmartBDM_PickListDescController pd = new SmartBDM_PickListDescController();
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}