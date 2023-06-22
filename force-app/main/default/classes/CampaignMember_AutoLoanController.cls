public with sharing class CampaignMember_AutoLoanController {

    private static Map<String,Campaign_Member_allow_edit_Profile__mdt> cmAllowEditProfile {
        get
        {
            if(cmAllowEditProfile == null){
                cmAllowEditProfile = new Map<String,Campaign_Member_allow_edit_Profile__mdt>();
                List<Campaign_Member_allow_edit_Profile__mdt> cmAllowEditList = [SELECT Profile__c FROM Campaign_Member_allow_edit_Profile__mdt];
                for(Campaign_Member_allow_edit_Profile__mdt cmAllow :cmAllowEditList)
                {
                    cmAllowEditProfile.put(cmAllow.Profile__c,cmAllow);
                }          
            }
            return cmAllowEditProfile;
        }
        set;
    }

    @AuraEnabled
    public static Boolean checkPermissionToEdit(String recordId){
        try {
            Boolean isPermission = false;
            Id profileId = Userinfo.getProfileId();
            String profileName = [SELECT Id,Name FROM Profile WHERE Id =: profileId].Name;
            CampaignMember cm = [SELECT Id,Campaign.Status,RTL_Contact_Method__c,RTL_Is_Interface_Success__c,RTL_Is_Send_To_HPAP__c FROM CampaignMember WHERE Id =: recordId];
            System.debug('profileName:'+profileName);
            System.debug('cm:'+cm);
            System.debug('cmAllowEditProfile:'+cmAllowEditProfile);
            if(cm != null)
            {
                if(cm.RTL_Contact_Method__c == 'AL Sales' && cm.RTL_Is_Interface_Success__c == false 
                && cm.RTL_Is_Send_To_HPAP__c == false && cmAllowEditProfile.containsKey(profileName) && cm.Campaign.Status != 'Expired')
                {
                    isPermission = true;
                }
            }
            System.debug('isPermission:'+isPermission);
            return isPermission;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}