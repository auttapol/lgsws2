@isTest
public without sharing class ReferralUtility_Test {
	static List<Branch_And_Zone__c> branchAndZoneList;
    
    static {
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
    }
    @isTest
    private static void Test_createReferral() {
        TestUtils.createAppConfig();
        TestUtils.createAppConfig_Trigger();

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Downloaded__c = false;
        fnaActivity.Branch__c = '001';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        RTLProductMaster.FNA_Assigned_Pool__c = 'OUTBOUND';
        listRTLProductMaster.add(RTLProductMaster);
        insert listRTLProductMaster;

        List<FNA_Product_Mapping__c> listProductMapping = new List<FNA_Product_Mapping__c>();
        FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
        productMapping.Product__c = listRTLProductMaster[0].Id;
        listProductMapping.add(productMapping);
        insert listProductMapping;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = false;
        productOffering.FNA_Product_Name__c = listProductMapping[0].Id;
        productOffering.FNA_Activity__c = listFnaAct[0].Id;
        productOffering.Flag_Highlight__c = true;
        listProductOffering.add(productOffering);
        insert listProductOffering;

        String FnaActivityId = listFnaAct[0].Id;
        String sessionData = listRTLProductMaster[0].Id;
        ReferralUtility.createReferral(FnaActivityId, sessionData);
    }

    @isTest
    private static void Test_createReferral_2() {
        TestUtils.createAppConfig();
        TestUtils.createAppConfig_Trigger();

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Downloaded__c = false;
        fnaActivity.Branch__c = '001';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        RTLProductMaster.FNA_Assigned_Pool__c = 'RMC';
        listRTLProductMaster.add(RTLProductMaster);
        insert listRTLProductMaster;

        List<FNA_Product_Mapping__c> listProductMapping = new List<FNA_Product_Mapping__c>();
        FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
        productMapping.Product__c = listRTLProductMaster[0].Id;
        listProductMapping.add(productMapping);
        insert listProductMapping;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = false;
        productOffering.FNA_Product_Name__c = listProductMapping[0].Id;
        productOffering.FNA_Activity__c = listFnaAct[0].Id;
        productOffering.Flag_Highlight__c = true;
        listProductOffering.add(productOffering);
        insert listProductOffering;

        String FnaActivityId = listFnaAct[0].Id;
        String sessionData = listRTLProductMaster[0].Id;
        ReferralUtility.createReferral(FnaActivityId, sessionData);
    }

    @isTest
    private static void Test_createReferral_3() {
        TestUtils.createAppConfig();
        TestUtils.createAppConfig_Trigger();
        
        List<AppConfig__c> listAconfig = new List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runReferralTrigger';
        Aconfig.Value__c = 'true';
        listAconfig.add(Aconfig);
        insert listAconfig;

        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        fnaActivity.Avatar_Downloaded__c = false;
        fnaActivity.Branch__c = '001';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        RTLProductMaster.FNA_Assigned_Pool__c = 'INBOUND';
        RTLProductMaster.RTL_Product_Group_Upper__c = 'LOAN';
        listRTLProductMaster.add(RTLProductMaster);
        insert listRTLProductMaster;

        List<FNA_Product_Mapping__c> listProductMapping = new List<FNA_Product_Mapping__c>();
        FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
        productMapping.Product__c = listRTLProductMaster[0].Id;
        listProductMapping.add(productMapping);
        insert listProductMapping;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = false;
        productOffering.FNA_Product_Name__c = listProductMapping[0].Id;
        productOffering.FNA_Activity__c = listFnaAct[0].Id;
        productOffering.Flag_Highlight__c = true;
        listProductOffering.add(productOffering);
        insert listProductOffering;

        Branch_and_Zone__c baz = new Branch_and_Zone__c();
        baz.Branch_Code__c = '123';
        baz.IsActive__c = true;
        insert baz;

        String FnaActivityId = listFnaAct[0].Id;
        String sessionData = listRTLProductMaster[0].Id;
        try{
            ReferralUtility.createReferral(FnaActivityId, sessionData);
        }catch(Exception ex){
            
        }
        
    }
}