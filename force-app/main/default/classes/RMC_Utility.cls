public with sharing class RMC_Utility {

    public static void abortOldJobs(String jobName){
        for(CronTrigger job : [SELECT id, CronJobDetail.name FROM CronTrigger WHERE CronJobDetail.name LIKE :JobName + '%']){
            System.abortJob(job.id);
        }
    }

    public static Map<String, String> getScheduleDT(String jobName, DateTime nextScheduleDT){
        Map<String, String> result = new Map<String, String>();
        Integer offset = UserInfo.getTimezone().getOffset(nextScheduleDT);
        Datetime localTime = nextScheduleDT.addSeconds(offset/1000);

        System.debug('nextScheduleDT : ' + localTime);
        String secondExp =  localTime.secondGmt() < 10 ? ( '0' + String.valueOf(localTime.secondGmt()) ) : String.valueOf(localTime.secondGmt());
        String minuteExp =  localTime.minuteGmt() < 10 ? ( '0' + String.valueOf(localTime.minuteGmt()) ) : String.valueOf(localTime.minuteGmt());
        String hourExp   =  localTime.hourGmt()   < 10 ? ( '0' + String.valueOf(localTime.hourGmt()) )   : String.valueOf(localTime.hourGmt());
        String dayExp    =  localTime.dayGmt()    < 10 ? ( '0' + String.valueOf(localTime.dayGmt()) )    : String.valueOf(localTime.dayGmt());
        String monthExp  =  localTime.monthGmt()  < 10 ? ( '0' + String.valueOf(localTime.monthGmt()) )  : String.valueOf(localTime.monthGmt());
        String yearExp  =   String.valueOf(localTime.yearGmt());

        String strSchedule = secondExp + ' ' + minuteExp + ' ' + hourExp + ' ' + dayExp + ' ' + monthExp + ' ' + '? '+ yearExp;
        System.debug('strSchedule : ' + strSchedule);
        String strJobName =  JobName + dayExp + '/' + monthExp + '/' + yearExp + ' '+ hourExp + ':' + minuteExp + ':' + secondExp;
        System.debug('strJobName : ' + strJobName);
        result.put('jobName', strJobName);
        result.put('jobSchedule', strSchedule);

        return result;
    }

    public static List<String> getSObjectFieldList(String objectName){
        List<String> accessibleFieldList = new List<String>();
        Map<String, SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap();
        if(fieldMap != null && !fieldMap.isEmpty()){
            for(Schema.SObjectField field : fieldMap.values()){
                Schema.DescribeFieldResult descResult = field.getDescribe();
                if(descResult.isAccessible()){
                    accessibleFieldList.add(descResult.getName());
                }
            }
        }
        return accessibleFieldList; 
    }

    public static List<Schema.FieldSetMember> getFieldsByFieldSet(String objectName, String fieldSetName){
        List<Schema.FieldSetMember> fieldSetMemberList;
        Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().FieldSets.getMap().get(fieldSetName);
        if(fieldSetObj != null){
            fieldSetMemberList =  fieldSetObj.getFields();
        }
        return fieldSetMemberList;
    }

    /*
    * Standard online log save method for webservice logging
    */
    public static void saveToOnlineLog(Boolean isSuccess ,String customerName, String errorMessage, String msLogId , String userName, 
                            String rmId , String serviceName ,String requestBody ,String responseBody , String customerId, String coreBankSegment,
                            DateTime startTime , DateTime endTime, String remark) {
        RTL_Online_Service_Log__c eachLog = new RTL_Online_Service_Log__c();
        //*** Mapping from TSD ****//
        eachLog.RTL_Is_Success__c         = isSuccess;  
        eachLog.RTL_Customer_Name__c      = customerName;
        //MuleSoft.Message
        eachLog.RTL_Error_Message__c      = errorMessage;
        //Mulesoft.LogId
        eachLog.RTL_Mulesoft_Log_Id__c    = msLogId;
        eachLog.RTL_Name_of_User__c       = userName;
        eachLog.RTL_RM_ID__c              = rmId;
        eachLog.RTL_Service_Name__c       = serviceName;
        if(!String.isBlank(customerId)) eachLog.RTL_Account__c            = customerId;
        eachLog.RTL_Customer_Segment__c   = coreBankSegment;
        eachLog.RTL_Start_DateTime__c     = startTime;
        eachLog.RTL_End_DateTime__c       = endTime;
        eachLog.Remark__c                 = remark;
        
        insert eachLog;

        List<Attachment> importattachmentfileList = new List<Attachment>();
        if(!String.isBlank(requestBody)){ 
            Attachment reqFile    = new Attachment();
            reqFile.parentId      = eachLog.id;
            reqFile.name          = 'requestBody.txt';
            reqFile.IsPrivate     = false;
            reqFile.body          = Blob.valueOf(requestBody);
            importattachmentfileList.add(reqFile);
        }

        if(!String.isBlank(responseBody)){ 
            Attachment resFile = new Attachment();
            resFile.parentId = eachLog.id;
            resFile.name = 'responseBody.txt';
            resFile.IsPrivate = false;
            resFile.body = Blob.valueOf(responseBody);
            importattachmentfileList.add(resFile);
        }

        if(importattachmentfileList != null && !importattachmentfileList.isEmpty())  insert importattachmentfileList;
    }

    public static AuthenticationToken startCallGetTokenService() {
        // Set request body
        SmartBDM_Service.RequestToken request = new SmartBDM_Service.RequestToken();
        request.endpoint = 'Smart_BDM_Cal_Tools_Create_Token_SIT';
//        request.endpoint = 'Smart_BDM_Cal_Tools_Create_Token';
         // Create callout request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint(request.parseEndpoint());
        req.setBody(request.parseBody());
        req.setTimeout(Smart_BDM_Constant.AUTHORIZATION_TIMEOUT);
        AuthenticationToken authen = new AuthenticationToken();
        Datetime startTime = DateTime.now();
        HttpResponse res;
        try {
            res = http.send(req);
            Datetime endTime = DateTime.now();
            if(res == null) {
                authen.isSuccess = false;
                authen.errorMessage = 'Null response.';
                authen.requestBody = request.parseBody();
                authen.responseBody = res.getBody();
            } else {
                if(res.getStatusCode() != 200) {
                    authen.isSuccess = false;
                    authen.errorMessage = AuthenticationToken.parse(res.getBody()).status.message;
                    authen.requestBody = request.parseBody();
                    authen.responseBody = res.getBody();
                }
                // Success with POST request
                else {
                    authen = AuthenticationToken.parse(res.getBody());
                    authen.isSuccess = true;
                    authen.errorMessage = '';
                    authen.requestBody = request.parseBody();
                    authen.responseBody = res.getBody();
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();
            Datetime endTime = DateTime.now();
            
            authen.isSuccess = false;
            authen.errorMessage = errorMessage;
            authen.requestBody = request.parseBody() + '\n' + 'Endpoint Callout: ' + request.parseEndpoint() + '\n';
            authen.responseBody = res != null ? res.getBody() : '';
        }
        return authen;
    }

    public static Boolean isEmployee(String tmbCustId) {
        try {
            return [SELECT RTL_Is_Employee__c FROM Account WHERE TMB_Customer_ID_PE__c = :tmbCustId LIMIT 1 FOR UPDATE].RTL_Is_Employee__c;
        } catch (Exception e) {
            return false;
        }
    }

    public static Account getAccount(String RMID) {
        try {
            // return [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :RMID LIMIT 1];
            return [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :RMID LIMIT 1 FOR UPDATE];
        } catch (Exception e) {
            return new Account();
        }
    }

    public static Map<String, RMC_Constant__mdt> getRMContants(String category){
        Map<String, RMC_Constant__mdt> constantMap = new Map<String, RMC_Constant__mdt>();
        List<RMC_Constant__mdt> recordList         = [SELECT Id, DeveloperName, Value__c FROM RMC_Constant__mdt WHERE Category__c =: category];
        if(recordList != null && !recordList.isEmpty()){
            for(RMC_Constant__mdt eachRecord : recordList){
                if(!String.isBlank(eachRecord.Value__c)){
                    constantMap.put(eachRecord.DeveloperName, eachRecord);
                }
            }
        }
        return constantMap;
    }

    public static Boolean isNotEmpty(Map<String, SObject> sObjectMap){
        return sObjectMap != null && !sObjectMap.isEmpty() && sObjectMap.size() > 0;
    }

    public static ProductCodeWrapper getProductInformation(Set<String> productCodeSet){
        ProductCodeWrapper productCodeMapSet    = new ProductCodeWrapper();
        Map<String, Product2> product2MapByProductCode = new Map<String, Product2>();
        Map<String, Product2> product2MapByRTLProductCode = new Map<String, Product2>();
        Map<String, Product2> product2MapByTMBProductType = new Map<String, Product2>();
        List<Product2> productList  = new List<Product2>();
        if(productCodeSet != null && !productCodeSet.isEmpty()){
            productList = [SELECT Id, ProductCode, Name, RTL_Product_Name_ENG__c, RTL_Product_Name_TH__c, RTL_Product_Short_Name_ENG__c, RTL_Product_Short_Name_TH__c, 
                                    Family, Sub_Family__c, RTL_Asset_Class__c, IsActive,  RMC_1Year_Return__c, RMC_Latest_Update_of_MF_Return__c,
                                    RTL_PRODUCT_CODE__c,RTL_TMB_Product_Type__c
                            FROM Product2
                            WHERE  ProductCode IN: productCodeSet
                            OR RTL_TMB_Product_Type__c IN: productCodeSet
                            OR RTL_Product_Code__c IN: productCodeSet];
        }
        if(productList != null && !productList.isEmpty()){
            for(Product2 eachProduct : productList){
                if(!String.isBlank(eachProduct.ProductCode)) product2MapByProductCode.put(eachProduct.ProductCode, eachProduct);    
                if(!String.isBlank(eachProduct.RTL_Product_Code__c)) product2MapByRTLProductCode.put(eachProduct.RTL_Product_Code__c, eachProduct);
                if(!String.isBlank(eachProduct.RTL_TMB_Product_Type__c)) product2MapByTMBProductType.put(eachProduct.RTL_TMB_Product_Type__c + 'CRE', eachProduct);

            }
        }

        productCodeMapSet.product2MapByProductCode = product2MapByProductCode;
        productCodeMapSet.product2MapByRTLProductCode = product2MapByRTLProductCode;
        productCodeMapSet.product2MapByTMBProductType = product2MapByTMBProductType;

        return productCodeMapSet;
    }

    public class ProductCodeWrapper{
        public Map<String, SObject> product2MapByProductCode {get;set;}
        public Map<String, SObject> product2MapByRTLProductCode {get;set;}
        public Map<String, SObject> product2MapByTMBProductType {get;set;}
    }
}