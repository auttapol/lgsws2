public with sharing class AccountDetailPageExtension {

    
    public String section {get;set;}
    public String section2 {get;set;}
    public String section3 {get;set;}
    public String section4 {get;set;}
    public String section5 {get;set;}
    public Boolean isVisible {get;set;} 
    public Boolean isVisible_B {get;set;}
    public Boolean isVisible_C {get;set;}
    public Boolean isVisible_D {get;set;}
    public Boolean isVisible_E {get;set;}
    public Boolean isLoading {get;set;}
    public Boolean isLoadSuccess {get;set;}
    
    public Account acct;
    public Account acctDetail;
    private Profile userProfile;
    
    public AccountDetailPageExtension(ApexPages.StandardController std){
    acct = (Account)std.getRecord();
        isLoading = true;
        isLoadSuccess = false;
        try
        {
            acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId,Core_Banking_Suggested_Segment__c FROM Account WHERE id = :acct.id ];
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        }
        catch (Exception e)
        { 
            system.debug( e.getMessage() );
            //exception here
        }
    }


    public String hiddenText {
        get{
            if( hiddenText == null )
            {
                hiddenText = '';
            }
            return hiddenText;
        }
        set;
    }
    
public String notAuthorizedMsg {
    get{
            if( notAuthorizedMsg == null )
            {
                notAuthorizedMsg = '';
            }
            return notAuthorizedMsg;
        }
        set;
    }

    public void loadParameter(){
        // set parameter value
        notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
    }
    
    public void loadData()
    {
        try{
        section = apexpages.currentPage().getParameters().get('sectionName');
            section2 = apexpages.currentPage().getParameters().get('sectionName2');
            section3 = apexpages.currentPage().getParameters().get('sectionName3');
            section4 = apexpages.currentPage().getParameters().get('sectionName4');
            section5 = apexpages.currentPage().getParameters().get('sectionName5');
            // if not defind sectionName in VF process will catch
        }catch(Exception e){
            section = apexpages.currentPage().getParameters().get('sectionName');
        }
        
      if(section2 != null && section2 != ''){
            isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
            isVisible_B = RTL_AccountUtility.verifyFieldSecurity(section2,userProfile.name, acctDetail.id);
            isVisible_C = RTL_AccountUtility.verifyFieldSecurity(section3,userProfile.name, acctDetail.id);
            isVisible_D = RTL_AccountUtility.verifyFieldSecurity(section4,userProfile.name, acctDetail.id);
            isVisible_E = RTL_AccountUtility.verifyFieldSecurity(section5,userProfile.name, acctDetail.id);
        }else{
            isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
        }        
        
        hiddenText = system.Label.Data_Condition_Hidden_Text;
        notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
        isLoading = false;
        isLoadSuccess = true;
    }
    
    /* check if the VF page is display by SF1 */
    public String theme { 
        get {
            return UserInfo.getUiThemeDisplayed();
        }         
    }

    public Boolean isSF1 {
        get {  
            if (theme == 'Theme4u'){
                return false;
            }                  
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
                String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
                ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
                (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
            ) {
                return true;
            }else{
                return false;
            }
        }
    }  
    

}