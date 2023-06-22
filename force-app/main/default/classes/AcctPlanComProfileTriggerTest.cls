@IsTest
public class AcctPlanComProfileTriggerTest{
    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.CreateProceBook();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    }
       public static testmethod void AcctPlanComProfileTrigger(){
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
        //Company1.Status__c = 'In Progress'; 
        Company1.Status__c = 'Approved'; 
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
        WalletDomain1.WalletFieldName__c = 'TotalWalletNiic__c';
        WalletDomain1.Row__c = 1;
        WalletDomain1.Seq__c = 1.1;
        insert WalletDomain1;

        AcctPlanProdStrategy__c strategy1 = new AcctPlanProdStrategy__c ();
        strategy1.AcctPlanWallet__c = Wallet1.id;
        strategy1.AcctPlanCompanyProfileID__c = Company1.id;
        strategy1.Name= '1. NIIc';
        insert strategy1;
        
        AcctPlanProdStrategy__c strategy2 = new AcctPlanProdStrategy__c ();
        strategy2.AcctPlanWallet__c = Wallet1.id;
        strategy2.AcctPlanCompanyProfileID__c = Company1.id;
        strategy2.Name= '2. NIId';
        insert strategy2;
        
                AcctPlanProdStrategy__c strategy3 = new AcctPlanProdStrategy__c ();
        strategy3.AcctPlanWallet__c = Wallet1.id;
        strategy3.AcctPlanCompanyProfileID__c = Company1.id;
        strategy3.Name= '3.1 TF Fee';
        insert strategy3;
        
        AcctPlanProdStrategy__c strategy4 = new AcctPlanProdStrategy__c ();
        strategy4.AcctPlanWallet__c = Wallet1.id;
        strategy4.AcctPlanCompanyProfileID__c = Company1.id;
        strategy4.Name= '3.2 FX Fee';
        insert strategy4;
        
        AcctPlanProdStrategy__c strategy5 = new AcctPlanProdStrategy__c ();
        strategy5.AcctPlanWallet__c = Wallet1.id;
        strategy5.AcctPlanCompanyProfileID__c = Company1.id;
        strategy5.Name= '3.3 L/G Fee';
        insert strategy5;
        
        
        AcctPlanProdStrategy__c strategy6 = new AcctPlanProdStrategy__c ();
        strategy6.AcctPlanWallet__c = Wallet1.id;
        strategy6.AcctPlanCompanyProfileID__c = Company1.id;
        strategy6.Name= '3.4 Cash Fee';
        insert strategy6;
        
        
        AcctPlanProdStrategy__c strategy7 = new AcctPlanProdStrategy__c ();
        strategy7.AcctPlanWallet__c = Wallet1.id;
        strategy7.AcctPlanCompanyProfileID__c = Company1.id;
        strategy7.Name= '3.5 AS Fee';
        insert strategy7;
        
        
        AcctPlanProdStrategy__c strategy8 = new AcctPlanProdStrategy__c ();
        strategy8.AcctPlanWallet__c = Wallet1.id;
        strategy8.AcctPlanCompanyProfileID__c = Company1.id;
        strategy8.Name= '3.6 Credit Fee';
        insert strategy8;
        
        AcctPlanProdStrategy__c strategy9 = new AcctPlanProdStrategy__c ();
        strategy9.AcctPlanWallet__c = Wallet1.id;
        strategy9.AcctPlanCompanyProfileID__c = Company1.id;
        strategy9.Name= '3.7 BA Fee';
        insert strategy9;
        
        
        AcctPlanProdStrategy__c strategy10 = new AcctPlanProdStrategy__c ();
        strategy10.AcctPlanWallet__c = Wallet1.id;
        strategy10.AcctPlanCompanyProfileID__c = Company1.id;
        strategy10.Name= '3.8 Derivative Fee';
        insert strategy10;
        
        
        AcctPlanProdStrategy__c strategy11 = new AcctPlanProdStrategy__c ();
        strategy11.AcctPlanWallet__c = Wallet1.id;
        strategy11.AcctPlanCompanyProfileID__c = Company1.id;
        strategy11.Name= '3.9 IB Fee';
        insert strategy11;
        
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
        
        
        
        Company1.Status__c = 'Approved';
        update Company1;
        
        }
}