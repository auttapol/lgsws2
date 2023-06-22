public with sharing class CustomSearchUtilityBarController {
    
    public static List<Campaign_Member_Profile_Assignment__mdt> cmProfileAssign {
        get{
            if(cmProfileAssign == null)
            {
                cmProfileAssign = [SELECT Id,MasterLabel,DeveloperName,Profile_Name__c FROM Campaign_Member_Profile_Assignment__mdt];
            }
            return cmProfileAssign;
        }
        set;
    }

    @AuraEnabled
    public static List<CampaignMember> searchCampaignMember(String searchKey)
    {
        System.debug('searchKey:'+searchKey);
        List<CampaignMember> cmObjList = [SELECT Id,RTL_Marketing_Code__c,RTL_Web_Unique_ID__c FROM CampaignMember WHERE RTL_Marketing_Code__c =: searchKey OR Id =: searchKey OR RTL_Web_Unique_ID__c =: searchKey LIMIT 50 ];
        return cmObjList;
    }

    @AuraEnabled
    public static Boolean checkProfileAssign()
    {      
        try {
            Boolean checkProfileAssign;
            User currentUser = [SELECT Id,Profile.Name,LanguageLocaleKey,Zone__c,RTL_Branch__c,RTL_Channel__c,Region__c FROM User WHERE Id =:UserInfo.getUserId()];
            for(Campaign_Member_Profile_Assignment__mdt profileAssign : cmProfileAssign)
			{
				if(currentUser.Profile.Name.ToUpperCase() == profileAssign.Profile_Name__c.ToUpperCase())
				{
					checkProfileAssign = true;
					break;
				}
				else {
					checkProfileAssign = false;
				}
			}
            return checkProfileAssign;
        } catch (Exception e) {
            System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
            return null;
        }
    }
    
}