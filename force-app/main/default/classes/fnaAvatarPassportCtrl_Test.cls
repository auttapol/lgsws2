@isTest
public without sharing class fnaAvatarPassportCtrl_Test {

    static fnaAvatarPassportCtrl testClass;

    @isTest
    private static void Test_fnaAvatarPassportCtrl() {
        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        System.currentPageReference().getParameters().put('Id',String.valueOf(listFnaAct[0].Id));

        testClass = new fnaAvatarPassportCtrl();
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        testClass.strImageBlob = EncodingUtil.base64Encode(myBlob);
        testClass.imageSharing = 'Image Sharing';
        testClass.saveScreenShot();
    }
}