public class ContactDataPartitionExtension 
{
    //private final String SECTION = 'Account Information';
    public String section {get;set;}
    public Boolean isLoading {get;set;}
    public Boolean isVisible {get;set;}
    public Boolean isLoadSuccess {get;set;}
    public String dateOfBirth {get;set;}
    public Integer age {get;set;}
    public Contact cont;
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
            }else{
                return false;
            }
        }
    }

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

    public ContactDataPartitionExtension(ApexPages.StandardController std){
        cont = (Contact)std.getRecord();
        isLoading = true;
        isLoadSuccess = false;

    }

    public void loadData()
    {
        try{
        	section = 'ComCust:Contacts';
        }catch(Exception e){
            this.section = section;
        }
        Contact contDateBirth = new Contact();
        contDateBirth = [SELECT Date_of_Birth__c  FROM Contact WHERE id = :cont.id ];
        DateTime currentDate = DateTime.now();
        DateTime dt =  contDateBirth.Date_of_Birth__c;
        system.debug('dt::'+dt);
       	Integer currentYear = currentDate.year();
        if(dt==null)
        {
            dateOfBirth = '';
        	age = 0;
        }
        else
        {
        Integer birthYear = dt.year();
        age = currentYear - birthYear;
        system.debug('dt::'+dt);
        dateOfBirth = dt.format('dd/MM/yyyy');
        system.debug('dateOfBirth::'+dateOfBirth);
        }
        
        Contact contDetail = new Contact();
        Profile userProfile = new Profile();
        Account acctDetail = new Account();

        try
        {
            contDetail = [SELECT id,AccountId  FROM Contact WHERE id = :cont.id ];
            acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId FROM Account WHERE id = :contDetail.AccountId ];
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            
        }
        catch (Exception e)
        { 
            //exception here
        }
        system.debug('section::'+section);
        system.debug('userProfilename::'+userProfile.name);
        system.debug('recordTypename::'+acctDetail.recordType.name);


        isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name,cont.id);
		system.debug(isVisible);
        isLoading = false;
        isLoadSuccess = true;
        system.debug('isSF1::'+isSF1);
        
    }

}