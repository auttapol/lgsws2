@isTest
public without sharing class fnaGenerateOTPCtrl_Test {

    @isTest
    private static void Test_fnGenerateOTP() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<OTP_Master__c> listOTPMaster = new List<OTP_Master__c>();
        OTP_Master__c OTPMaster = new OTP_Master__c();
        OTPMaster.FNA_Activity__c = listFnaAct[0].Id;
        OTPMaster.Secret_Key__c = 'RFDSYEPQYBF5OYCFSWTUIHU3YMY6UK37';
        OTPMaster.Counter__c = 1;
        listOTPMaster.add(OTPMaster);
        insert listOTPMaster;

        // OTP_Master__c OTPMaster_2 = new OTP_Master__c();
        // OTPMaster_2.FNA_Activity__c = listFnaAct[1].Id;
        // OTPMaster_2.Secret_Key__c = 'RFDSYEPQYBF5OYCFSWTUIHU3YMY6UK37';
        // OTPMaster_2.Counter__c = 1;
        // listOTPMaster.add(OTPMaster_2);
        // insert listOTPMaster;

        // List<OTP__c> listOTP = new List<OTP__c>();
        // OTP__c OTP = new OTP__c();
        // OTP.OTP_Master__c = listOTPMaster[1].Id;
        // OTP.IsUsed__c = true;
        // listOTP.add(OTP);
        // insert listOTP;

        fnaGenerateOTPCtrl.fnGenerateOTP(listFnaAct[0].Id);
    }

    @isTest
    private static void Test_fnVerifyOTP() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String FNAId = listFnaAct[0].Id;
        String otpCode = '123456';
        fnaGenerateOTPCtrl.fnVerifyOTP(FNAId, otpCode);
    }

    @isTest
    private static void Test_fnVerifyOTP_2() {

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;
        
        // fnaGenerateOTPCtrl.FNA_ACTIVITY_PREFIX = (String)listFnaAct[0].Id;

        List<OTP_Master__c> listOTPMaster = new List<OTP_Master__c>();
        OTP_Master__c OTPMaster = new OTP_Master__c();
        OTPMaster.FNA_Activity__c = listFnaAct[0].Id;
        OTPMaster.Secret_Key__c = 'RFDSYEPQYBF5OYCFSWTUIHU3YMY6UK37';
        OTPMaster.Counter__c = 0;
        listOTPMaster.add(OTPMaster);
        insert listOTPMaster;

        List<OTP__c> listOTP = new List<OTP__c>();
        OTP__c OTP = new OTP__c();
        OTP.OTP_Master__c = listOTPMaster[0].Id;
        OTP.IsUsed__c = true;
        OTP.OTP_Code__c = '006415';
        listOTP.add(OTP);
        insert listOTP;

        String FNAId = listFnaAct[0].Id;
        String otpCode = '006415';
        fnaGenerateOTPCtrl.fnVerifyOTP(FNAId, otpCode);

        OTP_Master__c OTPMaster_2 = new OTP_Master__c();
        OTPMaster_2 = fnaGenerateOTPCtrl.increaseCounter(listOTPMaster[0]);
    }

    @isTest
    private static void Test_requestOTP() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;


        List<OTP_Master__c> listOTPMaster = new List<OTP_Master__c>();
        OTP_Master__c OTPMaster = new OTP_Master__c();
        OTPMaster.FNA_Activity__c = listFnaAct[0].Id;
        OTPMaster.Secret_Key__c = 'RFDSYEPQYBF5OYCFSWTUIHU3YMY6UK37';
        OTPMaster.Counter__c = 0;
        listOTPMaster.add(OTPMaster);
        insert listOTPMaster;

        List<OTP__c> listOTP = new List<OTP__c>();
        OTP__c OTP = new OTP__c();
        OTP.OTP_Master__c = listOTPMaster[0].Id;
        OTP.IsUsed__c = true;
        OTP.IsExpired__c = true;
        OTP.OTP_Code__c = '006415';
        listOTP.add(OTP);
        insert listOTP;

        String FNAId = listFnaAct[0].Id;

        fnaGenerateOTPCtrl.fnGenerateOTP(FNAId);

        // fnaGenerateOTPCtrl.requestOTP(FNAId);
    }
}