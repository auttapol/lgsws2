public class LeadProxyExtensionCtrl {    
    private final ApexPages.StandardController std ;
    private final Lead Leadrec;
    private RecordType recTypes;
    public string recordTypeName {
        get {
            return recordTypeId != null ? Schema.Sobjecttype.Lead.getRecordTypeInfosById().get(recordTypeId).getDeveloperName() : '';
        }
    }
    public string recordTypeId {get;set;}
    public string referralId {get;set;}
    public boolean isCommercial;
    public string AccountId {get;set;}
    public Lead LeadFromSearch{get;set;}
    public string url{get;set;}
    
    
        
    public LeadProxyExtensionCtrl(ApexPages.StandardController controller){
        std = controller;  
        isCommercial = false;
        Leadrec = (Lead)std.getRecord();
        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');  
        recordTypeId = recordTypeId != null ? recordTypeId : ApexPages.currentPage().getParameters().get('recordTypeId');  
        referralId = ApexPages.currentPage().getParameters().get('referralId');
        //AccountId = ApexPages.currentPage().getUrl().substringBetween('_lkid=', '&');
        //Passing parameter from search customer
        LeadFromSearch = new lead();
        getPassingParams(LeadFromSearch);
        //Passing parameter from referral
        if(referralId!=null){
            populateReferralInfo(LeadFromSearch,referralId);
        }
        system.debug(referralId);
        // Get Record TypeID and Name
    
    }
    public PageReference redirectPage(){         
        system.debug(':::: Lead Id  = ' + Lead.Id);
        string url ='/';
        
        //if is Edit Mode
         if(LeadRec.id!=null){
              recTypes = [select Id, Name, sobjectType,DeveloperName from RecordType   
                    where Id  =:Leadrec.RecordTypeId
                   LIMIT 1];
             
             //Commercial
             //
             //
             if(recTypes.DeveloperName.containsIgnoreCase('Commercial')){
                 url = '/apex/LeadCreation?id='+ Leadrec.Id; 
                 if(referralId != null) url += '&referralId='+referralId;
                 isCommercial =true;
             }
             
             //Retail
             if(recTypes.DeveloperName.containsIgnoreCase('Retail')){
                 url = '/apex/RetailLeadEdit?id='+ Leadrec.Id; 
                 if(referralId != null) url += '&referralId='+referralId;
             }
    
         }else{ // Create Mode
            Schema.DescribeSObjectResult dsr = Lead.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordType;
            
             for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()) {
                    defaultRecordType = rti;
                }
            }
            
             if(null == recordTypeId){
                 recTypes = [select Id, Name, sobjectType,DeveloperName from RecordType   
                         where Id  =:defaultRecordType.getRecordTypeId()
                         LIMIT 1];
             }else{
                 recTypes = [select Id, Name, sobjectType,DeveloperName from RecordType   
                         where Id  =:recordTypeId
                         LIMIT 1];
             }
             
             //Commercial 
             if(recTypes.DeveloperName.containsIgnoreCase('Commercial')){
                url = '/apex/LeadCreation'; 
                if(referralId != null) url += '?referralId='+referralId;
                isCommercial =true;
             }
             
             //Retail
             if(recTypes.DeveloperName.containsIgnoreCase('Retail')){
                url = '/apex/RetailLeadCreation?RecordType='+recTypes.Id;
                if(referralId != null) url += '&referralId='+referralId;
             }
                          
        }   
        
        System.debug('URL : '+url);
        if(isCommercial){ 
            PageReference page = new PageReference(url); 
            page.setRedirect(true); 
            return page; 
        }else{
            PageReference page = new PageReference(url); 
            page.setRedirect(true); 
            return page; 
        }
    }

    
 public PageReference redirectMobile(){         
        system.debug(':::: Lead Id  = ' + LeadRec.Id);
         
        string url ='/';
        //Edit Mode
         if(LeadRec.id !=null){
              recTypes = [select Id, Name, sobjectType,DeveloperName from RecordType   
                    where Id  =:Leadrec.RecordTypeId
                   LIMIT 1];
             
             //Commercial
             //
             //
             if(recTypes.DeveloperName.containsIgnoreCase('Commercial')){
                 url = '/apex/LeadCreation?id='+ Leadrec.Id;
                 if(referralId != null) url += '&referralId='+referralId;
                 isCommercial =true;
             }
             
             //Retail
             if(recTypes.DeveloperName.containsIgnoreCase('Retail')){
                url = '/apex/RetailLeadEdit?id='+ Leadrec.Id;
                if(referralId != null) url += '&referralId='+referralId;
             }     
            
         }
     //Create Mode
     else{
             
            Schema.DescribeSObjectResult dsr = Lead.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordType;
            for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()) {
                    defaultRecordType = rti;
                }
            }
            
            if(null == recordTypeId){
                 recTypes = [select Id, Name, sobjectType,DeveloperName from RecordType   
                         where Id  =:defaultRecordType.getRecordTypeId()
                         LIMIT 1];
             }else{
                 recTypes = [select Id, Name, sobjectType,DeveloperName from RecordType   
                         where Id  =:recordTypeId
                         LIMIT 1];
             }
            //Commercial
            if(recTypes.DeveloperName.containsIgnoreCase('Commercial')){
                url = '/apex/LeadCreation'; 
                if(referralId != null) url += '?referralId='+referralId;
                isCommercial=true;
            }
            //Retail
            if(recTypes.DeveloperName.containsIgnoreCase('Retail')){
                url = '/apex/RetailLeadCreation?RecordType='+recTypes.Id; 
                if(referralId != null) url += '&referralId='+referralId;
            }    
        }   
        
         if(isCommercial){
             PageReference result = Page.LeadCreateMobile;
             if(LeadRec.id!=null){
                   result.getParameters().put('id',LeadRec.id);
             }
              
             if (recTypes != null ){
                  result.getParameters().put('RecordType',recTypes.id);
             }
               
         
            result.setRedirect(true); 
            return result;
         }else{
            PageReference page = new PageReference(url); 
            page.setRedirect(true); 
            return page; 
         }
    }


    /////new Parameter method for commercial Lead Record type/////
    public static Map<String, Branch_and_Zone__c> branchNameMap{
        get{
            if(branchNameMap ==null){
              branchNameMap = new Map<String, Branch_and_Zone__c>();
              for(Branch_and_Zone__c branchzone : [Select Id,Name, Branch_Code__c, RTL_Region_Code__c, RTL_Zone_Code__c from Branch_and_Zone__c]) {
                  branchNameMap.put(branchzone.Name, branchzone);
              }
            }
            return branchNameMap;
          
        }set;}
    private static String assignValue(String existingValue,String newValue){
        if(existingValue == null)
            return newValue;
        return existingValue;
    }    

    private void getPassingParams(lead  leadobj){
        
        leadobj.Customer_type__c = ApexPages.currentPage().getParameters().get('customer_type');
        leadobj.Company = ApexPages.currentPage().getParameters().get('company_name');
        leadobj.Mobile_No__c = ApexPages.currentPage().getParameters().get('mobile_number');
        leadobj.Office_No__c = ApexPages.currentPage().getParameters().get('office_number');
        leadobj.ID_Type__c = ApexPages.currentPage().getParameters().get('id_type');
        leadobj.ID_Number__c = ApexPages.currentPage().getParameters().get('id_number');
        leadobj.Status = 'Open';
        
    }
    private void populateReferralInfo(Lead leadObj,String referralId){
        String action = 'Create';
        if(LeadRec.id!=null){
            action = 'Edit';
        }
        Map<String,String> channelLeadSourceMap = RTL_ReferralAssignUtility.channelLeadSourceMap;
        RTL_Referral__c referral = [SELECT Id,Name,RTL_Mobile1__c,RTL_FirstName__c,RTL_LastName__c,RTL_Title__c,RTL_Ext__c,
        RTL_Position__c,RTL_Sales_Amount_Per_Year__c,RTL_Company__c,RTL_Email__c,RTL_Office_Number__c,
        RTL_Comment__c,RTL_EmployeeId__c,RTL_Employee_Name__c,RTL_Account_Name__c,OwnerId,
        RTL_Preferred_Branch__c,RTL_Branch__c,RTL_Phone1__c,RTL_Stage__c,RTL_Refer_Branch_Name__c,RTL_Type__c,
        RecordType.DeveloperName,RTL_Channel_Segment__c,(SELECT Id,Name FROM Leads__r)
            FROM RTL_Referral__c WHERE ID=:referralId LIMIT 1 ];
        leadObj.RTL_Referral__c = referralId;
        if(action == 'Create'){
            leadObj.LastName = assignValue(leadObj.LastName,referral.RTL_LastName__c);
              leadObj.Salutation = assignValue(leadObj.Salutation,referral.RTL_Title__c);
              leadObj.FirstName = assignValue(leadObj.FirstName,referral.RTL_FirstName__c);
              leadObj.Phone__c = assignValue(leadObj.Phone__c,referral.RTL_Mobile1__c);
              leadObj.Ext__c = assignValue(leadObj.Ext__c,referral.RTL_Ext__c);
              leadObj.Company = assignValue(leadObj.Company,referral.RTL_Company__c==null?referral.RTL_FirstName__c+' '+referral.RTL_LastName__c:referral.RTL_Company__c);
              leadObj.Title = assignValue(leadObj.Title,referral.RTL_Position__c);
              leadObj.Office_No__c = assignValue(leadObj.Office_No__c,referral.RTL_Phone1__c);
              leadObj.Mobile_No__c = assignValue(leadObj.Mobile_No__c,referral.RTL_Mobile1__c);
              leadObj.Email__c = assignValue(leadObj.Email__c,referral.RTL_Email__c);
              leadObj.Remark__c = assignValue(leadObj.Remark__c,referral.RTL_Comment__c);
              leadObj.Preferred_Branch__c = assignValue(leadObj.Preferred_Branch__c,referral.RTL_Preferred_Branch__c);  
          }
          //Referer Information
          leadObj.Referral_Staff_ID__c = assignValue(leadObj.Referral_Staff_ID__c,referral.RTL_EmployeeID__c);
          leadObj.Referral_Staff_Name__c = assignValue(leadObj.Referral_Staff_Name__c,referral.RTL_Employee_Name__c);           
          leadObj.Status = 'Contacted';
          String leadSource = 'Refer from Branch';
          if(referral.RecordType.DeveloperName == 'Refer_within_Commercial'|| referral.RecordType.DeveloperName == 'Closed_Refer_within_Commercial'){
            leadSource = 'Refer within Commercial';
            if(channelLeadSourceMap.containsKey(referral.RTL_Channel_Segment__c)){
                leadSource = channelLeadSourceMap.get(referral.RTL_Channel_Segment__c);
            }
        }
        leadObj.LeadSource = assignValue(leadObj.LeadSource,leadSource);

          leadObj.Contacted_Flag__c  = true;
          leadObj.Pre_screening_Result__c = 'Passed';
          if(branchNameMap.containsKey(referral.RTL_Refer_Branch_Name__c )){
            leadObj.Branch_Referred__c = branchNameMap.get(referral.RTL_Refer_Branch_Name__c ).id;
            }else{
            leadObj.Referral_Staff_ID__c = null;
            leadObj.Referral_Staff_Name__c = null;
        }
    }

    
}