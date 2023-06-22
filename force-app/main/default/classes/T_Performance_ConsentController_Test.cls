@isTest
public with sharing class T_Performance_ConsentController_Test {
    public static final Id SYSADMIN_PROFILE_ID{
        get
        {
            if(SYSADMIN_PROFILE_ID == null){
                SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            }
            return SYSADMIN_PROFILE_ID;
        }
        set;
    }
    
    public static final Id TMB_SYSADMIN_PROFILE_ID{
        get
        {
            if(TMB_SYSADMIN_PROFILE_ID == null){
                TMB_SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB System Administrator' LIMIT 1].Id;
            }
            return TMB_SYSADMIN_PROFILE_ID;
        }
        set;
    }

    @isTest static void testGetListContentVersion(){
        PageReference pageRef = Page.T_Performance_ConsentPage;
        Test.setCurrentPage(pageRef);
        pageRef.setRedirect(true);  
        ContentFolderItem cfi = new ContentFolderItem();
        /* cfi.IsDeleted = false;
        cfi.IsFolder = false;
        cfi.ParentContentFolderId = 'testhaha'; */
        List<ContentVersion> cv = [SELECT VersionData,ContentDocumentId, FileExtension, Title , LastModifiedDate FROM ContentVersion LIMIT 1];
        T_Performance_ConsentController.getListContentVersion('');
        /* T_Performance_ConsentController.getListContentVersion('T-Performance'); */
        T_Performance_ConsentController.getPDF();
    }
}