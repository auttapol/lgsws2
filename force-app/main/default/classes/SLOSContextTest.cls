@istest
public class SLOSContextTest {
  
    static {
        TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        //TestUtils.CreateTriggerMsg();
        TestInit.createCustomSettingStageApproval();
        
    }
    
    public static Id pb1 {get{return Test.getStandardPricebookId();}set;}
    public static pricebook2 pb2 {get;set;}
    public static product2 prod {get;set;}
    public static pricebookentry pbe {get;set;}
    public static account acct {get;set;}
    public static opportunity oppt {get;set;} 
    public static host_product_mapping__c hostmap {get;set;}
    
    public static void setInitial()
    {
        insert new status_code__c(name = '8041', Status_Message__c = 'test');
        insert new status_code__c(name = '8043', Status_Message__c = 'test');
        insert new status_code__c(name = '8037', Status_Message__c = 'test');
        insert new status_code__c(name = '8038', Status_Message__c = 'test');
        insert new status_code__c(name = '8039', Status_Message__c = 'test');
        insert new status_code__c(name = '8023', Status_Message__c = 'test');
        insert new status_code__c(name = '8040', Status_Message__c = 'test');
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        insert new AppConfig__c(name = 'FilterPrimaryProvince', value__c = 'จ.|จังหวัด');
        insert new AppConfig__c(name = 'FilterPrimaryDistrict', value__c = 'อ.|อำเภอ|เขต');
        insert new AppConfig__c(name = 'FilterPrimarySubDistrict', value__c = 'ต.|ตำบล|แขวง');
        insert new AppConfig__c(name = 'FilterRetailSegment	', value__c = '5|6|7|8|9');
        insert new Trigger_Msg__c(name = 'Permission_Create_Opportunity', Description__c   = 'description');
        insert new Account_Plan_Fiscal_Year__c(name='2',ad_year__c='2015',be_year__c='2558');
        user u = [select segment__c from user where id =: userinfo.getUserId()];
        if (u.segment__c != null){ 
            insert new Price_book_access__c(name=u.segment__c,PricebookItem__c='test');
        }
        else insert new Price_book_access__c(name='MB',PricebookItem__c='test');
        insert new Price_book_access__c(name='Default',PricebookItem__c='test');
        
        pb2 = new pricebook2(name='test',isActive=true,TMB_Pricebook__c='test');
        insert pb2;
        prod = new product2(name='test',isactive=true,Product_Domain__c='Risk');
        insert prod;
        pbe = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb1,usestandardprice=false);
        insert pbe;
        
        acct = testutils.createAccounts(1, 'fname', 'Individual', false).get(0);
        acct.Account_Type__c = 'Existing Customer';
        acct.ID_Type_PE__c =null;
        acct.ID_Number_PE__c =null;
        insert acct;
        oppt = new opportunity(Pricebook2Id=pb1,accountid = acct.id, name='test', ownerid = acct.ownerid,
                               Expected_submit_date__c = date.today(), closedate = date.today(),
                               Host_Product_Group__c = 'TMB SME SmartBiz',
                               stagename = 'Analysis');
        insert oppt;
		
        hostmap = new Host_Product_Mapping__c(Active_Flag__c=true,Host_Name__c='SLS',
                                              Host_Product_Group__c='TMB SME SmartBiz',
                                             Product_Program__c='TMB SME SmartBiz',Credit_Type_ID__c='102',
                                             Host_Prod_Name_Credit_Facility__c ='OD for Floating Charge',Product_Group_ID__c='1',
                                             Product_Program_ID__c='1',Salesforce_Product__c=prod.id);
     	insert hostmap;  
    }
    public static testmethod void myPositiveUnitTest(){
        
                Test.startTest();
        
        setInitial();
        
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='Dec',RevisedStartYear__c=string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c='Dec',RevisedStartYearFee__c=string.valueof(system.today()).substring(0,4)
                                                               ,Type_Of_Reference__c='NIIc',Type_Of_Reference_Fee__c='AS Fee'
                                                               ,host_product_mapping__c=hostmap.id
                                                              );
          insert opptline;

        
        
        List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
        lines.add(opptline);
        SLOSContext context = new SLOSContext();
        SLOSContext.SLOSRequest request = new SLOSContext.SLOSRequest(oppt ,lines);
        
        Test.stopTest();
        
    }

}