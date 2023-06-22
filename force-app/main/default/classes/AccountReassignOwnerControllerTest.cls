@isTest
public class AccountReassignOwnerControllerTest {
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id RPSPEC_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Commercial Report Specialist Profile' LIMIT 1].Id;
    public static final Id TH_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Team Head Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;

    static{
        TestUtils.createAppConfig();

        TestUtils.CreateProceBookAccess();
        TestUtils.CreateProceBook();

        Id CommercialPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Commercial Pricebook' LIMIT 1].Id;

        product2 prod = new product2(
            Name = 'PROD1',
            Product_Domain__c = 'Funding & Borrowing',
            IsActive = true,
            Family = 'CONTINGENT LIABILITIES',
            ProductCode = '12345678'
        );
        insert prod;
        
        product2 prod2 = new product2(
            Name = 'PROD2',
            Product_Domain__c = 'Deposit & investment',
            IsActive = true,
            Family = 'CONTINGENT LIABILITIES',
            ProductCode = '99999999'
        );
        insert prod2;

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;

        List<User> userlst = new List<User>();

        User User01 = RTL_TestUtility.createUsers(1, 'testuser', 'testuser', 'testuser@tmb.com.test', false).get(0);
		User01.ProfileId = SESM_PROFILE_ID;
		User01.isActive = true;
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '111111';
		User01.Zone__c = 'SE-ChiangMai';
		User01.Zone_Code__c = '9999';
		User01.Region__c = 'SE1-North1';
		User01.Region_Code__c = '1111';
        User01.Segment__c = 'SE';
        userlst.add(User01);
        
        User User02 = RTL_TestUtility.createUsers(1, 'testuser2', 'testuser2', 'testuser2@tmb.com.test', false).get(0);
		User02.ProfileId = SEZM_PROFILE_ID;
		User02.isActive = true;
		User02.RTL_Branch_Code__c = bz.Branch_Code__c;
		User02.Employee_ID__c = '222222';
		User02.Zone__c = 'SE-ChiangMai';
		User02.Zone_Code__c = '9999';
		User02.Region__c = 'SE1-North1';
		User02.Region_Code__c = '1111';
        User02.Segment__c = 'SE';
        userlst.add(User02);

        User User03 = RTL_TestUtility.createUsers(1, 'testuser3', 'testuser3', 'testuser3@tmb.com.test', false).get(0);
		User03.ProfileId = TH_PROFILE_ID;
		User03.isActive = true;
		User03.RTL_Branch_Code__c = bz.Branch_Code__c;
		User03.Employee_ID__c = '333333';
		User03.Zone__c = 'SE-ChiangMai';
		User03.Zone_Code__c = '9999';
		User03.Region__c = 'SE1-North1';
		User03.Region_Code__c = '1111';
        User03.Segment__c = 'SE';
        userlst.add(User03);

        User User04 = RTL_TestUtility.createUsers(1, 'testuser4', 'testuser4', 'testuser4@tmb.com.test', false).get(0);
		User04.ProfileId = BDM_PROFILE_ID;
		User04.isActive = true;
		User04.RTL_Branch_Code__c = bz.Branch_Code__c;
		User04.Employee_ID__c = '444444';
		User04.Zone__c = 'SE-ChiangMai';
		User04.Zone_Code__c = '9999';
		User04.Region__c = 'SE1-North1';
		User04.Region_Code__c = '1111';
        User04.Segment__c = 'SE';
        userlst.add(User04);

        User User05 = RTL_TestUtility.createUsers(1, 'testuser5', 'testuser5', 'testuser5@tmb.com.test', false).get(0);
		User05.ProfileId = BDM_PROFILE_ID;
		User05.isActive = true;
		User05.RTL_Branch_Code__c = bz.Branch_Code__c;
		User05.Employee_ID__c = '555555';
		User05.Zone__c = 'SE-ChiangMai';
		User05.Zone_Code__c = '8888';
		User05.Region__c = 'SE1-North1';
		User05.Region_Code__c = '2222';
        User05.Segment__c = 'BB';
        userlst.add(User05);

        User User06 = RTL_TestUtility.createUsers(1, 'testuser6', 'testuser6', 'testuser6@tmb.com.test', false).get(0);
		User06.ProfileId = RPSPEC_PROFILE_ID;
		User06.isActive = true;
		User06.RTL_Branch_Code__c = bz.Branch_Code__c;
		User06.Employee_ID__c = '666666';
		User06.Zone__c = 'SE-ChiangMai';
		User06.Zone_Code__c = '9999';
		User06.Region__c = 'SE1-North1';
		User06.Region_Code__c = '1111';
        User06.Segment__c = 'SE';
        userlst.add(User06);

        insert userlst;
        
        List<Account> pospectAccts = TestUtils.createAccounts(20, 'name', 'Qualified Prospect', false);
        
        for (Account acct : pospectAccts) {
            acct.OwnerId = User01.Id;
            acct.Account_Type__c = 'Qualified Prospect';
            acct.Stamp_Owner_Region_Group__c = 'SE1-North1';
            acct.Stamp_Owner_Region_Code_Group_Code__c = '1111';
            acct.Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
            acct.Stamp_Owner_Zone_Code_Team_C__c = '9999';
            acct.Stamp_Owner_Segment__c = 'SE';
        }

        insert pospectAccts;

        List<Account> existingAccts = TestUtils.createAccounts(20, 'name', 'Existing Customer', false);

        for (Account acct : existingAccts) {
            acct.OwnerId = User01.Id;
            acct.Account_Type__c = 'Existing Customer';
            acct.Stamp_Owner_Region_Group__c = 'SE1-North1';
            acct.Stamp_Owner_Region_Code_Group_Code__c = '1111';
            acct.Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
            acct.Stamp_Owner_Zone_Code_Team_C__c = '9999';
            acct.Stamp_Owner_Segment__c = 'SE';
        }
        insert existingAccts;

        List<Product_Information_On_Hand__c> prdInfoOnHandlst = new List<Product_Information_On_Hand__c>();

        for (Integer i = 0 ; i < pospectAccts.size() ; i++) {
            Product_Information_On_Hand__c prdInfoOnHand = new Product_Information_On_Hand__c();
            Product_Information_On_Hand__c prdInfoOnHand2 = new Product_Information_On_Hand__c();
            
            prdInfoOnHand.Account__c = pospectAccts.get(i).Id;
            prdInfoOnHand2.Account__c = pospectAccts.get(i).Id;

            prdInfoOnHand.Product_Hierachy_Code__c = prod.Id;
            prdInfoOnHand2.Product_Hierachy_Code__c = prod2.Id;

            prdInfoOnHandlst.add(prdInfoOnHand);
            prdInfoOnHandlst.add(prdInfoOnHand2);
        }

        insert prdInfoOnHandlst;

        List<Product_Information_Detail__c> prdInfoDetaillst = new List<Product_Information_Detail__c>();

        for(Product_Information_On_Hand__c prdInfoOnHand : prdInfoOnHandlst){
            Product_Information_Detail__c prdInfoDetail = new Product_Information_Detail__c();

            prdInfoDetail.Customer__c = prdInfoOnHand.Account__c;
            prdInfoDetail.Product_Information__c = prdInfoOnHand.Id;
            prdInfoDetail.Limit_Balance__c = 2000;
            prdInfoDetail.Ending_out_Ending_Balance__c = 2000;

            prdInfoDetaillst.add(prdInfoDetail);
        }

        insert prdInfoDetaillst;

    }

    @isTest
    public static void testAccountSelection() {
        User user = [SELECT Id, Name FROM User WHERE Email = 'testuser6@tmb.com.test' AND ProfileId = :RPSPEC_PROFILE_ID LIMIT 1];
        Account tempAcct = [SELECT Id, Name, Change_to_owner__c, OwnerId FROM Account LIMIT 1];
        
        AppConfig__c Aconfig1 = new AppConfig__c();
        Aconfig1.Name = 'sfadm Account Name';
        Aconfig1.Value__c = 'sfadm System Account';        
        insert Aconfig1;

        System.runAs(user){
            AccountReassignOwnerController ctrl = new AccountReassignOwnerController();
            List<SelectOption> selectedValue = ctrl.selectedValue;
            selectedValue = ctrl.filterCustomerSelectValue;
            selectedValue = ctrl.filterApprovalPendingValue;
            List<SelectOption> filterCustomerSegmentOption  = ctrl.filterCustomerSegmentOption;
            String sfadmSystemAccount = ctrl.sfadmSystemAccount;
            ctrl.limitSelect = 10;
            ctrl.generateAccountShowlst();

            ctrl.isToggleSelectAll = true;
            ctrl.toggleSelectAll();
            ctrl.selectAcc();
            ctrl.backToSelectAcc();
            ctrl.isToggleSelectAll = false;
            ctrl.toggleSelectAll();
            ctrl.selectAcc();
            
            List<Account> a = new List<Account>();
            a.add(tempAcct);
            ctrl.reverseList(a);
        }
    }

    @isTest
    public static void testReassignAccountBySM() {
        User SMuser = [SELECT Id, Name FROM User WHERE Email = 'testuser@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        User BDMuser = [SELECT Id, Name FROM User WHERE Email = 'testuser4@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User BDMuser2 = [SELECT Id, Name FROM User WHERE Email = 'testuser5@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        Account tempAcct = [SELECT Id, Name, Change_to_owner__c, OwnerId FROM Account LIMIT 1];

        System.runAs(SMuser){
            AccountReassignOwnerController ctrl = new AccountReassignOwnerController();
            List<SelectOption> selectedValue = ctrl.selectedValue;
            ctrl.limitSelect = 1;
            ctrl.generateAccountShowlst();

            ctrl.isToggleSelectAll = true;
            ctrl.toggleSelectAll();
            ctrl.selectAcc();
            tempAcct.Change_to_owner__c = null;
            ctrl.tmpAcct = tempAcct;
            ctrl.reassignAccount();
            tempAcct.Change_to_owner__c = BDMuser.Id;
            ctrl.tmpAcct = tempAcct;
            ctrl.reassignAccount();
            tempAcct.Change_to_owner__c = BDMuser2.Id;
            ctrl.tmpAcct = tempAcct;
            ctrl.reassignAccount();
        }
    }

    @isTest
    public static void testReassignAccountByTH() {
        User THuser = [SELECT Id, Name FROM User WHERE Email = 'testuser3@tmb.com.test' AND ProfileId = :TH_PROFILE_ID LIMIT 1];
        User BDMuser = [SELECT Id, Name FROM User WHERE Email = 'testuser4@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User BDMuser2 = [SELECT Id, Name FROM User WHERE Email = 'testuser5@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        Account tempAcct = [SELECT Id, Name, Change_to_owner__c, OwnerId FROM Account LIMIT 1];

        System.runAs(THuser){
            AccountReassignOwnerController ctrl = new AccountReassignOwnerController();
            List<SelectOption> selectedValue = ctrl.selectedValue;
            ctrl.limitSelect = 1;
            ctrl.generateAccountShowlst();

            ctrl.isToggleSelectAll = true;
            ctrl.toggleSelectAll();
            ctrl.selectAcc();
            tempAcct.Change_to_owner__c = BDMuser.Id;
            ctrl.tmpAcct = tempAcct;
            ctrl.reassignAccount();
            tempAcct.Change_to_owner__c = BDMuser2.Id;
            ctrl.tmpAcct = tempAcct;
            ctrl.reassignAccount();
        }
    }

    @isTest
    public static void testReassignAccountByZM() {
        User ZMuser = [SELECT Id, Name FROM User WHERE Email = 'testuser2@tmb.com.test' AND ProfileId = :SEZM_PROFILE_ID LIMIT 1];
        User BDMuser = [SELECT Id, Name FROM User WHERE Email = 'testuser4@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User BDMuser2 = [SELECT Id, Name FROM User WHERE Email = 'testuser5@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        Account tempAcct = [SELECT Id, Name, Change_to_owner__c, OwnerId FROM Account LIMIT 1];

        System.runAs(ZMuser){
            AccountReassignOwnerController ctrl = new AccountReassignOwnerController();
            List<SelectOption> selectedValue = ctrl.selectedValue;
            ctrl.limitSelect = 1;
            ctrl.generateAccountShowlst();

            ctrl.isToggleSelectAll = true;
            ctrl.toggleSelectAll();
            ctrl.selectAcc();
            tempAcct.Change_to_owner__c = BDMuser.Id;
            ctrl.tmpAcct = tempAcct;
            ctrl.reassignAccount();
            tempAcct.Change_to_owner__c = BDMuser2.Id;
            ctrl.tmpAcct = tempAcct;
            ctrl.reassignAccount();
        }
    }

    @isTest
    public static void testPagination() {
        User user = [SELECT Id, Name FROM User WHERE Email = 'testuser@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        Account tempAcct = [SELECT Id, Name, Change_to_owner__c, OwnerId FROM Account LIMIT 1];

        System.runAs(user){
            AccountReassignOwnerController ctrl = new AccountReassignOwnerController();
            ctrl.limitSelect = 10;

            ctrl.generateAccountShowlst();

            ctrl.PaginationNext();
            ctrl.PaginationNext();
            ctrl.PaginationNext();
            ctrl.PaginationPrev();
            ctrl.PaginationPrev();
            ctrl.PaginationPrev();
        }
    }

    @isTest
    public static void testSearchFlow() {
        User user = [SELECT Id, Name FROM User WHERE Email = 'testuser@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        Account tempAcct = [SELECT Id, Name, Change_to_owner__c, Current_Owner__c, Previous_Owner__c, OwnerId, Group__c FROM Account LIMIT 1];
        Group__c gr = new Group__c (Name = 'g1');
        insert gr;

        System.runAs(user){
            AccountReassignOwnerController ctrl = new AccountReassignOwnerController();
            ctrl.limitSelect = 10;
            ctrl.generateAccountShowlst();

            ctrl.customerStageFilter = 'Existing Customer';
            ctrl.filterCustomer = 'myCustomer';
            tempAcct.Previous_Owner__c = user.Id;
            tempAcct.Current_Owner__c = user.Id;
            tempAcct.Group__c = gr.Id;
            ctrl.tmpAcct = tempAcct;
            ctrl.searchAccountByfilter();
            ctrl.filterCustomer = 'myTeamsInactiveOwner';
            ctrl.filterIsApprovalPending = 'pendingapproval';
            ctrl.searchAccountByfilter();
            ctrl.filterCustomer = 'newCustomer';
            ctrl.filterIsApprovalPending = 'nopending';
            ctrl.searchAccountByfilter();
            
        }
    }

    @isTest
    public static void testErrorQueryAccount(){
        
        User user = [SELECT Id, Name FROM User WHERE Email = 'testuser@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        User BDMuser = [SELECT Id, Name FROM User WHERE Email = 'testuser4@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        Account tempAcct = [SELECT Id, Name, Change_to_owner__c, OwnerId FROM Account LIMIT 1];

        System.runAs(user){
            AccountReassignOwnerController ctrl = new AccountReassignOwnerController();
            ctrl.limitSelect = 10;
            ctrl.queryAccountField = '';
            ctrl.searchAccountByfilter();
        }
    }
}