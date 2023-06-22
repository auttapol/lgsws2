@isTest
public class AccountCreationCheckDisqualifiedTest {

    
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
        
        List<Status_Code__C> statusList = new List<Status_Code__C>();
         Status_Code__c error61 = new Status_Code__c();
        error61.isError__c = false;
        error61.Name = '6001';
        error61.Status_Message__c = 'Test'; 
         Status_Code__c error62 = new Status_Code__c();
        error62.isError__c = false;
        error62.Name = '6002';
        error62.Status_Message__c = 'Test'; 
        statusList.add(error61);
        statusList.add(error62);
        
        insert statusList;
    }
    
    
    
    public static testmethod void RunDisqualifiedProspectbyID(){
        System.debug(':::: RunDisqualifiedProspect Start ::::');
        
        u = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            
           
        LisT<Account> acct =  TestUtils.createAccounts(3,'testDisqualified','Juristic', false);
            Account firstAcct = acct.get(0);
            firstAcct.ID_Type_PE__c = 'BRN ID';
            firstAcct.ID_Number_PE__c = '15551';
            firstAcct.Phone = '423432';
            insert firstacct;
            Account secondAcct = acct.get(1);
            secondAcct.Name = 'secondAcct';
            secondAcct.ID_Type_PE__c = 'BRN ID';
            secondAcct.ID_Number_PE__c = '15551';
            secondAcct.Phone ='123123';
            insert secondAcct;
           
            Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(secondAcct);
            AccountCreationCheckDisqualified acctdisinsert = new AccountCreationCheckDisqualified(controllerinsert);
            acctdisinsert.CheckDisqualified();
            acctdisinsert.viewCustomer();
            acctdisinsert.cancelCutomer();
            
            Account thirdacct = acct.get(2);
             ApexPages.StandardController controllerinsert2 = new ApexPages.StandardController(thirdacct);
            AccountCreationCheckDisqualified acctdisinsert2 = new AccountCreationCheckDisqualified(controllerinsert2);
            acctdisinsert2.CheckDisqualified();
            Test.stopTest(); 
            
            
           
        }    
        
        System.debug(':::: RunDisqualifiedProspect End ::::');
    }
    
    
   
    
}