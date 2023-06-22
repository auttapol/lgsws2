public without sharing class CaseAutoCreateTriggerHandler {
    public static void afterUpdate(List<Id> chatSessionIdList, Map<Id, AgentWork> chatworkMap) {
        List<iigproduct_2__ChatSession__c> chatSessionList = [
            SELECT
                Id,
                iigproduct_2__Subject__c,
                iigproduct_2__Social_ID__r.iigproduct_2__Social_Type__c,
                iigproduct_2__Social_ID__r.iigproduct_2__Display_Name__c,
                iigproduct_2__Social_ID__r.iigproduct_2__Phone_Number__c,
                iigproduct_2__Social_ID__r.iigproduct_2__Email__c,
                iigproduct_2__Status__c,
                iigproduct_2__Case__c,
                Accept_Datetime__c,
                Assign_Datetime__c
            FROM iigproduct_2__ChatSession__c
            // WHERE Id IN :chatSessionIdList AND iigproduct_2__Social_ID__r.iigproduct_2__Social_Type__c = 'ttb Website'
            WHERE Id IN :chatSessionIdList AND iigproduct_2__Case__c = NULL
        ];

        // map of chatSessionId to Case
        Map<Id, Case> mapSessioIdToCase = new Map<Id, Case>();

        // skill master
        Map<String, Skill_Master__c> skillMasterMapWeb = new Map<String, Skill_Master__c>();

        List<Skill_Master__c> skillListWeb = [
            SELECT Id, Topic__c, Segment__c, Service_Level1__c, Service_Level2__c, Validate_Code__c
            FROM Skill_Master__c
            WHERE Source__c = 'Chat - ttb Web'
        ];

        List<Skill_Master__c> skillListLine = [
            SELECT Id, Topic__c, Segment__c, Service_Level1__c, Service_Level2__c, Validate_Code__c
            FROM Skill_Master__c
            WHERE Source__c = 'Chat - Line'
        ];

        List<Skill_Master__c> skillListFacebook = [
            SELECT Id, Topic__c, Segment__c, Service_Level1__c, Service_Level2__c, Validate_Code__c
            FROM Skill_Master__c
            WHERE Source__c = 'Chat - Facebook'
        ];

        for (Skill_Master__c s : skillListWeb) {
            skillMasterMapWeb.put(s.Topic__c, s);
        }

        for (iigproduct_2__ChatSession__c chatSession : chatSessionList) {
            Case thisCase = new Case();
            thisCase.Status = 'New';
            thisCase.Subject = chatSession.iigproduct_2__Subject__c;
            thisCase.Contact_Person_Name__c = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Display_Name__c;
            thisCase.Contact_Person_Phone__c = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Phone_Number__c;
            thisCase.Contact_Person_Email__c = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Email__c;
            String socialType = chatSession.iigproduct_2__Social_ID__r.iigproduct_2__Social_Type__c;
            if (socialType == 'ttb Website') {
                socialType = 'Chat - ttb Web';
                if (skillMasterMapWeb.containsKey(thisCase.Subject)) {
                    thisCase.PTA_Segment__c = skillMasterMapWeb.get(thisCase.Subject).Segment__c;
                    thisCase.Category__c = skillMasterMapWeb.get(thisCase.Subject).Service_Level1__c;
                    thisCase.Sub_Category__c = skillMasterMapWeb.get(thisCase.Subject).Service_Level2__c;
                    // thisCase.Service_Type_Matrix_Code__c = skillMasterMapWeb.get(thisCase.Subject).Validate_Code__c;
                }
            } else if (socialType == 'Line') {
                socialType = 'Chat - Line';
                thisCase.Subject = skillListLine[0].Topic__c;
                thisCase.PTA_Segment__c = skillListLine[0].Segment__c;
                thisCase.Category__c = skillListLine[0].Service_Level1__c;
                thisCase.Sub_Category__c = skillListLine[0].Service_Level2__c;
                // thisCase.Service_Type_Matrix_Code__c = skillListLine[0].Validate_Code__c;
            } else if (socialType == 'Facebook') {
                socialType = 'Chat - Facebook';
                thisCase.Subject = skillListFacebook[0].Topic__c;
                thisCase.PTA_Segment__c = skillListFacebook[0].Segment__c;
                thisCase.Category__c = skillListFacebook[0].Service_Level1__c;
                thisCase.Sub_Category__c = skillListFacebook[0].Service_Level2__c;
                // thisCase.Service_Type_Matrix_Code__c = skillListFacebook[0].Validate_Code__c;
            }
            thisCase.Origin = socialType;
            // thisCase.Current_Service_Template__c = 'General';
            mapSessioIdToCase.put(chatSession.Id, thisCase);

            if (chatworkMap.containsKey(chatSession.Id) && chatSession.Accept_Datetime__c == null && chatSession.Assign_Datetime__c == null) {
                chatSession.Accept_Datetime__c = chatworkMap.get(chatSession.Id).AcceptDateTime;
                chatSession.Assign_Datetime__c = chatworkMap.get(chatSession.Id).AssignedDateTime;
            }
        }

        List<iigproduct_2__ChatSession__c> caseSessionList = [
            SELECT Id, iigproduct_2__Case__c, iigproduct_2__Case__r.OwnerId
            FROM iigproduct_2__ChatSession__c
            WHERE Id IN :chatSessionIdList AND iigproduct_2__Case__c != NULL
        ];


        Id currUserId = UserInfo.getUserId();
        Set<Id> caseToUpdate = new Set<Id>();
        for (iigproduct_2__ChatSession__c chat : caseSessionList) {
            if (currUserId != chat.iigproduct_2__Case__r.OwnerId) {
                caseToUpdate.add(chat.iigproduct_2__Case__c);
            }
        }

        List<Case> changedOwnerCase = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseToUpdate];
        for (Case eachCase : changedOwnerCase) {
            eachCase.OwnerId = currUserId;
        }
        
        if (!changedOwnerCase.isEmpty()){
            update changedOwnerCase;
            System.debug('---case owner changed---');
        }

        if (Case.sObjectType.getDescribe().isCreateable() || Case.sObjectType.getDescribe().isUpdateable()) {
            upsert mapSessioIdToCase.values();
        }

        for (iigproduct_2__ChatSession__c thisChatSession : chatSessionList) {
            Case mapCase = mapSessioIdToCase.get(thisChatSession.Id);
            thisChatSession.iigproduct_2__Case__c = mapCase.Id;
            if (thisChatSession.iigproduct_2__Status__c == 'Waiting') {
                thisChatSession.iigproduct_2__Status__c = 'Inprogress';
            }
            System.debug('changed session');
        }
        
        update chatSessionList;
        
    }

    /*
    public static void afterUpdateForSocialPost(List<Id> socialPostIdList, Map<Id, AgentWork> postworkMap) {
        if (!socialPostIdList.isEmpty()) {
            Case newCase = null;
            Case mapCase = null;
            Skill_Master__c currentSkillMaster = null;
            Map<Id, Case> mapSocialPostIdWithCase = new Map<Id, Case>();
            List<Social_Post__c> socialPostToUpdateList = new List<Social_Post__c>();

            // Find skill master information
            Map<String, Skill_Master__c> skillMasterMap = new Map<String, Skill_Master__c>();
            for (Skill_Master__c skillMaster : [SELECT id, Topic__c, Source__c, Segment__c, Assign_to_Queue__c, Service_Level1__c, Service_Level2__c, Service_Level3__c, Problem_Type__c, Social_Network__c, Topic_Profile_Name__c 
                                                    FROM Skill_Master__c 
                                                    WHERE Assign_to_Queue__c like 'Post%']) {

                skillMasterMap.put(skillMaster.Topic_Profile_Name__c, skillMaster);
            }
            
            List<Social_Post__c> socialPostList = [SELECT id, Topic_Profile_Name__c, Social_Post_Author__r.Post_Author_Name__c
                                                    FROM Social_Post__c 
                                                    WHERE id in :socialPostIdList];

            for (Social_Post__c socialPost : socialPostList) {
                System.debug('SocialPost :: ' + socialPost.id);

                currentSkillMaster = skillMasterMap.get(socialPost.Topic_Profile_Name__c);
                
                // Create new Case
                newCase = new Case();
                newCase.Status = 'New';
                newCase.Contact_Person_Name__c = socialPost.Social_Post_Author__r.Post_Author_Name__c;
                newCase.Subject = currentSkillMaster.Topic__c;
                newCase.PTA_Segment__c = currentSkillMaster.Segment__c;
                newCase.Category__c = currentSkillMaster.Service_Level1__c;
                newCase.Sub_Category__c = currentSkillMaster.Service_Level2__c;
                newCase.Origin = currentSkillMaster.Social_Network__c;

                mapSocialPostIdWithCase.put(socialPost.Id, newCase);
            }

            if (Case.sObjectType.getDescribe().isCreateable() || Case.sObjectType.getDescribe().isUpdateable()) {
                upsert mapSocialPostIdWithCase.values();
            }

            for (Social_Post__c socialPost : socialPostList) {
                mapCase = mapSocialPostIdWithCase.get(socialPost.Id);
                socialPost.Case__c = mapCase.Id;

                // Update datetime field when accept AgentWork
                if (postworkMap.containsKey(socialPost.Id)) {
                    socialPost.Accept_Datetime__c = postworkMap.get(socialPost.Id).AcceptDateTime;
                    socialPost.Assign_Datetime__c = postworkMap.get(socialPost.Id).AssignedDateTime;
                }
            }

            update socialPostList;
        }

    }
    */

    public static void afterUpdateForCase(List<Id> caseIdList, Map<Id, AgentWork> caseworkMap) {
        if (!caseIdList.isEmpty()) {
            List<Case> caseList = [SELECT Id, SourceId, Accept_Datetime__c FROM Case WHERE Id IN :caseIdList];
            List<Case> eList = new List<Case>();
            if (!caseList.isEmpty()) {
                for (Case c : caseList) {
                    Schema.SObjectType sourceObjectType = c.SourceId.getSObjectType();
                    if (Schema.EmailMessage.getSObjectType() == sourceObjectType && caseworkMap.containsKey(c.Id) && c.Accept_Datetime__c == null) {
                        c.Accept_Datetime__c = caseworkMap.get(c.Id).AcceptDateTime;
                        eList.add(c);
                    }
                }
                update eList;
            }
        }
    }
}