public class RTL_CampaignHistoryExtension {
    private static final string SECTION_CAMP_HIST = 'RtlCust:Campaign History';
    public Boolean isAccessibleCampHist {get;set;}
    private Map<String,RTL_Fulfillment_Type_Mapping__mdt> mapFulfillmentType = new Map<String,RTL_Fulfillment_Type_Mapping__mdt>();
    public class MassCampaignData{
        public Campaign camObj  {get;set;}
        public CampaignMember camMemObj  {get;set;}
        public CampaignMember getCam()
        {
            if( this.camObj != null )
            {
                return new CampaignMember(CampaignId = this.camObj.id);
            }
            else
            {
                return null;
            }
        }
    }
    public class SmsCampaignData{
        public Campaign camObj  {get;set;}
        public SMSCampaignMemberResponse smsCamMemObj  {get;set;}
        public CampaignMember getCam()
        {
            if( this.camObj != null )
            {
                return new CampaignMember(CampaignId = this.camObj.id);
            }
            else
            {
                return null;
            }
        }
    }
    public class FulfillmentnData{
        public Campaign camObj  {get;set;}
        public RTL_Fulfillment__c fulfillmentObj  {get;set;}
        public String status_code_string {get;set;}
        public CampaignMember getCam()
        {
            if( this.camObj != null )
            {
                return new CampaignMember(CampaignId = this.camObj.id);
            }
            else
            {
                return null;
            }
        }
    }
    public class ExclusiveCampaignData{
        public Campaign camObj  {get;set;}
        public CampaignMemberResponse camMemResObj  {get;set;}
        public CampaignMember getCam()
        {
            if( this.camObj != null )
            {
                return new CampaignMember(CampaignId = this.camObj.id);
            }
            else
            {
                return null;
            }
        }
        
    }
    
    public Account accountObj{get;set;}
    private Id accountId;
    public List<String> exclusiveCampaignRecordTypeDevName {
        get{
            if( exclusiveCampaignRecordTypeDevName == null )
            {
                exclusiveCampaignRecordTypeDevName = new List<String>();
                exclusiveCampaignRecordTypeDevName.add('Exclusive_Campaign_Active');
                exclusiveCampaignRecordTypeDevName.add('Exclusive_Campaign_Expired');
                
            }
            return exclusiveCampaignRecordTypeDevName;
        }
        set;
    }
    public List<String> localExCampaignRecordTypeDevName {
        get{
            if( localExCampaignRecordTypeDevName == null )
            {
                localExCampaignRecordTypeDevName = new List<String>();
                localExCampaignRecordTypeDevName.add('Local_Exclusive_Campaign_Active');
                localExCampaignRecordTypeDevName.add('Local_Exclusive_Campaign_Expired');
                localExCampaignRecordTypeDevName.add('Local_Exclusive_Campaign');   
            }
            return localExCampaignRecordTypeDevName;
        }
        set;
    }
    public List<String> massCampaignRecordTypeDevName {
        get{
            if( massCampaignRecordTypeDevName == null )
            {
                massCampaignRecordTypeDevName = new List<String>();
                massCampaignRecordTypeDevName.add('Mass_Campaign_Active');
            }
            return massCampaignRecordTypeDevName;
        }
        set;
    }
    private Integer calloutTimeoutSecond{
        get{
            if( calloutTimeoutSecond == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,CalloutTimeoutSecond__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                calloutTimeoutSecond = (Integer)chMeta.CalloutTimeoutSecond__c;
            }
            return calloutTimeoutSecond;
        }
        set;
    }
    public String campaignLiteURL {
        get{
            if( campaignLiteURL == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,CampaignLiteURL__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                campaignLiteURL = chMeta.CampaignLiteURL__c;
            }
            return campaignLiteURL;
        }
        set;
    }
    private Integer customerRequestCampaignItemPerPage {
        get{
            if( customerRequestCampaignItemPerPage == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,CustomerRequestDisplay__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                customerRequestCampaignItemPerPage = integer.valueOf(chMeta.CustomerRequestDisplay__c);
            }
            return customerRequestCampaignItemPerPage;
        }
        set;
    }
    public List<CampaignMember> customerRequestCampaign {get;set;}
    public Integer customerRequestCampaignPage {get;set;}
    public Long customerRequestCampaignTotalPage {get;set;}
    public Boolean disablePreviousCustomerRequeste {get;set;}
    public Boolean disableNextCustomerRequest {get;set;}
    public List<Integer> customerRequestPageList {get;set;}

    public List<CampaignMember> call_customerRequestCampaign {get;set;}
    public Integer call_customerRequestCampaignPage {get;set;}
    public Long call_customerRequestCampaignTotalPage {get;set;}
    public Boolean call_disablePreviousCustomerRequeste {get;set;}
    public Boolean call_disableNextCustomerRequest {get;set;}
    public List<Integer> call_customerRequestPageList {get;set;}
    
    private Integer exclusiveCampaignItemPerPage {
        get{
            if( exclusiveCampaignItemPerPage == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,ExclusiveDisplay__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                exclusiveCampaignItemPerPage = integer.valueOf(chMeta.ExclusiveDisplay__c);
            }
            return exclusiveCampaignItemPerPage;
        }
        set;
    }
    private Integer call_exclusiveCampaignItemPerPage {
        get{
            if( call_exclusiveCampaignItemPerPage == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,ExclusiveDisplay__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                call_exclusiveCampaignItemPerPage = integer.valueOf(chMeta.ExclusiveDisplay__c);
            }
            return call_exclusiveCampaignItemPerPage;
        }
        set;
    }
    private Integer Max_Exclusive_records {
        get{
            if( Max_Exclusive_records == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,ExclusiveDisplay__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Max_Exclusive_records'];
                Max_Exclusive_records = chMeta.ExclusiveDisplay__c != null ? integer.valueOf(chMeta.ExclusiveDisplay__c) : 100;
            }
            return Max_Exclusive_records;
        }
        set;
    }
    private Integer smsCampaignItemPerPage {
        get{
            if( smsCampaignItemPerPage == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,SmsDisplay__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                smsCampaignItemPerPage = integer.valueOf(chMeta.SmsDisplay__c);
            }
            return smsCampaignItemPerPage;
        }
        set;
    }
    public List<CampaignMember> exclusiveCampaign {get;set;}
    public Integer exclusiveCampaignPage {get;set;}
    public Long exclusiveExCampaignTotalPage {get;set;}
    public Boolean disablePreviousExclusive {get;set;}
    public Boolean disableNextExclusive {get;set;}
    public List<Integer> exclusivePageList {get;set;}
    public List<CampaignMember> call_exclusiveCampaign {get;set;}
    public Integer call_exclusiveCampaignPage {get;set;}
    public Long call_exclusiveExCampaignTotalPage {get;set;}
    public Boolean call_disablePreviousExclusive {get;set;}
    public Boolean call_disableNextExclusive {get;set;}
    public List<Integer> call_exclusivePageList {get;set;}
    public Integer campaignPage;
    public Integer CampaignItemPerPage;
    public List<CampaignMember> smsCampaign {get;set;}
    public Integer smsCampaignPage {get;set;}
    public Long smsExCampaignTotalPage {get;set;}
    public Boolean disablePreviousSMS {get;set;}
    public Boolean disableNextSMS {get;set;}
    public List<Integer> smsPageList {get;set;}
    public List<Integer> listItem {get;set;}
    private Integer localExCampaignItemPerPage {
        get{
            if( localExCampaignItemPerPage == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,LocalExclusiveDisplay__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                localExCampaignItemPerPage = integer.valueOf(chMeta.LocalExclusiveDisplay__c);
            }
            return localExCampaignItemPerPage;
        }
        set;
    }
    public List<CampaignMember> localExCampaign {get;set;}
    public Integer localExCampaignPage {get;set;}
    public Long localExCampaignTotalPage {get;set;}
    public Boolean disablePreviousLocalEx {get;set;}
    public Boolean disableNextLocalEx {get;set;}
    public List<Integer> localExPageList {get;set;}
    public String campaignPeriodMethod {get;set;}
    private Date campaignFromDate;
    private Date campaignToDate;
    private Integer massCampaignItemPerPage {
        get{
            if( massCampaignItemPerPage == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,MassDisplay__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                massCampaignItemPerPage = integer.valueOf(chMeta.MassDisplay__c);
            }
            return massCampaignItemPerPage;
        }
        set;
    }
    //public List<CampaignMember> massCampaign {get;set;}
    public List<MassCampaignData> massCampaign {get;set;}
    public Integer massCampaignPage {get;set;}
    public Long massCampaignTotalPage {get;set;}
    public Boolean disablePreviousMass {get;set;}
    public Boolean disableNextMass {get;set;}
    public List<Integer> massPageList {get;set;}
    public List<RTL_Fulfillment__c> fulfillmentList {get;set;}
    public Integer fulfillmentPage {get;set;}
    public Long fulfillmentTotalPage {get;set;}
    public Boolean disablePreviousfulfillment {get;set;}
    public Boolean disableNextfulfillment {get;set;}
    public List<Integer> fulfillmentPageList {get;set;}
    public List<FulfillmentnData> fulfillData {get;set;}
    private Integer fulfillmentItemPerPage {
        get{
            if( fulfillmentItemPerPage == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,FulfillmentDisplay__c
                                                            from RTL_Campaign_History_Setting__mdt 
                                                            where DeveloperName = 'Campaign_Display_Setting'];
                fulfillmentItemPerPage = integer.valueOf(chMeta.FulfillmentDisplay__c);
            }
            return fulfillmentItemPerPage;
        }
        set;
    }
    public List<Integer> customerRequestPagination {get;set;}
    public List<Integer> call_customerRequestPagination {get;set;}
    public List<Integer> exclusivePagination {get;set;}    
    public List<Integer> call_exclusivePagination {get;set;}  
    public List<Integer> localExPagination {get;set;}
    public List<Integer> massPagination {get;set;}
    
    public List<Integer> smsPagination {get;set;}
    public List<Integer> fulfilmentPaignation {get;set;}
    public Boolean isCallingCampaign {
        get{
            if( isCallingCampaign == null )
            {
                isCallingCampaign = true;
            }
            return isCallingCampaign;
        }
        set;
    }
    public Boolean isRenderCampaign  {
        get{
            if( isRenderCampaign == null )
            {
                isRenderCampaign = false;
            }
            return isRenderCampaign;
        }
        set;
    }
    public Boolean isRenderSMS {
        get{
            if( isRenderSMS == null )
            {
                isRenderSMS = false;
            }
            return isRenderSMS;
        }
        set;
    }
    public Boolean isRenderFulfillment {
        get{
            if( isRenderFulfillment == null )
            {
                isRenderFulfillment = false;
            }
            return isRenderFulfillment;
        }
        set;
    }
    public Boolean isRenderCallingCampaign {
        get{
            if( isRenderCallingCampaign == null )
            {
                isRenderCallingCampaign = false;
            }
            return isRenderCallingCampaign;
        }
        set;
    }
    private String endpointInt06{
        get{
            if( endpointInt06 == null )
            {
                RTL_Campaign_Endpoint__c endpointSetting = RTL_Campaign_Endpoint__c.getValues('Campaign TO HQ INT06');
                if( endpointSetting != null )
                {
                    endpointInt06 = endpointSetting.RTL_Endpoint__c;
                }
            }
            return endpointInt06;
        }
        set;
    }
    private String endpointInt07{
        get{
            if( endpointInt07 == null )
            {
                RTL_Campaign_Endpoint__c endpointSetting = RTL_Campaign_Endpoint__c.getValues('Campaign TO HQ INT07');
                if( endpointSetting != null )
                {
                    endpointInt07 = endpointSetting.RTL_Endpoint__c;
                }
            }
            return endpointInt07;
        }
        set;
    }
    public String requestLabel;
    public Boolean exclusiveCalloutSuccess{
        get{
            if( exclusiveCalloutSuccess == null )
            {
                exclusiveCalloutSuccess = true;
            }
            return exclusiveCalloutSuccess;
        }
        set;
    }
    public Boolean call_exclusiveCalloutSuccess{
        get{
            if( call_exclusiveCalloutSuccess == null )
            {
                call_exclusiveCalloutSuccess = true;
            }
            return call_exclusiveCalloutSuccess;
        }
        set;
    }

    public String exclusiveCalloutError{get;set;}
    public String exclusiveCalloutErrorDesc{get;set;}
    public String call_exclusiveCalloutError{get;set;}
    public String call_exclusiveCalloutErrorDesc{get;set;}
    public Boolean smsCalloutSuccess{
        get{
            if( smsCalloutSuccess == null )
            {
                smsCalloutSuccess = true;
            }
            return smsCalloutSuccess;
        }
        set;
    }
    public String int06DataList {get;set;}
    public String smsCalloutError{get;set;}
    public String smsCalloutErrorDesc{get;set;}
    Class CampaignMemberResponse{
        public String CampaignSalseforceId{get;set;}
        public String CampaignCode{get;set;}
        public String MarketingCode{get;set;}
        public String ProductOfferString{get;set;}
        public String CampaignChannel{get;set;}
        public String MobileNumber{get;set;}
        public String UpdateDate{get;set;}
        public String ResultContact{get;set;}
        public String AgentID{get;set;}
        public String ResultDetail{get;set;}
        public String ResultBusiness{get;set;}
        public String ContactDate{get;set;}
        public String Reason{get;set;}
        public String SmsMessage{get;set;}
        public String SmsContent{get;set;}
        public String RegisterDate{get;set;}
        public String DisplayFlag{get;set;}
        public String DisplayDate{get;set;}
        public String ClickFlag{get;set;}
        public String EmailSendDate{get;set;}
        public String EmailRejectDate{get;set;}
        public String EmailOpenFlag{get;set;}
        public String EmailClickFlag{get;set;}
        public String EmailClickDate{get;set;}
        public String ContactSubStatus{get;set;}
        public String OfferSubResult{get;set;}
        public String OfferResult{get;set;}
        public CampaignMember camMemObject {get;set;}
    }
    Class SMSCampaignMemberResponse{
        public String SourceUniqueID{get;set;}
        public String MobilePhoneNumber{get;set;} 
        public String CampaignCode{get;set;}
        public String Message{get;set;}
        public String Content{get;set;} 
        public String RegisterDateText{get;set;}
        public DateTime RegisterDate{
            get{
                return parseDateTime(RegisterDateText);
            }
            set;
        }
        public String RegisterDateFormatted{
            get{
                return parseDateTime(RegisterDateText).addHours(-7).format();
            }
            set;
        }
        public String ApplyChannel{get;set;}
        private DateTime parseDateTime(String dateTimeText)
        {
            try{
                if( dateTimeText != null && dateTimeText != '' )
                {
                    return DateTime.valueOfGMT(dateTimeText.replace('T',' '));
                }
                else
                {
                    return null;
                }
            }
            catch (Exception e)
            {
                return null;
            }
        }
    }
    Class FulfillmentCampaignMemberResponse{
        //public String CampaignCode{get;set;}
        //public String CampaignCode{get;set;}
        //public String CampaignCode{get;set;}
    }
    
    // Callback method
    private List<String>  campCode;
    public List<CampaignMemberResponse> cmWrapperList {get;set;}
    public List<CampaignMemberResponse> call_cmWrapperList {get;set;}
    public List<SMSCampaignMemberResponse> smsWrapperList {get;set;}
    public List<FulfillmentCampaignMemberResponse> fulfillmentWrapperList {get;set;}
    public List<SmsCampaignData> smsCampData {get;set;}
    public List<ExclusiveCampaignData> cmData {get;set;}
    public List<ExclusiveCampaignData> call_cmData {get;set;}
    private String requestBodyINT06;
    private String requestBodyINT07;
    // -------- Telephony Outbound ---------
    public Boolean checkProfileAssign {get;set;}
    public List<Campaign_Member_Profile_Assignment__mdt> cmProfileAssign {
        get{
            if(cmProfileAssign == null)
            {
                cmProfileAssign = [SELECT Id,MasterLabel,DeveloperName,Profile_Name__c FROM Campaign_Member_Profile_Assignment__mdt];
            }
            return cmProfileAssign;
        }
        set;
    }
    // -------- Telephony Outbound ---------
    public RTL_CampaignHistoryExtension(ApexPages.StandardController stdController) {
        accountId = stdController.getRecord().id;
        try {
            accountObj = [Select ID,Name,TMB_Customer_ID_PE__c FROM Account WHERE id =: accountId ];
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        /*
CR Data Partition Check for access right 
*/
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        isAccessibleCampHist = RTL_AccountUtility.verifyFieldSecurity(SECTION_CAMP_HIST,userProfile.name,accountId );
        // -------- Telephony Outbound ---------
        System.debug('User Profile : ' + userProfile.Name.ToUpperCase());
        for(Campaign_Member_Profile_Assignment__mdt profileAssign : cmProfileAssign)
        {
            if(userProfile.Name.ToUpperCase() == profileAssign.Profile_Name__c.ToUpperCase())
            {
                checkProfileAssign = true;
                break;
            }
            else {
                checkProfileAssign = false;
            }
        }
        // -------- Telephony Outbound ---------
        // If no right ,do not execute any code
        if( isAccessibleCampHist )
        {
            System.debug('Set default value!');
            isRenderCallingCampaign = true;
            campaignPeriodMethod = '3month';
            exclusiveCampaignPage = 1; 
            call_exclusiveCampaignPage = 1; 
            localExCampaignPage = 1;
            massCampaignPage = 1;
            customerRequestCampaignPage = 1;
            call_customerRequestCampaignPage = 1;
            smsCampaignPage = 1;
            fulfillmentPage =1;
            setCampaignPeriod();
            //requestInt06();
        }
        else 
        {
            //ApexPages.Message( ApexPages.severity.WARNING , Label.Data_Condition_NotAuthorizedMsg );
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.Data_Condition_NotAuthorizedMsg ));
            
        }
        
        //End CR Data Partition
        
    }
    public String selectedTab{get;set;}
    private Datetime startCallINT06;
    private Datetime endCallINT06;
    private Datetime startCallINT07;
    private Datetime endCallINT07;
    public Object requestInt06() 
    {
        System.debug('==== start callout INT06 ============');
        
        startCallINT06 = system.now();
        HttpRequest req = new HttpRequest();
        
        if(isCallingCampaign){
            campaignPage = call_exclusiveCampaignPage;
            CampaignItemPerPage = call_exclusiveCampaignItemPerPage;
        }else{
            campaignPage = exclusiveCampaignPage;
            CampaignItemPerPage = exclusiveCampaignItemPerPage;
        }
        try{
            Integer startRow = 1 + ( campaignPage-1 )*CampaignItemPerPage ;
            Integer endRow =  startRow + CampaignItemPerPage-1;
            String tmbCustId = accountObj.TMB_Customer_ID_PE__c;

            Datetime startDateTime = campaignFromDate;
            Datetime endDateTime = campaignToDate;
            
            String startDate = startDateTime.format('yyyy-MM-dd');
            String endDate = endDateTime.format('yyyy-MM-dd');
            requestBodyINT06 = '<CampaignMemberRequest>\n'+
                '<CampaignMember>\n'+
                '<CustID>'+ tmbCustId +'</CustID>\n'+
                '<CampStartDate>'+ startDate +'</CampStartDate>\n'+
                '<CampEndDate>'+ endDate +'</CampEndDate>\n'+
                '<MarketingCode></MarketingCode>\n'+
                '<StartRow>'+1+'</StartRow>\n'+
                '<EndRow>'+Max_Exclusive_records+'</EndRow>\n'+
                '</CampaignMember>\n'+
                '</CampaignMemberRequest>\n';
            system.debug('Request06: ' + requestBodyINT06);
            // Create callout request
            req.setMethod('POST');
            //req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(endpointInt06);
            req.setBody(requestBodyINT06);
            //============= test for connection ===================
            Http h = new Http();
            HttpRequest reqTest = new HttpRequest();
            reqTest.setEndpoint(endpointInt06);
            reqTest.setMethod('POST');
            HttpResponse resTest = h.send(reqTest);
            //============ throw error if endpoint not available ===========
        }
        catch(Exception e) { 
            endCallINT06 = system.now();
            if(isCallingCampaign){
                call_exclusiveCalloutSuccess = false;
            }else{
                exclusiveCalloutSuccess = false;
            }
            String errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            String errorDescText = e.getMessage() + '(' + e.getLineNumber() + ')';
            String rmId = accountObj.TMB_Customer_ID_PE__c;
            String resultBody = '';
            RTL_CampaignUtil.insertOnlineLogWithResponse( errorCodeText,errorDescText, rmId , RTL_CampaignUtil.INT06_SERVICE_NAME , 
                                                         accountObj.id ,requestBodyINT06 , resultBody , startCallINT06 ,endCallINT06 );
            System.debug(' INT06 Error: '+e.getMessage());
            return null;
        }  
        Continuation con = new Continuation(calloutTimeoutSecond); 
        con.continuationMethod='processResponseInt06';
        this.requestLabel = con.addHttpRequest(req);
        return con;  
    }
    public Object processResponseInt06() {   
        system.debug('==== start process response06 ============');
        endCallINT06 = system.now();
        String resultBody = '';
        String errorCodeText = '';
        String errorDescText = '';
        String rmId = '';
        String tmbCustId = accountObj.TMB_Customer_ID_PE__c;
        String customerName = accountObj.Name;
        rmId = tmbCustId;
        try
        {
            
            // Get the response by using the unique label
            HttpResponse response = Continuation.getResponse(this.requestLabel);
            // Set the result variable that is displayed on the Visualforce page
            
            if( response == null ) 
            { 
                errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
                errorDescText = RTL_CampaignUtil.INT06_NO_RESPONSE_ERROR;
                if(isCallingCampaign){
                    call_exclusiveCalloutSuccess = false;
                    call_exclusiveCalloutError = errorCodeText;
                    call_exclusiveCalloutErrorDesc = errorDescText;
                }else{
                    exclusiveCalloutSuccess = false;
                    exclusiveCalloutError = errorCodeText;
                    exclusiveCalloutErrorDesc = errorDescText;
                }
                
                // RTL_CampaignUtil.insertOnlineLog( errorCodeText,errorDescText, tmbCustId , 'INT06' , customerName );
                // return null;
            }
            else if( response.getStatusCode() != 200 )
            {
                errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
                errorDescText = RTL_CampaignUtil.getHttpResponseMessage( response.getStatus(),response.getStatusCode() );
                if(isCallingCampaign){
                    call_exclusiveCalloutSuccess = false;
                    call_exclusiveCalloutError = errorCodeText;
                    call_exclusiveCalloutErrorDesc = errorDescText;
                }else{
                    exclusiveCalloutSuccess = false;
                    exclusiveCalloutError = errorCodeText;
                    exclusiveCalloutErrorDesc = errorDescText;
                }
            }
            else
            {
                resultBody = response.getBody();
                system.debug('Response06:'+resultBody);
                Dom.Document doc = new Dom.Document();
                doc.load(resultBody);
                Dom.XMLNode root = doc.getRootElement();
                Dom.XMLNode header = root.getChildElement('Header', null);
                //Dom.XMLNode errorCode = header.getChildElement('ErrorCode', null);
                errorCodeText =  header.getChildElement('ErrorCode', null).getText();
                errorDescText =  header.getChildElement('ErrorDescription', null).getText();
                String errorStatusText =  header.getChildElement('ErrorStatus', null).getText();
                cmWrapperList = new List<CampaignMemberResponse>();
                cmData = new List<ExclusiveCampaignData>();
                call_cmWrapperList = new List<CampaignMemberResponse>();
                call_cmData = new List<ExclusiveCampaignData>();
                if( errorStatusText == 'fail' )
                {
                    if(isCallingCampaign){
                        call_exclusiveCalloutSuccess = false;
                        call_exclusiveCalloutError = errorCodeText;
                        call_exclusiveCalloutErrorDesc = errorDescText;
                    }else{
                        exclusiveCalloutSuccess = false;
                        exclusiveCalloutError = errorCodeText;
                        exclusiveCalloutErrorDesc = errorDescText;
                    }
                }
                else 
                {
                    errorCodeText = '';
                    errorDescText = '';
                    if(isCallingCampaign){
                        call_exclusiveCalloutSuccess = true;
                    }else{
                        exclusiveCalloutSuccess = true;
                    }
                    int06DataList = resultBody;
                    setExclusiveData();
                }
            }
        }
        catch(Exception e) {
            System.debug(' INT06 Error: '+e.getMessage());
            errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            errorDescText = e.getMessage() + '(' + e.getLineNumber() + ')';
            if(isCallingCampaign){
                call_exclusiveCalloutSuccess = false;
                call_exclusiveCalloutError = errorCodeText;
                call_exclusiveCalloutErrorDesc = errorDescText;
            }else{
                exclusiveCalloutSuccess = false;
                exclusiveCalloutError = errorCodeText;
                exclusiveCalloutErrorDesc = errorDescText;
            }
            // RTL_CampaignUtil.insertOnlineLog( errorCodeText,errorDescText, tmbCustId , 'INT06' , customerName );
        }
        RTL_CampaignUtil.insertOnlineLogWithResponse( errorCodeText,errorDescText, rmId , RTL_CampaignUtil.INT06_SERVICE_NAME , 
                                                     accountObj.id ,requestBodyINT06 , resultBody , startCallINT06 ,endCallINT06 );
        return null;
    }
    public void setExclusiveData(){
        Integer index = 0;
        Integer TotalRecord = 0;
        cmWrapperList = new List<CampaignMemberResponse>();
        cmData = new List<ExclusiveCampaignData>();
        call_cmWrapperList = new List<CampaignMemberResponse>();
        call_cmData = new List<ExclusiveCampaignData>();

        List<String> campCode = new List<String>();
        List<String> markettingCode = new List<String>();
        System.debug('isCallingCampaign : ' +isCallingCampaign);
        if(isCallingCampaign){
            campaignPage = call_exclusiveCampaignPage;
            CampaignItemPerPage = call_exclusiveCampaignItemPerPage;
        }else{
            campaignPage = exclusiveCampaignPage;
            CampaignItemPerPage = exclusiveCampaignItemPerPage;
        }
        Integer startRow = 1 + ( campaignPage-1 )*CampaignItemPerPage ;
        Integer endRow =  startRow + CampaignItemPerPage-1;
        Dom.Document doc = new Dom.Document();
        doc.load(int06DataList);
        Dom.XMLNode root = doc.getRootElement();
        Dom.XMLNode cmList = root.getChildElement('CampaignMemberList', null);
        System.debug('int06DataList ' + int06DataList);

        for (Dom.XMLNode child: cmList.getChildElements()) {
            String camCode = child.getChildElement('CampaignCode', null).getText().trim();
            if(isCallingCampaign){
                if(camCode.startsWith('D') && !camCode.startsWith('D9')){
                    TotalRecord++;
                    index++;
                }
            }else{
                if(camCode.startsWith('D9')){
                    TotalRecord++;
                    index++;
                }
            }
            if(index >= startRow && index <= endRow){
                if(isCallingCampaign){
                    if(camCode.startsWith('D') && !camCode.startsWith('D9')){
                        CampaignMemberResponse cmr = new CampaignMemberResponse();
                        cmr.CampaignCode = child.getChildElement('CampaignCode', null).getText().trim();
                        cmr.MarketingCode = child.getChildElement('MarketingCode', null).getText().trim();
                        cmr.ProductOfferString = child.getChildElement('ProductOfferString', null).getText().trim();
                        cmr.CampaignChannel = child.getChildElement('CampaignChannel', null).getText().trim();
                        cmr.MobileNumber = child.getChildElement('MobileNumber', null).getText().trim();
                        cmr.UpdateDate = child.getChildElement('UpdateDate', null).getText().trim();
                        cmr.AgentID = child.getChildElement('AgentID', null).getText().trim();
                        cmr.ResultDetail = child.getChildElement('ResultDetail', null).getText().trim();
                        cmr.ResultBusiness = child.getChildElement('ResultBusiness', null).getText().trim();
                        cmr.ContactDate = child.getChildElement('ContactDate', null).getText().trim();
                        cmr.Reason = child.getChildElement('Reason', null).getText().trim();
                        cmr.SmsMessage = child.getChildElement('SmsMessage', null).getText().trim();
                        cmr.SmsContent = child.getChildElement('SmsContent', null).getText().trim();
                        cmr.RegisterDate = child.getChildElement('RegisterDate', null).getText().trim();
                        cmr.DisplayFlag = child.getChildElement('DisplayFlag', null).getText().trim();
                        cmr.DisplayDate = child.getChildElement('DisplayDate', null).getText().trim();
                        cmr.ClickFlag = child.getChildElement('ClickFlag', null).getText().trim();
                        cmr.EmailSendDate = child.getChildElement('EmailSendDate', null).getText().trim();
                        cmr.EmailRejectDate = child.getChildElement('EmailRejectDate', null).getText().trim();
                        cmr.EmailClickFlag = child.getChildElement('EmailClickFlag', null).getText().trim();
                        cmr.EmailClickDate = child.getChildElement('EmailClickDate', null).getText().trim();
                        cmr.ContactSubStatus = child.getChildElement('ContactSubStatus', null).getText().trim();
                        cmr.OfferSubResult = child.getChildElement('OfferSubResult', null).getText().trim();
                        cmr.OfferResult = child.getChildElement('OfferResult', null).getText().trim();
                        call_cmWrapperList.add(cmr);
                        campCode.add(cmr.CampaignCode);
                        markettingCode.add(cmr.MarketingCode);
                    }
                }else{
                    if(camCode.startsWith('D9')){
                        CampaignMemberResponse cmr = new CampaignMemberResponse();
                        cmr.CampaignCode = child.getChildElement('CampaignCode', null).getText().trim();
                        cmr.MarketingCode = child.getChildElement('MarketingCode', null).getText().trim();
                        cmr.ProductOfferString = child.getChildElement('ProductOfferString', null).getText().trim();
                        cmr.CampaignChannel = child.getChildElement('CampaignChannel', null).getText().trim();
                        cmr.MobileNumber = child.getChildElement('MobileNumber', null).getText().trim();
                        cmr.UpdateDate = child.getChildElement('UpdateDate', null).getText().trim();
                        cmr.AgentID = child.getChildElement('AgentID', null).getText().trim();
                        cmr.ResultDetail = child.getChildElement('ResultDetail', null).getText().trim();
                        cmr.ResultBusiness = child.getChildElement('ResultBusiness', null).getText().trim();
                        cmr.ContactDate = child.getChildElement('ContactDate', null).getText().trim();
                        cmr.Reason = child.getChildElement('Reason', null).getText().trim();
                        cmr.SmsMessage = child.getChildElement('SmsMessage', null).getText().trim();
                        cmr.SmsContent = child.getChildElement('SmsContent', null).getText().trim();
                        cmr.RegisterDate = child.getChildElement('RegisterDate', null).getText().trim();
                        cmr.DisplayFlag = child.getChildElement('DisplayFlag', null).getText().trim();
                        cmr.DisplayDate = child.getChildElement('DisplayDate', null).getText().trim();
                        cmr.ClickFlag = child.getChildElement('ClickFlag', null).getText().trim();
                        cmr.EmailSendDate = child.getChildElement('EmailSendDate', null).getText().trim();
                        cmr.EmailRejectDate = child.getChildElement('EmailRejectDate', null).getText().trim();
                        cmr.EmailClickFlag = child.getChildElement('EmailClickFlag', null).getText().trim();
                        cmr.EmailClickDate = child.getChildElement('EmailClickDate', null).getText().trim();
                        cmr.ContactSubStatus = child.getChildElement('ContactSubStatus', null).getText().trim();
                        cmr.OfferSubResult = child.getChildElement('OfferSubResult', null).getText().trim();
                        cmr.OfferResult = child.getChildElement('OfferResult', null).getText().trim();
                        cmWrapperList.add(cmr);
                        campCode.add(cmr.CampaignCode);
                        markettingCode.add(cmr.MarketingCode);
                    }
                }
            }
        }
        List<Campaign> idCampCodeList = new List<Campaign>([SELECT ID,RTL_Campaign_Code_10_digits__c,
                                                            Name,StartDate,EndDate,status,RTL_Campaign_Channel__c,RTL_Campaign_Channel_formula__c
                                                            FROM Campaign
                                                            WHERE RTL_Campaign_Code_10_digits__c in :campCode]);
        Map<String,Campaign> idCamCodeMap =  new Map<String, Campaign>();
        for( Campaign cc : idCampCodeList )
        {
            if( !idCamCodeMap.containsKey(cc.RTL_Campaign_Code_10_digits__c) )
            {
                idCamCodeMap.put(cc.RTL_Campaign_Code_10_digits__c,cc);
            }
        }
        List<CampaignMember> cammemList = [SELECT id,RTL_Marketing_Code__c,RTL_Offer_Result__c,RTL_Offer_Result_CC__c  FROM CampaignMember WHERE RTL_Marketing_Code__c in :markettingCode ];
        MAP<String,CampaignMember> cammemSFMap = new MAP<String,CampaignMember>();
        for( CampaignMember cm : cammemList )
        {
            cammemSFMap.put(cm.RTL_Marketing_Code__c,cm);
        }
        MAP<String,CampaignMemberResponse> campaignCodeWithObj = new MAP<String,CampaignMemberResponse>();
        if(isCallingCampaign){
            for( CampaignMemberResponse cmr : call_cmWrapperList )
            {
                if( cammemSFMap.containsKey(cmr.MarketingCode) )
                {
                    cmr.CampaignSalseforceId = cammemSFMap.get(cmr.MarketingCode).id;
                    cmr.camMemObject = cammemSFMap.get(cmr.MarketingCode);
                }
                if( !campaignCodeWithObj.containsKey(cmr.CampaignCode) )
                {
                    campaignCodeWithObj.put(cmr.CampaignCode,cmr);
                }
            }
        }else{
            for( CampaignMemberResponse cmr : cmWrapperList )
            {
                if( cammemSFMap.containsKey(cmr.MarketingCode) )
                {
                    cmr.CampaignSalseforceId = cammemSFMap.get(cmr.MarketingCode).id;
                    cmr.camMemObject = cammemSFMap.get(cmr.MarketingCode);
                }
                if( !campaignCodeWithObj.containsKey(cmr.CampaignCode) )
                {
                    campaignCodeWithObj.put(cmr.CampaignCode,cmr);
                }
            }
        }
        
        
        for ( String idKey : campaignCodeWithObj.keyset() ) 
        {
            Campaign c = idCamCodeMap.get(idKey);
            ExclusiveCampaignData mcd = new ExclusiveCampaignData();
            mcd.camObj = c;
            mcd.camMemResObj = campaignCodeWithObj.get(idKey);
            if(isCallingCampaign){
                call_cmData.add(mcd);
            }else{
                cmData.add(mcd);
            }
        }

        exclusivePageList = new List<Integer>();
        call_exclusivePageList = new List<Integer>();

        Integer rowLimit = isCallingCampaign? call_exclusiveCampaignItemPerPage : exclusiveCampaignItemPerPage;
        System.debug('Total Rec : ' + TotalRecord);
        System.debug('rowLimit Rec : ' + rowLimit);

        if(isCallingCampaign){
            call_exclusiveExCampaignTotalPage = ((Decimal.valueOf(TotalRecord) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);
            call_disablePreviousExclusive = false;
            call_disableNextExclusive = false;
            if( call_exclusiveCampaignPage == 1)
            {
                call_disablePreviousExclusive = true;
            }
            if( call_exclusiveCampaignPage >= call_exclusiveExCampaignTotalPage )
            {
                call_disableNextExclusive = true;
            }
            Integer count = 1;
            call_exclusivePageList.add(count);
            while ( count*rowLimit < TotalRecord ) {
                count++;
                call_exclusivePageList.add(count);
            }
            call_exclusivePagination = pagination(call_exclusivePageList,call_exclusiveCampaignPage);
        }else{
            exclusiveExCampaignTotalPage = ((Decimal.valueOf(TotalRecord) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);
            disablePreviousExclusive = false;
            disableNextExclusive = false;
            if( exclusiveCampaignPage == 1)
            {
                disablePreviousExclusive = true;
            }
            if( exclusiveCampaignPage >= exclusiveExCampaignTotalPage )
            {
                disableNextExclusive = true;
            }
            Integer count = 1;
            exclusivePageList.add(count);
            while ( count*rowLimit < TotalRecord ) {
                count++;
                exclusivePageList.add(count);
            }
            exclusivePagination = pagination(exclusivePageList,exclusiveCampaignPage);
        }
    }
    public Object requestInt07() 
    {
        System.debug('==== start callout INT 07 ============');
        startCallINT07 = system.now();
        
        HttpRequest req = new HttpRequest();
        try{
            
            Integer startRow =  1 +(smsCampaignPage - 1) * smsCampaignItemPerPage ;
            Integer endRow =  startRow + smsCampaignItemPerPage-1;
            String tmbCustId = accountObj.TMB_Customer_ID_PE__c;
            String startDate =  Datetime.now().addYears(-2).format('yyyy-MM-dd');
            String endDate = Datetime.now().format('yyyy-MM-dd');
            requestBodyINT07 = '<SmsRegistrationRequest>\n'+
                '<CampaignMember>\n'+
                '<CustID>'+ tmbCustId +'</CustID>\n'+
                '<FromDate>'+ startDate +'</FromDate>\n'+
                '<ToDate>'+ endDate +'</ToDate>\n'+
                '<StartRow>'+startRow+'</StartRow>\n'+
                '<EndRow>'+endRow+'</EndRow>\n'+
                '</CampaignMember>\n'+
                '</SmsRegistrationRequest>\n';
            system.debug('Request07: ' + requestBodyINT07);
            //============= test for connection ===================
            Http h = new Http();
            HttpRequest reqTest = new HttpRequest();
            reqTest.setEndpoint(endpointInt07);
            reqTest.setMethod('POST');
            HttpResponse resTest = h.send(reqTest);
            //============ throw error if endpoint not available ===========
            req.setMethod('POST');
            req.setEndpoint(endpointInt07);
            req.setBody(requestBodyINT07);
            
        }
        catch(Exception e) {
            endCallINT07 = system.now();
            smsCalloutSuccess = false;
            String errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            String errorDescText = e.getMessage() + '(' + e.getLineNumber() + ')';
            String rmId = accountObj.TMB_Customer_ID_PE__c;
            String resultBody = '';
            RTL_CampaignUtil.insertOnlineLogWithResponse( errorCodeText,errorDescText, rmId , RTL_CampaignUtil.INT07_SERVICE_NAME , 
                                                         accountObj.id ,requestBodyINT07 , resultBody , startCallINT07 ,endCallINT07  );
            System.debug(e.getMessage());
            return null;
        }
        Continuation con = new Continuation(calloutTimeoutSecond);
        con.continuationMethod='processResponseInt07';
        this.requestLabel = con.addHttpRequest(req);
        return con; 
    }
    public Object processResponseInt07() {   
        system.debug('==== start process response INT 07 ============');
        endCallINT07 = system.now();
        
        String resultBody = '';
        String errorCodeText = '';
        String errorDescText = '';
        String rmId = '';
        String tmbCustId = accountObj.TMB_Customer_ID_PE__c;
        String customerName = accountObj.Name;
        rmId = tmbCustId;
        try
        {
            
            HttpResponse response = Continuation.getResponse(this.requestLabel);
            if( response == null ) 
            { 
                errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
                errorDescText = RTL_CampaignUtil.INT07_NO_RESPONSE_ERROR;
                smsCalloutSuccess = false;
                smsCalloutError = errorCodeText;
                smsCalloutErrorDesc = errorDescText;
            }
            else if( response.getStatusCode() != 200 )
            {
                errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
                errorDescText = RTL_CampaignUtil.getHttpResponseMessage( response.getStatus(),response.getStatusCode() );
                smsCalloutSuccess = false;
                smsCalloutError = errorCodeText;
                smsCalloutErrorDesc = errorDescText;
            }
            else
            {
                resultBody = response.getBody();
                system.debug('Response07:'+resultBody);
                Dom.Document doc = new Dom.Document();
                doc.load(resultBody);
                Dom.XMLNode root = doc.getRootElement();
                Dom.XMLNode header = root.getChildElement('Header', null);
                Dom.XMLNode errorCode = header.getChildElement('ErrorCode', null);
                errorCodeText =  header.getChildElement('ErrorCode', null).getText();
                errorDescText =  header.getChildElement('ErrorDescription', null).getText();
                String errorStatusText =  header.getChildElement('ErrorStatus', null).getText();
                smsPageList = new List<Integer>();
                Integer totalRecords = 0;
                if( header.getChildElement('TotalRecords', null).getText() != '' )  
                {
                    totalRecords = Integer.valueOf(header.getChildElement('TotalRecords', null).getText());
                }
                Integer rowLimit = smsCampaignItemPerPage;
                smsExCampaignTotalPage = ((Decimal.valueOf(totalRecords) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);
                disablePreviousSMS = false;
                disableNextSMS = false;
                if( smsCampaignPage == 1)
                {
                    disablePreviousSMS = true;
                }
                
                if( smsCampaignPage >= smsExCampaignTotalPage )
                {
                    disableNextSMS = true;
                }
                
                Integer count = 1;
                smsPageList.add(count);
                while ( count*rowLimit < totalRecords ) {
                    count++;
                    smsPageList.add(count);
                }
                smsPagination = pagination(smsPageList,smsCampaignPage);
                smsWrapperList = new List<SMSCampaignMemberResponse>();
                smsCampData = new List<SmsCampaignData>();
                if( errorStatusText == 'fail' )
                {
                    smsCalloutSuccess = false;
                    smsCalloutError = errorCodeText;
                    smsCalloutErrorDesc = errorDescText;
                    // RTL_CampaignUtil.insertOnlineLog( errorCodeText,errorDescText, tmbCustId , 'INT07' , customerName );
                }
                else 
                {
                    errorCodeText = '';
                    errorDescText = '';
                    smsCalloutSuccess = true;
                    Dom.XMLNode smsList = root.getChildElement('CampaignSmsRegistrationList', null);
                    campCode = new List<String>();
                    for (Dom.XMLNode child: smsList.getChildElements()) 
                    {
                        SMSCampaignMemberResponse smsr = new SMSCampaignMemberResponse();
                        smsr.SourceUniqueID = child.getChildElement('SourceUniqueID', null).getText().trim();
                        smsr.MobilePhoneNumber = child.getChildElement('MobilePhoneNumber', null).getText().trim();
                        smsr.CampaignCode = child.getChildElement('CampaignCode', null).getText().trim();
                        smsr.Message = child.getChildElement('Message', null).getText().trim();
                        smsr.Content = child.getChildElement('Content', null).getText().trim();
                        smsr.RegisterDateText = child.getChildElement('RegisterDate', null).getText().trim();
                        smsr.ApplyChannel = child.getChildElement('ApplyChannel', null).getText().trim();
                        String cc = smsr.CampaignCode;
                        campCode.add(cc);
                        smsWrapperList.add(smsr);
                    }
                    
                    List<Campaign> idCampCodeList = new List<Campaign>([SELECT ID,RTL_Campaign_Code_10_digits__c,name
                                                                        FROM Campaign
                                                                        WHERE RTL_Campaign_Code_10_digits__c in :campCode]);
                    Map<String,Campaign> idCamCodeMap =  new Map<String, Campaign>();
                    for( Campaign cc : idCampCodeList )
                    {
                        if( !idCamCodeMap.containsKey(cc.RTL_Campaign_Code_10_digits__c) )
                        {
                            idCamCodeMap.put(cc.RTL_Campaign_Code_10_digits__c,cc);
                        }
                    }
                    for( SMSCampaignMemberResponse smsw : smsWrapperList )
                    {
                        SmsCampaignData mcd = new SmsCampaignData();
                        mcd.camObj = idCamCodeMap.get(smsw.CampaignCode);
                        mcd.smsCamMemObj = smsw;
                        smsCampData.add(mcd);
                    }
                    // MAP<String,SMSCampaignMemberResponse> campaignCodeWithObj = new MAP<String,SMSCampaignMemberResponse>();
                    // for( SMSCampaignMemberResponse smsw : smsWrapperList )
                    // {
                    //     if( !campaignCodeWithObj.containsKey(smsw.CampaignCode) )
                    //     {
                    //         campaignCodeWithObj.put(smsw.CampaignCode,smsw);
                    //     }
                    // }
                    // for ( String idKey : campaignCodeWithObj.keyset() ) 
                    // {
                    //     Campaign c = idCamCodeMap.get(idKey);
                    //     SmsCampaignData mcd = new SmsCampaignData();
                    //     mcd.camObj = c;
                    //     mcd.smsCamMemObj = campaignCodeWithObj.get(idKey);
                    //     smsCampData.add(mcd);
                    // }
                }     
            }
        }
        catch(Exception e) {
            endCallINT07 = system.now();
            System.debug(' INT07 Error: '+e.getMessage());
            errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            errorDescText = e.getMessage() + '(' + e.getLineNumber() + ')';
            smsCalloutSuccess = false; 
            smsCalloutError = errorCodeText;
            smsCalloutErrorDesc = errorDescText;
        }
        RTL_CampaignUtil.insertOnlineLogWithResponse( errorCodeText,errorDescText, rmId , RTL_CampaignUtil.INT07_SERVICE_NAME , 
                                                     accountObj.id ,requestBodyINT07 , resultBody , startCallINT07 ,endCallINT07  );
        // Return null to re-render the original Visualforce page
        return null;
    }
    public List<Integer> pagination(List<Integer> totalPageList,Integer clickPage){
        Boolean checkDot = true;
        Set<String> duplicate = new Set<String>();
        List<Integer> listItem = new List<Integer>();
        for(Integer numberItem : totalPageList){
            Integer value = Math.abs(clickPage-numberItem);
            if(totalPageList.size()<10){
                listItem.add(numberItem);
            }
            else{
                if(numberItem<4 || numberItem>totalPageList.size()-3){
                    listItem.add(numberItem);
                    checkDot=true;
                }
                else{
                    if(value<3){
                        if(duplicate.add(String.valueOf(numberItem))==true){
                            listItem.add(numberItem);
                            checkDot=true;
                        }
                    }
                    else{
                        if(checkDot){
                            listItem.add(-1);
                            checkDot=false;
                        }
                    }
                }
            }
        }
        return listItem;
    }
    /*
* Method to refresh all displayed data in Campaign History
* For Phase II - INT 6 , 7 will add more data to refresh
*/
    public void reloadAllData()
    {
        //queryExclusive(exclusiveCampaignPage);
        System.debug('isCallingCampaign : ' + isCallingCampaign);
        
        if(isCallingCampaign){
            queryCustomerRequest(call_customerRequestCampaignPage,true);
        }else{
            queryCustomerRequest(customerRequestCampaignPage,false);
            queryLocalEx(localExCampaignPage,false);
            queryMass(massCampaignPage,false);
        }
        queryFulfillment(fulfillmentPage);    
    }

    public void setCampaignPeriod()
    {
        if( campaignPeriodMethod == 'past' )
        {
            campaignFromDate = date.today().addMonths(-12);
            campaignToDate = date.today().addMonths(-6).addDays(-1); 
            isCallingCampaign = false;
        }
        else if( campaignPeriodMethod == 'current' )
        {
            campaignFromDate = date.today().addMonths(-6);
            campaignToDate = date.today();
            isCallingCampaign = false;
        }
        else if( campaignPeriodMethod == '3month' )
        {
            System.debug('campaignPeriodMethod3m' + campaignPeriodMethod);
            campaignFromDate = date.today().addMonths(-3);
            campaignToDate = date.today();
            isCallingCampaign = true;
        }
        else if( campaignPeriodMethod == '1year' )
        {
            System.debug('campaignPeriodMethod1y' + campaignPeriodMethod);

            campaignFromDate = date.today().addMonths(-12);
            campaignToDate = date.today().addMonths(-3).addDays(-1); 
            isCallingCampaign = true;
        }
        exclusiveCampaignPage = 1; 
        call_exclusiveCampaignPage = 1;
        localExCampaignPage = 1;
        massCampaignPage = 1;
        customerRequestCampaignPage = 1;
        call_customerRequestCampaignPage = 1;

        //queryExclusive(exclusiveCampaignPage);
        
        if(isCallingCampaign){
            queryCustomerRequest(call_customerRequestCampaignPage,true);
        }else{
            queryCustomerRequest(customerRequestCampaignPage,false);
            queryLocalEx(localExCampaignPage,false);
            queryMass(massCampaignPage,false);
        }
        queryFulfillment(fulfillmentPage);    
    }
    private void queryCustomerRequest(Integer pageNo, Boolean isCallingCamp)
    {
        String condition = '';
        if(isCallingCamp){
            condition += ' AND Campaign.RTL_Campaign_Code_10_digits__c LIKE \'D%\' AND (NOT Campaign.RTL_Campaign_Code_10_digits__c LIKE \'D9%\') ';
        }else{
            condition += ' AND (Campaign.RTL_Campaign_Code_10_digits__c LIKE \'D9%\' OR (NOT Campaign.RTL_Campaign_Code_10_digits__c LIKE \'D%\') )' ;
        }
        List<String> listcampaignobj = new List<String>{'Drop-Lead'};
        String countQuery ='SELECT Count() from CampaignMember '+
            'WHERE Campaign.RecordType.DeveloperName = :exclusiveCampaignRecordTypeDevName '+
            'AND Customer__c = :accountId '+
            //'AND ( Campaign.status != \'On Hold\' OR RTL_Contact_Staff_Name__c != NULL ) ' +
            'AND Campaign.StartDate >= :campaignFromDate '+
            'AND Campaign.StartDate <= :campaignToDate ' +
            'AND Campaign.RTL_Campaign_Objective_child__c in: listcampaignobj ' + condition;

        Integer countTotalRecords = Database.countQuery(countQuery);
        if( countTotalRecords == 0 || accountId == null )
        {
            if(isCallingCamp){
                call_disablePreviousCustomerRequeste = true;
                call_disableNextCustomerRequest = true;
                call_customerRequestCampaign = null;
                call_customerRequestCampaignPage = 1;
                call_customerRequestCampaignTotalPage = 1;
                call_customerRequestPageList = new List<Integer>();
            }else{
                disablePreviousCustomerRequeste = true;
                disableNextCustomerRequest = true;
                customerRequestCampaign = null;
                customerRequestCampaignPage = 1;
                customerRequestCampaignTotalPage = 1;
                customerRequestPageList = new List<Integer>();
            }

        }
        else 
        {
            Integer rowLimit = customerRequestCampaignItemPerPage;
            Integer rowOffset = (pageNo-1)*rowLimit;
            // customerRequestCampaign = [SELECT ID, Campaign.RTL_Campaign_Code_9_digits__c , Campaign.RTL_Campaign_Code_10_digits__c,
            //                            Campaign.Name,Campaign.StartDate,Campaign.EndDate,Campaign.RecordType.DeveloperName,
            //                            Campaign.status,Campaign.RTL_Campaign_Channel__c,RTL_Offer_Result__c,RTL_Offer_Result_CC__c,Campaign.RTL_Campaign_Channel_formula__c
            //                            FROM CampaignMember
            //                            WHERE Campaign.RecordType.DeveloperName in :exclusiveCampaignRecordTypeDevName
            //                            AND Customer__c = :accountId
            //                            //AND ( Campaign.status != 'On Hold' OR RTL_Contact_Staff_Name__c != NULL )
            //                            AND Campaign.StartDate >= :campaignFromDate
            //                            AND Campaign.StartDate <= :campaignToDate
            //                            AND Campaign.RTL_Campaign_Objective_child__c = 'Drop-Lead'
            //                            ORDER BY Campaign.Status DESC , Campaign.StartDate DESC
            //                            LIMIT :rowLimit OFFSET :rowOffset
            //                           ];
            String query = 'SELECT ID, Campaign.RTL_Campaign_Code_9_digits__c , Campaign.RTL_Campaign_Code_10_digits__c,' +
                            'Campaign.Name,Campaign.StartDate,Campaign.EndDate,Campaign.RecordType.DeveloperName,' +
                            'Campaign.status,Campaign.RTL_Campaign_Channel__c,RTL_Offer_Result__c,RTL_Offer_Result_CC__c,Campaign.RTL_Campaign_Channel_formula__c' +
                            ' FROM CampaignMember' +
                            ' WHERE Campaign.RecordType.DeveloperName in :exclusiveCampaignRecordTypeDevName' +
                            ' AND Customer__c = :accountId' +
                            //AND ( Campaign.status != 'On Hold' OR RTL_Contact_Staff_Name__c != NULL )
                            ' AND Campaign.StartDate >= :campaignFromDate' +
                            ' AND Campaign.StartDate <= :campaignToDate' +
                            ' AND Campaign.RTL_Campaign_Objective_child__c in: listcampaignobj ' + condition +
                            ' ORDER BY Campaign.Status DESC , Campaign.StartDate DESC' +
                            ' LIMIT :rowLimit OFFSET :rowOffset';
            if(isCallingCamp){
                call_customerRequestCampaignTotalPage = ((Decimal.valueOf(countTotalRecords) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);

                call_customerRequestCampaign = Database.query(query);
                System.debug('customerRequestCampaign ' +  call_customerRequestCampaign[0].Campaign.Name);

                call_disablePreviousCustomerRequeste = false;
                call_disableNextCustomerRequest = false;
                if( pageNo == 1)
                {
                    call_disablePreviousCustomerRequeste = true;
                }
                if( pageNo*rowLimit >= countTotalRecords )
                {
                    call_disableNextCustomerRequest = true;
                }
                call_customerRequestPageList = new List<Integer>();
                Integer count = 1;
                call_customerRequestPageList.add(count);
                while ( count*rowLimit < countTotalRecords ) {
                    count++;
                    call_customerRequestPageList.add(count);
                }
                call_customerRequestPagination = pagination(call_customerRequestPageList,pageNo);
            }else{
                customerRequestCampaignTotalPage = ((Decimal.valueOf(countTotalRecords) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);

                customerRequestCampaign = Database.query(query);
                System.debug('customerRequestCampaign ' + customerRequestCampaign[0].Campaign.Name);

                disablePreviousCustomerRequeste = false;
                disableNextCustomerRequest = false;
                if( pageNo == 1)
                {
                    disablePreviousCustomerRequeste = true;
                }
                if( pageNo*rowLimit >= countTotalRecords )
                {
                    disableNextCustomerRequest = true;
                }
                customerRequestPageList = new List<Integer>();
                Integer count = 1;
                customerRequestPageList.add(count);
                while ( count*rowLimit < countTotalRecords ) {
                    count++;
                    customerRequestPageList.add(count);
                }
                customerRequestPagination = pagination(customerRequestPageList,pageNo);
            }
        }
    }
    //private void queryExclusive(Integer pageNo)
    //{
    ////String countQuery ='SELECT Count() from CampaignMember '+
    ////'WHERE Campaign.RecordType.DeveloperName = :exclusiveCampaignRecordTypeDevName '+
    ////'AND Customer__c = :accountId '+
    ////'AND ( Campaign.status != \'On Hold\' OR RTL_Contact_Staff_Name__c != NULL ) ' +
    ////'AND Campaign.StartDate >= :campaignFromDate '+
    ////'AND Campaign.StartDate <= :campaignToDate ' +
    ////'AND Campaign.RTL_Campaign_Objective_child__c != \'Drop-Lead\' '
    ////;
    //Integer countTotalRecords = totalRecords;
    ////Integer countTotalRecords = Database.countQuery(countQuery);
    //system.debug('countTotalRecords : '+countTotalRecords);
    //system.debug('accountId : '+accountId);
    //if( countTotalRecords == 0 || accountId == null )
    //{
    //disablePreviousExclusive = true;
    //disableNextExclusive = true;
    //exclusiveCampaign = null;
    //exclusiveCampaignPage = 1;
    //exclusiveExCampaignTotalPage = 1;
    //exclusivePageList = new List<Integer>();
    //}
    //else 
    //{
    ////Integer rowLimit = exclusiveCampaignItemPerPage;
    ////Integer rowOffset = (pageNo-1)*rowLimit;
    ////exclusiveExCampaignTotalPage = ((Decimal.valueOf(countTotalRecords) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);
    ////exclusiveCampaign = [SELECT ID, Campaign.RTL_Campaign_Code_9_digits__c , Campaign.RTL_Campaign_Code_10_digits__c,
    ////Campaign.Name,Campaign.StartDate,Campaign.EndDate,Campaign.RecordType.DeveloperName,
    ////Campaign.status,Campaign.RTL_Campaign_Channel__c,RTL_Offer_Result__c,Campaign.RTL_Campaign_Channel_formula__c
    ////FROM CampaignMember
    ////WHERE Campaign.RecordType.DeveloperName in :exclusiveCampaignRecordTypeDevName
    ////AND Customer__c = :accountId
    ////AND ( Campaign.status != 'On Hold' OR RTL_Contact_Staff_Name__c != NULL )
    ////AND Campaign.StartDate >= :campaignFromDate
    ////AND Campaign.StartDate <= :campaignToDate
    ////AND Campaign.RTL_Campaign_Objective_child__c != 'Drop-Lead'
    ////ORDER BY Campaign.Status DESC , Campaign.StartDate DESC
    ////LIMIT :rowLimit OFFSET :rowOffset
    ////];
    ////disablePreviousExclusive = false;
    ////disableNextExclusive = false;
    ////if( pageNo == 1)
    ////{
    ////disablePreviousExclusive = true;
    ////}
    ////if( pageNo*rowLimit >= countTotalRecords )
    ////{
    ////disableNextExclusive = true;
    ////}
    ////exclusivePageList = new List<Integer>();
    ////Integer count = 1;
    ////exclusivePageList.add(count);
    ////while ( count*rowLimit < countTotalRecords ) {
    ////count++;
    ////    exclusivePageList.add(count);
    ////}
    //Integer rowLimit = 3;
    //exclusivePageList = new List<Integer>();
    ////exclusiveExCampaignTotalPage = ((Decimal.valueOf(countTotalRecords) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);
    //Integer count = 1;
    //exclusivePageList.add(count);
    //while ( count*rowLimit < totalRecords ) {
    //count++;
    //    exclusivePageList.add(count);
    //}
    //system.debug('exclusivePageList : '+exclusivePageList);
    //}
    //}
    private void queryLocalEx(Integer pageNo, Boolean isCallingCamp)
    {   
        String condition = '';
        if(isCallingCamp){
            condition += ' AND Campaign.RTL_Campaign_Code_10_digits__c LIKE \'D%\' AND (NOT Campaign.RTL_Campaign_Code_10_digits__c LIKE \'D9%\') ';
        }else{
            condition += ' AND (Campaign.RTL_Campaign_Code_10_digits__c LIKE \'D9%\' OR (NOT Campaign.RTL_Campaign_Code_10_digits__c LIKE \'D%\') )' ;
        }
        String countQuery ='SELECT Count() from CampaignMember '+
            'WHERE Campaign.RecordType.DeveloperName = :localExCampaignRecordTypeDevName '+
            'AND Customer__c = :accountId '+
            //'AND ( Campaign.status != \'On Hold\' OR RTL_Contact_Staff_Name__c != NULL ) ' +
            'AND Campaign.StartDate >= :campaignFromDate '+
            'AND Campaign.StartDate <= :campaignToDate' + condition;
        
        Integer countTotalRecords = Database.countQuery(countQuery);
        if( countTotalRecords == 0 || accountId == null )
        {
            disablePreviousLocalEx = true;
            disableNextLocalEx = true;
            localExCampaign = null;
            localExCampaignPage = 1;
            localExCampaignTotalPage = 1;
            localExPageList = new List<Integer>();
        }
        else 
        {
            Integer rowLimit = localExCampaignItemPerPage;
            Integer rowOffset = (pageNo-1)*rowLimit;
            localExCampaignTotalPage = ((Decimal.valueOf(countTotalRecords) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);
            // localExCampaign = [SELECT ID, Campaign.RTL_Campaign_Code_9_digits__c , Campaign.RTL_Campaign_Code_10_digits__c,
            //                    Campaign.Name,Campaign.StartDate,Campaign.EndDate,Campaign.RecordType.DeveloperName,
            //                    Campaign.status,Campaign.RTL_Campaign_Channel__c,RTL_Offer_Result__c,Campaign.RTL_Campaign_Channel_formula__c
            //                    FROM CampaignMember
            //                    WHERE Campaign.RecordType.DeveloperName in :localExCampaignRecordTypeDevName
            //                    AND Customer__c = :accountId
            //                    // AND ( Campaign.status != 'On Hold' OR RTL_Contact_Staff_Name__c != NULL )
            //                    AND Campaign.StartDate >= :campaignFromDate
            //                    AND Campaign.StartDate <= :campaignToDate
            //                    ORDER BY Campaign.Status DESC , Campaign.StartDate DESC
            //                    LIMIT :rowLimit OFFSET :rowOffset
            //                   ];
           String query =  'SELECT ID, Campaign.RTL_Campaign_Code_9_digits__c , Campaign.RTL_Campaign_Code_10_digits__c,' +
                               'Campaign.Name,Campaign.StartDate,Campaign.EndDate,Campaign.RecordType.DeveloperName,' +
                               'Campaign.status,Campaign.RTL_Campaign_Channel__c,RTL_Offer_Result__c,Campaign.RTL_Campaign_Channel_formula__c' +
                               ' FROM CampaignMember' +
                               ' WHERE Campaign.RecordType.DeveloperName in :localExCampaignRecordTypeDevName' +
                               ' AND Customer__c = :accountId' +
                               // AND ( Campaign.status != 'On Hold' OR RTL_Contact_Staff_Name__c != NULL )
                               ' AND Campaign.StartDate >= :campaignFromDate' +
                               ' AND Campaign.StartDate <= :campaignToDate' + condition +
                               ' ORDER BY Campaign.Status DESC , Campaign.StartDate DESC' +
                               ' LIMIT :rowLimit OFFSET :rowOffset';
            localExCampaign = Database.query(query);
            disablePreviousLocalEx = false;
            disableNextLocalEx = false;
            if( pageNo == 1)
            {
                disablePreviousLocalEx = true;
            }
            if( pageNo*rowLimit >= countTotalRecords )
            {
                disableNextLocalEx = true;
            }
            localExPageList = new List<Integer>();
            Integer count = 1;
            localExPageList.add(count);
            while ( count*rowLimit < countTotalRecords ) {
                count++;
                localExPageList.add(count);
            }
            localExPagination = pagination(localExPageList,pageNo);
        }
    }
    private void queryMass(Integer pageNo, Boolean isCallingCamp)
    {
        String condition = '';
        if(isCallingCamp){
            condition += ' AND RTL_Campaign_Code_10_digits__c LIKE \'D%\' AND (NOT RTL_Campaign_Code_10_digits__c LIKE \'D9%\') ';
        }else{
            condition += ' AND (RTL_Campaign_Code_10_digits__c LIKE \'D9%\' OR (NOT RTL_Campaign_Code_10_digits__c LIKE \'D%\') )' ;
        }
        System.debug('campaignFromDate:'+campaignFromDate);
        System.debug('campaignToDate:'+campaignToDate);
        System.debug('massCampaignRecordTypeDevName: '+massCampaignRecordTypeDevName);
        massCampaign = new List<massCampaignData>();
        String countQuery ='SELECT Count() FROM Campaign '+
            'WHERE RecordType.DeveloperName in :massCampaignRecordTypeDevName '+
            'AND status != \'On Hold\' '+
            'AND IsActive = true ' +
            'AND StartDate >= :campaignFromDate '+
            'AND StartDate <= :campaignToDate' + condition;
          
        Integer countTotalRecords = Database.countQuery(countQuery);
        System.debug('countTotalRecords: '+ countTotalRecords);  
        if( countTotalRecords == 0 || accountId == null )
        {
            disablePreviousMass = true;
            disableNextMass = true;
            massCampaign = null;
            massCampaignPage = 1;
            massCampaignTotalPage = 1;
            massPageList = new List<Integer>();
        }
        else 
        {
            Integer rowLimit = massCampaignItemPerPage;
            Integer rowOffset = (pageNo-1)*rowLimit;
            massCampaignTotalPage = ((Decimal.valueOf(countTotalRecords) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);
            // Map<ID,Campaign> massCamList =  new Map<ID, Campaign>([SELECT ID,RTL_Campaign_Code_10_digits__c,
            //                                                        Name,StartDate,EndDate,status,RTL_Campaign_Channel__c,RTL_Campaign_Channel_formula__c
            //                                                        FROM Campaign
            //                                                        WHERE RecordType.DeveloperName in :massCampaignRecordTypeDevName
            //                                                        AND status != 'On Hold'
            //                                                        AND IsActive = true
            //                                                        AND StartDate >= :campaignFromDate
            //                                                        AND StartDate <= :campaignToDate
            //                                                        ORDER BY Campaign.Status DESC , Campaign.StartDate DESC
            //                                                        LIMIT :rowLimit OFFSET :rowOffset
            //                                                       ]);
            String query = 'SELECT ID,RTL_Campaign_Code_10_digits__c,' +
                           'Name,StartDate,EndDate,status,RTL_Campaign_Channel__c,RTL_Campaign_Channel_formula__c' +
                           ' FROM Campaign' +
                           ' WHERE RecordType.DeveloperName in :massCampaignRecordTypeDevName' +
                           ' AND status != \'On Hold\'' +
                           ' AND IsActive = true' +
                           ' AND StartDate >= :campaignFromDate' +
                           ' AND StartDate <= :campaignToDate' + condition +
                           ' ORDER BY Campaign.Status DESC , Campaign.StartDate DESC' +
                           ' LIMIT :rowLimit OFFSET :rowOffset' ;
            List<Campaign> listcamp =  Database.query(query);
            Map<ID,Campaign> massCamList =  new Map<ID, Campaign>(listcamp);

            List<CampaignMember> cmList = [ SELECT ID,Name,RTL_Offer_Result__c,CampaignId
                                           FROM CampaignMember 
                                           WHERE CampaignId in :massCamList.keyset() 
                                           AND Customer__c = :accountId
                                          ];
            MAP<ID,CampaignMember> campaignWithMember = new MAP<ID,CampaignMember>();
            for( CampaignMember cm : cmList )
            {
                if( !campaignWithMember.containsKey(cm.CampaignId) )
                {
                    campaignWithMember.put(cm.CampaignId,cm);
                }
            }
            for ( ID idKey : massCamList.keyset() ) 
            {
                Campaign c = massCamList.get(idKey);
                MassCampaignData mcd = new MassCampaignData();
                mcd.camObj = c;
                mcd.camMemObj = campaignWithMember.get(idKey);
                massCampaign.add(mcd);
            }
            disablePreviousMass = false;
            disableNextMass = false;
            if( pageNo == 1)
            {
                disablePreviousMass = true;
            }
            if( pageNo*rowLimit >= countTotalRecords )
            {
                disableNextMass = true;
            }
            massPageList = new List<Integer>();
            Integer count = 1;
            massPageList.add(count);
            while ( count*rowLimit < countTotalRecords ) {
                count++;
                massPageList.add(count);
            }
            massPagination = pagination(massPageList,pageNo);
        }
    }
    
    private void queryFulfillment(Integer pageNo)
    {
        String tmbCustId = accountObj.TMB_Customer_ID_PE__c;
        fulfillData = new List<FulfillmentnData>();
        String countQuery ='SELECT Count() FROM RTL_Fulfillment__c '+
            'WHERE RTL_Customer__c=:accountId ';
        Integer countTotalRecords = Database.countQuery(countQuery);
        if( countTotalRecords == 0 || accountId == null )
        {
            disablePreviousfulfillment = true;
            disableNextfulfillment = true;
            //fulfillmentList = null;
            fulfillmentPage = 1;
            fulfillmentTotalPage = 1;
            fulfillmentPageList = new List<Integer>();
        }
        else 
        {
            Integer rowLimit =  fulfillmentItemPerPage;
            Integer rowOffset = (pageNo-1)*rowLimit;
            fulfillmentTotalPage = ((Decimal.valueOf(countTotalRecords) )/Decimal.valueOf(rowLimit)).round(System.RoundingMode.CEILING);
            
            fulfillmentList = new List<RTL_Fulfillment__c>();
            fulfillmentList = [ SELECT ID , RTL_Account_ID__c, RTL_Amount__c, RTL_Campaign__c, 
                               RTL_Delivery_Date__c, RTL_Description__c, RTL_Fulfillment_Address__c, RTL_Fulfillment_Status__c, 
                               RTL_Fulfillment_Type__c, RTL_Home_No__c, RTL_Fulfillment_ID__c, RTL_Mobile_No__c, RTL_Office_No__c, 
                               RTL_PCI_Card_NO__c,RTL_Customer__r.TMB_Customer_ID_PE__c
                               FROM RTL_Fulfillment__c 
                               WHERE RTL_Customer__r.TMB_Customer_ID_PE__c=: tmbCustId
                               ORDER BY RTL_Delivery_Date__c DESC , RTL_Account_ID__c DESC
                               LIMIT :rowLimit OFFSET :rowOffset];
            List<String> campCode = new List<String>();
            for( RTL_Fulfillment__c ffm : fulfillmentList )
            {
                campCode.add(ffm.RTL_Campaign__c);
            }
            system.debug('campCode : '+campCode);
            //system.debug('fulfillList===>'+fulfillList);
            List<Campaign> idCampCodeList = new List<Campaign>([SELECT ID,RTL_Campaign_Code_10_digits__c,name
                                                                FROM Campaign
                                                                WHERE id in :campCode]);
            system.debug('idCampCodeList : '+idCampCodeList);
            Map<String,Campaign> idCamCodeMap =  new Map<String, Campaign>();
            for( Campaign cc : idCampCodeList )
            {
                if( !idCamCodeMap.containsKey(cc.Id) )
                {
                    idCamCodeMap.put(cc.Id,cc);
                }
            }
            system.debug('idCamCodeMap : '+idCamCodeMap);
            for( RTL_Fulfillment__c ffm : fulfillmentList )
            {
                FulfillmentnData mcd = new FulfillmentnData();
                mcd.camObj = idCamCodeMap.get(ffm.RTL_Campaign__c);
                mcd.fulfillmentObj = ffm;
                fulfillData.add(mcd);
            }
            if(fulfillData.size() > 0){
                for(FulfillmentnData f : fulfillData){
                    f.status_code_string = RTL_CampaignMemberUtil.getFulfillmentCodeWithDesc(f.fulfillmentObj.RTL_Fulfillment_Status__c,f.fulfillmentObj.RTL_Fulfillment_Type__c);
                }
            }
            
            // system.debug('fulfillData===>'+fulfillData);
            disablePreviousfulfillment = false;
            disableNextfulfillment = false;
            if( pageNo == 1)
            {
                disablePreviousfulfillment = true;
            }
            if( pageNo*rowLimit >= countTotalRecords )
            {
                disableNextfulfillment = true;
            }
            fulfillmentPageList = new List<Integer>();
            Integer count = 1;
            fulfillmentPageList.add(count);
            while ( count*rowLimit < countTotalRecords ) {
                count++;
                fulfillmentPageList.add(count);
            }
            fulfilmentPaignation = pagination(fulfillmentPageList,pageNo);
        }
    }
    public PageReference previousCustomerRequest()
    {
        customerRequestCampaignPage--;
        queryCustomerRequest(customerRequestCampaignPage,false);
        return null;
    }
    public PageReference nextCustomerRequest()
    {
        customerRequestCampaignPage++;
        queryCustomerRequest(customerRequestCampaignPage,false);
        return null;
    }
    public PageReference navigateCustomerRequest()
    {
        queryCustomerRequest(customerRequestCampaignPage,false);
        return null;
    }
    public PageReference call_previousCustomerRequest()
    {
        call_customerRequestCampaignPage--;
        queryCustomerRequest(call_customerRequestCampaignPage,true);
        return null;
    }
    public PageReference call_nextCustomerRequest()
    {
        call_customerRequestCampaignPage++;
        queryCustomerRequest(call_customerRequestCampaignPage,true);
        return null;
    }
    public PageReference call_navigateCustomerRequest()
    {
        queryCustomerRequest(call_customerRequestCampaignPage,true);
        return null;
    }
    public Object previousExclusive()
    {
        exclusiveCampaignPage--;
        setExclusiveData();
        //return  requestInt06();
        //queryExclusive(exclusiveCampaignPage);
        return null;
    }
    public Object nextExclusive()
    {
        exclusiveCampaignPage++;
        setExclusiveData();
        //return requestInt06();
        //queryExclusive(exclusiveCampaignPage);
        return null;
    }
    public PageReference navigateExclusive()
    {
        setExclusiveData();
        // requestInt06();
        //queryExclusive(exclusiveCampaignPage);
        return null;
    }
    public Object call_previousExclusive()
    {
        call_exclusiveCampaignPage--;
        setExclusiveData();
        // return  requestInt06();
        //queryExclusive(exclusiveCampaignPage);
        return null;
    }
    public Object call_nextExclusive()
    {
        call_exclusiveCampaignPage++;
        setExclusiveData();

        //return requestInt06();
        //queryExclusive(exclusiveCampaignPage);
        return null;
    }
    public PageReference call_navigateExclusive()
    {
        //requestInt06();
        setExclusiveData();
        //queryExclusive(exclusiveCampaignPage);
        return null;
    }
    public Object previousSMS()
    {
        smsCampaignPage--;
        return  requestInt07();
    }
    public Object nextSMS()
    {
        smsCampaignPage++;
        return requestInt07();
    }
    public PageReference navigateSMS()
    {
        requestInt07();
        //queryExclusive(exclusiveCampaignPage);
        return null;
    }
    public PageReference previousLocalEx()
    {
        localExCampaignPage--;
        queryLocalEx(localExCampaignPage,false);
        return null;
    }
    public PageReference nextLocalEx()
    {
        localExCampaignPage++;
        queryLocalEx(localExCampaignPage,false);
        return null;
    }
    public PageReference navigateLocalEx()
    {
        queryLocalEx(localExCampaignPage,false);
        return null;
    }
    public PageReference previousMass()
    {
        massCampaignPage--;
        queryMass(massCampaignPage ,false);
        return null;
    }
    public PageReference nextMass()
    {
        massCampaignPage++;
        queryMass(massCampaignPage ,false);
        return null;
    }
    public PageReference navigateMass()
    {
        queryMass(massCampaignPage ,false);
        return null;
    }
    
    public PageReference previousFulfillment()
    {
        fulfillmentPage--;
        queryFulfillment(fulfillmentPage);
        return null;
    }
    public PageReference nextFulfillment()
    {
        fulfillmentPage++;
        queryFulfillment(fulfillmentPage);
        return null;
    }
    public PageReference navigateFulfillment()
    {
        queryFulfillment(fulfillmentPage);
        return null;
    }
    public void displayData()
    {
        String tabName = Apexpages.currentPage().getParameters().get('tabName');
        if( tabName == 'campaign' )
        {
            system.debug(tabName);
            if( isRenderCampaign == false )
            {
                // Reder data for SMS
            }
            isRenderCampaign = true;
            isCallingCampaign = false;

        }
        else if ( tabName == 'sms' )
        {
            system.debug(tabName);
            if( isRenderSMS == false )
            {
                // Reder data for SMS
            }
            isRenderSMS = true;
        }
        else if( tabName == 'fulfillment' )
        {
            system.debug(tabName);
            if( isRenderFulfillment == false )
            {
                // Reder data for fulfillment
            }
            isRenderFulfillment = true;
        }
        else if( tabName == 'callingcampaign' )
        {
            system.debug(tabName);
            if( isRenderCallingCampaign == false )
            {
                // Reder data for fulfillment
            }
            isRenderCallingCampaign = true;
            isCallingCampaign = true;
        }
    }
}