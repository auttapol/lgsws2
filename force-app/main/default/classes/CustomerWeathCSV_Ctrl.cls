public with sharing class CustomerWeathCSV_Ctrl extends OscControllerBase{
   
    public Boolean isFirstPage {get; set;}
    public String acctId {get; set;}
    public Id accountId {get; set;}
    public String rtl_OtcAtmAdmIbMib {get; set;}
    public String rtl_MibStatus {get; set;}
    public String rtl_Suitability {get;set;}
    public String touchStatus {get;set;}
    public String ibStatus {get;set;}
    public String pageMessage {get;set;}
    public String accImage {get; set;}
    public String birthday {get; set;}
    // public Boolean doNotContactFlag {get;set;}
    
    // new parameter OSC07
    public String csProfFreqBr {get;set;}
 
    public Account acct {get;set;}
    
    private String rmid; /* crmid  */
    public string cname; /* name  */
    private Profile userProfile;

    // Related list.
    public decimal recPerPage = 5;
    public List<Opportunity> listOppty {get; set;}
    public List<Case> listCase {get; set;}
        
    public AsyncRTL_CvsAnalyticsDataService.getCVSAnalyticsDataResponse_elementFuture asyncRet;

    public Branch_and_Zone__c getBranch(String branchCode){

        Branch_and_Zone__c branch;
        try
        {
            branch = [Select Name, Branch_Name__c, RTL_Region_Code__c, RTL_Zone_Code__c from Branch_and_Zone__c WHERE Branch_Code__c =: branchCode LIMIT 1];
        }
        catch(exception e)
        {
            // No branch return;
        }

        return branch;
    }
    
    public CustomerWeathCSV_Ctrl(ApexPages.StandardController stdController){
        acct = (Account)stdController.getRecord();
        acct = [SELECT ID,Name,TMB_Customer_ID_PE__c,Account_Type__c,RTL_OTC_ATM_ADM_IB_MIB__c,RTL_MIB_Status__c,RTL_Suitability__c,RTL_Privilege2__c 
                // TMBCCC-20 start
                ,Zip_Code_Primary_PE__c 
                ,RTL_RM_Name__c 
                ,RTL_Wealth_RM__c
                ,Wealth_RM_EMP_Code__c
                ,RTL_Commercial_RM__c 
                ,RTL_AUM_Last_Calculated_Date__c 
                ,Sub_segment__c 
                ,RTL_Average_AUM__c 
                ,OwnerId
                // TMBCCC-20 end
                // New CSV
                ,FATCA__c
                ,Account_Photo_del__c
                ,RTL_Risk_Level_Details__c
                ,RTL_Customer_Name_TH__c
                ,Customer_Name_PE_Eng__c
                ,NID__c
                ,RTL_Date_Of_Birth__c
                ,Mobile_Number_PE__c
                ,Email_Address_PE__c
                ,RTL_Marital_Details__c
                ,RTL_No_of_Children__c
                ,RTL_Education_Details__c
                ,RTL_Occupation__c
                ,RTL_Income__c
                ,Hobbies__c
                ,Favorite_Sport__c
                ,RTL_Special_Pref__c
                ,RTL_Do_Not_Contact__c
                ,RTL_Fund_Risk_Mismatch__c
                ,RTL_Fund_High_Concentration_Risk__c
                ,RTL_Age__c
                // New CSV End
                FROM Account WHERE Id =: acct.id ];
        
        accountId = acct.id;
        pageMessage = '';

        accImage = acct.Account_Photo_del__c;
        if (accImage != null && accImage != ''){
            Integer index = accImage.indexOf('src="');
            accImage = accImage.substring(index);
            accImage = accImage.remove('src="');
            accImage = accImage.substring(0, accImage.indexOf('"'));
            // system.debug('accImage: ' + accImage);
        }
        else{
            accImage = '';
        }
        
        cname = acct.Name;
        rmid = acct.TMB_Customer_ID_PE__c;

        userProfile = new Profile();
        try
        {
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        }
        catch (Exception e)
        { 
            system.debug( e.getMessage() );
            //exception here
        }

        // Set first page.
        isFirstPage = true;

        // Set lightning component visible default true.
        isVisible = true;
        isLightningVisible = true;

        // Birthday transform format.
        Datetime birth = acct.RTL_Date_Of_Birth__c;
        if (birth != null && accImage != ''){
            birthday = birth.format('dd/MM/yyyy');
        }
        else{
            birthday = '';
        }
        
        try
        {
            rtl_OtcAtmAdmIbMib = acct.RTL_OTC_ATM_ADM_IB_MIB__c;
        }catch(Exception e){
            pageMessage = System.Label.ERR001;
            System.debug(pageMessage);
        }

        // Query Oppty and case.
        queryOppty();
        queryCase();
        
    }

    // Add related list of Oppty.
    public void queryOppty(){
        listOppty = [Select Id
                            ,Name
                            ,StageName
                            ,Amount
                            ,CloseDate
                            ,RTL_Status__c
                    From Opportunity 
                    Where AccountId =: acct.Id
                    And RTL_Status__c in ('Open')
                    Order By CreatedDate DESC
                    Limit: integer.valueof(recPerPage)];
    }

    // Add related list of Case.
    public void queryCase(){
        listCase = [Select  Id
                            ,CaseNumber
                            ,Contact.Name
                            ,Subject
                            ,Priority
                            ,CreatedDate
                            ,Status
                            ,Owner_Name__c
                    From Case 
                    Where AccountId =: acct.Id
                    And Status in ('New', 'In progress')
                    Order By CreatedDate DESC
                    Limit: integer.valueof(recPerPage)];
    }
    /* -------------------------- End Service ------------------------------------------ */  
    
    public override void CallSOAP(Continuation contX) {
        try{
            System.debug('CallSOAP begin');
            contX.continuationMethod = 'processResponseSOAP';
            AsyncRTL_CvsAnalyticsDataService.AsyncCVSAnalyticsDataSOAP asynSvr = new AsyncRTL_CvsAnalyticsDataService.AsyncCVSAnalyticsDataSOAP();
            asyncRet = asynSvr.beginGetCVSAnalyticsData(contX, rmid); // fix
        }catch(Exception e){
         system.debug('CallSOAP Exception = ' + e.getMessage());   
        }
    }

    public Object processResponseSOAP() {
        try{
            RTL_CvsAnalyticsDataService.CVSAnalyticsData soapCVSAnalyticsData = asyncRet.getValue();
            
            AccountUtility.OSC07wraper resultData =  AccountUtility.processOSC07Data(soapCVSAnalyticsData,
                rmid,acct.RTL_Wealth_RM__c,acct.RTL_Commercial_RM__c);

            CVSAnalyticsDataDTO result = resultData.responseData;
            
            if(result.SoapStatus == 'ERROR'){
                pageMessage = TypeMapper.errorMessageMapping(result.SoapMessage==null?'':result.SoapMessage);
                return null;
            }
            
            touchStatus = result.touchStatus;
            ibStatus = result.ibStatus;
            acct.RTL_OTC_ATM_ADM_IB_MIB__c = result.UsagePercentage;//'10:20:20:25:25'
            acct.RTL_MIB_Status__c = result.MIBStatus;//'Applied'
            acct.RTL_Suitability__c = result.Suitability;
            csProfFreqBr = result.csProfFreqBr;

            if(getBranch(csProfFreqBr) != null){
                acct.RTL_Most_Visited_Branch__c = getBranch(csProfFreqBr).id;
            }

            rtl_MibStatus = acct.RTL_MIB_Status__c;
            system.debug('rtl_MibStatus' + rtl_MibStatus);
            rtl_OtcAtmAdmIbMib = acct.RTL_OTC_ATM_ADM_IB_MIB__c;
            rtl_Suitability = acct.RTL_Suitability__c;    

            return null;

        }catch(Exception e){
            PageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
            system.debug('Web services callout error with inner exception : ' + e.getMessage() + ':' + +e.getLineNumber() );   
        }
        return null;
    }

    public void NextPage(){
        isFirstPage = false;
    }

    public void PreviousPage(){
        isFirstPage = true;
    }

    // --------------------------- Data Partition--------------------------//
    public String section {get;set;}
    public Boolean isVisible {get;set;}
    public Boolean isLightningVisible {get;set;}


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
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, notAuthorizedMsg));
    }
    
    public void loadData(){

        system.debug('before load data: '+Limits.getQueries());
        try{
            section = apexpages.currentPage().getParameters().get('sectionName');
 
        }catch(Exception e){
            section = apexpages.currentPage().getParameters().get('sectionName');
        }

        isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, accountId); // isVisible
        isLightningVisible = !isVisible;
        // System.debug('isVisible: ' + isVisible );
        // System.debug('isLightningVisible: ' + isLightningVisible );

        if( isVisible != null && !isVisible ){
            notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, notAuthorizedMsg));            
        }
        
        //hiddenText = system.Label.Data_Condition_Hidden_Text;
        isLoading = false;
        isLoadSuccess = true;
    }
    // --------------------------- End Data Partition----------------------//

}