@isTest
public class CommercialDuplicateCheckTest {
    
    public static RecordType ProspectRecordType {get{
        if(ProspectRecordType ==null){
           ProspectRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Prospect' 
                                 AND sObjectType='Account' LIMIT 1];
        }
        return ProspectRecordType;
    }set;}
    
    
    public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}
  
    
    
    
    

    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();     
     	Sub_Purpose_Mapping__c subpurpose = new Sub_Purpose_Mapping__c();

     	subpurpose.Main_purpose__c = 'CB';
     	subpurpose.Sub_Purpose__c = 'Sell product';
     	subpurpose.Name = 'Subpurpose1';
     insert subpurpose;
        
         LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Individual', false);
            Account firstAcct = acct.get(0);
            firstAcct.ID_Type_PE__c = 'Passport ID';
            firstAcct.ID_Number_PE__c = '13255555';
            firstAcct.Phone = '0877874871';
         	firstAcct.RTL_NID__c = '555';
         	firstAcct.RecordTypeId = ProspectRecordType.id;
            insert firstacct;

        
         Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadREc.ID_REGEX__c = '556';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255556';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.recordTypeId = CommercialLeadRecordType.id;
        LeadRec.Status = 'Open';
        
         insert leadRec;
         
        
    }
    
    
    
    
     public static testmethod void LeadDuplicatedbyAccount(){
         
         Lead OriginalleadRec = new Lead();
        OriginalleadRec.Phone = '0877874871';
        OriginalleadRec.Company = 'LeadExtension';
        //OriginalleadRec.Account__c = firstacct.id;
        OriginalleadRec.ID_Type__c = 'Passport ID';
        OriginalleadRec.ID_Number__c = '13255555';
        OriginalleadRec.Mobile_No__c = '053532198';
        OriginalleadRec.Customer_Type__c = 'Individual';
        OriginalleadRec.FirstName =  'LeadExFirst';
        OriginalleadRec.LastName = 'LeadExLast';
         
           
            
         
            System.debug(CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(OriginalleadRec,OriginalleadRec));
         
    }

    
   

     public static testmethod void LeadDuplicatedbyLead(){
       
         Lead OriginalleadRec = new Lead();
        OriginalleadRec.Phone = '0877874871';
        OriginalleadRec.Company = 'LeadExtension';
        //OriginalleadRec.Account__c = firstacct.id;
        OriginalleadRec.ID_Type__c = 'Passport ID';
        OriginalleadRec.ID_Number__c = '13255556';
        OriginalleadRec.Mobile_No__c = '053532198';
        OriginalleadRec.Customer_Type__c = 'Individual';
        OriginalleadRec.FirstName =  'LeadExFirst';
        OriginalleadRec.LastName = 'LeadExLast';
           
            
            Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = 
                CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(OriginalleadRec,OriginalleadRec);
         
         CommercialDuplicateCheck.LeadWrapper lwrap = leadwrapperMap.get(0);
         System.debug(lwrap.OrgininalrecordType);
         
         
    }
    
}