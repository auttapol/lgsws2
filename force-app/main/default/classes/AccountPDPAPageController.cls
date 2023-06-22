public class AccountPDPAPageController {
    public Account acct {get; set;}
    public User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Employee_ID__c, RTL_Branch_Code__c FROM User WHERE ID =: Userinfo.getUserID() LIMIT 1];
            }
            return currentUser;
        }
        set;
    }

    public Blob encryptKey {
        get{
            if(encryptKey == null){
                encryptKey = AppConfig__c.getValues('PDPA_ENCRYPT_KEY') != null ? Blob.valueOf(AppConfig__c.getValues('PDPA_ENCRYPT_KEY').Value__c) : Blob.valueOf('fortestsmartqfortestsmartqfortes');
            }
            return encryptKey;
        }set;
    }

    public Blob encryptIV {
        get{
            if(encryptIV == null){
                encryptIV = AppConfig__c.getValues('PDPA_ENCRYPT_IV') != null ? Blob.valueOf(AppConfig__c.getValues('PDPA_ENCRYPT_IV').Value__c) : Blob.valueOf('ivkeytestforsmar');
            }
            return encryptIV;
        }set;
    }

    public String canvasParams {get; set;}
    public String pdpatype {get; set;}
    public String tmbid {get; set;}
    public String customerId {get; set;}
    public String consentLanguage {get; set;}
    public String consentType {get; set;}
    public String idType {get; set;}
    public String IdNumberEncrypt {get; set;}
    public Boolean isShowCanvase {get; set;}
    public Boolean isError {get; set;}
    public Boolean showPorcess {get; set;}

    public class F2FTokenResponse {
        public F2FTokenResponseStatus status {get;set;}
        public F2FTokenResponseData data {get;set;}   
    }

    public class F2FTokenResponseStatus {
        public String code {get;set;}
        public String description {get;set;}
    }

    public class F2FTokenResponseData {
        public String consentUrl {get;set;}
        public String formUrl {get;set;}
        public Boolean isCorrect {get;set;}
        public String token {get;set;}
    }

    public AccountPDPAPageController(ApexPages.StandardController std){
        acct = (Account)std.getRecord();
        isShowCanvase = false;
        showPorcess = false;
        isError = false;

        pdpatype = apexpages.currentpage().getparameters().get('pdpatype');
        tmbid = apexpages.currentpage().getparameters().get('tmbid');

        acct = [SELECT Id, Name, TMB_Customer_ID_PE__c, ID_Number_PE__c, First_name_PE__c, First_Name_ENG_PE__c, Last_Name_PE_Eng__c, Last_name_PE__c, ID_Type_PE__c FROM Account WHERE Id = :acct.id];

        customerId = acct.TMB_Customer_ID_PE__c == null ? '' : acct.TMB_Customer_ID_PE__c;
        consentLanguage = acct.ID_Type_PE__c == 'Citizen ID' ? 'TH' : 'EN';
        consentType = pdpatype == 'Market Conduct' ? 'MARKET' : pdpatype == 'PDPA' ? 'PDPA' : '';
        idType = acct.ID_Type_PE__c == 'Citizen ID' ? 'CI' : acct.ID_Type_PE__c == 'Passport ID' ? 'PP' : '';
        IdNumberEncrypt = idType == '' ? '' : acct.ID_Number_PE__c == null ? '' : encryptAES256(acct.ID_Number_PE__c);
    }
    
    public String encryptAES256(String data){
        return EncodingUtil.base64Encode(Crypto.encrypt('AES256', encryptKey, encryptIV, Blob.valueOf(data)));
    }
    
    public void showCanvas(){
        String closeAction = 'canvasPublish(\'close\');';
        String closeActionType = 'javascript';
        String consentAction = 'maintenance';
        String staffId = currentUser.Employee_ID__c == null ? '': currentUser.Employee_ID__c;
        String branchCode = currentUser.RTL_Branch_Code__c == null ? '' : currentUser.RTL_Branch_Code__c;
        String firstName = consentLanguage == 'TH' ? acct.First_name_PE__c == null ? '' : acct.First_name_PE__c : acct.First_Name_ENG_PE__c == null ? '' : acct.First_Name_ENG_PE__c;
        String lastName  = consentLanguage == 'TH' ? acct.Last_name_PE__c == null ? '' : acct.Last_name_PE__c : acct.Last_Name_PE_Eng__c == null ? '' : acct.Last_Name_PE_Eng__c;
        if(showPorcess) ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'GET Token..'));

        String result = pdpaCalloutUtil.getPDPAF2FServiceToken(closeAction, closeActionType, consentAction, consentType, customerId, staffId, branchCode, consentLanguage, firstName, lastName, idType, IdNumberEncrypt);

        try {
            F2FTokenResponse resp = (F2FTokenResponse) JSON.deserialize(result, F2FTokenResponse.class);
            System.debug('resp  : ' + resp);
            if(resp.status != null && resp.status.code != null && resp.status.code == '0000'){
                isShowCanvase = true;
                isError = false;
                canvasParams = '{token:"' + resp.data.token + '"}';
    
                if(showPorcess) ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Token: ' + canvasParams));
            }else{
                isError = true;
                if(showPorcess) ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Get token error.'));
            }
        } catch (Exception e) {
            System.debug(e);
            isError = true;
            if(showPorcess) ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Get token error.'));
        }
    }
}