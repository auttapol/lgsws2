public class AccountDataPartitionExtension
{
    //private final String SECTION = 'Account Information';
    public String section {get;set;}
    public String section2 {get;set;}
    public String section3 {get;set;}
    public Boolean isVisible {get;set;}
    public Boolean isVisible_B {get;set;}
    public Boolean isVisible_C {get;set;}
    public Boolean isLoading {get;set;}
    public Boolean isLoadSuccess {get;set;}
    public Account acct {get;set;}
    public String parent {get;set;}
    public String theme { 
        get {
            return UserInfo.getUiThemeDisplayed();
        }         
    }
    public Boolean isSF1 {
        get {         
            if (theme == 'Theme4u' || theme == 'Theme4t'){
                return false;
            }
            else if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
                String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
                ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
                (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
            ) {
                return true;
            } else {
                return false;
            }
        }
    }
	public String hiddenText {get;set;}
/*    
    public String hiddenText {
        get{
            if( hiddenText == null )
            {
                //hiddenText = '***********';
                hiddenText = system.Label.Data_Condition_Hidden_Text;
            }
            return hiddenText;
        }
        set;
    }
*/
    
    public AccountDataPartitionExtension(ApexPages.StandardController std){
        acct = (Account)std.getRecord();
        isLoading = true;
        isLoadSuccess = false;

    }

    public void loadData()
    {
        try{
        	section = apexpages.currentPage().getParameters().get('sectionName');
            section2 = apexpages.currentPage().getParameters().get('sectionName2');
            section3 = apexpages.currentPage().getParameters().get('sectionName3');
        }catch(Exception e){
            section = apexpages.currentPage().getParameters().get('sectionName');
        }
        Account acctDetail = new Account();
        Profile userProfile = new Profile();

        try
        {
            acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId,Parent.name FROM Account WHERE id = :acct.id ];
            acct = acctDetail;
            parent = acct.Parent.name;
            System.debug(acct);
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        }
        catch (Exception e)
        { 
            //exception here
        }
        if(section2 != null && section2 != ''){
            isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
            isVisible_B = RTL_AccountUtility.verifyFieldSecurity(section2,userProfile.name, acctDetail.id);
            isVisible_C = RTL_AccountUtility.verifyFieldSecurity(section3,userProfile.name, acctDetail.id);
        }else{
            isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
        } 
        
        hiddenText = system.Label.Data_Condition_Hidden_Text;
        
        isLoading = false;
        isLoadSuccess = true;
        
        system.debug('isVisible::'+isVisible);
        system.debug('SF1::'+isSF1);
    }

    public Pagereference customCancel(){
        System.debug('WHY !?!');
        PageReference viewPage;

        viewPage = new ApexPages.StandardController(acct).view();   
        
        viewPage.setRedirect(true);
        return viewPage; 
    }
}