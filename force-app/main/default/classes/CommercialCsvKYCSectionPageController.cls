public class CommercialCsvKYCSectionPageController {
    public static CVSAnalyticsDataDTO CVSObject = new CVSAnalyticsDataDTO();

    public class responseWrapper {
        public Boolean isServiceError;
        public String errorMessage;
        public String Status;
        public String touchStatus;
        public String LastLoginSuccessDate;
      }

    public static Integer cvsRetry {
        get{
            if(cvsRetry == null) {
                //get from custom label
                cvsRetry = Label.Number_Of_Retry_Times != null ? Integer.valueOf(Label.Number_Of_Retry_Times) : 3;
            }
            return cvsRetry;
        }set;
    }

    public static Integer cvsRetryDelay {
        get{
            if(cvsRetryDelay == null) {
                //get from custom label
                cvsRetryDelay = Label.Retry_SetTimeOut != null ? Integer.valueOf(Label.Retry_SetTimeOut) : 20000;
            }
            return cvsRetryDelay;
        }set;
    }

    public Integer cvsRetryRemain {get;set;}
    public Boolean isCVSInvalidToken {get;set;}
    public String webServiceErrMsg {get;set;}
    public Boolean isCVSRetryTimeout {get;set;}
    public Boolean isError {get;set;}
    public String ttbtouch {get;set;}
    public String fontColorTTBTouch {get;set;}
    public String fontColorError {get;set;}
    public Id recordId {get;set;}
    public Account acct {get;set;}
    public String last_login {get;set;}
    public responseWrapper resultObj {get;set;}
    public String subDebtTransDetail {get;set;}
    public String subDebtTransFlag {get;set;}
    public Object responseObj {get;set;}

    public CommercialCsvKYCSectionPageController() {

    }

    public CommercialCsvKYCSectionPageController(ApexPages.StandardController stdController){
        System.debug('test '+stdController);
        recordId = stdController.getRecord().Id;
        // acct = (Account)stdController.getRecord();
        cvsRetryRemain = cvsRetry; // set retry default
        isCVSRetryTimeout = false;
        isError = false;
        
    }

    public void setCVSRetryState() {
        System.debug('Before Set retry state'+cvsRetryRemain);
        if(cvsRetryRemain != null) {
            cvsRetryRemain -= 1;
            System.debug('Call set pdpa retry state'+cvsRetryRemain);
            webServiceErrMsg = 'Error getting data, retrying... ('+String.valueOf(cvsRetry-cvsRetryRemain)+')';
        }
        System.debug('After Set retry state'+cvsRetryRemain);
    }

    public void initialData() {
        getCustomerData();
        getCVSObject();
        getSubDebtTransaction();
    }

    public void getCustomerData() {
        if(recordId != null) {
            Account responseAccount;
            try {
                responseAccount = RetailCSVCustomerChartController.fetchAccount(recordId);
            }catch(Exception e){
                System.debug('Fail to call service:' + e.getMessage());
            }
            System.debug(responseAccount);
            if(responseAccount != null) {
                acct = responseAccount;
            }
        }
    }

    public void getSubDebtTransaction(){
        List<Sub_Debt_Transaction__c> subDebtTran = [SELECT Id, Name,Customer__c FROM Sub_Debt_Transaction__c WHERE Customer__c =: recordId];
        subDebtTransFlag = System.Label.Sub_Debt_Transaction_Flag;
        subDebtTransDetail = subDebtTran.size()>0? System.Label.Sub_Debt_Transaction_Yes_Message : System.Label.Sub_Debt_Transaction_No_Message;

    }

    public void getCVSObject() {
        // PDPAStructure pdpaData = New PDPAStructure();
        // String acc = JSON.parse(customerData);
        // Object acc = JSON.parse(customerData);
        // Object acc = customerData;
        System.debug('get cvs object'+acct);
        
        Object result;
        try{
            result = RetailCSVCustomerChartController.getCVSObject2(recordId, acct);
            responseObj = result;
            System.debug('ResponseBody: ' + result);
        }catch(Exception e){
            isError = true;
            System.debug('Fail to call service:' + e.getMessage());
        }
        // responseObj = result;
        System.debug(responseObj);
        isCVSInvalidToken = result != null ? String.valueOf(result).contains('invalid_token') : false;
        System.debug('check invalid token flag '+isCVSInvalidToken);
        if(isCVSInvalidToken && cvsRetryRemain <= 0) {
            isCVSRetryTimeout = true;
            webServiceErrMsg = 'Error getting data';
            fontColorError = 'Red';
        }

        if(result != null) {
            resultObj = (responseWrapper)JSON.deserialize(String.valueOf(result), responseWrapper.class);
            isError = resultObj.Status == 'SUCCESS' ? false : true;
            if(resultObj.Status == 'SUCCESS') {
                if (resultObj.touchStatus == 'YES') {
                    // last_login = resultObj.LastLoginSuccessDate;
                    // String date_format = '';
                    // if (last_login) {
                    //     const date = new Date(last_login);
                    //     date_format = date.toLocaleDateString('th-TH', {
                    //         year: '2-digit',
                    //         month: 'short',
                    //         day: 'numeric',
                    //     })
                    // }
                    // มี (เข้าใช้งานล่าสุด 9 ก.พ. 65)
    
                    // ttbtouch = 'มี (เข้าใช้งานล่าสุด ' + date_format + ')';
                    fontColorTTBTouch = '';
                } else {
                    ttbtouch = 'ไม่มี';
                    fontColorTTBTouch = 'Red';
                }
            }
        } else {
            isError = true;
        }
        System.debug(resultObj);
        // if(resultObj.touchStatus != null) {
        //     isError = false;
        
        // }
        // System.debug('debug ttbtouch '+ttbtouch);
    }

    // public void setTouchStatusVariable() {
    //     String tStatus = ApexPages.currentPage().getParameters().get('tstatus');
    //     String tStatusMsg = ApexPages.currentPage().getParameters().get('tmsg');
    //     ttbtouch = tStatusMsg;
    //     if(tStatus == 'YES') {
    //         fontColorTTBTouch = '';
    //     } else {
    //         fontColorTTBTouch = 'Red';
    //     }
    // }

    public void setTouchStatusVariable() {
        String tStatusMsg = ApexPages.currentPage().getParameters().get('tmsg');
        if(tStatusMsg != null) {
            ttbtouch = tStatusMsg;
        }
    }


}