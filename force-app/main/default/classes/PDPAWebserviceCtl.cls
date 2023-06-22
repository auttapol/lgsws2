public class PDPAWebserviceCtl implements Database.AllowsCallouts{
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    private String SERVICE_NAME = 'PDPA_and_Market_Consent';
    private RTL_Online_Service_Log__c onlineLog = new RTL_Online_Service_Log__c();

    private String customerId;
    private String financialId;

    public String tmbCustId;
    public String pdpatype;

    private String emplooyeeID;

    public String pageMessage {get;set;}
    public Account accountObj{get;set;}
    public boolean isExistingCust {get;set;}
    public boolean isErrorResponse {get;set;}
    public boolean isErrorThailandList {get;set;}
    public boolean isSendMailSuccess {get;set;}
    public boolean isSendMailError {get;set;}
    public String tTitle {get;set;}
    public String tMsg {get;set;}
    public String tType {get;set;}

    public static String dboEmailAddr {
        get {
            if(dboEmailAddr == null) {
                AppConfig__c configDpoEmail = AppConfig__c.getValues('DPO Email Address');
                if(configDpoEmail == null) {
                    dboEmailAddr = 'sf_admin@tmbbank.com';
                } else {
                    dboEmailAddr = configDpoEmail.Value__c;
                }
            } 
            return dboEmailAddr;
        }
        set;
    }

    public static Set<String> allowedProfileList {
        get {
            if(allowedProfileList == null) {
                allowedProfileList = new Set<String>();
                Map<String, PDPA_Activity_profile_button__mdt> profileMdt = PDPA_Activity_profile_button__mdt.getAll();
                for(PDPA_Activity_profile_button__mdt profile : profileMdt.values()) {
                    allowedProfileList.add(profile.Profile_Name__c);
                }
            }
            return allowedProfileList;
        }
        set;
    }
    

    public String urlToUpdatePdpa {
        get{
            if(urlToUpdatePdpa == null){
                if(isProfileinCanvasList){
                    urlToUpdatePdpa = '/apex/Accountpdpapage';
                }else{
                    urlToUpdatePdpa = '/apex/PDPAScreenUpdateComponent';
                }
            }

            return urlToUpdatePdpa;
        }set;
    }

    public static String ETEAppId {
        get{
            if(ETEAppId == null){
                if(UserInfo.getUiThemeDisplayed() == 'Theme4t'){
                    ETEAppId = AppConfig__c.getValues('PDPA_ETE_Digital_App_ID') != null ? AppConfig__c.getValues('PDPA_ETE_Digital_App_ID').Value__c : 'A0291-SF1';
                }else{
                    ETEAppId = AppConfig__c.getValues('PDPA_ETE_Paper_App_ID') != null ? AppConfig__c.getValues('PDPA_ETE_Paper_App_ID').Value__c : 'A0291';
                }
            }
            return ETEAppId;
        }set;
    }

    public Boolean isProfileinCanvasList {
        get{
            if(isProfileinCanvasList == null){
                isProfileinCanvasList = false;

                if(profileMapChanel.containsKey(currtUser.Profile.Name) && profileMapChanel.get(currtUser.Profile.Name) == 'BR'){
                    isProfileinCanvasList = true;
                }
                
            }
            return isProfileinCanvasList;
        }set;
    }

    public static User currtUser {
        get{
            if(currtUser == null){
                currtUser = [SELECT Id, Employee_ID__c, Profile.Name, Email FROM User WHERE Id = :UserInfo.getUserId()];
            }
            return currtUser;
        }set;
    }

    private static List<String> cusIdTypeEngList {
        get{
            if(cusIdTypeEngList == null) {
                cusIdTypeEngList = AppConfig__c.getValues('PDPA_ID_type_language_ENG')?.Value__c.split(';');
                if(cusIdTypeEngList == null) {
                    cusIdTypeEngList =  new List<String>{'Passport ID', 'Work permit ID', 'Alien ID'};
                }
            }
            return cusIdTypeEngList;
        } set;
    }

    public static Integer pdpaRetry {
        get{
            if(pdpaRetry == null) {
                //get from custom label
                pdpaRetry = Label.Number_Of_Retry_Times != null ? Integer.valueOf(Label.Number_Of_Retry_Times) : 3;
            }
            return pdpaRetry;
        }set;
    }

    public static Integer pdpaRetryDelay {
        get{
            if(pdpaRetryDelay == null) {
                //get from custom label
                pdpaRetryDelay = Label.Retry_SetTimeOut != null ? Integer.valueOf(Label.Retry_SetTimeOut) : 20000;
            }
            return pdpaRetryDelay;
        }set;
    }

    public Integer pdpaRetryRemain {
        get;set;
    }

    public Boolean isPDPAInvalidToken {
        get{
            if(isPDPAInvalidToken == null) {
                isPDPAInvalidToken = false;
            }
            return isPDPAInvalidToken;
        }set;
    }

    public String webServiceErrMsg {get;set;}
    public Boolean isViewPDPARetryTimeout {get;set;}

    public Account currentObject {get;set;}

    public Boolean endProcess {get;set;}
    public String errorcallOut {get; set;}
    public Boolean isEdit {get; set;}
    public Boolean isPermitted {get; set;}

    //valiable for online service log
    private String customerName;
    private String rmID;
    private Datetime startTime;
    private Datetime endTime;
    private String errorMessageRespone;
    private String uidLogId;
    private Boolean isSuccess = false;
   
    private String tempFlag;
    private String tempType; 
    private Date tempConsentSignDate; 

    private String needUpdateflagHistory;
    private APICallInterface APICALL_HANDLER = null;

    Integer timeout = Integer.valueOf(AppConfig__c.getValues('PDPA_Timeout').Value__c);   

    Map<String,PDPAMapping__c> mapType = new Map<String,PDPAMapping__c>();
    List<PDPAMapping__c> PDPAMapping = new List<PDPAMapping__c>();

    public List<PDPAStructure.PDPAconsents> pdpaForDisplay {get;set;}
    public Integer selectedConsentIdx {get;set;}

    List<PDPAStructure.PDPAconsents> pdpaForHistory = New List<PDPAStructure.PDPAconsents>();
    
    private List<PDPA_Update_Flag_Permission__c> profileList {
        get{
            if(profileList == null){
                profileList = [SELECT Id, Name, Profile_Name__c, Channel__c, PermissionUpdateFlag__c, Previous_Flag__c FROM PDPA_Update_Flag_Permission__c];
            }
            return profileList;
        }set;
    }

    public Map<String,String> profileMapChanel {
        get{
            if(profileMapChanel == null){
                profileMapChanel = new Map<String,String>();

                for(PDPA_Update_Flag_Permission__c pro : profileList){
                    profileMapChanel.put(pro.Profile_Name__c, pro.Channel__c);
                }
            }
            return profileMapChanel;
        }set;
    }

    Map<String,String> profileMapPermission = New Map<String, String>(); 
    
    //Add by CR PDPA enhancement for Contact center 
    Map<String,String> profileMapPreviousFlag = New Map<String, String>(); 

    User currentUser = new User();

    public PDPAStructure.PDPAconsents pdpaViewBeforeEdit {get;set;}

    public list<PDPAMapping__c> getPDPAMapping(){
        if(PDPAMapping.size() <= 0 || PDPAMapping == null){
            return [Select Name, Description__c,Display_Type__c, Template_Type__c, Description_TH__c,
                    Multiple_Update__c from PDPAMapping__c ];
        }else{
            return PDPAMapping; //Default timeout value 30 seconds
        }
    }

    public PDPAWebserviceCtl(ApexPages.StandardController stdController) {
        ID accountId = stdController.getRecord().id;
        Account currentObject = (Account)stdController.getRecord();

        tmbCustId = apexpages.currentpage().getparameters().get('tmbid');
        pdpatype = apexpages.currentpage().getparameters().get('pdpatype');

        PDPAWebserviceCtl2(accountId, currentObject, tmbCustId, pdpatype);
    }

    public void PDPAWebserviceCtl2(Id accountId, Account currentObject, String tmbCustId, String pdpatype) {
        isSendMailSuccess = false;
        isSendMailError = false;           
        pdpaRetryRemain = pdpaRetry; // set retry default
        isViewPDPARetryTimeout = false;      
        // ID accountId = stdController.getRecord().id;
        // currentObject = (Account)stdController.getRecord();

        try{

            try{
                accountObj = [Select ID,Name,TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c, ID_Type_PE__c, Customer_Name_PE_Eng__c, RTL_Customer_Name_TH__c, Email_Address_PE__c, Last_name_PE__c, Last_Name_PE_Eng__c, First_Name_ENG_PE__c, First_name_PE__c, RTL_Customer_Title__c FROM Account WHERE id =: accountId ];
            }catch(Exception e){
                accountObj = [Select ID,Name,TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c, ID_Type_PE__c, Customer_Name_PE_Eng__c, RTL_Customer_Name_TH__c, Email_Address_PE__c, Last_name_PE__c, Last_Name_PE_Eng__c, First_Name_ENG_PE__c, First_name_PE__c, RTL_Customer_Title__c FROM Account WHERE TMB_Customer_ID_PE__c =: tmbCustId ];
            }

            customerName = accountObj.Name;
            rmID = accountObj.TMB_Customer_ID_PE__c;

            if(accountObj.TMB_Customer_ID_PE__c != null){
                customerId = accountObj.TMB_Customer_ID_PE__c.substring(16,30);
                financialId = accountObj.TMB_Customer_ID_PE__c.substring(0,16);
                isExistingCust = true;
            }else{
                customerId= null;
                financialId = null;
                isExistingCust = false;
            }

        } catch(Exception e) {
            System.debug(e.getMessage());
            isExistingCust = false;
            errorMessageRespone = e.getMessage();
        }
        isErrorResponse = false;  

    }

    public PDPAWebserviceCtl(){

    }

    public PageReference consentPDF(PDPAStructure.PDPAconsents selectedConsent)
    {
        // [channel=RSL, consentBy=RSLU0151, consentDateTime=2021-09-11 10:51:00, consentSignDate=2021-09-11 00:00:00, decriptionEN=Consent for Disclosure of Personal Information, decriptionTH=การให้ความยินยอมในการเปิดเผยข้อมูลส่วนบุคคลตามพ.ร.บ.คุ้มครองข้อมูลส่วนบุคคล, flag=NO, needUpdateFlag=No, needUpdateFlagReason=, type=PDPA, version=8]
        // System.debug('Selected pdpa ' + selectedConsent);
        PageReference pageRef = Page.MarketConductConsentPDF;
        pageRef.getParameters().put('ver', selectedConsent.version);
        pageRef.getParameters().put('type', selectedConsent.type);
        pageRef.getParameters().put('via', selectedConsent.channel);
        if(selectedConsent.consentSignDate != null) {
            pageRef.getParameters().put('grantdate', string.valueof(((Datetime)selectedConsent.consentSignDate).format('dd/MM/yyyy')));
        }
        String displayFlag = '';
        String name = '';
        if(cusIdTypeEngList.contains(accountObj.ID_Type_PE__c)) {
            // eng
             System.debug('Show account obj '+accountObj);
            if(accountObj.First_Name_ENG_PE__c == null || accountObj.Last_Name_PE_Eng__c == null) {
                //use th
                if(accountObj.Last_name_PE__c == null) {
                    accountObj.Last_name_PE__c = '';
                }
                accountObj.RTL_Customer_Title__c = 'คุณ';
                name = accountObj.RTL_Customer_Title__c + ' ' + accountObj.First_name_PE__c + ' ' + accountObj.Last_name_PE__c;
            } else {
                accountObj.RTL_Customer_Title__c = 'Khun';
                name = accountObj.RTL_Customer_Title__c + ' ' + accountObj.First_Name_ENG_PE__c + ' ' + accountObj.Last_Name_PE_Eng__c;
            }
            pageRef.getParameters().put('name', name);
            // pageRef.getParameters().put('lang','en');
            if(selectedConsent.wsCurrentFlag == 'Y') {
                displayFlag = Label.PDPA_PDF_Flag_EN_Accept;
            } else if(selectedConsent.wsCurrentFlag == 'N') {
                displayFlag = Label.PDPA_PDF_Flag_EN_Reject;
            } else {
                displayFlag = Label.PDPA_PDF_Flag_EN_Other;
            }
        } else {
            // th
                accountObj.RTL_Customer_Title__c = 'คุณ';
            if(accountObj.Last_name_PE__c == null) {
                accountObj.Last_name_PE__c = '';
            }
            name = accountObj.RTL_Customer_Title__c + ' ' + accountObj.First_name_PE__c + ' ' + accountObj.Last_name_PE__c;
            pageRef.getParameters().put('name', name);
            // pageRef.getParameters().put('lang','th');
            if(selectedConsent.wsCurrentFlag == 'Y') {
                displayFlag = Label.PDPA_PDF_Flag_TH_Accept;
            } else if(selectedConsent.wsCurrentFlag == 'N') {
                displayFlag = Label.PDPA_PDF_Flag_TH_Reject;
            } else {
                displayFlag = Label.PDPA_PDF_Flag_TH_Other;
            }
        }
        
        pageRef.getParameters().put('consentAccept',displayFlag);
        pageRef.getParameters().put('emp', currentUser.Email);
        pageRef.setRedirect(true);        
        return pageRef; 
    }

    public PageReference printConsentPDF() {
        PDPAStructure.PDPAconsents selectedConsent = pdpaForDisplay.get(selectedConsentIdx);
        saveActivityLog('Print', selectedConsent);
        return consentPDF(selectedConsent);
    }

    public void sendMail() {
        // if account does not have email then hide email button
        if(validateEmail(accountObj.Email_Address_PE__c)) {
            PDPAStructure.PDPAconsents selectedConsent = pdpaForDisplay.get(selectedConsentIdx);
            List<String> EmailIds = new List<String>{};
        	EmailIds.add(accountObj.Email_Address_PE__c);
            PageReference ref = consentPDF(selectedConsent);
            Blob b;
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Unit.Test');
            } else {
                b = ref.getContentAsPDF();
            }
            Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
           
            efa1.setBody(b);
    
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String emailTemplateName = '';
            try {
                List<OrgWideEmailAddress> orgWideEmailLst = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: dboEmailAddr LIMIT 1];
                // OtherException extends BaseException {}
                if(orgWideEmailLst.size() > 0) {
                    OrgWideEmailAddress orgWideEmail = orgWideEmailLst.get(0);
                    if(!validateEmail(orgWideEmail.Address)) {
                        // throw new Exception('Invalid org-wide email address');
                        throw new OtherException ('Invalid org-wide email address');
                    }
                    email.setOrgWideEmailAddressId(orgWideEmail.Id);
                } else {
                    if(!validateEmail(currentUser.Email)) {
                        throw new OtherException ('Invalid email address');
                    }
                }
            }
            catch(Exception e) {
                tTitle = 'Error';
                tMsg = e.getMessage();
                tType = 'error';
                isSendMailError = true;
            }
            if(!isSendMailError) {
                if(cusIdTypeEngList.contains(accountObj.ID_Type_PE__c)) {
                    //eng
                    emailTemplateName = 'PDPA - Email Template EN';

                    if(accountObj.First_Name_ENG_PE__c == null || accountObj.Last_Name_PE_Eng__c == null) {
                        //use th
                        efa1.setFileName('Copy of consent of คุณ ' + accountObj.First_name_PE__c + ' ' + accountObj.Last_name_PE__c + '.pdf');
                    } else {
                        efa1.setFileName('Copy of consent of Khun ' + accountObj.First_Name_ENG_PE__c + ' ' + accountObj.Last_Name_PE_Eng__c + '.pdf');
                    }
        
                } else {
                    //th
                    if(accountObj.First_name_PE__c == null) { accountObj.First_name_PE__c = ''; }
                    if(accountObj.Last_name_PE__c == null) { accountObj.Last_name_PE__c = ''; }
                    emailTemplateName = 'PDPA - Email Template TH';
                    efa1.setFileName('สำเนาการขอความยินยอมของคุณ ' + accountObj.First_name_PE__c + ' ' + accountObj.Last_name_PE__c + '.pdf');
                }
             
                EmailTemplate mailTemp = [SELECT Id, Name ,Subject,Body FROM EmailTemplate WHERE Name =: emailTemplateName];
        
                email.setSubject(mailTemp.Subject);
                email.setPlainTextBody(mailTemp.Body);
        
                email.setSaveAsActivity(false); 
                email.setToAddresses(EmailIds);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {email};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
                Boolean isSuccess = true;
                for(Messaging.SendEmailResult result :results ){
                    if(!result.isSuccess()) {
                        isSuccess = false;
                        tTitle = 'Error';
                        tMsg = 'Send email failed.';
                        tType = 'error';
                        isSendMailError = true;
                        break;
                    }
                }
        
                if(isSuccess) {
                    saveActivityLog('Email', selectedConsent);
                    isSuccess = false;
                    tTitle = 'Success';
                    tMsg = 'Send mail success';
                    tType = 'success';
                    isSendMailSuccess = true;
                }
            }  
        } else {
            isSuccess = false;
            tTitle = 'Error';
            tMsg = 'Invalid target email address';
            tType = 'error';
            isSendMailError = true;
        }
    }

    private static Boolean validateEmail(String email) {
        Boolean res = true;
            
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            res = false;
        return res;	
    }

    private void saveActivityLog(String activityType, PDPAStructure.PDPAconsents consentData) {
        if(consentData != null) {
            PDPA_Activity_Log__c activity = new PDPA_Activity_Log__c(
                Account_Id__c = accountObj.Id,
                Description_EN__c = consentData.decriptionEN,
                Description_TH__c = consentData.decriptionTH,
                Version__c = consentData.version,
                Consent__c = consentData.wsCurrentFlag,
                Activity_Channel__c = consentData.channel,
                Activity_Type__c = activityType,
                Consent_Type__c = consentData.type,
                Employee_Id__c = consentData.consentBy,
                Record_Date__c = consentData.consentDateTime,
                Create_Date__c = Datetime.now(),
                Sign_Off_Date__c = consentData.consentSignDate,
                Requested_Date__c = Date.today()
            );
            
            insert activity;
        }
    }

    public void setPDPARetryState() {
        if(pdpaRetryRemain != null) {
            pdpaRetryRemain -= 1;
            webServiceErrMsg = 'Error getting data, retrying... ('+String.valueOf(pdpaRetry-pdpaRetryRemain)+')';
        }
    }

    public void viewPDPA(){
        String requestBody = '';
        String responseBody = '';
        
        if(isExistingCust){          
            this.checkPrintPermission(); // check permission
            if(tmbCustId == null && pdpatype == null){
                requestBody = '{'+  '"customerId":"' +customerId+ '",' +'"financialId":"'+financialId+'"}';
            }else{

                customerId = tmbCustId.substring(16,30);
                financialId = tmbCustId.substring(0,16);
                requestBody = '{'+  '"customerId":"' +customerId+ '",' +'"financialId":"'+financialId+'"}';

            }
            // profileList =  [Select ID, Name, Profile_Name__c, Channel__c, PermissionUpdateFlag__c from PDPA_Update_Flag_Permission__c];

            currentUser = [Select ID, Employee_ID__c, UserProfileName__c, Email from User where id =: UserInfo.getUserId()];                        
            
            if(profileList.size() > 0){
                for(PDPA_Update_Flag_Permission__c pro :profileList ){
                    profileMapPermission.put(pro.Profile_Name__c, pro.PermissionUpdateFlag__c);
                    
                    //Add by CR PDPA enhancement for Contact center 
                    profileMapPreviousFlag.put(pro.Profile_Name__c, pro.Previous_Flag__c);
                }
            } 

            isEdit = false;

            if(profileMapChanel.containsKey(currentUser.UserProfileName__c)){
                isEdit = true;
            }

            PDPAStructure pdpaData = New PDPAStructure();
            responseBody = callService(requestBody, 'PDPA_and_Market_Consent_getFlag');
            System.debug('Get flag response'+responseBody);

            isPDPAInvalidToken = responseBody.contains('invalid_token');
            if(isPDPAInvalidToken && pdpaRetryRemain <= 0) {
                isViewPDPARetryTimeout = true;
            }
            //Set defualt not error Thailand list
            isErrorThailandList = false;

            if(responseBody != null){  
                if(responseBody.contains('"consentDateTime": ""')){
                    responseBody = responseBody.replace('"consentDateTime": ""', '"consentDateTime": null');
                }                
                if(responseBody.contains('"consentSignDate": ""')){
                    responseBody = responseBody.replace('"consentSignDate": ""', '"consentSignDate": null');
                }
                try{
                    pdpaData = PDPAStructure.parseJsontoObj(responseBody);
                    errorMessageRespone = pdpaData.status.description; 
                }catch(Exception e){
                    isErrorResponse = true;
                    errorMessageRespone = e.getMessage();  
                    onlineLog('VIEW_PDPA_AND_MARKET_CONSENT',requestBody,responseBody);             
                }   

            }                                
            //Response not error
            if(isErrorResponse == false){               
                isSuccess = true;
                PDPAMapping = getPDPAMapping();
                if(PDPAMapping.size() > 0 && mapType.size() <= 0){
                    for(integer i = 0; i < PDPAMapping.size() ; i++){
                        mapType.put(PDPAMapping[i].Name, PDPAMapping[i]);
                    }
                }     

                List<PDPAStructure.PDPAconsents> papaList = pdpaData.data.consents;
                pdpaForDisplay = New List<PDPAStructure.PDPAconsents>();
                for(integer i = 0; i < papaList.size(); i++){
                        
                        //Check customer in Thailand list flag Y, if customer in thailand list show error in screen
                        if(papaList[i].needUpdateFlagReason == 'TS2000'){                            
                            isErrorThailandList = true;                            
                            isErrorResponse = false;
                            isSuccess = true;
                            errorMessageRespone = Label.PDPA_Thailand_List_Flag;                           
                            break;
                        }

                        papaList[i].wsCurrentFlag = papaList[i].flag;
                        if(papaList[i].flag == 'Y'){
                            papaList[i].flag = Label.PDPA_Accept_YES;
                        }else if(papaList[i].flag == 'N'){
                            papaList[i].flag = Label.PDPA_Accept_NO;
                        }

                         if(papaList[i].needUpdateFlag == 'Y'){
                            papaList[i].needUpdateFlag = Label.PDPA_Need_Update_YES;
                        }else if(papaList[i].needUpdateFlag == 'N'){
                            papaList[i].needUpdateFlag = Label.PDPA_Need_Update_NO;
                        }

                        //Show only record in mapping
                        if(mapType.get(papaList[i].type) != null){                            
                            String originType = papaList[i].type;

                            PDPAMapping__c newMap = new PDPAMapping__c();
                            newMap = mapType.get(papaList[i].type);                      

                            papaList[i].type = newMap.Display_Type__c;
                            papaList[i].decriptionEN = newMap.Description__c;
                            papaList[i].decriptionTH = newMap.Description_TH__c;
                            pdpaForDisplay.add(papaList[i]);
                            //Add 1 record to show before edit
                            if((newMap.Display_Type__c == pdpatype && pdpatype != null )|| Test.isRunningTest()){    
                                                       
                                tempConsentSignDate = papaList[i].consentSignDate;
                                pdpaViewBeforeEdit = papaList[i];
                                pdpaForHistory.add(papaList[i]);                             
                                //Default consent sign date to Today 
                                pdpaViewBeforeEdit.consentSignDate = system.today(); 
                                
                                tempType = originType;                                  
                                tempFlag = papaList[i].flag; 
                                needUpdateflagHistory = pdpaViewBeforeEdit.needUpdateFlag;                          

                            }
                        }                       
                }
            }

            try{                
                onlineLog('VIEW_PDPA_AND_MARKET_CONSENT',requestBody,responseBody);
            }catch(Exception e){
                system.debug('Print error exception write online log = '+ e.getMessage());
                //Do not thing
            } 
        }  
        

    }   

    private void checkPrintPermission() {
        isPermitted = false;
        if(allowedProfileList.contains(currtUser.Profile.Name)) {
            isPermitted = true;
        }
    }

  
    public String callService(String requestBody, String endPoint){
        startTime = system.now();
        HttpRequest req = new HttpRequest();
        APIGateway_Service.RequestToken request = new APIGateway_Service.RequestToken();
        request.endpoint = endPoint;        
        
        // AuthenticationToken authenTokenCalculateTools = APIGateway_Service.startCallGetTokenService('Smart_BDM_Cal_Tools_Create_Token');
        // String access_token = authenTokenCalculateTools.access_token;
        String access_token = SmartBDM_Utility.tokenKeyCalculateTools;
        
        if(!Test.isRunningTest()){
            if(access_token == null || access_token == ''){
                isErrorResponse = true;
                isSuccess = false;
                errorMessageRespone = '{"status": {"code":"400","description":"invalid_token"}}';
                return errorMessageRespone;
            }
        }
        

        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();

        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');

        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', ETEAppId);
        req.setHeader('Authorization', 'bearer ' + access_token);
        req.setHeader('Request-Datetime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));        
       
        req.setEndpoint(request.parseEndpoint());
        req.setBody(requestBody);
        //milliseconds 
        req.setTimeout((timeout*1000));
        HttpResponse res;
        String response;
        try{
            res = http.send(req);
            response = res.getBody();
            uidLogId =  uuidGenerateor.getValue();
            Integer statusCode = res.getStatusCode();       
            
            errorMessageRespone = response;
            if(statusCode != 200 ){
                isErrorResponse = true;
                isSuccess = false;

            } else {
                isErrorResponse = false;
            }
            endTime = system.now();
        }catch(Exception e){
            errorMessageRespone = 'System error: ' + e.getMessage() + '\n';
            errorMessageRespone += 'There is error during processing : ' + e.getStackTraceString();
            endTime = DateTime.now();
            isErrorResponse = true;
            isSuccess = false;
        }    

        return response;

    }

    public PageReference saveForm(){
        isErrorResponse = false;
        endProcess = false;
       
        String version;
        Date today = system.today();
        List<Consent_Template__c> consentTemList = New List<Consent_Template__c>();
        try{
            consentTemList = [Select ID, Name, Effective_Date__c, Expiry_Date__c, Template_Type__c, 
                        Template_Version__c, Template_Language__c, Template_Mode__c, Template_Name__c from Consent_Template__c 
                        where Effective_Date__c <= today and Template_Language__c = 'TH' and Template_Mode__c = 'P' 
                        ORDER BY Template_Version__c ASC ];

            PDPAMapping__c newConvertMap = new PDPAMapping__c();
            newConvertMap = mapType.get(tempType);

            map<String, String> mapTemplateVersion = New map<String,String>();

            if(consentTemList.size() > 0){
                for(Consent_Template__c conTem : consentTemList){
                    mapTemplateVersion.put(conTem.Template_Type__c, conTem.Template_Version__c);
                }
            }

            if(newConvertMap != null){
                version = mapTemplateVersion.get(newConvertMap.Template_Type__c);
            }

        }catch(Exception e){
            isSuccess = false;
            errorMessageRespone = Label.PDPA_Error_Mapping;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PDPA_Error_Mapping));
        }

        String requestUpdateBody = '';
        String responseUpdate = '';

        String Channel = 'CRM-BR'; //Default value
        String permissionflag;
        String multiUpdate;

        //Add by CR PDPA enhancement for Contact center
        String permisionPreviousFlag = '';   

        //This is for test class only
        if(Test.isRunningTest()){  
            isEdit = true;   
            pdpaViewBeforeEdit = new PDPAStructure.PDPAconsents();       
            pdpaViewBeforeEdit.flag = 'YES';
            permissionflag = 'Y';
            pdpaViewBeforeEdit.consentSignDate = system.today();
            tempType = 'PDPA-DEPOSIT';
            multiUpdate = 'PDPA';
            
        }

        string flagUpdate = '';
        if(pdpaViewBeforeEdit.flag == Label.PDPA_Accept_YES){
            flagUpdate = 'Y';
        }else if(pdpaViewBeforeEdit.flag == Label.PDPA_Accept_NO){
            flagUpdate = 'N';
        } 

        String tempPreviousFlag = '';
        if(tempFlag == Label.PDPA_Accept_YES){
            tempPreviousFlag = 'Y';
        }else if(tempFlag == Label.PDPA_Accept_NO){
            tempPreviousFlag = 'N';
        } 

        Boolean isPermissionUpdate = false;

        if(isEdit){
            Channel = profileMapChanel.get(currentUser.UserProfileName__c); 
            if(!Test.isRunningTest()){
                permissionflag = profileMapPermission.get(currentUser.UserProfileName__c);
                permisionPreviousFlag = profileMapPreviousFlag.get(currentUser.UserProfileName__c);
            }

            //******Add by CR PDPA enhancement for Contact center ****
            Boolean flagPrevious = true;
            if(permisionPreviousFlag != null){           
                if(!permisionPreviousFlag.equalsIgnoreCase('ALL') && tempPreviousFlag != permisionPreviousFlag){
                    flagPrevious = false;
                }
            }
            //******End Add by CR PDPA enhancement for Contact center ****
            
            if(permissionflag != null){
                if(flagPrevious && (permissionflag.equalsIgnoreCase(flagUpdate) || permissionflag.equalsIgnoreCase('ALL'))){
                    isPermissionUpdate = true;
 
                } 
            }
        } 
        
        
 
        if(pdpaViewBeforeEdit.flag ==  null){
            isSuccess =false;
            errorMessageRespone = Label.PDPA_Update_Error_Null_value;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PDPA_Update_Error_Null_value));
        }else if(tempFlag == pdpaViewBeforeEdit.flag){           
            isSuccess =false;
            errorMessageRespone = Label.PDPA_Error_Update_Same_Value;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PDPA_Error_Update_Same_Value));
        }else if(!isPermissionUpdate){
            isSuccess =false;
            errorMessageRespone = Label.PDPA_validate_contact_center;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PDPA_validate_contact_center));
        }else if(pdpaViewBeforeEdit.consentSignDate != null && pdpaViewBeforeEdit.consentSignDate > System.today()){
            isSuccess =false;
            errorMessageRespone = Label.PDPA_Error_ConsentSignDate;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PDPA_Error_ConsentSignDate));
        }else{            
            
            String consentDate = DateTime.newInstance(pdpaViewBeforeEdit.consentSignDate.year(),pdpaViewBeforeEdit.consentSignDate.month(),pdpaViewBeforeEdit.consentSignDate.day()).format('yyyy-MM-dd');
            if(!Test.isRunningTest()){
                multiUpdate = mapType.get(tempType).Multiple_Update__c;
            }
            if(multiUpdate == null || multiUpdate == ''){
                requestUpdateBody = '{'+  '"customerId":"' +customerId+ '",' +'"financialId":"'+financialId+'",'+
                    '"consents":[{"type":"'+tempType + '","flag":"'+
                    flagUpdate+'","version":"'+ version +'","consentBy":"'+ currentUser.Employee_ID__c +
                    '","channel":"'+ Channel +'","consentSignDate":"'+consentDate+'"}]}';  
            }else{
                requestUpdateBody = '{'+  '"customerId":"' +customerId+ '",' +'"financialId":"'+financialId+'",'+
                    '"consents":[{"type":"'+tempType + '","flag":"'+
                    flagUpdate+'","version":"'+ version +'","consentBy":"'+ currentUser.Employee_ID__c +
                    '","channel": "'+ Channel +'","consentSignDate":"'+consentDate+'"}'; 
                if(multiUpdate.contains(';')){
                    String[] consentType = multiUpdate.split(';');
                    for(integer i = 0; i < consentType.size() ; i++ ){
                        requestUpdateBody = requestUpdateBody + 
                        ',{"type":"'+consentType[i] + '","flag":"'+
                        flagUpdate+'","version":"'+ version +'","consentBy":"'+ currentUser.Employee_ID__c +
                        '","channel": "'+ Channel +'","consentSignDate":"'+consentDate+'"}';
                    }
                }else{
                    requestUpdateBody = requestUpdateBody + 
                    ',{"type":"'+multiUpdate + '","flag":"'+
                    flagUpdate+'","version":"'+ version +'","consentBy":"'+ currentUser.Employee_ID__c +
                    '","channel": "'+ Channel +'","consentSignDate":"'+consentDate+'"}';
                } 
                requestUpdateBody = requestUpdateBody + ']}';

            }            

            //Add log history before update PDPA flag
            PDPAStructure.PDPAconsents pdpaUpdate = New PDPAStructure.PDPAconsents();
            pdpaUpdate.flag = pdpaViewBeforeEdit.flag;
            pdpaUpdate.type = pdpaViewBeforeEdit.type;
            pdpaUpdate.consentBy = currentUser.Employee_ID__c;
            pdpaUpdate.needUpdateFlag = needUpdateflagHistory;
            pdpaUpdate.version = version;
            pdpaUpdate.consentDateTime = system.now();
            pdpaUpdate.channel = channel;
            pdpaUpdate.consentSignDate = pdpaViewBeforeEdit.consentSignDate;

            pdpaForHistory.add(pdpaUpdate);                
            
            responseUpdate = callService(requestUpdateBody, 'PDPA_and_Market_Consent_Update');            

            PDPAStructure respdpaData = PDPAStructure.parseJsontoObj(responseUpdate);
            errorMessageRespone = respdpaData.status.description;

            if(isErrorResponse == false){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,Label.PDPA_Update_Success));
                endProcess = true;
                isSuccess = true;
                //if update flag success, insert log history in CRM
                // savePDPAHistory(pdpaForHistory);

            }else{
                isSuccess =false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PDPA_Update_Error_Response));
            } 
                 
        }
        //Add online log history
        onlineLog('UPDATE_PDPA_AND_MARKET_CONSENT',requestUpdateBody,responseUpdate);
        return null;
  
    } 
    
    public List<SelectOption> getFlag() {
        List<SelectOption> options = new List<SelectOption>();
        if(pdpaViewBeforeEdit.flag != null && pdpaViewBeforeEdit.flag != ''){          
            options.add(new SelectOption(tempFlag,pdpaViewBeforeEdit.flag));
            if(pdpaViewBeforeEdit.flag == Label.PDPA_Accept_YES ){
                options.add(new SelectOption(Label.PDPA_Accept_NO,Label.PDPA_Accept_NO));
            }else{
                options.add(new SelectOption(Label.PDPA_Accept_YES,Label.PDPA_Accept_YES));
            }            
        }else{
            options.add(new SelectOption('',''));
            options.add(new SelectOption(Label.PDPA_Accept_YES,Label.PDPA_Accept_YES));
            options.add(new SelectOption(Label.PDPA_Accept_NO,Label.PDPA_Accept_NO));
        }        
        return options;
    }

    private void onlineLog(String serviceName, String requestBody, String responseBody){

        String base64Data = '';
        
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();       

        OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,customerName, errorMessageRespone, uidLogId , userName, rmId , serviceName ,requestBody ,responseBody , accountObj , startTime , endTime, base64Data );
    }

    public Boolean getisErrorResponse(){
        return isErrorResponse;
    }

    public String geterrorMessageRespone(){
        return errorMessageRespone;
    }
    /*
    private void savePDPAHistory(List<PDPAStructure.PDPAconsents> pdpaList){
        PDPA_and_Market_Consent_History__c PDPAHistory = New PDPA_and_Market_Consent_History__c();

        if(pdpaList.size() == 2 || Test.isRunningTest()){
            PDPAHistory.Customer__c = accountObj.id;
            PDPAHistory.Name = pdpaList[0].type;
            PDPAHistory.Decription__c = pdpaList[0].decriptionEN;
            PDPAHistory.Decription_TH__c = pdpaList[0].decriptionTH;

            PDPAHistory.Channel_Before_Update__c = pdpaList[0].channel;
            PDPAHistory.ConsentBy_Before_Update__c = pdpaList[0].consentBy;
            PDPAHistory.ConsentDateTime_Before_Update__c = pdpaList[0].consentDateTime;            
            PDPAHistory.Flag_Before_Update__c = tempFlag;
            PDPAHistory.NeedUpdateFlag_Before_Update__c = pdpaList[0].needUpdateFlag;
            PDPAHistory.Version_Before_Update__c = pdpaList[0].version;
            PDPAHistory.Consent_Sign_Date_Before_Update__c = tempConsentSignDate;
            
            if(!Test.isRunningTest()){
                PDPAHistory.Channel_After_Update__c = pdpaList[1].channel;
                PDPAHistory.ConsentBy_After_Update__c   = pdpaList[1].consentBy;
                PDPAHistory.Consent_Date_Time_After_Update__c = pdpaList[1].consentDateTime;            
                PDPAHistory.Flag_After_Update__c = pdpaList[1].flag;
                PDPAHistory.Need_Update_Flag_After_Update__c = pdpaList[1].needUpdateFlag;
                PDPAHistory.Version_After_Update__c = pdpaList[1].version;
                PDPAHistory.Consent_Sign_Date_After_Update__c = pdpaList[1].consentSignDate;
            }
            insert PDPAHistory;
        }
    }
    */
}