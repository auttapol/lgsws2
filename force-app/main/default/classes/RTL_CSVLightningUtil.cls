public with sharing class RTL_CSVLightningUtil extends AbstractCoreClass {
    private static String APPID = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;
    private static final Integer timeout {
        get {
            // 120000 ms
            if(timeout == null){
                List<App_Config__mdt> productHoldingTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'ProductHolding_TIMEOUT_INT_SECS'];
                return productHoldingTimeOut != null && productHoldingTimeOut.size() > 0 ? Integer.valueOf(productHoldingTimeOut.get(0).Value__c) * 1000 : 120000;
            }
            return timeout;
        }
        set;
    }

    private static Account getAccount(String RMID) {
        try {
            return [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :RMID LIMIT 1];
        } catch (Exception e) {
            return new Account();
        }
    }

    public static String getBranchId(String brCode){
        try {
            return String.isEmpty(brCode) ? '' : [SELECT Id, Name, Branch_Code__c FROM Branch_and_Zone__c WHERE Branch_Code__c = :brCode LIMIT 1].Id;
        } catch( Exception e ){
            return brCode;
        } 
    }

    @AuraEnabled (continuation=true)
    public static Object getCVSAnalyticsData(String rmId){
        try {
            Datetime StartTime = (Datetime)Datetime.now();
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint('callout:OSC07');
            req.setBody('{ "GetCVSAnalyticsDataRequest": { "RMID": "' + rmId + '" } }');
            req.setTimeout(timeout);

            Continuation con = new Continuation(timeout/1000 != 0 ? timeout/1000 : 1);
            con.state = new Map<String, Object>{
                'RMID' => rmId,
                'RequestBody' => req.getBody(),
                'StartTime' => StartTime,
                'Account' => getAccount(rmId)
            };
            con.continuationMethod = 'callbackCVSAnalyticsData';
            con.addHttpRequest(req);

            return con;
        } catch( Exception e ){
            System.debug('System error : ' + e.getMessage());
            System.debug('Stack Trace : ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public static void saveOnlineSerivceLogCVSAnalytics(Object state, HttpResponse res, String ServiceName) {
        String StatusCode = String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(res.getBody()))) : '';
        String StatusDesc = String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
        Boolean isSuccess = String.isNotEmpty(res.getBody()) ? StatusCode == '200' && !StatusDesc.contains('java.lang.Exception') : false;
        Account AccountObj = (Account)JSON.deserialize(JSON.serialize(getResult('Account', state)), Account.Class);
        RTL_CampaignUtil.saveToOnlineLog(
            isSuccess,
            AccountObj != null ? AccountObj.Name : '', // customerName
            String.isNotEmpty(StatusDesc) ? StatusDesc : Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()),
            '', // msLogId
            UserInfo.getName(),
            (String)getResult('RMID', state),
            ServiceName,
            (String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('RequestBody', state))),
            res.getBody(),
            AccountObj,
            // convert to GMT locale time
            Datetime.valueOf(((String)getResult('StartTime', state)).replace('T', ' ').replace('Z', ' ')).addHours(7),
            Datetime.now()
        );
    }

    @AuraEnabled
    public static Object callbackCVSAnalyticsData(List<String> labels, Object state) {
        String responseBody = '';
        try{
            HttpResponse res = Continuation.getResponse((String)labels.get(0));
            saveOnlineSerivceLogCVSAnalytics(state, res, 'CVSAnalytics - OSC07');
            
            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode())
                };
            }
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(getResult('Status.StatusCode', result));
            String CVS_StatusCode = String.valueOf(getResult('GetCVSAnalyticsDataResponse.Result.Status', result));
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetCVSAnalyticsDataResponse', result)).isEmpty() || CVS_StatusCode == 'ERROR') {
                return getResult('Status', result);
            }
            Object data = getResult('GetCVSAnalyticsDataResponse.Result', result);
            String MIBStatus = ((String)getResult('MIBStatus', data));
            String csProfSubsegment = ((String)getResult('csProfSubsegment', data));
            String csProfFreqBr = ((String)getResult('csProfFreqBr', data));
            data = putObject('promptPay', MIBStatus.split('/').size() > 1 ? MIBStatus.split('/').get(1) : 'NO', data);
            data = putObject('csProfSubsegment', AccountUtility.getSubSegment(csProfSubsegment), data);
            data = putObject('csProfFreqBr', getBranchId(csProfFreqBr), data);
            return data;
        } catch( Exception e ){
            responseBody += '\nSystem error : ' + e.getMessage();
            responseBody += '\nStack Trace : ' + e.getStackTraceString();
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Object getDescribeFieldResultAndValue(String recordId, List<String> fields) {
        Account AccountObj = Database.query('SELECT ' + String.join(fields, ',') + ' FROM Account WHERE Id = :recordId LIMIT 1');
        Map<String, Schema.SObjectField> sObjectField = Schema.SObjectType.Account.fields.getMap();
        Map<String, Object> fieldDescribe = new Map<String, Object>();
        for (String f : fields) {
            if(!f.contains('__r')) {
                Schema.DescribeFieldResult dfr = sObjectField.get(f).getDescribe();
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => dfr.getName(),
                    'value' => AccountObj.get(dfr.getName()),
                    'label' => dfr.getLabel(),
                    'type' => dfr.getType(),
                    'inlineHelpText' => dfr.getInlineHelpText(),
                    'isAccessible' => dfr.isAccessible()
                });
            }
            else {
                Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(AccountObj));
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => f,
                    'value' => AccountObj.get(f.substringBefore('.').replace('__r', '__c')) != null ? ((Map<String, Object>)tempObj.get(f.substringBefore('.'))).get(f.substringAfterLast('.')) : null
                });
            }
        }
        return JSON.deserializeUntyped(JSON.serialize(fieldDescribe));
    }

    @AuraEnabled(cacheable=true)
    public static Object getReference(Id recordId)
    {
        if(recordId == null) return null;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Object sObj = Database.query('SELECT Id, Name FROM ' + sObjName + ' WHERE Id = :recordId LIMIT 1');
        Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)sObj).get(0)));
        return ((Map<String, Object>)tempObj).containsKey('Name') ? ((Map<String, Object>)tempObj).get('Name') : null;
    }

    @AuraEnabled
    public static Account getAccountField(Id accId)
    {
        try{
            return [ SELECT Id, TMB_Customer_ID_PE__c, RTL_Wealth_RM__c, RTL_Commercial_RM__c, Consolidate_Status__c, RTL_CC_STMT_status__c, RTL_RDC_STMT_status__c, RTL_C2G_STMT_status__c FROM Account WHERE Id = :accId ];
        }catch( Exception e ){
            return null;
        }      
    }

    @AuraEnabled
    public static String getMessengerCoverArea(Id accId){
        try{
            Account acct = [SELECT Id, Zip_Code_Primary_PE__c, TMB_Customer_ID_PE__c, RTL_Wealth_RM__c, RTL_Commercial_RM__c FROM Account WHERE Id = :accId ];
            if(getIsCoverArea()){
                return messengerCoverArea(acct.Zip_Code_Primary_PE__c);
            }
        }catch( Exception e ){
            System.debug(e.getMessage());
        }
        return null;
    }

    private static String messengerCoverArea(String zipcode){
        try{
            return  [SELECT RTL_Area__c FROM RTL_Messenger_Cover_Area__c WHERE RTL_Zip_Code__c = :zipcode limit 1 ].RTL_Area__c;
        }catch( Exception e ){
            return 'Not Cover';
        }
    }

    private static Boolean getIsCoverArea(){
        String profileName = [ SELECT Name FROM profile WHERE Id = :UserInfo.getProfileId() limit 1 ].Name;
        try{
            return [ SELECT Cover_Area__c FROM RTL_Customer_Call_Center__mdt WHERE Profile_Name__c = :profileName ].Cover_Area__c;
        }catch( Exception e ){
            return false;
        }
    }

    @AuraEnabled
    public static Verification_History__c getVerification(String Id)
    {
        try
        {
            return [SELECT Id, Name, Verification_Type__c, Customer_Type__c, Verification_Result__c, Verification_Status__c, Fail_Reason__c, Xfer__c, Phone_Number__c, Extension_Number__c, 
                Call_ID__c, Employee_ID__c, TMB_Cust_ID__c, Customer__c, Verification_Date_Time__c, Verification_Action__c
                FROM Verification_History__c WHERE Id =: Id];
        }
        catch( Exception e )
        {
            return null;
        }  
    }

    @AuraEnabled
    public static Map<String, String> getVerStatusColorCode(String Verification_Status)
    {
        Map<String, String> result = new Map<String, String>();
        if(Verification_Status != null){
            List<String> status = Verification_Status.split(' ');
            String verifyStatusCode = status[0];
            try {
                Verification_Status_Code__mdt verStatus = [SELECT Id, Label, Color__c, Description__c FROM Verification_Status_Code__mdt WHERE Label = :verifyStatusCode LIMIT 1];
                result.put(verStatus.Description__c, verStatus.Color__c);

                return result;
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }

        return result;
    }

    @AuraEnabled
    public static String getVerResultColorCode(String Verification_Result)
    {
        String result = '#000000';
        if(Verification_Result != null){
            try {
                Verification_Result__mdt verResult = [SELECT Id, Label, Color__c, Result__c FROM Verification_Result__mdt WHERE Label = :Verification_Result LIMIT 1];
                return verResult.Color__c;
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }
        return result;
    }

    @AuraEnabled
    public static CXM_Survey__c getCXM(String AccId){
        try {
            Account acct = [SELECT Id,TMB_Customer_ID_PE__c FROM Account WHERE Id =: AccId];
            CXM_Survey__c thisCXM = [SELECT Id,Account__c,Survey_Score__c,Survey_Datetime__c FROM CXM_Survey__c WHERE Customer_ID__c =:acct.TMB_Customer_ID_PE__c AND Survey_Datetime__c  = LAST_N_DAYS:30 ORDER BY Survey_Datetime__c DESC LIMIT 1];
            // CXM_Survey__c thisCXM = [SELECT Id,Account__c,Survey_Score__c,Survey_Datetime__c FROM CXM_Survey__c WHERE Survey_Datetime__c > LAST_N_MONTHS:1 LIMIT 1];
            return thisCXM;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<CXM_Survey_Condition__mdt> getCXMMeta(){
        try {
            List<CXM_Survey_Condition__mdt> CXMMeta = [SELECT Emotion_Face__c,Highest_Score__c,Lowest_Score__c,Possible_Value__c FROM CXM_Survey_Condition__mdt];
            return CXMMeta;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled (cacheable=true)
    public static string getWatermarkHTML() {
        string userId = UserInfo.getUserId();
        User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
        string userEmpId = loginUser.Employee_ID__c;

        return userEmpId;
    }

    @AuraEnabled
    public static Object CallCYCCampaignMappingInqAPI(String NameCredentail,Object headerParam, Object bodyParam,Object OnlineServiceLog){
        CYCCampaignMappingInqAPI CYCcampaignAPI = new CYCCampaignMappingInqAPI();
        Object result = CYCcampaignAPI.Preparedata(NameCredentail,(String)headerParam,(String) bodyParam,(String) OnlineServiceLog);
        return result;
    }


    @AuraEnabled
    public static List<Case> getComplaint(String accRecordId){
        try {
            List<case> complaintList = [SELECT Id,Subject,Casenumber, CreatedDate, IsClosed, Status,Is_Over_SLA__c FROM Case WHERE Accountid =: accRecordId AND Category__c = 'Complaint' ORDER BY CreatedDate DESC LIMIT 5];
            return complaintList;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Setup format for segment coloring */
    @AuraEnabled
    public static String getSetUpFormat(String formatName){
        String retResult = SetUpFormat.getSetupFormat(formatname);
        return retResult; 
    }

    @AuraEnabled
    public static string getPdpaDetail(String tmbCustId, String serviceName){
       String result = pdpaCalloutUtil.getFagPdpa(tmbCustId, serviceName);
       return result;
    }

    @AuraEnabled
    public static String getSubDebtTransaction(Id accId){
        List<Sub_Debt_Transaction__c> subDebtTran = [SELECT Id, Name,Customer__c FROM Sub_Debt_Transaction__c WHERE Customer__c =: accId];
        String subDebtTransDetail = subDebtTran.size()>0? System.Label.Sub_Debt_Transaction_Yes_Message : System.Label.Sub_Debt_Transaction_No_Message;
        return subDebtTransDetail;  
    }

    @AuraEnabled
    public static String getInstantLendingDetail(Id accId){
        String instantLendingDetail = '';
        List<Retail_Instant_Lending__c> retailLending = [SELECT Id, Name, Customer__c, Instant_lending_detail__c, Expiry_Date__c FROM Retail_Instant_Lending__c WHERE Customer__c =: accId];
        instantLendingDetail = retailLending.size()>0? retailLending[0].Instant_lending_detail__c : '';
        return instantLendingDetail;
    }
  
}