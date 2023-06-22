@isTest
public class CaseUpdateStdExtensionTest {
	static{
        TestUtils.createAppConfig();
    }

    static{
        TestUtils.createAppConfig();
    }
    
    public static testmethod void CaseUpdate(){
          
        Test.startTest();
        List<selectOption> PTA_Segment_Options = new List<selectOption>();
        PTA_Segment_Options.add(new selectOption('', '-- None --'));
        
        Case caseObj = new Case(PTA_Segment__c = 'Test', Category__c = 'Test', Sub_Category__c = 'Test');
        caseObj.Contact_Person_Name__c = 'Test Name';
        caseObj.Service_Type_Matrix_Code__c = 'xxxx9';
        
        List<Account> accList = RTL_TestUtility.createAccounts(1,true);
        accList.get(0).Segment_crm__c = '1';
        update accList;
        PageReference caseUpdateStd = Page.CaseUpdateStd;
        caseUpdateStd.getparameters().put('def_account_id',accList.get(0).id);
        Test.setCurrentPage(caseUpdateStd); 

        String clone = '0';
        ApexPages.StandardController sc1 = new ApexPages.StandardController(caseObj);
        CaseUpdateStdExtension Case1= new CaseUpdateStdExtension(sc1);
        
        apexpages.currentpage().getparameters().put('picklistAPI','Sub_Category__c');
        apexpages.currentpage().getparameters().put('picklistAPI','Issue__c');
        
        Case1.PTA_Segment_Options = PTA_Segment_Options;
        Case1.save();
        
        apexpages.currentpage().getparameters().put('clone','1');
        Case1.save();
        Case1.getAccountId();
        
        Test.stopTest();
    }

    @isTest
    public static void testResource(){
        //TestUtils.createForCXMToSales();
        TestUtils.createSMSNotiHandler();
        Case caseObj = new Case(PTA_Segment__c = 'SBG', Category__c = 'Service Level1', Sub_Category__c = 'Service level2',Product_Category__c='Service level3',Issue__c='Service level4');
        caseObj.Product_Type_1__c = 'Deposit';
        caseObj.Product_Type_2__c = 'Loan';
        caseObj.Product_Type_3__c = 'Deposit';
        caseObj.Contact_Person_Name__c = 'Test Name';
        caseObj.Service_Type_Matrix_Code__c = 'xxxx9';
        caseObj.Current_Service_Template__c = 'General';
        insert caseObj;

        //Create Service Type matrix
        Service_Type_Matrix__c SeMatrix = New Service_Type_Matrix__c();
        SeMatrix.Segment__c = 'SBG';
        SeMatrix.Service_Level1__c = 'Service Level1';
        SeMatrix.Service_Level2__c = 'Service level2';
        SeMatrix.Service_Level3__c = 'Service level3';
        SeMatrix.Service_Level4__c = 'Service level4';
        SeMatrix.SLA__c = 7;
        SeMatrix.Severity__c = '1';
        SeMatrix.Responsible_BU__c = 'Test Queue SE';
        SeMatrix.Problem_Type__c = 'Test Problem Type';
        SeMatrix.Journey__c = 'Test Jorney';
        SeMatrix.active__c = true;
        SeMatrix.Closed_By_BU__c = 'Test Queue SE';
        SeMatrix.Validate_Code__c = 'xxxx8';
        // [2020-03-26] Case Select Template.
        SeMatrix.Service_Template__c = 'CreditService';
        insert SeMatrix;

        List<Case> caselst = new List<Case>();

        Case caseObj2 = new Case(PTA_Segment__c = 'SBG', Category__c = 'Service Level1', Sub_Category__c = 'Service level2',Product_Category__c='Service level3',Issue__c='Service level4');
        caseObj2.Product_Type_1__c = 'Deposit';
        caseObj2.Product_Type_2__c = 'Loan';
        caseObj2.Product_Type_3__c = 'Deposit';
        caseObj2.Contact_Person_Name__c = 'Test Name';
        caseObj2.Service_Type_Matrix_Code__c = 'xxxx9';
        caseObj2.Current_Service_Template__c = 'General';
        caselst.add(caseObj2);

        Case caseObj3 = new Case(PTA_Segment__c = '', Category__c = 'Service Level1', Sub_Category__c = 'Service level2',Product_Category__c='Service level3',Issue__c='Service level4');
        caseObj3.Product_Type_1__c = 'Deposit';
        caseObj3.Product_Type_2__c = 'Loan';
        caseObj3.Product_Type_3__c = 'Deposit';
        caseObj3.Contact_Person_Name__c = 'Test Name';
        caseObj3.Service_Type_Matrix_Code__c = 'xxxx9';
        caseObj3.Current_Service_Template__c = 'General';
        caselst.add(caseObj3);

        Case caseObj4 = new Case(PTA_Segment__c = 'SBG', Category__c = '', Sub_Category__c = 'Service level2',Product_Category__c='Service level3',Issue__c='Service level4');
        caseObj4.Product_Type_1__c = 'Deposit';
        caseObj4.Product_Type_2__c = 'Loan';
        caseObj4.Product_Type_3__c = 'Deposit';
        caseObj4.Contact_Person_Name__c = 'Test Name';
        caseObj4.Service_Type_Matrix_Code__c = 'xxxx9';
        caseObj4.Current_Service_Template__c = 'General';
        caselst.add(caseObj4);

        Case caseObj5 = new Case(PTA_Segment__c = 'SBG', Category__c = 'Service Level1', Sub_Category__c = '',Product_Category__c='Service level3',Issue__c='Service level4');
        caseObj5.Product_Type_1__c = 'Deposit';
        caseObj5.Product_Type_2__c = 'Loan';
        caseObj5.Product_Type_3__c = 'Deposit';
        caseObj5.Contact_Person_Name__c = 'Test Name';
        caseObj5.Service_Type_Matrix_Code__c = 'xxxx9';
        caseObj5.Current_Service_Template__c = 'General';
        caselst.add(caseObj5);

        Case caseObj6 = new Case(PTA_Segment__c = 'SBG', Category__c = 'Service Level1', Sub_Category__c = 'Service level2',Product_Category__c='Service level3',Issue__c='');
        caseObj6.Product_Type_1__c = 'Deposit';
        caseObj6.Product_Type_2__c = 'Loan';
        caseObj6.Product_Type_3__c = 'Deposit';
        caseObj6.Contact_Person_Name__c = 'Test Name';
        caseObj6.Service_Type_Matrix_Code__c = 'xxxx9';
        caseObj6.Current_Service_Template__c = 'General';
        caselst.add(caseObj6);

        Case caseObj7 = new Case(PTA_Segment__c = 'RBG', Category__c = 'Service Level1', Sub_Category__c = 'Service level2',Product_Category__c='Service level3',Issue__c='');
        caseObj7.Product_Type_1__c = 'Deposit';
        caseObj7.Product_Type_2__c = 'Loan';
        caseObj7.Product_Type_3__c = 'Deposit';
        caseObj7.Contact_Person_Name__c = 'Test Name';
        caseObj7.Service_Type_Matrix_Code__c = 'xxxx9';
        caseObj7.Current_Service_Template__c = 'General';
        caseObj7.Contact_Person_Phone__c ='0800000000';
        caseObj7.Contact_Person_Phone_2__c ='0800000000';
        caseObj7.To_Ext_1__c ='401 ,403';
        caseObj7.To_Ext_2__c ='401 ,(403)- 1';
        caselst.add(caseObj7);

        insert caselst;

        SeMatrix = New Service_Type_Matrix__c();
        SeMatrix.Segment__c = 'SBG';
        SeMatrix.Service_Level1__c = 'Service Level1';
        SeMatrix.Service_Level2__c = 'Service level2';
        SeMatrix.Service_Level3__c = 'Service level3';
        SeMatrix.Service_Level4__c = 'Service level4s';
        SeMatrix.SLA__c = 7;
        SeMatrix.Severity__c = '1';
        SeMatrix.Responsible_BU__c = 'Test Queue SE';
        SeMatrix.Problem_Type__c = 'Test Problem Type';
        SeMatrix.Journey__c = 'Test Jorney';
        SeMatrix.active__c = true;
        SeMatrix.Closed_By_BU__c = 'Test Queue SE';
        SeMatrix.Validate_Code__c = 'xxxx9';
        // [2020-03-26] Case Select Template.
        SeMatrix.Service_Template__c = 'CreditService';
        insert SeMatrix;

        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(caseObj);
        CaseUpdateStdExtension cls = new CaseUpdateStdExtension(sc1);

        List<selectOption> PTA_Segment_Options = cls.PTA_Segment_Options;
        List<selectOption> CaseStatus_Options  = cls.CaseStatus_Options;
        Boolean isAccessibleATM_ADM = cls.isAccessibleATM_ADM;
        Boolean isAccessibleSE_Process = cls.isAccessibleSE_Process;
        String selected_PTA_Segment = cls.selected_PTA_Segment;

        cls.productNumberForEdit3 = '00001234567';
        cls.productNumberForEdit2 = '00001234567';
        cls.save();

        PageReference pageRef = Page.CaseUpdateStd;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(caseObj2);
        ApexPages.currentPage().getParameters().put('serviceId', SeMatrix.Id);
        ApexPages.currentPage().getParameters().put('templateName', SeMatrix.Service_Template__c);
        CaseUpdateStdExtension cls2 = new CaseUpdateStdExtension(sc);
        String PTA_Segment_Options_Str = cls2.PTA_Segment_Options_Str;
        List<Service_Type_Matrix__c> selectSegmentPicklist = CaseUpdateStdExtension.selectSegmentPicklist('SBG');
        cls2.SetCaseTemplate();
        cls2.newSave();

        sc = new ApexPages.Standardcontroller(caseObj3);
        cls2 = new CaseUpdateStdExtension(sc);
        cls2.SetCaseTemplate();
        cls2.newSave();

        sc = new ApexPages.Standardcontroller(caseObj4);
        cls2 = new CaseUpdateStdExtension(sc);
        cls2.SetCaseTemplate();
        cls2.newSave();

        sc = new ApexPages.Standardcontroller(caseObj5);
        cls2 = new CaseUpdateStdExtension(sc);
        cls2.SetCaseTemplate();
        cls2.newSave();
        
        sc = new ApexPages.Standardcontroller(caseObj6);
        cls2 = new CaseUpdateStdExtension(sc);
        cls2.SetCaseTemplate();
        cls2.newSave();

        Test.stopTest();
    }
    
}