public class RetailLeadExtension {
    private Lead lead;
    public String action {get;set;}   
    public Boolean hasError {get;set;}
    private String recordtypeId;
    private String referralId;
    private String ids;
    private String saveAndNew {get;set;}
    //public String displayS1 {get;set;}
    private RTL_Referral__c referral;
    private static final String STR_INSERT = 'insert';
    private static final String STR_UPDATE = 'update';


    public Integer getDisplayS1() {
      return (UserInfo.getUiThemeDisplayed() == 'Theme4t'? 1:2);
    }

    public RetailLeadExtension(ApexPages.StandardController std){
      //displayS1 = getDisplayS1();
        this.lead = (Lead)std.getRecord();
        recordtypeId = ApexPages.currentPage().getParameters().get('RecordType');
        recordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
        referralId = ApexPages.currentPage().getParameters().get('referralId');
        ids = ApexPages.currentPage().getParameters().get('id');
        lead.RecordTypeId = recordtypeId;
        
        if(referralId != null){
            referral = [SELECT Id,Name,RTL_Mobile1__c,RTL_FirstName__c,RTL_LastName__c,RTL_Title__c,
                        		RTL_Office_Number__c,RTL_Email__c,RTL_EmployeeID__c,RTL_Phone1__c,
                        		RTL_Product_Name__c, RecordType.Name
                        FROM RTL_Referral__c 
                        WHERE ID=:referralId LIMIT 1 ];
            
            lead.RTL_Referral__c = referralId;
			lead.Salutation = referral.RTL_Title__c==null?'':referral.RTL_Title__c;
            lead.LastName = referral.RTL_LastName__c;
            lead.FirstName = referral.RTL_FirstName__c;
            lead.RTL_Mobile_Number__c = referral.RTL_Mobile1__c;
            lead.RTL_Office_Number__c = referral.RTL_Phone1__c;
            lead.RTL_Email_Address__c = referral.RTL_Email__c;
            lead.RTL_Source_Reference__c = referral.RTL_EmployeeId__c;
            lead.RTL_Primary_Interested_Product__c = referral.RTL_Product_Name__c;
            lead.LeadSource = 'Others Referral';
            lead.Status = 'Contacted';
        }

        System.debug('INSERT LEAD :::::::::::::: '+ApexPages.currentPage().getParameters());
        
        action = STR_INSERT;  
        
        //edit mode
        if(null != lead.id)
        {
            action = STR_UPDATE;
        }
        else/*create mode*/
        {
            lead.OwnerId = System.UserInfo.getUserId();
        }
    }

    private void updateSourceRef() {
        //if lead contains Referral, then set RTL_Source_Reference__c to RTL_EmployeeId__c and LeadSource to 'Others Referral'
        if (lead.RTL_Referral__c != null) {
            RTL_Referral__c referralObj = [SELECT RTL_EmployeeId__c 
                                        FROM RTL_Referral__c 
                                        WHERE ID=:lead.RTL_Referral__c LIMIT 1 ];

            lead.RTL_Source_Reference__c = referralObj.RTL_EmployeeId__c;
            lead.LeadSource = 'Others Referral';
        }else {
            //To fix INC0060125 Please fix to not clear values of Lead source and Source Referral on Lead on 10-09-2018
            //lead.RTL_Source_Reference__c = null;
            //lead.LeadSource = null;
        }
    }

    public PageReference save(){
        hasError = false;
        try
        {
            System.debug('String Action :: '+action);
            lead.Company = checkNull(lead.FirstName) + ' '+ checkNull(lead.LastName); 

            //modifed at 8 Aug 2017 for assign RTL_Source_Reference__c and LeadSource
            updateSourceRef();
            //CR AL Re-org Long Term
            checkContactAddress();
            
            if(action == STR_INSERT)
            {
                insert lead;
            }
            else
            {
                update lead;
            }    
            
        }  
        catch(DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
            System.debug(e.getDmlMessage(0));
            hasError = true;
            return null;
        }catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            System.debug(e.getMessage());
            hasError = true;
            return null;
        }

        SaveAndNew = ApexPages.currentPage().getParameters().get('saveAndNew');
        //check if user click on save or save & new button       
        System.debug('Save And New ???? '+SaveAndNew);
        if(saveAndNew == 'saveAndNew'){
            PageReference newLead = new PageReference('/apex/RetailLeadCreation');
            newLead.setRedirect(true);
            return newLead;
        }

    	return UserInfo.getUiThemeDisplayed() == 'Theme3' ? new PageReference('/' + lead.Id).setRedirect(true) : null;
    }
    
    public void saveLead(){
         //Create save point before insert/update
        Savepoint sp = Database.setSavepoint();
        hasError = false;
        try
        {
        	System.debug('String Action :: '+action);
            lead.Company = checkNull(lead.FirstName) + ' '+ checkNull(lead.LastName); 
            
            //modifed at 8 Aug 2017 for assign RTL_Source_Reference__c and LeadSource
            updateSourceRef();
            //CR AL Re-org Long Term
            checkContactAddress();

        	if(action == STR_INSERT)
            {     

                insert lead;
                if(referral != null && referral.RecordType.Name == 'Retail Cross Channel Referral' && lead.RTL_Referral__c != null && lead.RTL_ID_Type__c != null 
                   && lead.RTL_Citizen_Id__c != null && lead.Status == 'Contacted'){
                    lead.Status = 'Qualified';
                    update lead;
                }
             
          	}
            else
            {
                update lead;
          	}    
            
        }  
        catch(DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
            System.debug(e.getDmlMessage(0));
            hasError = true;
            Database.rollback(sp);
        }catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            hasError = true;
            Database.rollback(sp);
        }
        
    }
    
    public PageReference cancelLead(){
      PageReference leadHome = new PageReference('/00Q/o');
      if(null != lead.id) {
        leadHome = new PageReference('/'+lead.id);
      }
      leadHome.setRedirect(true);
      return leadHome;
    }
    
    public Boolean getisCreateMode(){
        return action == STR_INSERT?true:false;
    }
    
    public string checkNull(string input){
        if(null == input)
            return '';
        return input;
    }

    //CR AL Re-org Long Term
    private void checkContactAddress(){
        if(lead.RTL_Contact_Address__c != null)
        {
            List<RTL_Contact_Address__c> contactAddr = [SELECT Id,Name,RTL_Province__c,RTL_District__c,RTL_Sub_District__c,RTL_Zipcode__c,IsActive__c FROM RTL_Contact_Address__c WHERE (Id =: lead.RTL_Contact_Address__c) AND (IsActive__c = true) LIMIT 1];
            lead.RTL_AL_ContactProvince__c = contactAddr[0].RTL_Province__c;
            lead.RTL_AL_ContactDistrict__c =  contactAddr[0].RTL_District__c;      
            lead.RTL_AL_ContactSubDistrict__c = contactAddr[0].RTL_Sub_District__c;
            lead.RTL_AL_ContactZipcode__c = contactAddr[0].RTL_Zipcode__c;
        }
        else {
            lead.RTL_AL_ContactProvince__c = null;
            lead.RTL_AL_ContactDistrict__c =  null;
            lead.RTL_AL_ContactSubDistrict__c = null;
            lead.RTL_AL_ContactZipcode__c = null;
        }
    }

}