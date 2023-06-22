// public with sharing class fnaGenerateOTPCtrl {
//     public fnaGenerateOTPCtrl() {

//     }
// }

/*
 * Block comments with details of changes
 */
public without sharing class fnaGenerateOTPCtrl
{
    // protected final string USER_PREFIX    = User.sObjectType.getDescribe().getKeyPrefix();
    // protected final string ACCOUNT_PREFIX = Account.sObjectType.getDescribe().getKeyPrefix();
    @TestVisible
    private final static string FNA_ACTIVITY_PREFIX = FNA_Activity__c.sObjectType.getDescribe().getKeyPrefix();
    private static Boolean checkNewOTP = false;
    private static String otpMaster;
    private final static List<App_Config__mdt> RETRY_LIMIT = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'RETRY_LIMIT' LIMIT 1];
    private final static List<App_Config__mdt> EXPIRE_MIN = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'EXPIRE_MIN' LIMIT 1];
    // private final static integer RETRY_LIMIT = 3;
    // private final static integer EXPIRE_MIN = 5;

    @AuraEnabled
    public static OTP__c fnGenerateOTP(string fnaId){
        // fnaId = UrlHelper.decryptParams(fnaId);
        system.debug('fnaId : ' + fnaId);
        checkNewOTP = true;
        // string requestId = 'a3W0l00000060DAEAY';
        // generateRandomRef(4);
        // system.debug('generateRandomRef(4) is : ' + generateRandomRef(4));
        OTP__c otpRecord = requestOTP(fnaId); //FNA_Activity Id
        otpMaster = otpRecord.OTP_Master__c;
        system.debug('OTP Code is : ' + otpRecord.OTP_Code__c);
        system.debug('OTP Ref is : ' + otpRecord.Otp_Ref__c);
        return otpRecord;
    }

    @AuraEnabled
    public static Integer fnVerifyOTP(string fnaId, string otpCode){
        // fnaId = UrlHelper.decryptParams(fnaId);
        system.debug('fnaId : ' + fnaId);
        system.debug('otpCode : ' + otpCode);
        // string requestId = 'a3W0l00000060DAEAY';
        Integer result = verifyOTP(fnaId, otpCode); //FNA_Activity Id, OTP Code
        system.debug('OTP Code result is : ' + result);
        return result;
    }

    private static String getUser(string FNAId) {
        // User currentUser = [Select id , AccountId , ContactId From user Where  Id = : userId ];
        List<FNA_Activity__c> currentUser = [SELECT Id FROM FNA_Activity__c WHERE Id =: FNAId];
        return currentUser[0].Id;
    }
    /*
	* @description Returns OTP_Master__c Object
	* @param requestId the id of the user to look up
	* @return OTP_Master__c
	* @example
	*  OTP_Master__c otpms = createNewOtpMaster(user.Id);
	*/
    private static OTP_Master__c createNewOtpMaster(Id requestFNAId) {
        String userFNAId;
        // string accountId;
        // User user;
        if (((string)requestFNAId).startsWith(FNA_ACTIVITY_PREFIX)) {
            // User
            userFNAId 		= getUser(requestFNAId);
            // userId 		= user.Id;
            // accountId 	= user.AccountId;
        } else {
            // Account
            // userId = null;
            // accountId = requestId;
        }
        //Check field -> null
        OTP_Master__c otpms =  (OTP_Master__c)OTP_Master__c.sObjectType.newSObject(null, true);
        otpms.FNA_Activity__c = userFNAId;
        // otpms.Account__c = accountId;
        otpms.Secret_Key__c = OtpUtil.generateBase32Key();//<<==  Create particular user key
        system.debug('Secret Key : ' + otpms.Secret_Key__c);
        //Insert
        insert otpms;
        system.debug('otpms in createNewOtpMaster : ' + otpms);

        return otpms;
    }
    /*
	* @description get OTP Master for user
	* @param requestId the id of the user to look up
	* @return OTP_Master__c
	* @example
	*  OTP_Master__c otpms = getUserOtpMaster(user.Id);
	*/
    private static OTP_Master__c selectUserOtpMaster(Id FNAId) {
        OTP_Master__c otpms ;
        string filter = FNAId;
        if (((string)FNAId).startsWith(FNA_ACTIVITY_PREFIX)) {
            String userFNAId	= getUser(FNAId);
            filter = userFNAId;
        }
        List<OTP_Master__c> lstOtpms = [select Id , FNA_Activity__c, Secret_Key__c , Counter__c  From OTP_Master__c Where FNA_Activity__c = : filter limit 1];
        if (lstOtpms.size() > 0) {
            otpms = lstOtpms[0];
        }
        return otpms;
    }
    /*
	* @description get OTP Master for user or create new record if not existing record found
	* @param requestId the id of the user to look up
	* @return OTP_Master__c
	* @example
	*  OTP_Master__c otpms = getUserOtpMaster(user.Id);
	*/
    public static OTP_Master__c getUserOtpMaster(Id FNAId) {
        OTP_Master__c otpms;

        otpms = selectUserOtpMaster(FNAId);
        //Flow 1) Found OTP Master for specific user id
        if (null != otpms) {
            if (((string)FNAId).startsWith(FNA_ACTIVITY_PREFIX) && null == otpms.FNA_Activity__c) {
                otpms.FNA_Activity__c = FNAId;
                update otpms;
            }
            return otpms;
        }
        //Flow 2) Create new OTP Master for new request
        else {
            otpms = createNewOtpMaster(FNAId);
        }
        // system.debug('otpms')
        return otpms;
    }

    private static OTP__c getCurrentOTP(Id FNAId , string otpCode) {

        string filter = FNAId;
        if (((string)FNAId).startsWith(FNA_ACTIVITY_PREFIX)) {
            String userFNAId = getUser(FNAId);
            filter = userFNAId;
        }

        List<OTP__c> otps = [SELECT Id, Expire_DateTIme__c, IsExpired__c, IsUsed__c , Issue_DateTime__c ,
                             OTP_Code__c, OTP_Master__c , OTP_Master__r.FNA_Activity__c, Retry__c, Otp_Ref__c
                             FROM OTP__c
                             WHERE OTP_Code__c = : otpCode AND OTP_Master__r.FNA_Activity__c = : filter];

        if (otps.size() > 0) return otps[0];
        return null;
    }

    private static OTP__c createOtpRecord(Id otpMasterId , string otpCode) {
        OTP__c otp =  (OTP__c)OTP__c.sObjectType.newSObject(null, true);
        // List<OTP__c> otp = [SELECT Id, IsExpired__c, IsUsed__c, Issue_DateTime__c, OTP_Code__c, Otp_Ref__c, OTP_Master__c, Retry__c, Expire_DateTime__c FROM OTP__c];
        otp.OTP_Master__c = otpMasterId;
        otp.OTP_Code__c = otpCode;
        otp.Otp_Ref__c = OtpUtil.generateRandomRef(4);
        system.debug('otp.Otp_Ref__c in createOtpRecord : ' + otp.Otp_Ref__c);
        DateTime cdt = Datetime.now();
        otp.Issue_DateTime__c = cdt;
        otp.Expire_DateTIme__c = cdt.addMinutes(Integer.valueOf(EXPIRE_MIN[0].Value__c));
        insert otp;

        return otp;
    }

    @TestVisible
    private static OTP_Master__c increaseCounter(OTP_Master__c otpms) {
        system.debug('otpms in increaseCounter : ' + otpms);
        otpms.Counter__c += 1;
        update otpms;
        return otpms;
    }

    @testVisible
    private static string createOTP(OTP_Master__c otpms) {
        string otpCode;
        system.debug('otpms in createOTP : ' + otpms);
        Long counter = (Long) otpms.Counter__c;
        system.debug('User key : ' + otpms.Secret_Key__c);
        system.debug('Current Couter : ' + counter);
        otpCode = OtpUtil.generateOTP(otpms.Secret_Key__c, counter);
        system.debug('New OTP : ' + otpCode);
        return otpCode;
    }

    /**
	* @description 
	* @param requestId is account id or userid
	* @return OTP__c record
	*/ 
    public static OTP__c requestOTP(Id requestId) {
        //1 Check current OTP and Is It valide
        OTP_Master__c otpms = getUserOtpMaster(requestId);
        system.debug('OTP_Master__c otpms : ' + otpms);
        // system.debug('OTP_Master__c otpms.Counter__c : ' + otpms.Counter__c);
        string otpCode = createOTP(otpms);
        system.debug('Current OTP : ' + otpCode);
        //Get OTP Record
        OTP__c otpRecord = getCurrentOTP(requestId, otpCode);
        DateTime cdt = Datetime.now();

        //Flow 1)  Create New OTP Record
        if (null == otpRecord ) {
        // if (null == otpRecord ) {
            // otpms = increaseCounter(otpms);
            // otpCode = createOTP(otpms);
            otpRecord = createOtpRecord(otpms.Id , otpCode);
        }
        //Flow 2)  Existing OTP Record
        else {
            // Condition 2.1 ) OTP Record invalid
            if (otpRecord.IsUsed__c || otpRecord.IsExpired__c || checkNewOTP == true) {
                // Create New Record
                otpms = increaseCounter(otpms);
                otpCode = createOTP(otpms);
                //>Creat new OTP
                otpRecord = createOtpRecord(otpms.Id , otpCode);
                checkNewOTP = false;

            } else { // Condition 2.2 ) OTP Still Valid
                //>Time Condition
                Long milliseconds = otpRecord.Expire_DateTime__c.getTime()  - cdt.getTime() ;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                //>Retry Condition
                boolean isExceedLimit = otpRecord.Retry__c > Integer.valueOf(RETRY_LIMIT[0].Value__c) ? true : false;
                // Condition 2.2.1 ) Valide less than 1 min or exceed retry
                if (minutes < 1L/* less than 1 min*/  ||  isExceedLimit) {
                    if (isExceedLimit) {otpRecord.IsUsed__c = true;}
                    if (minutes < 1L) {otpRecord.IsExpired__c = true;}
                    update otpRecord;
                    otpms = increaseCounter(otpms);
                    otpCode = createOTP(otpms);
                    //>Creat new OTP
                    otpRecord = createOtpRecord(otpms.Id , otpCode);
                    checkNewOTP = false;
                }
            }
        }
        return otpRecord;
    }
    public static Integer verifyOTP(Id requestId, string otpCode) {
        Datetime cdt = DateTime.now();
        //System Current OTP
        OTP_Master__c otpms = getUserOtpMaster(requestId);
        string userCurrentOtp = createOTP(otpms);
        System.debug('userCurrentOtp : '+ userCurrentOtp);
        System.debug('requestId : '+ requestId);

        OTP__c otp = getCurrentOTP( requestId , userCurrentOtp);
        System.debug('OTP : '+ otp);

        List<OTP_Master__c> checkOTP = [SELECT (SELECT Id, IsUsed__c, OTP_Code__c, Otp_Ref__c FROM OTP__r WHERE OTP_Code__c =: otpCode ORDER BY CreatedDate DESC), FNA_Activity__c FROM OTP_Master__c WHERE FNA_Activity__c =: otpms.FNA_Activity__c];
        // List<OTP__c> checkOTP = [SELECT Id, IsUsed__c, OTP_Code__c, Otp_Ref__c, OTP_Master__c FROM OTP__c WHERE OTP_Master__c =: otp.OTP_Master__c AND OTP_Code__c =: otpCode];
        Boolean checkOTPBool = false;
        
        for(OTP_Master__c checkOTPMasterCondition : checkOTP){
            system.debug('checkOTPMasterCondition : ' + checkOTPMasterCondition);
            for(OTP__c checkOTPCondition : checkOTPMasterCondition.OTP__r){
                if(checkOTPCondition.OTP_Code__c == otpCode && checkOTPCondition.Id == otp.Id){
                    checkOTPBool = true;
                    // system.debug('checkOTPCondition : ' + checkOTPCondition);
                }
            }
        }

        if (null == otp) {
            system.debug('Please request the new OTP');
            return 1;
        } else if (( otp.IsUsed__c || !checkOTP[0].OTP__r.isEmpty() ) && checkOTPBool == false) {
            system.debug('Cannot use old OTP Code');
            otp.Retry__c += 1;
            update otp;
            return 2;
        } else {
            boolean isMatch    = userCurrentOtp == otpCode;
            boolean isExpire   = cdt > otp.Expire_DateTIme__c;
            boolean isMaxReTry = otp.Retry__c >= (Integer.valueOf(RETRY_LIMIT[0].Value__c) - 1);
            boolean isUsed = otp.IsUsed__c;
            if (isExpire) {
                otp.IsExpired__c = true;
                otp.IsUsed__c = true;
                update otp;
                system.debug('OTP Code was expired');
                return 3;
            }
            if (isMaxReTry) {
                otp.IsUsed__c = true;
                update otp;
                system.debug('OTP Code was hit max retry');
                return 4;
            }

            if (!isMatch) {
                otp.Retry__c += 1;
                system.debug('OTP Code miss match');
                update otp;
                return 5;
            }
            if (isUsed) {
                system.debug('Cannot use old OTP Code');
                return 6;
            }
        }
        //Every Things OK

        system.debug('Verify success');
        otp.IsExpired__c = false;
        otp.IsUsed__c = true;
        update otp;
        increaseCounter(otpms);
        system.debug('Counter : ' + otpms.Counter__c);
        return 7;
    }


}