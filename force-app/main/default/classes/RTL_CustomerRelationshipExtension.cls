public with sharing class RTL_CustomerRelationshipExtension extends OscControllerBase {
    
    public String acctId {get; set;}
    public Id accountId {get; set;}
    public String rtl_OtcAtmAdmIbMib {get; set;}
    public String rtl_MibStatus {get; set;}
    public String rtl_Suitability {get;set;}
    public String rtl_Privilege2Url {get;set;}
    public String rtl_currentPrivilege2 {get;set;}
    public String rtl_entitledPrivilege2 {get;set;}
    public String rtl_afPrivilegeFlag {get;set;}
    public Boolean PrivilegeFlag {get;set;}
    public Boolean initialised {get; set;}
    public String pageMessage {get;set;}
    
    // new parameter OSC07
    public String touchStatus {get;set;}
    public String ibStatus {get;set;}
    public String csProfFreqBr {get;set;}
    public decimal csProfAvgaum12m {get;set;}
    public Date csProfAvgaum12mDt {get;set;}
    public String csProfSubsegment {get;set;}
    public String csProfWealthExpDt {get;set;}
    // MIS
    // csProfSubsegment = Sub_segment__c
    
    // TMBCCC-20 start
    public String rtl_MsgArea {get;set;}
    // TMBCCC-20 end
    private Profile userProfile;   
    public Account acct {get;set;}
    
    public String empBrCode_userId {get;set;}
    private String rmid; /* crmid  */
    public string cname; /* name  */

        
    public AsyncRTL_CvsAnalyticsDataService.getCVSAnalyticsDataResponse_elementFuture asyncRet;
    
    public ViewState ViewState { get; set; }

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
    
    public RTL_CustomerRelationshipExtension(ApexPages.StandardController stdController){
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
                ,RTL_Fund_Risk_Mismatch__c
                ,RTL_Fund_High_Concentration_Risk__c
                // TMBCCC-20 end
                ,Core_Banking_Suggested_Segment__c
                ,RTL_SBO_FLAG__c
                ,RTL_EXIST_NONJU_FLAG__c
                FROM Account WHERE Id =: acct.id ];

        try{

            acct.RTL_Commercial_RM__c = AccountUtility.getCommercial_RM(acct.OwnerId);

        }catch(Exception e){
            system.debug(e.getMessage() + ' at ' +e.getLineNumber() );
        }
        
        accountId = acct.id;
        pageMessage = '';
        PrivilegeFlag = false;
        
        cname = acct.Name;
        rmid = acct.TMB_Customer_ID_PE__c;
        
        ViewState = new ViewState();        
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
        
        try
        {

        //persist the values into custom fields with action method
        acctId =  String.valueOf(acct.Id);
        accountId = acct.Id;  
        //rtl_OtcAtmAdmIbMib = acct.RTL_OTC_ATM_ADM_IB_MIB__c;
            try{
                rtl_OtcAtmAdmIbMib = '<table border="1" style="font-size:95%;font-family:Arial,Helvetica,sans-serif;border-collapse: collapse;border: 0.5px solid #CCC;">';
                String[] OtCAtmAdmIbMinLabelArray = Label.OTC_ATM_ADM_IB_MIB.split(':');
                String[] OtCAtmAdmIbMinValueArray = (acct.RTL_OTC_ATM_ADM_IB_MIB__c==null) ? new List<String>(OtCAtmAdmIbMinLabelArray.size()) : acct.RTL_OTC_ATM_ADM_IB_MIB__c.split(':') ;
                
                rtl_OtcAtmAdmIbMib += '<tr align="center">';
                for( Integer i = 0 ; i < OtCAtmAdmIbMinLabelArray.size() ; i++  ){
                    rtl_OtcAtmAdmIbMib += '<td style="width:45px;border: 0.5px solid #CCC;">'+OtCAtmAdmIbMinLabelArray[i]+'</td>';
                }
                rtl_OtcAtmAdmIbMib += '</tr>';
                
                rtl_OtcAtmAdmIbMib += '<tr align="center">';
                for( Integer i = 0 ; i < OtCAtmAdmIbMinValueArray.size() ; i++  ){
                    rtl_OtcAtmAdmIbMib += '<td style="border: 0.5px solid #CCC;">'+((OtCAtmAdmIbMinValueArray[i]==null) ? '&nbsp;' : OtCAtmAdmIbMinValueArray[i]) +'</td>';
                }
                rtl_OtcAtmAdmIbMib += '</tr>';
                rtl_OtcAtmAdmIbMib += '</table>';
            }catch( Exception e ){
                
            }
        rtl_MibStatus = acct.RTL_MIB_Status__c;
        rtl_Suitability = acct.RTL_Suitability__c;
        

        initialised = false;
        }catch(Exception e){
            pageMessage = System.Label.ERR001;
            System.debug(pageMessage);
        }
        
        // TMBCCC-20 start
        if( getIsCoverArea() ){
            rtl_MsgArea = getMessengerCoverArea(acct.Zip_Code_Primary_PE__c);
        }
        // TMBCCC-20 end
        
    }
    /* -------------------------- End Service ------------------------------------------ */  

    private String requestLabelOSC07;
    private Object stateOSC07;
    public String responseVF {get; set;}

    public Object calloutRestOSC07() {
        Continuation con = (Continuation)RTL_CSVLightningUtil.getCVSAnalyticsData(rmid);
        HttpRequest httpRequestOSC07 = (HttpRequest)con.getRequests().values().iterator().next();
        this.requestLabelOSC07 = (String)con.getRequests().keyset().iterator().next();
        this.stateOSC07 = new Map<String, Object>{
            'RMID' => acct.TMB_Customer_ID_PE__c,
            'RequestBody' => httpRequestOSC07.getBody(),
            'StartTime' => Datetime.now(),
            'Account' => acct
        };
        return con;
    }

    public Object callbackCVSAnalyticsData() {
        String currentSuitability = acct.RTL_Suitability__c;
        HttpResponse res = Continuation.getResponse(this.requestLabelOSC07);
        try {
            System.debug('this.stateOSC07 : ' + this.stateOSC07);
            System.debug('this.requestLabelOSC07 : ' + this.requestLabelOSC07);
            System.debug('res : ' + res.getBody());
            this.responseVF = res.getBody();
            RTL_CSVLightningUtil.saveOnlineSerivceLogCVSAnalytics(this.stateOSC07, res, 'CVSAnalytics - OSC07');
            Map<String, Object> resultBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(AbstractCoreClass.getResult('Status.StatusCode', resultBody));
            if (StatusCode != '200' || ((Map<String, Object>)AbstractCoreClass.getResult('GetCVSAnalyticsDataResponse', resultBody)).isEmpty()) {
                pageMessage = String.valueOf(AbstractCoreClass.getResult('Status.StatusDesc', resultBody));
                return null;
            }

            CVSAnalyticsDataDTO result = (CVSAnalyticsDataDTO)JSON.deserialize(JSON.serialize(AbstractCoreClass.getResult('GetCVSAnalyticsDataResponse.Result', resultBody)), CVSAnalyticsDataDTO.Class);
            System.debug(JSON.serializePretty(result));
            touchStatus = result.touchStatus;
            ibStatus = result.ibStatus;
            csProfFreqBr = result.csProfFreqBr;
            csProfAvgaum12m = result.csProfAvgaum12m;
            csProfAvgaum12mDt = result.csProfAvgaum12mDt;
            csProfSubsegment = AccountUtility.getSubSegment(result.csProfSubsegment);
            csProfWealthExpDt = result.csProfWealthExpDt;

            acct.RTL_OTC_ATM_ADM_IB_MIB__c = result.UsagePercentage;//'10:20:20:25:25'
            acct.RTL_MIB_Status__c = result.MIBStatus;//'Applied'
            acct.RTL_Suitability__c = result.Suitability;
            rtl_currentPrivilege2 = formatPrivilege2(result.currentPrivilege2Desc);
            rtl_entitledPrivilege2 = formatPrivilege2(result.entitledPrivilege2Desc);
            rtl_Privilege2Url = result.privilege2Url;
            rtl_afPrivilegeFlag = result.afPrivilegeFlag;

            if(getBranch(csProfFreqBr) != null){
            	acct.RTL_Most_Visited_Branch__c = getBranch(csProfFreqBr).id;
            }
            acct.RTL_Average_AUM__c = csProfAvgaum12m;

            if(rtl_afPrivilegeFlag == 'Y'){
                PrivilegeFlag = true;
            }
            
            //acct.RTL_Privilege2__c = result.currentPrivilege2Desc;
            //acct.RTL_Entitled_Privilege2__c = result.entitledPrivilege2Desc;
            //acct.RTL_Privilege_URL2__c = result.privilege2Url;
                  
        

        	//persist the values into custom fields with action method
        	acctId =  String.valueOf(acct.Id);
        	accountId = acct.Id;  
        	//rtl_OtcAtmAdmIbMib = acct.RTL_OTC_ATM_ADM_IB_MIB__c;
            try
            {
                rtl_OtcAtmAdmIbMib = '<table border="1" style="font-size:95%;font-family:Arial,Helvetica,sans-serif;border-collapse: collapse;border: 0.5px solid #CCC;">';
                String[] OtCAtmAdmIbMinLabelArray = Label.OTC_ATM_ADM_IB_MIB.split(':');
                String[] OtCAtmAdmIbMinValueArray = (acct.RTL_OTC_ATM_ADM_IB_MIB__c==null) ? new List<String>(OtCAtmAdmIbMinLabelArray.size()) : acct.RTL_OTC_ATM_ADM_IB_MIB__c.split(':') ;
                
                rtl_OtcAtmAdmIbMib += '<tr align="center">';
                for( Integer i = 0 ; i < OtCAtmAdmIbMinLabelArray.size() ; i++  ){
                    rtl_OtcAtmAdmIbMib += '<td style="width:45px;border: 0.5px solid #CCC;">'+OtCAtmAdmIbMinLabelArray[i]+'</td>';
                }
                rtl_OtcAtmAdmIbMib += '</tr>';
                
                rtl_OtcAtmAdmIbMib += '<tr align="center">';
                for( Integer i = 0 ; i < OtCAtmAdmIbMinValueArray.size() ; i++  ){
                    rtl_OtcAtmAdmIbMib += '<td style="border: 0.5px solid #CCC;">'+((OtCAtmAdmIbMinValueArray[i]==null) ? '&nbsp;' : OtCAtmAdmIbMinValueArray[i]) +'</td>';
                }
                rtl_OtcAtmAdmIbMib += '</tr>';
                rtl_OtcAtmAdmIbMib += '</table>';
            }catch( Exception e ){
                
            }
        	rtl_MibStatus = acct.RTL_MIB_Status__c;
            // [2020-07-14] If current Suitability is not same as OSC07 result then update Account.
            if (currentSuitability != acct.RTL_Suitability__c){
                Account tempAcc = new Account();
                tempAcc.Id = acct.Id;
                tempAcc.RTL_Suitability__c = acct.RTL_Suitability__c;
                update tempAcc;
            }
        	rtl_Suitability = acct.RTL_Suitability__c;
        

        	initialised = false;
        
        	// TMBCCC-20 start
        	if( getIsCoverArea() ){
            	rtl_MsgArea = getMessengerCoverArea(acct.Zip_Code_Primary_PE__c);
        	}
        	// TMBCCC-20 end
            
        } catch (Exception e) {
            String errorMessage = e.getMessage();
            errorMessage += '\n' + e.getStackTraceString();
            System.debug(errorMessage);
        }
        return null;
    }


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
            initialised = resultData.isInitialised;
            
            if(result.SoapStatus == 'ERROR'){
                pageMessage = TypeMapper.errorMessageMapping(result.SoapMessage==null?'':result.SoapMessage);
                return null;
            }
            
            touchStatus = result.touchStatus;
            ibStatus = result.ibStatus;
            csProfFreqBr = result.csProfFreqBr;
            csProfAvgaum12m = result.csProfAvgaum12m;
            csProfAvgaum12mDt = result.csProfAvgaum12mDt;
            csProfSubsegment = AccountUtility.getSubSegment(result.csProfSubsegment);
            csProfWealthExpDt = result.csProfWealthExpDt;

            acct.RTL_OTC_ATM_ADM_IB_MIB__c = result.UsagePercentage;//'10:20:20:25:25'
            acct.RTL_MIB_Status__c = result.MIBStatus;//'Applied'
            acct.RTL_Suitability__c = result.Suitability;
            rtl_currentPrivilege2 = formatPrivilege2(result.currentPrivilege2Desc);
            rtl_entitledPrivilege2 = formatPrivilege2(result.entitledPrivilege2Desc);
            rtl_Privilege2Url = result.privilege2Url;
            rtl_afPrivilegeFlag = result.afPrivilegeFlag;
            
            if(getBranch(csProfFreqBr) != null){
            	acct.RTL_Most_Visited_Branch__c = getBranch(csProfFreqBr).id;
            }
            acct.RTL_Average_AUM__c = csProfAvgaum12m;

            if(rtl_afPrivilegeFlag == 'Y'){
                PrivilegeFlag = true;
            }
            
            //acct.RTL_Privilege2__c = result.currentPrivilege2Desc;
            //acct.RTL_Entitled_Privilege2__c = result.entitledPrivilege2Desc;
            //acct.RTL_Privilege_URL2__c = result.privilege2Url;
                  
        

        	//persist the values into custom fields with action method
        	acctId =  String.valueOf(acct.Id);
        	accountId = acct.Id;  
        	//rtl_OtcAtmAdmIbMib = acct.RTL_OTC_ATM_ADM_IB_MIB__c;
            try
            {
                rtl_OtcAtmAdmIbMib = '<table border="1" style="font-size:95%;font-family:Arial,Helvetica,sans-serif;border-collapse: collapse;border: 0.5px solid #CCC;">';
                String[] OtCAtmAdmIbMinLabelArray = Label.OTC_ATM_ADM_IB_MIB.split(':');
                String[] OtCAtmAdmIbMinValueArray = (acct.RTL_OTC_ATM_ADM_IB_MIB__c==null) ? new List<String>(OtCAtmAdmIbMinLabelArray.size()) : acct.RTL_OTC_ATM_ADM_IB_MIB__c.split(':') ;
                
                rtl_OtcAtmAdmIbMib += '<tr align="center">';
                for( Integer i = 0 ; i < OtCAtmAdmIbMinLabelArray.size() ; i++  ){
                    rtl_OtcAtmAdmIbMib += '<td style="width:45px;border: 0.5px solid #CCC;">'+OtCAtmAdmIbMinLabelArray[i]+'</td>';
                }
                rtl_OtcAtmAdmIbMib += '</tr>';
                
                rtl_OtcAtmAdmIbMib += '<tr align="center">';
                for( Integer i = 0 ; i < OtCAtmAdmIbMinValueArray.size() ; i++  ){
                    rtl_OtcAtmAdmIbMib += '<td style="border: 0.5px solid #CCC;">'+((OtCAtmAdmIbMinValueArray[i]==null) ? '&nbsp;' : OtCAtmAdmIbMinValueArray[i]) +'</td>';
                }
                rtl_OtcAtmAdmIbMib += '</tr>';
                rtl_OtcAtmAdmIbMib += '</table>';
            }catch( Exception e ){
                
            }
        	rtl_MibStatus = acct.RTL_MIB_Status__c;
        	rtl_Suitability = acct.RTL_Suitability__c;
        

        	initialised = false;
        
        	// TMBCCC-20 start
        	if( getIsCoverArea() ){
            	rtl_MsgArea = getMessengerCoverArea(acct.Zip_Code_Primary_PE__c);
        	}
        	// TMBCCC-20 end

            return null;

        }catch(Exception e){
            PageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
            system.debug('Web services callout error with inner exception : ' + e.getMessage() + ':' + +e.getLineNumber() );   
        }
        return null;
    }

    public class ViewState {
        //public Map<string /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode { get; set; }
        public CVSAnalyticsDataDTO CVSAnalyticsData { get; set; }
        public ViewState()
        {
            CVSAnalyticsData = new CVSAnalyticsDataDTO();
        }
       
    }
    
    public String theme { 
        get {
            return UserInfo.getUiThemeDisplayed();
        }         
    }
    
    /* check if the VF page is display by SF1 */
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
    @TestVisible
    private String formatPrivilege2(String input){
        if(input == null){
            return '';
        }
        System.debug('INPUT :: '+input);
        System.debug('INPUT LENGTH :: '+input.length());
        return input.trim().replace('|','\n');
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
    
        // --------------------------------------------------------------------------------------
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

        if( isVisible != null && !isVisible ){
            notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, notAuthorizedMsg));            
        }
        
        //hiddenText = system.Label.Data_Condition_Hidden_Text;
        isLoading = false;
        isLoadSuccess = true;
    }

    public String calCulatedWB_PB{
        get{
            if(account.RTL_Calculated_WB_PB_Amount__c != null ){
                Account accountForCalWBPB = [SELECT Id, RTL_Calculated_WB_PB_Amount__c FROM Account WHERE Id =: acct.id];
                //String calWbPb = '(1234567.2345679/12345678.21324897613)';
                String calWbPb = accountForCalWBPB.RTL_Calculated_WB_PB_Amount__c;
                calWbPb = calWbPb.substring(1,calWbPb.length()-1);
                System.debug('callWbPb:' + calWbPb);
                String[] WbPb = calWbPb.split('/',2);
                System.debug('WbPb: '+WbPb);
                return '(' + wbpbConvert(WbPb[0]) + '/' + wbpbConvert(WbPb[1]) + ')';
            }else {
                return null;
            }
        } set;
    }
    
    public String wbpbConvert(String wbpb){
        String[] wbpbList = wbpb.split('\\.',2);
        System.debug('wbpbList: ' + wbpbList);
        String wbpbConverted = '';
        Integer lenghtString = wbpbList[0].length();
        Integer colonTime = lenghtString/3;
        if (math.mod(lenghtString, 3) == 0) {
            colonTime -= 1;
        }
        
        for(Integer i = 0; i<colonTime ; i++){
            wbpbConverted = ',' + wbpbList[0].substring(lenghtString-((i+1)*3), lenghtString-(i*3)) + wbpbConverted;
            System.debug(': ' + wbpbConverted);
        }
        if(!wbpb.contains('.')){
            return wbpbList[0].substring(0,lenghtString-(colonTime*3))+wbpbConverted + '.00';
        }
        else {
            return wbpbList[0].substring(0,lenghtString-(colonTime*3))+wbpbConverted + '.' + String.valueOf(Decimal.valueof('0.' + wbpbList[1]).setScale(2)).split('\\.',2)[1];
        }
    }
}