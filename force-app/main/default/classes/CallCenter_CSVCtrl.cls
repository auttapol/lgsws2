public with sharing class CallCenter_CSVCtrl extends OscControllerBase{
    
    public String rmid {get;set;}
    public wrapperWealthData wsWealthData {get;set;}
    
    public Account currentObject {get;set;}
    public Integer limitSize{get;set;}
    public Integer doNotContactSize {get;set;}
    public Integer caseSize {get;set;}
    public Integer complaintSize {get;set;}
    public Integer opportunitySize {get;set;}
    public Integer referralSize {get;set;}
    public Integer openActivitySize {get;set;}
    public Integer activityHistorySize {get;set;}
    public Integer interestProductSize {get;set;}
    public Integer FnaActivitySize {get;set;}
    public Integer accountHistorySize {get;set;}
    public Integer noteAndAttachSize {get;set;}
    
    public String acctId15Digi {get;set;}
    public Boolean editPage {get;set;}
    
    public String rlidDoNotContact {get;set;}
    public String rlidComplaint {get;set;}
    public String rlidCase {get;set;}
    public String rlidReferral {get;set;}
    public String rlidInterestProduct {get;set;}
    public String rlidFnaActivity {get;set;}
    
    public String rlidOpportunity {get;set;}
    public String rlidOpenActivity {get;set;}
    public String rlidActivityHistory {get;set;}
    public String rlidAccountHistory {get;set;}    

    //CR CCPIN
    public Verification_History__c verifyObject {get;set;}
    public String rlidVerify {get;set;}
    public String verifyStatusCode {get;set;}
    public String verifyStatusDescription {get;set;}
    public String verifyResult_color {get;set;}
    public String verifyStatus_color {get;set;}
    public Integer verificationListSize {get;set;}
    public List<Verification_History__c> VerificationList 
    {
        get
        {
            if(VerificationList == null)
            {
                VerificationList = new List<Verification_History__c>();
            }
            return VerificationList;
        
        }set; 
    }
    
    public List<RTL_Do_not_Contact_Info__c> DoNotContactList {get
    {
        if(DoNotContactList == null){
            DoNotContactList = new List<RTL_Do_not_Contact_Info__c>();
        }
        return DoNotContactList;
        
    }set; }

    public List<Case> CaseList {get
    {
        if(CaseList == null){
            CaseList = new List<Case>();
        }
        return CaseList;
        
    }set; }
    
    
    public List<Customer_Complaint__c> CustomerComplaintList {get
    {
        if(CustomerComplaintList == null){
            CustomerComplaintList = new List<Customer_Complaint__c>();
        }
        return CustomerComplaintList;
        
    }set; }
    
    public List<Opportunity> OpportunityList {get
    {
        if(OpportunityList == null){
            OpportunityList = new List<Opportunity>();
        }
        return opportunityList;
        
    }set; }
    
    public List<RTL_Referral__c> ReferralsList {get
    {
        if(ReferralsList == null){
            ReferralsList = new List<RTL_Referral__c>();
        }
        return ReferralsList;
        
    }set; }
    
    public List<OpenActivity> OpenActivityList {get
    {
        if(OpenActivityList == null){
            OpenActivityList = new List<OpenActivity>();
        }
        return openActivityList;
        
    }set; }
    
    public List<wrapperActivityHistory> ActivityHistoryList {get
    {
        if(ActivityHistoryList == null){
            ActivityHistoryList = new List<wrapperActivityHistory>();
        }
        return activityHistoryList;
        
    }set; }
    
    public List<RTL_Interested_products_c__c> InterestedProductList {get
    {
        if(InterestedProductList == null){
            InterestedProductList = new List<RTL_Interested_products_c__c>();
        }
        return InterestedProductList;
        
    }set; }
    
    public List<FNA_Activity__c> FnaActivityList {get
    {
        if(FnaActivityList == null){
            FnaActivityList = new List<FNA_Activity__c>();
        }
        return FnaActivityList;
        
    }set; }
    
    public List<AccountHistory> AccountHistoryList {get
    {
        if(AccountHistoryList == null){
            AccountHistoryList = new List<AccountHistory>();
        }
        return AccountHistoryList;
        
    }set; }
    
    public List<wrapperNoteAndAttach> NoteAndAttachList {get
    {
        if(NoteAndAttachList == null){
            NoteAndAttachList = new List<wrapperNoteAndAttach>();
        }
        return NoteAndAttachList;
        
    }set; }
    
    // TMBCCC-20 start
    public String rtl_MsgArea {get;set;}
    // TMBCCC-20 end
    
    public CallCenter_CSVCtrl(){     
        limitSize = 5;
        editPage = false;

        try{
            String accId =  Apexpages.currentPage().getParameters().get('Id');  
            currentObject = getAccountInfo(accId);
            rmid = currentObject.TMB_Customer_ID_PE__c;

            // -------- CCPIN --------
            String verifyId =  Apexpages.currentPage().getParameters().get('verf_hist_id');  
            verifyObject = getVerification(verifyId);

            List<Verification_Status_Code__mdt> statusCodeList = [SELECT Id, Label, Color__c,Description__c FROM Verification_Status_Code__mdt]; 
            Map<String,Verification_Status_Code__mdt> statuCodeMap = new Map<String,Verification_Status_Code__mdt>();

            for( Verification_Status_Code__mdt codeList : statusCodeList)
            {
                statuCodeMap.put(codeList.Label, codeList);
            }

            if(verifyObject.Verification_Status__c != null) 
            {
                List<String> status = verifyObject.Verification_Status__c.split(' ');
                verifyStatusCode = status[0]; 
                System.debug('verifyStatusCode:'+verifyStatusCode);
                if( statuCodeMap.containsKey( verifyStatusCode ) )
                {
                    verifyStatus_color = statuCodeMap.get( verifyStatusCode ).Color__c;
                    System.debug('verifyStatus_color:'+verifyStatus_color);
                    verifyStatusDescription = statuCodeMap.get( verifyStatusCode ).Description__c;              
                }
            }

            List<Verification_Result__mdt> resultList = [SELECT Id, Label, Color__c,Result__c FROM Verification_Result__mdt]; 
            Map<String,Verification_Result__mdt> resultMap = new Map<String,Verification_Result__mdt>();

            for( Verification_Result__mdt result : resultList)
            {
                resultMap.put(result.Label, result);
            }

            if(verifyObject.Verification_Result__c != null)
            {
                if( resultMap.containsKey( verifyObject.Verification_Result__c ) )
                {
                    verifyResult_color = resultMap.get( verifyObject.Verification_Result__c ).Color__c;
                    
                }

            }
            // -----------------------
            try{
                acctId15Digi = String.valueOf(currentObject.Id).substring(0, 15);
            }catch( Exception e ){                
                System.debug('error : '+e.getMessage());
            }          
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
        }
        
        // TMBCCC-20 start
        if( getIsCoverArea() ){
            rtl_MsgArea = getMessengerCoverArea(currentObject.Zip_Code_Primary_PE__c);
        }
        // TMBCCC-20 end
        
        /*rlidDoNotContact = getCustomFieldId('RTL_Do_not_Contact_Info','Customer');
        rlidComplaint = getCustomFieldId('Customer_Complaint','Account');
        rlidReferral = getCustomFieldId('RTL_Referral','RTL_Account_Name');
        rlidInterestProduct = getCustomFieldId('RTL_Interested_products_c','Customer');*/
        Map<String,CallCenter_RelatedList__mdt> configReleatedList = getConfigRelatedList();
        rlidVerify = configReleatedList.get('Verification_History__c').RLID__C;
        rlidCase = configReleatedList.get('Case').RLID__C;
        rlidDoNotContact = configReleatedList.get('RTL_Do_not_Contact_Info__c').RLID__C;
        rlidComplaint = configReleatedList.get('Customer_Complaint__c').RLID__C;
        rlidReferral = configReleatedList.get('RTL_Referral__c').RLID__C;
        rlidInterestProduct = configReleatedList.get('RTL_Interested_products_c__c').RLID__C;
        rlidFnaActivity = configReleatedList.get('FNA_Activity__c').RLID__C;
        rlidOpportunity = configReleatedList.get('Opportunity').RLID__C;
        rlidOpenActivity = configReleatedList.get('OpenActivity').RLID__C;
        rlidActivityHistory = configReleatedList.get('ActivityHistory').RLID__C;
        rlidAccountHistory = configReleatedList.get('AccountHistory').RLID__C;

        callVerificationList();
        callVerificationListSize();

        callDoNotContactList();
        callCustomerComplaintList();
        callOpportunityList();
        callReferralsList();
        callOpenActivityList();
        callActivityHistoryList();
        callInterestedProductList();
        callFnaActivityList();
        callAccountHistoryList();
        callNoteAndAttachList();
        callCaseList();
    }
    
    public PageReference editMode(){
        PageReference nextPage;
        //if( getCheckPermissionRecord() ){
            editPage = true;
            nextPage =  new PageReference('/apex/CallCenter_CSV_Edit?Id='+currentObject.Id+'&isdtp=vw'); 
            nextPage.setRedirect(true);    
            return nextPage;
        /*}else{
            nextPage =  new PageReference('/apex/abc?Id='+currentObject.Id+'&isdtp=vw'); 
            nextPage.setRedirect(true);    
            return nextPage;
        }*/       
    }
    
    public PageReference save(){
        try{
            update currentObject;
        }catch( Exception e ){
            System.debug(e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() ));
            return null;
        }
        
        
        PageReference nextPage =  new PageReference('/'+currentObject.Id+'?isdtp=vw'); 
        nextPage.setRedirect(true);    
        return nextPage;
    }
    
    public PageReference cancel(){
        PageReference nextPage =  new PageReference('/'+currentObject.Id+'?isdtp=vw'); 
        nextPage.setRedirect(true);    
        return nextPage;
    }
    
    public Account getAccountInfo(String accId){
        try{
            return [ SELECT Id,Name,Customer_Name_PE_Eng__c,ID_Type_PE__c,NID__c,RTL_Date_Of_Birth__c,
                    Mobile_Number_PE__c,Email_Address_PE__c,FATCA__c,Account_Type__c,Core_Banking_Suggested_Segment__c,
                    RTL_Wealth_RM__c,TMB_Customer_ID_PE__c,RTL_Customer_Reference_Id__c,RTL_Do_Not_Contact__c,
                    RTL_Occupation_Details__r.RTL_Occupation_Desc__c,RTL_Income_Conditional__c,Nationality__c,RTL_Age__c,
                    RTL_Is_Employee__c,RTL_Primary_Banking_All_Free_Benefit__c,RTL_Risk_Level_Details__c,RTL_Suitability__c,
                    RTL_Credit_Card_History__c,RTL_Personal_Loan_History__c,RTL_Entitled_Privilege2__c,RTL_Privilege2__c,
                    RTL_Alternative_Number__c,C_Home_phone_PE__c,RTL_Office_Phone_Number__c,Fax,Zip_Code_Primary_PE__c,
                    RTL_Customer_Name_TH__c,RTL_Birthday__c,RTL_Zodiac__c,RTL_Primary_Address__c,RTL_Registered_Address__c,
                    RTL_Office_Address__c,
                    RTL_Preferred_Contact_Channel__c,RTL_Alternative_Contact_Channel__c,RTL_Email_2__c,
                    RTL_Gender_View__c,RTL_CitizenID_Expiration_Date__c,RTL_NOT_CONSOL_STMT_status__c,RTL_CC_STMT_status__c,
                    RTL_RDC_STMT_status__c,RTL_C2G_STMT_status__c,RTL_Average_AUM__c,
                    RTL_Commercial_RM__c,RTL_AUM_Last_Calculated_Date__c,RTL_AUM__c,RTL_Most_Visited_Branch__c,RTL_Privilege1_Expired_Date__c,
                    RTL_Privilege1__c,Consolidate_Status__c,Market_Consent__c
                    , RTL_Customer_Title__c, First_name_PE__c, Last_name_PE__c
                    ,RTL_Fund_Risk_Mismatch__c
                    ,RTL_Fund_High_Concentration_Risk__c
                    , Fna_Avatar_Name__c, Fna_Product_Interested__c, Fna_Product_Holding__c
                    FROM Account 
                    WHERE Id = :accId ];
        }catch( Exception e ){
            return null;
        }      
    }
    
    public AsyncRTL_CvsAnalyticsDataService.getCVSAnalyticsDataResponse_elementFuture asyncRet;
    
    public override void CallSOAP(Continuation contX) {
        try{
            System.debug('CallSOAP begin');
            contX.continuationMethod = 'processResponseSOAP';
            AsyncRTL_CvsAnalyticsDataService.AsyncCVSAnalyticsDataSOAP asynSvr = new AsyncRTL_CvsAnalyticsDataService.AsyncCVSAnalyticsDataSOAP();
            asyncRet = asynSvr.beginGetCVSAnalyticsData(contX, rmid);
        }catch(Exception e){
            system.debug('CallSOAP Exception = ' + e.getMessage());   
        }
    }
    /*public Object CallWealthData(){
        Continuation contX = new Continuation(60);
        try{
            System.debug('CallSOAP begin');
            contX.continuationMethod = 'processResponseSOAP';
            AsyncRTL_CvsAnalyticsDataService.AsyncCVSAnalyticsDataSOAP asynSvr = new AsyncRTL_CvsAnalyticsDataService.AsyncCVSAnalyticsDataSOAP();
            //Mulesoft Mockup Data
            //rmid ='001100000000000000000014201195';
            asyncRet = asynSvr.beginGetCVSAnalyticsData(contX, rmid);
        }catch(Exception e){
            system.debug('CallSOAP Exception = ' + e.getMessage());   
        }
        return contX;
    }*/
    
    public Object processResponseSOAP() {
        try{
            
            /*RTL_CvsAnalyticsDataService.CVSAnalyticsData soapCVSAnalyticsData = cre.asyncRet.getValue();
            CVSAnalyticsDataDTO item = ((CVSAnalyticsDataDTO) TypeMapper.MappingSoapToDTO(soapCVSAnalyticsData));*/
            
            RTL_CvsAnalyticsDataService.CVSAnalyticsData soapCVSAnalyticsData = asyncRet.getValue();
            
            AccountUtility.OSC07wraper resultData =  AccountUtility.processOSC07Data(soapCVSAnalyticsData,
                                                                                     rmid,currentObject.RTL_Wealth_RM__c,currentObject.RTL_Commercial_RM__c);
            
            currentObject = getAccountInfo(currentObject.Id);
            
            //currentObject.RTL_Wealth_RM__c = RTL_AccountUtility.getWealth_RM(currentObject);
            
            System.debug('resultData : '+resultData);
            CVSAnalyticsDataDTO item = resultData.responseData;
            /*
            if(item.SoapStatus == 'ERROR'){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, item.SoapMessage));
                return null;
            }*/
            
            wsWealthData = new wrapperWealthData( item );
            
        }catch( Exception e ){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Web services callout error with inner exception : '+e.getMessage()));
            System.debug('error : '+e.getMessage());
        }

        
        return null;        
    }
    
    public class wrapperWealthData{
        CallCenter_CSVCtrl outer_class;
        public CVSAnalyticsDataDTO data {get;set;}
        public Boolean ibStatus {get;set;}
        public Boolean touchStatus {get;set;}
        public String freqBr {get;set;}
        public Boolean promptPay {get;set;}
        public String rtl_currentPrivilege2 {get;set;}        
        public String rtl_entitledPrivilege2 {get;set;}
        public String csProfSubsegment {get;set;}
        
        public wrapperWealthData(CVSAnalyticsDataDTO data){
            if( data != null ){
                this.data = data;
                this.ibStatus = (data.ibStatus=='YES') ? true : false;
                this.touchStatus = (data.touchStatus=='YES') ? true : false;
                this.freqBr = getBranchName(data.csProfFreqBr);
                this.promptPay = ( getPromptPay(data.MIBStatus)=='YES') ? true : false;
                this.rtl_currentPrivilege2 = formatPrivilege2(data.currentPrivilege2Desc);
                this.rtl_entitledPrivilege2 = formatPrivilege2(data.entitledPrivilege2Desc);
                this.csProfSubsegment = AccountUtility.getSubSegment(data.csProfSubsegment);
            }
        }        
        
        private String formatPrivilege2(String input){
            if(input == null){
                return '';
            }
            System.debug('INPUT :: '+input);
            System.debug('INPUT LENGTH :: '+input.length());
            return input.trim().replace('|','\n');
        }  
        
        public String getBranchName(String brCode){
            if( brCode == '' || brCode == null ){
                return '';
            }
            try{
                return [ select id,Name,Branch_Code__c from Branch_and_Zone__c where Branch_Code__c = :brCode limit 1 ].Name;
            }catch( Exception e ){
                return brCode;
            } 
        }
        
        public String getPromptPay(String promptPay){            
            try{
                List<String> strList = promptPay.split('/');
                if( strList.size() > 1 ){
                    return strList.get(1);
                }
            }catch( Exception e ){
                    System.debug('error : '+e.getMessage());            
            }            
            return null;
        }
    }
    


    
    public void callDoNotContactList(){       
        DoNotContactList = queryDoNotContactList();
    }
    
    public List<RTL_Do_not_Contact_Info__c > queryDoNotContactList(){
        try{       
            doNotContactSize = [ select count() from RTL_Do_not_Contact_Info__c where Customer__c = :currentObject.Id  ];
            return [ select id,Name,toLabel(Product_Group__c),tolabel(Channel__c),Start_Date__c,End_Date__c,LastModifiedDate
                    from RTL_Do_not_Contact_Info__c 
                    where Customer__c = :currentObject.Id order by LastModifiedDate desc limit :limitSize  ];
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
            return new List<RTL_Do_not_Contact_Info__c>();
        }
    }

    public void callCaseList(){       
        CaseList = queryCaseList();
    }

    public List<Case> queryCaseList(){
        try{       
            caseSize = [ SELECT count() FROM Case WHERE AccountId  = :currentObject.Id  ];
            return [ 
                SELECT id, CaseNumber, Subject, Sub_Category__c, CreatedDate, Status, OwnerId, Owner.Name, Owner_Team__c 
                FROM Case 
                WHERE AccountId =  :currentObject.Id 
                ORDER BY CreatedDate desc 
                LIMIT :limitSize  ];
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
            return new List<Case>();
        }
    }
    
    public void callCustomerComplaintList(){       
        CustomerComplaintList = queryCustomerComplaintList();
    }
    
    public List<Customer_Complaint__c > queryCustomerComplaintList(){
        try{
            complaintSize = [ select count() from Customer_Complaint__c  where Account__c = :currentObject.Id ];
            return [ select id,Name,Status__c,Issue__c,TMB_Care__c,Category__c,Channel__c,
                    Product_Category__c,Opened_Date__c,LastModifiedDate
                    from Customer_Complaint__c 
                    where Account__c = :currentObject.Id order by LastModifiedDate desc limit :limitSize  ];
        }catch( Exception e ){
            return new List<Customer_Complaint__c>();
        }
    }
    
    public void callOpportunityList(){       
        OpportunityList = queryOpportunityList();
    }
    public List<Opportunity > queryOpportunityList(){
        try{
            opportunitySize = [select count() from Opportunity where accountId = :currentObject.Id];
            return [ select id,Name,RTL_Product_Name__c,RTL_Product_Name__r.Name,RTL_Stage__c,Opportunity_Amount__c,Probability,Amount,
                    CreatedDate,LastModifiedDate,CloseDate,Owner.Name,RTL_Channel__c
                    from Opportunity 
                    where accountId = :currentObject.Id order by LastModifiedDate desc limit :limitSize ];
        }catch( Exception e ){
            return new List<Opportunity>();
        }
    }
    
    public void callReferralsList(){       
        ReferralsList = queryReferralsList();
    }
    public List<RTL_Referral__c > queryReferralsList(){
        try{
            referralSize = [ select count() from RTL_Referral__c  where RTL_Account_Name__c = :currentObject.Id ];
            return [ select id,Name,RTL_Account_Name__c,tolabel(RTL_Title__c),RTL_FirstName__c,RTL_LastName__c,
                    tolabel(RTL_Stage__c),RTL_Last_Assigned_Date_time__c,RecordType.Name,LastModifiedDate
                    from RTL_Referral__c 
                    where RTL_Account_Name__c = :currentObject.Id order by LastModifiedDate desc limit :limitSize  ];
        }catch( Exception e ){
            return new List<RTL_Referral__c>();
        }
    }
    
    public void callOpenActivityList(){       
        OpenActivityList = queryOpenActivityList();
    }
    public List<OpenActivity> queryOpenActivityList(){
        try{
            openActivitySize = [ select (select Id from OpenActivities order by ActivityDate ASC, LastModifiedDate DESC limit 500) from Account where Id = :currentObject.Id ].OpenActivities.size();
            List<OpenActivity> returnList = new List<OpenActivity>();
            for( OpenActivity eachAcc : [ select (select Id,Subject,tolabel(Status),tolabel(RTL_Event_Status__c),tolabel(Priority),
                                             IsTask,ActivityDate,Owner.Name,LastModifiedDate
                                             from OpenActivities order by ActivityDate ASC, LastModifiedDate DESC limit :limitSize) 
                                    from Account where Id = :currentObject.Id ].OpenActivities ){
                                       
                returnList.add(eachAcc);
            }
            System.debug('queryOpenActivityList : '+returnList);
            return returnList;
        }catch( Exception e ){
            System.debug('error queryOpenActivityList : '+e.getMessage());
            return new List<OpenActivity>();
        }
    }
    
    public void callActivityHistoryList(){       
        ActivityHistoryList = queryActivityHistoryList();
    }
    public List<wrapperActivityHistory> queryActivityHistoryList(){
        try{
            List<wrapperActivityHistory> returnList = new List<wrapperActivityHistory>();
            List<Id> activityHistoryId = new List<Id>();
            /*Map<Id,ActivityHistory> activityHis = new Map<Id,ActivityHistory>([ select (select Id,IsTask from ActivityHistories order by ActivityDate DESC, LastModifiedDate DESC limit :limitSize ) 
                                    from Account where Id = :currentObject.Id ].ActivityHistories);
            */
            activityHistorySize = [ select (select Id,IsTask from ActivityHistories order by ActivityDate DESC, LastModifiedDate DESC limit 500 ) from Account where Id = :currentObject.Id ].ActivityHistories.size();
            
            Map<Id,ActivityHistory> activityHis = new Map<Id,ActivityHistory>([ select (select Id,Subject,tolabel(Status),tolabel(RTL_Event_Status__c),tolabel(Priority),
                                                  ActivityDate,Owner.Name,LastModifiedDate,RTL_NBO_History__c,IsTask from ActivityHistories order by ActivityDate DESC, LastModifiedDate DESC limit :limitSize ) 
                                         from Account where Id = :currentObject.Id].ActivityHistories);
            Map<Id,Task> taskList = new Map<Id,Task>([ select Id,RecordType.Name from Task where Id IN :activityHis.keyset() ]);
            Map<Id,Event> eventList = new Map<Id,Event>([ select Id,RecordType.Name from Event where Id IN :activityHis.keyset() ]);
            
            for( ActivityHistory each : activityHis.values() ){
                if( taskList.containsKey(each.Id) ){
                    returnList.add( new wrapperActivityHistory(each, taskList.get(each.Id).RecordType.Name ) );
                }else if( eventList.containsKey(each.Id) ){
                    returnList.add( new wrapperActivityHistory(each, eventList.get(each.Id).RecordType.Name ) );
                }
                
            }
            
            /*for( Task eachTask : [ select Id,Subject,tolabel(Status),tolabel(RTL_Event_Status__c),tolabel(Priority),
                                  ActivityDate,Owner.Name,LastModifiedDate,RTL_NBO_History__c,RecordType.Name from Task where Id IN :activityHis.keyset() limit :limitSize ]  ){ 
                                      if( returnList.size() < limitSize ){
                                          returnList.add( new wrapperActivityHistory(eachTask, activityHis.get(eachTask.Id) ) );
                                      }
                                      
                                  }  */
            
           /* for( Event eachEvent : [ select Id,Subject,tolabel(RTL_Event_Status__c),
                                    ActivityDate,Owner.Name,LastModifiedDate,RTL_NBO_History__c,RecordType.Name from Event where Id IN :activityHis.keyset() limit :limitSize ]  ){ 
                                        if( returnList.size() < limitSize ){
                                            returnList.add( new wrapperActivityHistory(eachEvent, activityHis.get(eachEvent.Id) ) );
                                        }
                                    }*/
            
            return returnList;
        }catch( Exception e ){
            return new List<wrapperActivityHistory>();
        }
    }
    
    public class wrapperActivityHistory{
        public ActivityHistory t {get;set;}
        public String recordTypeName {get;set;}
        
        public wrapperActivityHistory(ActivityHistory t,String recordTypeName){            
            this.t = t;            
            this.recordTypeName = recordTypeName;
        }
    }
    
    public void callInterestedProductList(){       
        InterestedProductList = queryInterestedProductList();
    }
    public List<RTL_Interested_products_c__c > queryInterestedProductList(){
        try{
            interestProductSize = [ select count() from RTL_Interested_products_c__c  where Customer__c = :currentObject.Id ];
            return [ select id,Name,Product_Name__c,Product_group__c,Product_Sub_Group__c,LastModifiedDate,Product_Name__r.Name
                    from RTL_Interested_products_c__c 
                    where Customer__c = :currentObject.Id order by LastModifiedDate desc limit :limitSize ];
        }catch( Exception e ){
            return new List<RTL_Interested_products_c__c>();
        }
    }
    
    public void callFnaActivityList(){
        FnaActivityList = queryFnaActivityList();
    }
    public List<FNA_Activity__c > queryFnaActivityList(){
        try{
            FnaActivitySize = [ SELECT count() FROM FNA_Activity__c WHERE Customer__c = :currentObject.Id ];
            return [ SELECT id, Name, Avatar_Master__c, Avatar_Master__r.name, Avatar_Name__c, Product_Interested__c, Product_Holding__c, 
                    		CreatedDate, Expired__c, LastModifiedDate, Have_Referral__c
                    FROM FNA_Activity__c 
                    WHERE Customer__c = :currentObject.Id order by LastModifiedDate desc limit :limitSize ];
        }catch( Exception e ){
            return new List<FNA_Activity__c>();
        }
    }
    
    public void callAccountHistoryList(){       
        AccountHistoryList = queryAccountHistoryList();
    }
    public List<AccountHistory > queryAccountHistoryList(){
        try{            
            List<AccountHistory> returnList = new List<AccountHistory>();
            accountHistorySize = 0;
            //accountHistorySize = [ select count() from AccountHistory where accountId = :currentObject.Id];
           /* returnList = [ select tolabel(Field),OldValue,NewValue,CreatedDate,CreatedBy.Name,CreatedById
                    from AccountHistory 
                    where accountId = :currentObject.Id order by CreatedDate desc limit :limitSize  ];*/
            Integer c = 0;
            for( AccountHistory each : [ select tolabel(Field),OldValue,NewValue,CreatedDate,CreatedBy.Name,CreatedById
                    from AccountHistory 
                    where accountId = :currentObject.Id order by CreatedDate desc ] ){
                        if( each.OldValue != null ){
                           /* System.debug('oldValue '+String.valueOf(each.OldValue));
                            System.debug('oldBoolean '+(String.valueOf(each.OldValue).startsWith('005')));
                            System.debug('oldBoolean '+(String.valueOf(each.OldValue).startsWith('00G')));*/
                            if( ( !(String.valueOf(each.OldValue).startsWith('005')) && !(String.valueOf(each.OldValue).startsWith('00G'))  ) ){
                                if( c < 5){
                                    returnList.add(each);
                                    c++;
                                }
                                accountHistorySize++;
                            }
                        }else if( each.NewValue != null ){
                           /* System.debug('NewValue '+String.valueOf(each.NewValue));
                            System.debug('NewValue '+(String.valueOf(each.NewValue).startsWith('005')));
                            System.debug('NewValue '+(String.valueOf(each.NewValue).startsWith('00G')));*/
                            if( ( !(String.valueOf(each.NewValue).startsWith('005')) && !(String.valueOf(each.NewValue).startsWith('00G'))  ) ){
                                if( c < 5){
                                    returnList.add(each);
                                    c++;
                                }
                                accountHistorySize++;
                                 }
                        }else{
                            if( c < 5){
                                returnList.add(each);
                                c++;
                            }
                            accountHistorySize++;
                        }

            }
            return returnList;
        }catch( Exception e ){
            return new List<AccountHistory>();
        }
    }
    
    public void callNoteAndAttachList(){       
        NoteAndAttachList = queryNoteAndAttachList();
    }
    public List<wrapperNoteAndAttach> queryNoteAndAttachList(){
        try{
            List<wrapperNoteAndAttach> returnList = new List<wrapperNoteAndAttach>();
            noteAndAttachSize = [ Select (Select Id From NotesAndAttachments)  from Account where Id = :currentObject.Id].NotesAndAttachments.size();
            for( NoteAndAttachment each : [ Select Id, (Select Id, IsNote, Title,Parent.Name,ParentId,CreatedById,CreatedBy.Name,LastModifiedDate 
                                                        From NotesAndAttachments order by LastModifiedDate desc limit :limitSize )
                                    from Account
                                    where Id = :currentObject.Id order by CreatedDate desc ].NotesAndAttachments ){
                                        String lbType = (each.IsNote) ? 'Note' : 'Attachment';
                                        returnList.add( new wrapperNoteAndAttach(each,lbType) );
                                    }
            return returnList;
        }catch( Exception e ){
            return new List<wrapperNoteAndAttach>();
        }
    }
    
    public class wrapperNoteAndAttach{
        public NoteAndAttachment naa {get;set;}
        public String noteType {get;set;}
        public wrapperNoteAndAttach(NoteAndAttachment naa,String noteType){
            this.naa = naa;
            this.noteType = noteType;            
        }
    }
    
    // TMBCCC-20 start
    public String getMessengerCoverArea(String zipcode){
        try{
            return  [ select RTL_Area__c from RTL_Messenger_Cover_Area__c where RTL_Zip_Code__c = :zipcode limit 1 ].RTL_Area__c;
        }catch( Exception e ){
            return 'Not Cover';
        }
    }
    
    public static Boolean getIsCoverArea(){
        String profileName = [ select Name from profile where Id = :UserInfo.getProfileId() limit 1 ].Name;
        try{
            return [ select Cover_Area__c from RTL_Customer_Call_Center__mdt where Profile_Name__c = :profileName ].Cover_Area__c;
        }catch( Exception e ){
            return false;
        }
    }
    // TMBCCC-20 end

    /*public String getCustomFieldId(String objName,String fieldName){
        try{
            String objid = objName;//Id of the object
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v43.0/tooling/query/?q=Select+id,DeveloperName+from+CustomObject+where+DeveloperName=\''+objid+'\'');
            req.setMethod('GET');
            System.debug('endpoint : '+ req.getEndpoint() );
            System.debug('body toString'+req.toString());
            Http h = new Http();
            HttpResponse res = h.send(req);    
            req.setMethod('POST');
            string a = res.getBody(); 
            System.debug('a : '+a);
            list<String> lst = new list<String>();
            Matcher m = Pattern.compile('"Id":"(\\w+)","DeveloperName":"(\\w+)"').matcher(a);
            String queryid;
            while(m.find()) {
                lst.add(m.group(2)+':'+m.group(1)); 
                queryid = m.group(1);
            }
            System.debug(lst);
            System.debug('queryid '+queryid);
            String fName = fieldName;//Id of the object
            objid = queryid;//Id of the object
            req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v43.0/tooling/query/?q=Select+id,DeveloperName+from+CustomField+where+DeveloperName=\''+fName+'\'+and+TableEnumOrId=\''+objid+'\'');
            req.setMethod('GET');
            h = new Http();
            res = h.send(req);    
            req.setMethod('POST');
            a = res.getBody(); 
            System.debug('a : '+a);
            lst = new list<String>();
            String rsReturn;
            m = Pattern.compile('"Id":"(\\w+)","DeveloperName":"(\\w+)"').matcher(a);
            while(m.find()) {
                lst.add(m.group(2)+':'+m.group(1)); 
                rsReturn = m.group(1).substring(0,15);
            }
            System.debug(lst);
            return rsReturn;
        }catch( Exception e ){
            System.debug('erorr : '+e.getMessage());
        }
        return null;
    }*/
    
    public Map<String,CallCenter_RelatedList__mdt> getConfigRelatedList(){
        Map<String,CallCenter_RelatedList__mdt> rsList = new Map<String,CallCenter_RelatedList__mdt>();
        try{
            for( CallCenter_RelatedList__mdt each : [ select Object_API__c,RLID__c from CallCenter_RelatedList__mdt ] ){
                rsList.put(each.Object_API__c,each);
            }
        }catch( Exception e ){
            System.debug('erorr : '+e.getMessage());
        }
        
        return rsList;
    }
    
    public boolean getCheckPermissionRecord(){
        try{
            return [ SELECT RecordId,HasEditAccess  FROM UserRecordAccess WHERE UserId= :UserInfo.getUserId() AND RecordId = :currentObject.Id limit 1 ].HasEditAccess;
        }catch( Exception e ){
            return false;
        }     
    }

    //CR CCPIN ----------------
    public Verification_History__c getVerification(String Id)
    {
        try
        {
            return [SELECT Id, Name, Verification_Type__c, Verification_Result__c, Verification_Status__c, Fail_Reason__c, Xfer__c, Phone_Number__c, Extension_Number__c, 
                Call_ID__c, Employee_ID__c, TMB_Cust_ID__c, Customer__c, Verification_Date_Time__c,Verification_Action__c
                FROM Verification_History__c WHERE Id =: Id];
        }
        catch( Exception e )
        {
            return null;
        }  
    }

    public void callVerificationList(){       
        VerificationList = queryVerificationList();
        
        List<Verification_Status_Code__mdt> statusCodeList = [SELECT Id, Label, Color__c,Description__c FROM Verification_Status_Code__mdt]; 
        Map<String,String> statusMap = new Map<String,String>();

        for( Verification_Status_Code__mdt codeList : statusCodeList)
        {
            statusMap.put(codeList.Label, codeList.Description__c);
        }
        for( Verification_History__c vh : VerificationList)
        {
            if( statusMap.containsKey( vh.Verification_Status__c ) )
            {
                vh.Verification_Status__c = statusMap.get( vh.Verification_Status__c );
            }
        }
    } 

     public void callVerificationListSize(){       
        verificationListSize = queryVerificationListSize().Size();
        
    } 
    
    public List<Verification_History__c > queryVerificationList(){
        try{       
            return [ SELECT Id, Name, Verification_Type__c, Verification_Result__c, Verification_Status__c, Fail_Reason__c, Xfer__c, 
                Phone_Number__c, Extension_Number__c, Call_ID__c, Employee_ID__c, TMB_Cust_ID__c, Customer__c, Verification_Date_Time__c 
                FROM Verification_History__c
                WHERE Customer__c = :currentObject.Id Order By LastModifiedDate DESC LIMIT :limitSize  ];
 
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
            return new List<Verification_History__c>();
        }
    }

    public List<Verification_History__c > queryVerificationListSize(){
        try{       
            return [ SELECT Id, Name, Verification_Type__c, Verification_Result__c, Verification_Status__c, Fail_Reason__c, Xfer__c, 
                Phone_Number__c, Extension_Number__c, Call_ID__c, Employee_ID__c, TMB_Cust_ID__c, Customer__c, Verification_Date_Time__c 
                FROM Verification_History__c
                WHERE Customer__c = :currentObject.Id Order By LastModifiedDate ];
 
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
            return new List<Verification_History__c>();
        }
    }
    // -------------------------
}