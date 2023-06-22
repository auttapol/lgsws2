@isTest
public class EditSLLGroupControllerTest {
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
	public static final Id RM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
    public static final Id Record_Type_Available = [SELECT Id FROM RecordType WHERE Name = 'Available' LIMIT 1].Id;
    public static final Id Record_Type_Draft = [SELECT Id FROM RecordType WHERE Name = 'Draft' LIMIT 1].Id;
    public static final Id ExistingRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();

        Account priCus1 = TestUtils.createAccounts(1, 'SLLG', 'Individual', false).get(0);
        priCus1.RecordTypeId = ExistingRecordType;
        insert priCus1;

        List<User> userpam = TestUtils.createUsers(3, 'userF', 'userL', 'usertest@gmail.com', false);
        userpam[0].Employee_ID__c = '21212';
        userpam[1].Employee_ID__c = '34343';
        userpam[2].Employee_ID__c = '67890';
        userpam[0].ProfileId = SESM_PROFILE_ID;

        insert userpam[0];

        userpam[1].ProfileId = SEZM_PROFILE_ID;
        userpam[1].ManagerId = userpam[0].Id;
        insert userpam[1];

        userpam[2].ProfileId = RM_PROFILE_ID;
        userpam[2].ManagerId = userpam[1].Id;
        insert userpam[2];

        SLL_Group__c sllNewG = new SLL_Group__c();
        sllNewG.Name = 'nameEditTest';
        sllNewG.Primary_Customer__c = priCus1.Id;
        sllNewG.PAM__c = userpam[2].Id;
        sllNewG.Approver1__c = userpam[1].Id;
        sllNewG.Approver2__c = userpam[0].Id;
        sllNewG.Remark__c = 'RemarknameEditTest';
        insert sllNewG;

    }

    @isTest
    public static void testEditSllGAva(){
        
        Account acc = [SELECT Id, name FROM Account];
        SLL_Group__c sllNG = [SELECT Id, Name, PAM__c, Primary_Customer__c, Approver1__c, Approver2__c FROM SLL_Group__c];
        sllNG.RecordTypeId = Record_Type_Available;
        sllNG.Is_Active__c = true;
        update sllNG;

        SLL_Group__c editSll = new SLL_Group__c();
        editSll.Name = 'nameEditTest edit2';
        editSll.Primary_Customer__c = acc.Id;
        editSll.PAM__c = sllNG.PAM__c;
        editSll.Remark__c = 'edit2';

        Test.startTest(); 
        	EditSLLGroupController.editSllG(sllNG.Id, editSll.Name, editSll.Primary_Customer__c, editSll.PAM__c, editSll.Remark__c);
        Test.stopTest();

    }

    @isTest
    public static void testEditSllGSDraft(){

        Account acc = [SELECT Id, name FROM Account];
        SLL_Group__c sllNewG2 = [SELECT Id, Name, PAM__c, Primary_Customer__c, Approver1__c, Approver2__c FROM SLL_Group__c];
        sllNewG2.RecordTypeId = Record_Type_Draft;
        sllNewG2.Is_Active__c = false;
        update sllNewG2;

        // Account customer = TestUtils.createAccounts(1, 'SLLGTest23', 'Individual', false).get(0);
        // customer.Name = 'SLLCustTest1';
        // customer.ID_Number_PE__c = '123123123';
        Account customer = new Account(); 
        customer.Name = 'SLLCustTest1';
        customer.Phone ='050111222';
        customer.Mobile_Number_PE__c  = '0801112233';
        customer.ID_Type_PE__c  = 'Citizen ID';
        customer.ID_Number_PE__c  = '1510100181965';
        customer.RecordTypeId = ExistingRecordType;
           
        customer.Customer_Type__c = 'Individual';
        customer.First_name_PE__c = 'SLLCustTest1';
        customer.First_Name_ENG_PE__c = 'SLLCustTest1';
        customer.Last_name_PE__c = 'TestMock';
        customer.Last_Name_PE_Eng__c  = 'TestMock';
        customer.Rating = 'Hot';
        insert customer;

        List<SLL_Group_Approval_History__c> groupHis = new List<SLL_Group_Approval_History__c>();
        groupHis.add(new SLL_Group_Approval_History__c(SLL_Group_Name__c = sllNewG2.Id, Customer__c = customer.Id, Approval_Status_Pending__c = 'Rejected'));
        insert groupHis;

        SLL_Group__c editSll = new SLL_Group__c();
        editSll.Name = 'nameEditTest edit222';
        editSll.Primary_Customer__c = sllNewG2.Primary_Customer__c;
        editSll.PAM__c = sllNewG2.PAM__c;
        editSll.Remark__c = 'edit2';

        Test.startTest(); 
        	EditSLLGroupController.editSllG(sllNewG2.Id, editSll.Name, editSll.Primary_Customer__c, editSll.PAM__c, editSll.Remark__c);
        Test.stopTest();

    }

    @isTest
    public static void testEditSllGSPAMInAct(){

        Account acc = [SELECT Id, name FROM Account limit 1];

        List<User> userpamAct = TestUtils.createUsers(3, 'userFAct', 'userLAct', 'usertestAct@gmail.com', false);
        userpamAct[0].Employee_ID__c = '24532';
        userpamAct[1].Employee_ID__c = '32323';
        userpamAct[2].Employee_ID__c = '65656';
        
        userpamAct[0].ProfileId = SESM_PROFILE_ID;
        insert userpamAct[0];

        userpamAct[1].ProfileId = SEZM_PROFILE_ID;
        userpamAct[1].ManagerId = userpamAct[0].Id;
        userpamAct[1].IsActive = false;
        insert userpamAct[1];

        userpamAct[2].ProfileId = RM_PROFILE_ID;
        userpamAct[2].ManagerId = userpamAct[1].Id;
        insert userpamAct[2];

        SLL_Group__c sllNewG = new SLL_Group__c();
        sllNewG.Name = 'nameEditTest321';
        sllNewG.Primary_Customer__c = acc.Id;
        sllNewG.PAM__c = userpamAct[2].Id;
        sllNewG.Approver1__c = userpamAct[1].Id;
        sllNewG.Approver2__c = userpamAct[0].Id;
        sllNewG.Remark__c = 'RemarknameEditTest';
        sllNewG.RecordTypeId = Record_Type_Available;
        sllNewG.Is_Active__c = true;
        insert sllNewG;

        SLL_Group__c editSll = new SLL_Group__c();
        editSll.Name = 'nameEditTest edit222';
        editSll.Primary_Customer__c = acc.Id;
        editSll.PAM__c = userpamAct[2].Id;
        editSll.Remark__c = 'edit2';

        Test.startTest(); 
        	EditSLLGroupController.editSllG(sllNewG.Id, editSll.Name, editSll.Primary_Customer__c, editSll.PAM__c, editSll.Remark__c);
        Test.stopTest();
    }

    @isTest
    public static void testEditSllGErr(){

        Account acc = [SELECT Id, name FROM Account];
        SLL_Group__c sllNewG2 = [SELECT Id, Name, PAM__c, Primary_Customer__c, Approver1__c FROM SLL_Group__c];
        sllNewG2.Is_Active__c = true;
        sllNewG2.Approval_Status__c = 'Pending Approval - Active';
        update sllNewG2;

        SLL_Group__c editSll = new SLL_Group__c();
        editSll.Name = 'nameEditTest edit2';
        editSll.Primary_Customer__c = acc.Id;
        editSll.PAM__c = sllNewG2.PAM__c;
        editSll.Remark__c = 'edit2';

        Test.startTest(); 
            try {
        	    EditSLLGroupController.editSllG(sllNewG2.Id, editSll.Name, editSll.Primary_Customer__c, editSll.PAM__c, editSll.Remark__c);
            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Script-thrown exception');
            }
        Test.stopTest();
    }
}