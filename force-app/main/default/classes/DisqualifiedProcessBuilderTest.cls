@IsTest
public class DisqualifiedProcessBuilderTest {
    public static String STR_POSITIVE = 'positive';
    public static String STR_NEGATIVE = 'negative';
    public static User u;
    public static User u2;
   

    
    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    }
    
   /* public static testmethod void RunDisqualifiedProspectbyID(){
        System.debug(':::: RunDisqualifiedProspect Start ::::');
        
        u = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            
           
        LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Juristic', false);
            Account firstAcct = acct.get(0);
            firstAcct.ID_Type_PE__c = 'BRN ID';
            firstAcct.ID_Number_PE__c = '15551';
            firstAcct.Phone = '423432';
            insert firstacct;
             Id [] fixedSearchResults= new Id[1];
           fixedSearchResults[0] = firstacct.id;
           Test.setFixedSearchResults(fixedSearchResults);
            
            
            Account secondAcct = acct.get(1);
            secondAcct.ID_Type_PE__c = 'BRN ID';
            secondAcct.ID_Number_PE__c = '15552';
            secondAcct.Phone ='123123';
            insert secondAcct;
            
            secondAcct.ID_Type_PE__c = 'BRN ID';
            secondAcct.ID_Number_PE__c = '15551';
            update secondAcct;
            System.debug(':::: RunDisqualifiedProspect End ::::');
        }        
    }
    
    public static void flowTest(String testMode){
        //Test for T01 , T04
        List<Account> listAcc;
        for(Account a : TestInit.accountList.values() ){
            a = setValueCase_1(a,testMode);
        }
        
        try{
            update TestInit.accountList.values();
        }catch (DmlException e){
            System.debug('error : '+e.getMessage());
        }
        
        listAcc = [select Id,OwnerId,Owner_change_notification__c,Change_to_owner__c,Prospect_Converted_Date__c from Account where Id = :TestInit.accountList.keySet()];
        for(Account a : listAcc){
            if(testMode == STR_POSITIVE){
                //System.assertEquals(u2.Id, a.OwnerId);
                //System.assertEquals(true, a.Owner_change_notification__c);         
                //System.assertEquals(Date.today(), a.Prospect_Converted_Date__c);     
            }else{
                System.assertEquals(UserInfo.getUserId(), a.OwnerId);
                System.assertEquals(false, a.Owner_change_notification__c);
                //System.assertEquals(null, a.Prospect_Converted_Date__c);                   
            }
            
        }
        
        // Test for T05 , T06
        TestInit.accountList = null;
        TestInit.accountList.putAll(listAcc);
        for(Account a : TestInit.accountList.values() ){
            a = setValueCase_2(a,testMode);
        }
        
        try{
            update TestInit.accountList.values();
        }catch (DmlException e){
            System.debug('error : '+e.getDmlStatusCode(0) );
            System.assertEquals('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY',e.getDmlStatusCode(0));  
        }
        
        listAcc = [select Id,OwnerId,Owner_change_notification__c,Change_to_owner__c from Account where Id = :TestInit.accountList.keySet()];
        for(Account a : listAcc){
            if( testMode == STR_POSITIVE ){
                System.assertEquals(u2.Id, a.OwnerId);
                //System.assertEquals(true, a.Owner_change_notification__c);
            }else{
                System.assertEquals(a.OwnerId, a.OwnerId);
                System.assertEquals(false, a.Owner_change_notification__c);
            }
            
        }
    }
    
    public static Account setValueCase_1(Account a,String testMode){
        if( testMode == STR_POSITIVE ){
            a.Re_assign_prospect__c = 'yes';
            a.Account_Type__c = 'Qualified Prospect';
            a.Suggested_Sub_Segment__c = 'TEST';
        }else{
            a.Re_assign_prospect__c = 'yes';
            a.Account_Type__c = 'Qualified Prospect';
            a.Suggested_Sub_Segment__c = null;
        }
        return a;
    }
    
    public static Account setValueCase_2(Account a,String testMode){
        if( testMode == STR_POSITIVE ){
            a.Account_Approval_Status__c = 'Final Approved';
            a.Change_to_owner__c = u2.Id;
        }else{
            a.Account_Approval_Status__c = 'Final Approved';
            a.Change_to_owner__c = null;
        }
        return a;
    }    
    
    public static testmethod void ChangeOwnerAcctPlanTest(){
          //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test AccountPlan Step5' ;
        testAccount1.OwnerId = UserInfo.getUserId();
        testAccount1.Phone ='234123413';
         testAccount1.Mobile_Number_PE__c ='234123413';
        insert testAccount1;
        
        //Create Contact
        Contact cont1 = new Contact();
        cont1.FirstName='AccountPlan';
        cont1.LastName='Step5';
        cont1.Position__c = 'Manager';
        cont1.Accountid= testAccount1.id;
        insert cont1;
        
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        if(currentYear>2557) currentYear = currentDate.year() - 543;
        
        String YearStr = String.ValueOf(currentYear);
        
        //Create Account Plan
        AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
        Company1.Account__c=testAccount1.id;
        //Company1.Name='AccountPlan Step5';
        Company1.Status__c = 'In Progress';
        Company1.ownerId = UserInfo.getUserId();
        Company1.Year__c  = YearStr;
        insert Company1;
        
        User us = [SELECT ID,Segment__c,IsActive FROM User WHERE IsActive=:true and ID !=:UserInfo.getUserId() LIMIT 1];
        testAccount1.Owner = us;
        update testAccount1;
        
        User us2 = [SELECT ID,Segment__c,IsActive FROM User WHERE IsActive=:true and ID !=:us.Id LIMIT 1];
        testAccount1.Owner = us2;
        update testAccount1;
        
     
     }*/
    
    public static testmethod void RunDisqualifiedLeadByID(){
                   RecordType CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        
        List<Account> Acctlist = TestUtils.createAccounts(3,'AccountLead', 'Individual', false);
        
        account Acct1 = acctlist.get(0);
        acct1.ID_Type_PE__c = 'Alien ID';
        acct1.ID_Number_PE__c = '15551';
        acct1.Customer_Type__c = 'Individual';
        acct1.Mobile_Number_PE__c = '05334234';
        insert acct1;
        account Acct2 = acctlist.get(1);
        acct2.ID_Type_PE__c = 'Alien ID';
        acct2.ID_Number_PE__c = '155512';
        acct2.Customer_Type__c = 'Individual';
        acct2.Mobile_Number_PE__c = '05334234';
        insert acct2;
            
        Lead orginalLead = new Lead(LastName = 'Four', Company='Fry And Sons',ID_TYPE__c='Alien ID',ID_Number__c='155513',
                               MobilePhone='54354123', Mobile_No__c ='545345',Customer_Type__c='Individual'
                              );
        orginalLead.RecordTypeId = CommercialLeadRecordType.id;
        
        insert orginalLead;
        Id [] fixedSearchResults= new Id[2];
       fixedSearchResults[0] = acct1.id;
       //fixedSearchResults[1] = acct2.id;
       fixedSearchResults[0] =orginalLead.id;
       Test.setFixedSearchResults(fixedSearchResults);
        
        Lead LeadOne = new Lead(LastName = 'One', Company='Fry And Sons',ID_TYPE__c='BRN ID',ID_Number__c='15551',
                               MobilePhone='54354123', Mobile_No__c ='545345',Customer_Type__c='Juristic'
                              );
        Lead LeadTwo = new Lead(LastName = 'Two', Company='Fry And Sons',ID_TYPE__c='Alien ID',ID_Number__c='155512',
                               MobilePhone='54354123', Mobile_No__c ='545345',Customer_Type__c='Individual'
                              );
        Lead LeadThree = new Lead(LastName = 'Three', Company='Fry And Sons',ID_TYPE__c='Alien ID',ID_Number__c='15551',
                               MobilePhone='54354123', Mobile_No__c ='545345',Customer_Type__c='Individual'
                              );
         Lead LeadFour = new Lead(LastName = 'Four', Company='Fry And Sons',ID_TYPE__c='Alien ID',ID_Number__c='155513',
                               MobilePhone='54354123', Mobile_No__c ='545345',Customer_Type__c='Individual'
                              );
        List<Lead> LeadList = new List<Lead>();
        LeadList.add(LeadOne);
        LeadList.add(LeadTwo);
        LeadList.add(LeadThree);
        LeadList.add(LeadFour);
        
        List<DisqualifiedProcessBuilder.LeadWrapperSOAP> LeadWrapperList = new List<DisqualifiedProcessBuilder.LeadWrapperSOAP>();
        List<DisqualifiedProcessBuilder.LeadWrapperSOAP> LeadCheckResult = new List<DisqualifiedProcessBuilder.LeadWrapperSOAP>();
        Integer index  = 1;
        for(Lead leadRec  : LeadList){
            DisqualifiedProcessBuilder.LeadWrapperSOAP LeadWrapper = new DisqualifiedProcessBuilder.LeadWrapperSOAP();
            LeadWrapper.leadRec = LeadRec;
            LeadWrapper.index = index;
            LeadWrapperList.add(leadWrapper);
            index++;
        }
        
        
        for(DisqualifiedProcessBuilder.LeadWrapperSOAP leadwrap : DisqualifiedProcessBuilder.CheckDisqualifiedLeadSOAP(LeadWrapperList) ){
            System.debug(leadwrap.Leadrec);
            System.debug(leadwrap.index);
            System.debug(leadwrap.isfoundDuplicate);
            System.debug(leadwrap.ErrorMessage);
        }
        
        
    }    
    
    
    
}