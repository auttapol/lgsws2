public with sharing class RetailCSVCustomerChartController extends AbstractCoreClass{
    private static String APPID = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;
    public static Account acct = new Account();
    public static Object stateOSC07;
    public static CVSAnalyticsDataDTO CVSObject = new CVSAnalyticsDataDTO();
    public static Boolean isServiceError = false;
    public static Boolean isServiceSuccess = false;

    @AuraEnabled (cacheable=true)
    public static Account fetchAccount(Id recordId){
        acct = [SELECT ID,Name,TMB_Customer_ID_PE__c,Account_Type__c,RTL_OTC_ATM_ADM_IB_MIB__c,RTL_MIB_Status__c,RTL_Suitability__c,RTL_Privilege2__c 
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
                ,Core_Banking_Suggested_Segment__c
                ,KYC_Update__c
                ,KYC_flag__c
                ,E_KYC__c
                ,IAL__c
                FROM Account WHERE Id =: recordId LIMIT 1];
                // System.debug('acct'+acct);
        return acct;
    }

    @AuraEnabled
    public static String getProduct2NameFromRTLProductCODE (String productCode) {
        String Name = '#N/A';
        try {
            Product2 pd = [SELECT Id, Name FROM Product2 WHERE RTL_PRODUCT_CODE__c =: productCode LIMIT 1];
            Name = pd.Name;
        } catch (Exception e) {
            System.debug('getProduct2Name error' + e);
        }
        return Name;
    }

    @AuraEnabled
    public static String getProduct2SubFamily(String ProductCode){
        String SubFamily;
        // if (ProductCode.length() == 3) {    //Wait confirm 
        //     ProductCode = '0' + ProductCode;
        // }
        try {
            Product2 pd = [SELECT Id, Sub_Family__c FROM Product2 WHERE ProductCode =: ProductCode LIMIT 1];
            SubFamily = pd.Sub_Family__c;
        } catch (Exception e) {
            System.debug('getProduct2SubFamily error' + e);
        }
        return SubFamily;
    }

    @AuraEnabled 
    public static Branch_and_Zone__c getBranch(String brCode){
        Branch_and_Zone__c br = [SELECT Id, Name, Branch_Code__c FROM Branch_and_Zone__c WHERE Branch_Code__c =: brCode LIMIT 1];
        return br;
    }

    @AuraEnabled 
    public static Branch_and_Zone__c getBranchFromID(String branchId){
        Branch_and_Zone__c br = [SELECT Id, Name, Branch_Code__c FROM Branch_and_Zone__c WHERE Id =: branchId LIMIT 1];
        return br;
    }

    @AuraEnabled
    public static List<Integer> getUsagePercentageData(Id recordId,Account account){
        System.debug('Wire Input ' + recordId);
        List<Integer> cData = new List<Integer>();
        try {
            HttpResponse res = callCVSAnalyticsData(recordId, account);
            callCVSAnalyticsDataWrapperProcess(res);
        } catch (Exception e) {
            System.debug('Error callCVSAnalyticsData');
        }
        if(CVSObject.Status != 'SUCCESS'){
            CVSObject.UsagePercentage = '400:0:0:0:0:0';
            System.debug('Error callCVSAnalyticsData'+ CVSObject.Status);
        }
        String chartData = 'data: [' +  CVSObject.UsagePercentage.replaceAll(':', ', ') + ']';
        String[] dataString = CVSObject.UsagePercentage.split(':', 6);
        
        for (String dataS : dataString) {
            cData.add(Integer.valueOf(dataS));
        }
        System.debug(cData);
        System.debug('Chart Data: ' + chartData);
        return cData;
    }

    @AuraEnabled
    public static String getUsagePercentageRes(Id recordId,Account account){
        System.debug('Wire Input ' + recordId);
        List<Integer> cData = new List<Integer>();
        HttpResponse res = new HttpResponse();
        try {
            res = callCVSAnalyticsData(recordId, account);
        } catch (Exception e) {
            System.debug('Error callCVSAnalyticsData');
    }
        return res.getBody();
    }

    @AuraEnabled
    public static Object getCVSObject(Id recordId, Account account){
        List<String> result = new List<String>();
        System.debug('Call service for CVSObjrct');
        HttpResponse res = callCVSAnalyticsData(recordId, account);
        callCVSAnalyticsDataWrapperProcess(res);
        System.debug(CVSObject);
        if (CVSObject.Status == 'SUCCESS') {
            result.add(CVSObject.Status);
            if (CVSObject.afPrivilegeFlag == null) {
                result.add('');
            }else {
                result.add(CVSObject.afPrivilegeFlag);
            }
            if (CVSObject.csProfFreqBr == null) {
                result.add('');
            }else {
                result.add(CVSObject.csProfFreqBr);
            }
            if (CVSObject.csProfSubsegment == null) {
                result.add('');
            }else {
                result.add(CVSObject.csProfSubsegment);
            }
            if (CVSObject.suitability == null) {
                result.add('');
            }else {
                result.add(CVSObject.suitability);
            }
        }
        return result;
    }

    @AuraEnabled
    public static Object getCVSObject2(Id recordId, Account account){
        // List<String> result = new List<String>();
        HttpResponse res = callCVSAnalyticsData(recordId, account);
        Map<String, Object> resultBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String StatusCode = String.valueOf(AbstractCoreClass.getResult('Status.StatusCode', resultBody));
        if(StatusCode == '401') {
            return '{"isServiceError":true, "errorMessage": "invalid_token"}';
        } else {
            callCVSAnalyticsDataWrapperProcess(res);
            return JSON.serializePretty(CVSObject);
        }
    }

    @AuraEnabled (cacheable=true)
    public static User getUser(Id recordId){
        User user = [SELECT Id, Name FROM User WHERE Id =: recordId LIMIT 1];
        return user;
    }

    public static HttpResponse callCVSAnalyticsData(Id recordId, Account account) {
        //String rmId = '001100000000000000000000051187';
        // System.debug('rmId: ' + rmId);
        System.debug(account);
        System.debug(recordId);
        HttpResponse res;
        Http http = new Http();
        String response;
        if (account.Name == null) {
            System.debug('No account from JS');
            // acct = [SELECT ID,Name,TMB_Customer_ID_PE__c,Account_Type__c,RTL_OTC_ATM_ADM_IB_MIB__c,RTL_MIB_Status__c,RTL_Suitability__c,RTL_Privilege2__c 
            //     ,Zip_Code_Primary_PE__c 
            //     ,RTL_RM_Name__c 
            //     ,RTL_Wealth_RM__c
            //     ,Wealth_RM_EMP_Code__c
            //     ,RTL_Commercial_RM__c 
            //     ,RTL_AUM_Last_Calculated_Date__c 
            //     ,Sub_segment__c 
            //     ,RTL_Average_AUM__c 
            //     ,OwnerId
            //     ,RTL_Fund_Risk_Mismatch__c
            //     ,RTL_Fund_High_Concentration_Risk__c
            //     ,Core_Banking_Suggested_Segment__c
            //     FROM Account WHERE Id =: recordId ];
        }else {
            System.debug('Have account from JS');
            acct = account;
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint('callout:OSC07');
            req.setBody('{ "GetCVSAnalyticsDataRequest": { "RMID": "' + acct.TMB_Customer_ID_PE__c + '" } }');

            stateOSC07 = new Map<String, Object>{
                'RMID' => acct.TMB_Customer_ID_PE__c,
                'RequestBody' => req.getBody(),
                'StartTime' => Datetime.now(),
                'Account' => acct
            };
            
            res = http.send(req);
            RTL_CSVLightningUtil.saveOnlineSerivceLogCVSAnalytics(stateOSC07, res, 'CVSAnalytics - OSC07');
            System.debug('Http res: '+res);
        }
        return res;
    }

    public static Object callCVSAnalyticsDataWrapperProcess(HttpResponse res){
        try {
            Map<String, Object> resultBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(AbstractCoreClass.getResult('Status.StatusCode', resultBody));
            if (StatusCode != '200' || ((Map<String, Object>)AbstractCoreClass.getResult('GetCVSAnalyticsDataResponse', resultBody)).isEmpty()) {
                // pageMessage = String.valueOf(AbstractCoreClass.getResult('Status.StatusDesc', resultBody));
                isServiceError = true;
                return null;
            }
            isServiceError = false;
            isServiceSuccess = True;
            CVSAnalyticsDataDTO result = (CVSAnalyticsDataDTO)JSON.deserialize(JSON.serialize(AbstractCoreClass.getResult('GetCVSAnalyticsDataResponse.Result', resultBody)), CVSAnalyticsDataDTO.Class);
            System.debug(JSON.serializePretty(result));
            CVSObject = result;
            
        }catch(Exception e){
            // PageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
            system.debug('Web services callout error with inner exception : ' + e.getMessage() + ':' + +e.getLineNumber() );   
        }
        return null;
    }

    @AuraEnabled (cacheable=true)
    public static Account getAccountForCheckQM_A(Id recordId){
        Account account = new Account();
        try {
            account = [SELECT Id,Name , Primary_Address_Line_1_PE__c,Zip_Code_Primary_PE__c,Registered_Address_Line_1_PE__c,
                           Zip_Code_Registered_PE__c,Office_Address_Line_1_PE__c,Zip_Code_Office_PE__c,ID_Type_PE__c,ID_Number_PE__c,
                           Mobile_Number_PE__c,Email_Address_PE__c,RTL_Date_Of_Birth__c,RTL_Occupation_Details__c,
                           Segment_crm__c,RTL_RM_Last_Update__c,Core_Banking_Suggested_Segment__c,Account_Type__c,TMB_Customer_ID_PE__c
                           FROM Account WHERE Id =: recordId];
        } catch (Exception e) {
            
        }
        return account;
    }

    @AuraEnabled
    public static Object dataCheckQM_A(Account account){
        List<Boolean> result = new List<Boolean>();
        String dataAgeStatus;
        String qualityStatus;
        String marketingStatus;

        RTL_Data_Summary__c dataSummary;

        dataSummary = new RTL_Data_Summary__c();

        if(account.Account_Type__c == 'Retail Prospect' || account.Account_Type__c == 'Prospect' || account.Core_Banking_Suggested_Segment__c == 'Others'){
            qualityStatus = 'N.A.';
            marketingStatus = 'N.A.';
            dataAgeStatus = 'N.A.';
            
        }else{
            RTL_DataQualityCheck dataQualityCheck = new RTL_DataQualityCheck();
            dataQualityCheck.start(new List<Account>{account});
            dataSummary = [SELECT ID,Name,RTL_Data_Age__c,RTL_Marketing_Messages__c  ,RTL_Data_Quality__c ,RTL_Overall_Quality__c,
            RTL_Data_Age_Message__c
            FROM RTL_Data_Summary__c WHERE RTL_Account__c=:account.id];
            qualityStatus = dataSummary.RTL_Data_Quality__c;
            marketingStatus = dataSummary.RTL_Marketing_Messages__c;
            dataAgeStatus = dataSummary.RTL_Data_Age__c;
        }
        Boolean QMMatch = qualityStatus.equals(marketingStatus);
        Boolean QPass = qualityStatus.equals('Pass');

        result.add((QMMatch && QPass) ? true : false);
        result.add(dataAgeStatus.equals('Pass') ? true : false);
        System.debug('result QM_A' + result);
        return result;
    }

    @AuraEnabled
    public static Object getRemark(String ProductGroup){
        List<Product_Holding_Configuration__mdt> productConfigs = new List<Product_Holding_Configuration__mdt>();
        try {
            productConfigs = [SELECT Id, Product_Group__c, RTL_Remark__c 
                            FROM Product_Holding_Configuration__mdt];
            for (Product_Holding_Configuration__mdt productConfig : productConfigs) {
                if (productConfig.Product_Group__c == ProductGroup) {
                    return productConfig.RTL_Remark__c;
                }
            }
        } catch (Exception e) {
            
        }
        return '-';
    }

}