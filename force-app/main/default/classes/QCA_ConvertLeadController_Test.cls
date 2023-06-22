@isTest
private class QCA_ConvertLeadController_Test {

    public static RecordType LogaCallType {
        get{
            if(LogaCallType == null){
                LogaCallType = [SELECT id, Name FROM RecordType WHERE Name = 'Task Record Type' AND sObjectType = 'Task' LIMIT 1];
            }
            return LogaCallType;
        }set;
    }

    public static RecordType VisitType {
        get{
            if(VisitType == null){
                VisitType = [SELECT id, Name FROM RecordType WHERE Name = 'Visit Plan for Lead' AND sObjectType = 'Call_Report__c' LIMIT 1];
            }
            return VisitType;
        }set;
    }

    public static Id BDM_PROFILE_ID{
        get{
            if(BDM_PROFILE_ID == null){
                BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
            }
            return BDM_PROFILE_ID;
        }
        set;
    }

    public static Id pb1 {
        get{
            return Test.getStandardPricebookId();
        }
    }

    public static User OwnerRecord {
        get{
            if(OwnerRecord == null){
                OwnerRecord = [SELECT id, Username, Employee_ID__c FROM User WHERE Username = 'smartbdm@tmb.com.test' AND Employee_ID__c = '123456' LIMIT 1];
            }
            return OwnerRecord;
        }set;
    }
    public static Id CommercialPricebook {
        get{
            if(CommercialPricebook == null){
                CommercialPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Commercial Pricebook' LIMIT 1].Id;
            }
            return CommercialPricebook;
        }
        set;
    }

    public static Date d1 = Date.today();
    
    @testSetup 
    static void setup() {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        // TestUtils.CreateTriggerMsg();

        AppConfig__c mc = AppConfig__c.getValues('runtrigger');
        mc.Value__c = 'true';
        update mc;

        TestUtils.CreateProceBook();
        TestUtils.CreateProceBookAccess();

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;

		User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false).get(0);
        //User01.UserName = 'smartbdm@tmb.com.test';
		User01.ProfileId = BDM_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

        product2 prod = new product2(
            Name = 'PROD1',
            Product_Domain__c = 'Funding & Borrowing',
            IsActive = true,
            Family = 'CONTINGENT LIABILITIES',
            ProductCode = '12345678'
        );
        insert prod;

        // Pricebook2 pb = new Pricebook2(
        //     Name = 'Commercial Pricebook', 
        //     TMB_Pricebook__c ='TMB5412',
        //     Description = 'Price Book 2009 Products', IsActive = true);
        // insert pb;

        PricebookEntry standardPrice = new PricebookEntry( IsActive = true, UnitPrice = 1, Product2Id = prod.id, Pricebook2Id = pb1, UseStandardPrice = false);
        insert standardPrice;

        pricebookentry pbe = new pricebookentry(isactive = true, UnitPrice = 1, product2id = prod.id, Pricebook2Id = CommercialPricebook, UseStandardPrice = false);
        insert pbe;

        Host_Product_Mapping__c hostPrd = new Host_Product_Mapping__c(Active_Flag__c = true, Credit_Type_ID__c = '111', Host_Name__c = 'SLS', Host_Prod_Name_Credit_Facility__c = 'Factoring - Accepted invoice', Host_Product_Group__c = 'Supply Chain', Product_Group_ID__c = '9', Product_Program_ID__c = '180', Product_Program__c = 'Factoring', Salesforce_Product__c = prod.id);
        insert hostPrd;
        
        insert new status_code__c(name = '6003', Status_Message__c = 'Lead Duplicate');

        String dateInString = DateTime.Now().format('MMddyyyyhhmmss');
        Lead leadobj = new Lead(
            RecordTypeId = QCA_LeadSimplifiedController_Test.COMMERCIAL_LEAD_ID,
            OwnerId = User01.Id, 
            Customer_Type__c = 'Juristic',
            ID_Type__c = 'BRN ID',
            ID_Number__c = dateInString + '00' + String.valueOf(1) + '00' + String.valueOf(1),
            Customer_Name_EN__c = 'Name'+ dateInString + '00' + String.valueOf(1) + '00' + String.valueOf(1),
            Mobile_No__c = '0812345678',
            Office_No__c = '027777777',
            Salutation = 'Dr.',
            Firstname = 'Name' + '00' + String.valueOf(1),
            Lastname = 'Lname' + '00' + String.valueOf(1),
            Phone__c = '0812345678',            
            Company = 'Company' + String.valueOf(1)
        );
        insert leadObj;

        leadObj.Pre_screening_Result__c = 'Passed';
        leadObj.Status = 'Passed Prescreening';
        update leadObj;

        Task taskObj = new Task(
            RecordTypeId = LogaCallType.Id,
            OwnerId = User01.Id, 
            Subject = 'Call',
            WhoId = leadObj.Id,
            ActivityDate = Date.today(),
            Status = 'Complete',
            Priority = 'Normal'
        );
        insert taskObj;

        Call_Report__c visitObj = new Call_Report__c(
            OwnerId = User01.Id, 
            Lead__c = leadObj.Id,
            RecordTypeID = VisitType.Id,
            Date_of_Visit__c = Date.today(),
            Status__c = '1 - Open',
            Start_Visit_Time__c = '9:00',
            End_Visit_Time__c = '10:00',
            Categories__c = 'Initiatives',
            Main_purpose__c = 'SE.',
            Sub_Purpose__c = 'Selling',
            Outcome__c = 'Pending'
        );
        insert visitObj;

        Product_Interest__c productObj = new Product_Interest__c(
            OwnerId = User01.Id,
            Opportunity_Type__c = 'Credit',
            Product__c = prod.Id,
            Amount__c = 50000,
            Lead__c = leadObj.Id,
            Host_Product_Mapping__c = hostPrd.Id
        );
        insert productObj;

        dateInString = DateTime.Now().format('MMddyyyyhhmmss');
        Account acct = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
		acct.Customer_Type__c = 'Individual';
		acct.OwnerID = User01.Id;
		acct.RecordTypeId = QCA_LeadSimplifiedController_Test.PROSPECT_ID;
        acct.Customer_Type__c = 'Juristic';
        acct.ID_Type_PE__c = 'BRN ID';
        acct.ID_Number_PE__c = dateInString + '99901';
		insert acct;

        Lead Lead01 = RTL_TestUtility.createLeads(1, false).get(0);
        Lead01.RecordTypeId = QCA_LeadSimplifiedController_Test.COMMERCIAL_LEAD_ID;
        Lead01.OwnerID = User01.Id;
        Lead01.Account__c = acct.Id;
        Lead01.Customer_Type__c = 'Juristic';
        Lead01.ID_Type__c = 'BRN ID';
        Lead01.ID_Number__c = dateInString + '99901';
        Lead01.Office_No__c = '234567812';
        Lead01.Mobile_No__c = '081232344';
        insert Lead01;
        Lead01.Status = 'Passed Prescreening';
        Lead01.Pre_screening_Result__c = 'Passed';
        Lead01.Contacted_Flag__c = true;
        update Lead01;
        Call_Report__c  cr = new Call_Report__c(
            OwnerId = User01.Id,
            // Customer_name__c = a.id,
            Lead__c = Lead01.Id,
            Status__c = 'Open',
            Date_of_Visit__c = Date.today(),
            Categories__c  = 'Sell product',
            Main_purpose__c = 'Sell product',
            Sub_Purpose__c  = 'Product'
        );
        insert cr;
        Product_Interest__c productObj2 = new Product_Interest__c(
            OwnerId = User01.Id,
            Opportunity_Type__c = 'Credit',
            Product__c = prod.Id,
            Amount__c = 50000,
            Lead__c = Lead01.Id,
            Host_Product_Mapping__c = hostPrd.Id
        );
        insert productObj2;

    }

    public static List<Lead> getLeadList(){
        return [SELECT Id FROM Lead];
    }

    @isTest
    static void testCommercialLeadConvert() {
        Test.startTest();
        Lead leadObj = getLeadList().get(0);
        QCA_ConvertLeadController.convertLead(leadObj.id, d1, d1);
        Test.stopTest();
    }

    @isTest
    static void testCommercialAccountConvert() {
        Test.startTest();
        Lead leadObj = getLeadList().get(1);
        QCA_ConvertLeadController.convertLead(leadObj.id, d1, d1);
        Test.stopTest();
    }
}