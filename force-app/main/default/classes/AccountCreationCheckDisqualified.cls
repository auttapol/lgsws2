public without sharing class AccountCreationCheckDisqualified {
    public Account acct {get{
        if(acct ==null){
            acct = new Account();
           
        }
        return acct;
    }set;}
    private Account beforechangeAcct {get;set;}
    public Account oldAcct {get;set;}
static FINAL String STR_INSERT = 'insert';
    static FINAL String STR_UPDATE = 'update';
    public String str_Action;
    public boolean isUpdateSuccess {get{
        if(isUpdateSuccess==null){
            isUpdateSuccess=false;
        }
        return isUpdateSuccess;
    }set;}
    //R8
    public boolean isHasPermission {get;set;}
    
    public String section {get;set;}
    public Boolean isVisible {get;set;}
     public Boolean isLoading {get;set;}
    public Boolean isLoadSuccess {get;set;}
    public String hiddenText {
        get{
            if( hiddenText == null )
            {
                hiddenText = system.Label.Data_Condition_Hidden_Text;
            }
            return hiddenText;
        }
        set;
    }
    

    
    
    public AccountCreationCheckDisqualified(ApexPages.StandardController controller){
        isHasPermission =false;
                isLoading = true;
        isLoadSuccess = false;
        acct = (Account)controller.getRecord();
        beforechangeAcct = new Account();
        beforechangeAcct = acct.clone(true,true,true,true);
        if(acct.id==null){
             acct.OwnerID = userinfo.getUserId();
             getPassingParams(acct);
            System.debug('Create');
            isHasPermission =true;
        }else{
            
             List<UserRecordAccess> RecordAccessList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                                             WHERE UserId =: UserInfo.getUserId() 
                                             AND RecordId =: acct.id];
            
            if(RecordAccessList.size()>0){
                for(UserRecordAccess ura : RecordAccessList){
                     System.debug('ura : '+ura);
                        if(ura.HasEditAccess){
                            
                            isHasPermission =true;
                        }
                    
                }
            }
            
        }
        
        oldAcct = acct.clone(true,true,true,true);
        

       System.debug('isHasPermission : '+isHasPermission);
            
            if(!isHasPermission){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges'));
             }
        
        
    }
    
    private void getPassingParams(Account  acctObj){
        
        acctObj.customer_type__c = ApexPages.currentPage().getParameters().get('customer_type');
        acctObj.name = ApexPages.currentPage().getParameters().get('company_name');
        acctObj.Mobile_Number_PE__c = ApexPages.currentPage().getParameters().get('mobile_number');
        acctObj.Phone = ApexPages.currentPage().getParameters().get('office_number');
        acctObj.ID_Type_PE__c = ApexPages.currentPage().getParameters().get('id_type');
        acctObj.ID_Number_PE__c = ApexPages.currentPage().getParameters().get('id_number');
        
        
    }
    
    
    public Pagereference CheckDisqualified(){
       
List<account> acctlist = new List<Account>();
        acctlist.add(acct);
        List<account> oldacctList = new List<account>();
        oldacctList.add(oldAcct);
        if(acct.id ==null){
            acct.OwnerId = Userinfo.getUserId();
            str_Action = STR_INSERT;
        }else{
            str_Action = STR_UPDATE;
        }
        
        System.debug(acct.id);
        System.debug(acct.Name);
        System.debug(str_Action);
ApexPages.getMessages().clear();
        boolean isDML = true;
        boolean isDuplicated = false;
        //boolean isDuplicated = DisqualifiedProcessBuilder.CheckDisqualifiedAction(acctlist,oldacctList,str_Action);
        //
        //Check only Edit, Create account is forbidden
        if(str_Action=='update'){
            isDuplicated = CommercialDuplicateCheck.DuplicateCheckAccountSingleRecord(acct,beforechangeAcct);
            //isDuplicated = false;
        }
               
         System.debug('isDuplicated : '+isduplicated);

        
        if(isDuplicated){
            if(str_action==STR_INSERT){
                
                if(acct.ID_Type_PE__c !=null && acct.ID_Number_PE__c !=null){
                    isDML = false;
                    System.debug('ID Type ID Number');
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('6001').Status_Message__c));
                }else{
                    System.debug('Name');
                    isDML = false;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('6002').Status_Message__c));
                }
            }else if(str_action==STR_UPDATE){             
                if(acct.ID_Type_PE__c ==null && acct.ID_Number_PE__c ==null){
                    isDML = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('6002').Status_Message__c));
                }else{
                    //for Update ID_type/number is duplicated allow to dml for disqualified
                    //FIX BAU issues duplicate Existing Account 
                    isDML = false;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('6001').Status_Message__c));
                }
                
                
            }
        }

        if(isDML){
            try{
                if(acct.id ==null){
                    insert acct;
                }else{
                    update acct;
                }
                
                 isUpdateSuccess =true;
                
                
            }catch(DMLException e){
                System.debug(e.getMessage());
                System.debug(e.getTypeName());
                if(e.getMessage().containsIgnoreCase('Mobile or Office Phone Number must be entered')){
                    String errormessage = e.getMessage().split(',').get(1).replace(': []','');
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,errormessage) );
                }
                
                
       return null;
            }
       
        }
 
//
//return viewCutomer(); 
     return null;   
    }
    

    public Pagereference viewCustomer(){
        PageReference CustomerPage;
        CustomerPage = new ApexPages.StandardController(acct).view();
        //accountCreationPage.getParameters().put('customer_type',CustTypeStr);
        CustomerPage.setRedirect(true);          
        return CustomerPage; 
    }    
    
    public Pagereference cancelCutomer(){
        PageReference CustomerPage;
        CustomerPage = new ApexPages.StandardController(acct).view();
        //accountCreationPage.getParameters().put('customer_type',CustTypeStr);
        CustomerPage.setRedirect(true);          
        return CustomerPage; 
    }
    
    
    public void loadData()
    {
        section = apexpages.currentPage().getParameters().get('sectionName');
        Account acctDetail = new Account();
        Profile userProfile = new Profile();

        try
        {
            acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId FROM Account WHERE id = :acct.id ];
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        }
        catch (Exception e)
        { 
            //exception here
        }
        
		isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name,acctDetail.id);
		system.debug('Isvisible ::'+ isVisible);
        
                 isLoading = false;
        isLoadSuccess = true;
        system.debug('isLoadSuccess ::' + isLoading);
        system.debug('isLoading ::'+ isLoadSuccess);
       
    }
}