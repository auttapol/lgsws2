public class RetailCustomerExtension {
    private Account acct;
    public Boolean isLoading {get;set;}
    public Boolean isVisiblePerInfo {get;set;}
    public Boolean isVisibleContNum {get;set;}
    public Boolean isVisibleAltContInfo {get;set;}
    public Boolean isLoadSuccess {get;set;}
    private string SectionPerInfo = 'RtlCust:Customer Insight - Personalized Information';
    private string SectionContNum = 'RtlCust:Contact Number and Email Address';
    private string SectionAltContInfo = 'RtlCust:Customer Insight - Personalized Information';
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
        
    public Integer getDisplayS1() {
        return (UserInfo.getUiThemeDisplayed() == 'Theme4t'? 1:2);
    }
    
    public RetailCustomerExtension(ApexPages.StandardController std){
        this.acct = (Account)std.getRecord();
        //displayS1 = getDisplayS1();
		loadData();
        
    }
    
    
    public void loadData()
    {

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

	    isVisiblePerInfo = RTL_AccountUtility.verifyFieldSecurity(SectionPerInfo,userProfile.name,acct.id);
        isVisibleContNum = RTL_AccountUtility.verifyFieldSecurity(SectionContNum,userProfile.name,acct.id);
        isVisibleAltContInfo = RTL_AccountUtility.verifyFieldSecurity(SectionAltContInfo,userProfile.name,acct.id);
		system.debug('isVisiblePerInfo::'+isVisiblePerInfo);
        system.debug('isVisibleContNum::'+isVisibleContNum);
        system.debug('isVisibleAltContInfo::'+isVisibleAltContInfo);

    }
    
    
    
    public PageReference cancelCustomer(){
        PageReference acctHome = new PageReference('/001/o');
        if(null != acct.id) {
            acctHome = new PageReference('/'+acct.id);
        }
        acctHome.setRedirect(true);
        return acctHome;
    }
    
    public PageReference save(){
        try
        {
        
            update acct;
            
            
        }  
        catch(DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
            System.debug(e.getDmlMessage(0));
            return null;
        }catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        
        return  new PageReference('/'+acct.id);
    }
}