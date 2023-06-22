@IsTest
public class AccountPlanActionPlanConvertTest{

    static void setInitial()
    {
        insert new Account_Plan_Status_Code__c(name = '5022', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '5023', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '5024', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '5026', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '5027', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '5028', Status_Message__c = 'test');
    }

    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.CreateProceBook();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    }
    public static testMethod void ConvertToOpportunity(){
        setInitial();
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test AccountPlan Step5' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';   
        insert testAccount1;
        
        //Create Contact
        Contact cont1 = new Contact();
        cont1.FirstName='AccountPlan';
        cont1.LastName='Step5';
        cont1.Position__c = 'Manager';
        cont1.Accountid= testAccount1.id;
        insert cont1;
        
        //Create Account Plan
        AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
        Company1.Account__c=testAccount1.id;
        //Company1.Name='AccountPlan Step5';
        insert Company1;
        
        AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
        Wallet1.AcctPlanCompanyProfile__c = Company1.id;
        insert Wallet1;
        
        AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
        WalletDomain1.AcctPlanWallet__c = Wallet1.id;
        WalletDomain1.WalletDomain__c = 1;
        WalletDomain1.Priority__c ='High';
        WalletDomain1.SubDomain__c ='Liquidity Management';
        WalletDomain1.TypeOfNI__c = 'NIIC';
        insert WalletDomain1;
        
        
        AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
        acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
        acctplan1.Objective__c = 'Acquire New customers';
        acctplan1.Status__c = 'Post Board';
        acctplan1.WinningPropostion__c = 'Test Class';
        insert acctplan1;   
           
            Pricebook2 pb = new Pricebook2(Name = 'Commercial Pricebook', 
                                           TMB_Pricebook__c ='TMB5412',
                                           Description = 'Price Book 2009 Products', IsActive = true);
            insert pb;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
            						Family = 'Hardware',
                                    Product_Level__c ='1');
            insert prod;
           
           PricebookEntry standardPBE 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe;
           
        AcctPlanNIProject__c nirecord = new AcctPlanNIProject__c();
        nirecord.AcctPlanActionPlanID__c= acctplan1.id;
        nirecord.PropsProductOrServices__c = 'OD';
        nirecord.ExpectedIncremental__c = 10000;
        nirecord.TypeOfNI__c = 'NIIc';
        nirecord.NIRecuringType__c='Recurring';
        nirecord.ExpectedNimRate__c=10.00;
        nirecord.ExpectedIncrementalNIPerYear1Year__c=10000;
        nirecord.ExpectedIncrementalNIPerYear2Year__c=10000;
        nirecord.NIStartMonth__c = 'Jan';
        nirecord.NIStartYear__c= '2016';
        nirecord.DealProbability__c= '25%';
        nirecord.isConvert__c=true;
        nirecord.Product__c = prod.id;
        nirecord.UnitPrice__c = 1;
        insert nirecord;
        
        PageReference pageRef1 = Page.ConvertToOpportunity;
        //pageRef.getParameters().put('GroupID', String.valueOf(GroupID));
        pageRef1.getParameters().put('CompanyID', String.valueOf(Company1.id));
        Test.setCurrentPage(pageRef1);
        
           //Opportunity
           List<Account> accList = TestUtils.createAccounts(1, 'test', 'CType', true);
          List<Opportunity> oppList = TestUtils.createOpportunity(1, accList.get(0).Id, true);
           Opportunity oppty = oppList.get(0);
           ApexPages.StandardController controller = new ApexPages.StandardController(oppty);
       		pageRef1.getParameters().put('OpportunityID', oppty.id);
       		 AccountPlanActionPlanConvert OpptyConstructor= new AccountPlanActionPlanConvert(controller); 
           //
           
        AccountPlanActionPlanConvert AcctPlanConvert= new AccountPlanActionPlanConvert();     
        String Actplanid = AcctPlanConvert.ActionPlanID;
        OpportunityLineItem oppline  = AcctPlanConvert.OppLineItem;
        String jscript= AcctPlanConvert.jsScript;
        User us = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        us.Segment__c=null;
        update us;
        AcctPlanConvert.doconvert();
        us.Segment__c='SE';
        update us;
        AcctPlanConvert.doconvert();
        us.Segment__c='MB';
        update us;
        AcctPlanConvert.doconvert();

        
        Date today = system.today();
        AcctPlanConvert.Oppty.Name = 'Step5Test';
        AcctPlanConvert.doconvert();
        AcctPlanConvert.Oppty.OpportunityTypeForNI__c = 'Credit Product';
        AcctPlanConvert.doconvert();
        AcctPlanConvert.Oppty.Expected_submit_date__c = today-1;
        AcctPlanConvert.doconvert(); 
        AcctPlanConvert.Oppty.Expected_submit_date__c = today ;
        AcctPlanConvert.doconvert();
        AcctPlanConvert.Oppty.CloseDate= today-1;
        AcctPlanConvert.doconvert();
        AcctPlanConvert.Oppty.CloseDate= today;
        AcctPlanConvert.doconvert();
        
        List<AcctPlanNIProject__c > NIProjectList =AcctPlanConvert.NIProjectListNoOpt;
        
        for(AcctPlanNIProject__c n: NIProjectList){
        n.isConvert__c=true;
        }
        
        AcctPlanConvert.doconvert();
        
           
    }
        
        
        
    public static testMethod void ConvertSuccess(){
        setInitial();
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test AccountPlan Step5' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';  
        insert testAccount1;
        
        //Create Contact
        Contact cont1 = new Contact();
        cont1.FirstName='AccountPlan';
        cont1.LastName='Step5';
        cont1.Position__c = 'Manager';
        cont1.Accountid= testAccount1.id;
        insert cont1;
        
        //Create Account Plan
        AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
        Company1.Account__c=testAccount1.id;
        //Company1.Name='AccountPlan Step5';
        insert Company1;
        
        AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
        Wallet1.AcctPlanCompanyProfile__c = Company1.id;
        insert Wallet1;
        
        AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
        WalletDomain1.AcctPlanWallet__c = Wallet1.id;
        WalletDomain1.WalletDomain__c = 1;
        WalletDomain1.Priority__c ='High';
        WalletDomain1.SubDomain__c ='Liquidity Management';
        WalletDomain1.TypeOfNI__c = 'NIIC';
        insert WalletDomain1;
        
        
        AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
        acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
        acctplan1.Objective__c = 'Acquire New customers';
        acctplan1.Status__c = 'Post Board';
        acctplan1.WinningPropostion__c = 'Test Class';
        insert acctplan1;   
          
          Pricebook2 standardPricebook = new Pricebook2(); 
          Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];
          Map<String,Pricebook2> pricebookmap = new Map<String,Pricebook2>();
          for(Pricebook2 R : Records){
              pricebookmap.put(r.Name,r);
          }
        Id pricebookselected;
        
        User us = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        us.Segment__c='MB';
        update us;
        system.debug('pricebookmap='+pricebookmap.size());
        system.debug('pricebookmap value='+Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c);
        system.debug('pricebookmap value='+pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id);
        if(us.Segment__c != null){
                   //standardPricebook.id = pricebookmap.get('SE Price Book').id;
                    pricebookselected = pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id;
                  
                }else{ 
                    pricebookselected = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
                }
        
        List<PricebookEntry> pricbook = [SELECT ID,Name,IsActive,Product2Id,Pricebook2Id,Product2.Product_Level__c From PricebookEntry WHERE IsActive = true  AND Product2.Product_Level__c ='4' AND PriceBook2ID =: pricebookselected limit 1];
        Id prod;
        for(PricebookEntry p: pricbook){
        prod=p.Product2Id;
        }  
           
        AcctPlanNIProject__c nirecord = new AcctPlanNIProject__c();
        nirecord.AcctPlanActionPlanID__c= acctplan1.id;
        nirecord.PropsProductOrServices__c = 'OD';
        nirecord.ExpectedIncremental__c = 10000;
        nirecord.TypeOfNI__c = 'NIIc';
        nirecord.NIRecuringType__c='Recurring';
        nirecord.ExpectedNimRate__c=10.00;
        nirecord.ExpectedIncrementalNIPerYear1Year__c=10000;
        nirecord.ExpectedIncrementalNIPerYear2Year__c=10000;
        nirecord.NIStartMonth__c = 'Jan';
        nirecord.NIStartYear__c= '2016';
        nirecord.DealProbability__c= '25%';
        nirecord.isConvert__c=true;
        nirecord.product__c = prod;
        insert nirecord;
        

        PageReference pageRef3 = Page.ConvertToOpportunity;
        //pageRef.getParameters().put('GroupID', String.valueOf(GroupID));
        pageRef3.getParameters().put('CompanyID', String.valueOf(Company1.id));
        Test.setCurrentPage(pageRef3);
        
        AccountPlanActionPlanConvert AcctPlanConvert3= new AccountPlanActionPlanConvert();
        Date today = system.today();
        AcctPlanConvert3.Oppty.Name = 'Step5Test';
        AcctPlanConvert3.Oppty.OpportunityTypeForNI__c = 'Credit Product';
        AcctPlanConvert3.Oppty.Expected_submit_date__c = today;
        AcctPlanConvert3.Oppty.CloseDate= today;
        List<AcctPlanNIProject__c > NIProjectList2 =AcctPlanConvert3.NIProjectListNoOpt;
        
        for(AcctPlanNIProject__c n2 : NIProjectList2){
        n2.isConvert__c=true;
        }
        
        AcctPlanConvert3.doconvert(); 
        
        for(AcctPlanNIProject__c n2 : NIProjectList2){
        n2.UnitPrice__c= 5000;
        }

        
        AcctPlanConvert3.doconvert();   
           
           
    } 
        
        
        
    public static testMethod void ConvertNoRecordError(){
        setInitial();
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test AccountPlan Step5' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
        insert testAccount1;
        
        //Create Contact
        Contact cont1 = new Contact();
        cont1.FirstName='AccountPlan';
        cont1.LastName='Step5';
        cont1.Position__c = 'Manager';
        cont1.Accountid= testAccount1.id;
        insert cont1;
        
        //Create Account Plan
        AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
        Company1.Account__c=testAccount1.id;
        //Company1.Name='AccountPlan Step5';
        insert Company1;
        
        AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
        Wallet1.AcctPlanCompanyProfile__c = Company1.id;
        insert Wallet1;
        
        AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
        WalletDomain1.AcctPlanWallet__c = Wallet1.id;
        WalletDomain1.WalletDomain__c = 1;
        WalletDomain1.Priority__c ='High';
        WalletDomain1.SubDomain__c ='Liquidity Management';
        WalletDomain1.TypeOfNI__c = 'NIIC';
        insert WalletDomain1;
        
        
        AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
        acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
        acctplan1.Objective__c = 'Acquire New customers';
        acctplan1.Status__c = 'Post Board';
        acctplan1.WinningPropostion__c = 'Test Class';
        insert acctplan1;   
           
        
        PageReference pageRef2 = Page.ConvertToOpportunity;
        //pageRef.getParameters().put('GroupID', String.valueOf(GroupID));
        pageRef2.getParameters().put('CompanyID', String.valueOf(Company1.id));
        Test.setCurrentPage(pageRef2);
        
        AccountPlanActionPlanConvert AcctPlanConvert2= new AccountPlanActionPlanConvert();
        String Actplanid = AcctPlanConvert2.ActionPlanID;
        OpportunityLineItem oppline  = AcctPlanConvert2.OppLineItem;
        String jscript= AcctPlanConvert2.jsScript;
        
        AcctPlanConvert2.doconvert();
    }
        
        
        
}