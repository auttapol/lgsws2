public class LiveChatTranscriptTriggerHandler {
    
    //CR Non-Voice
    static Map<String,Skill_Master__c> skillMasterMap = new Map<String, Skill_Master__c>();
    static List<Skill_Master__c> skillMasterList;
    static List<String> subjectKeyword = new List<String>();
    
    
    public static void handleBeforeUpdate(Map<Id,LiveChatTranscript> oldMap,Map<Id,LiveChatTranscript> newMap)
    {
        for(LiveChatTranscript lct : newMap.Values())
        {
            
        }
    }
    
    public static void handleAfterUpdate(Map<Id,LiveChatTranscript> oldMap,Map<Id,LiveChatTranscript> newMap)
    {
        //CR Non-Voice
        skillMasterList = [SELECT Id, Name, Topic__c, Skill__c  , Source__c, Segment__c, Service_Level1__c, Service_Level2__c, Service_Level3__c
                           ,Validate_Code__c,Problem_Type__c,Journey__c 
                           FROM Skill_Master__c];
        if(skillMasterList.size() > 0)
        {
            for(Skill_Master__c skill : skillMasterList)
            {
                if(skill.Source__c == 'Email - ME')
                {
                    skillMasterMap.put(skill.Source__c,skill);
                }
                else 
                {
                    skillMasterMap.put(skill.Topic__c+skill.Source__c,skill);
                }
            }
        }    
        List<String> caseId = new List<String>();
        Map<String,LiveChatTranscript> chatNewMap = new Map<String,LiveChatTranscript>();
        Map<String,LiveChatTranscript> chatOldMap = new Map<String,LiveChatTranscript>();
        for(LiveChatTranscript lct : oldMap.Values())
        {
            chatOldMap.put(lct.Id,lct);
        }
        for(LiveChatTranscript lct : newMap.Values())
        {
            caseId.add(lct.caseId);  
            chatNewMap.put(lct.caseId,lct);
        }
        
        
        List<Case> caseList = [SELECT Id,Origin,Subject,PTA_Segment__c,Category__c,Sub_Category__c,Product_Category__c,Service_Type_Matrix_Code__c
                               ,Problem_Type__c,Journey__c,ContactId,OwnerId
                               FROM Case Where Id IN: caseId];
        List<Case> caseUpdateList = new List<Case>();
        for(Case caseObj : caseList)
        {           
            if(chatNewMap.containsKey(caseObj.Id))
            {     
                if(chatOldMap.get(chatNewMap.get(caseObj.Id).Id).CaseId == null && chatNewMap.get(caseObj.Id).CaseId != null)
                {
                    caseObj.OwnerId = chatNewMap.get(caseObj.Id).OwnerId;
                    caseObj.Subject = chatNewMap.get(caseObj.Id).Subject__c;
                    
                    if(chatNewMap.get(caseObj.Id).ContactId != null && caseObj.ContactId == null)
                    {
                        caseObj.ContactId = chatNewMap.get(caseObj.Id).ContactId;
                    }
                    
                    if(skillMasterMap.containsKey(chatNewMap.get(caseObj.Id).Subject__c+caseObj.Origin))
                    {                       
                        caseObj.PTA_Segment__c = skillMasterMap.get(chatNewMap.get(caseObj.Id).Subject__c+caseObj.Origin).Segment__c;
                        caseObj.Category__c = skillMasterMap.get(chatNewMap.get(caseObj.Id).Subject__c+caseObj.Origin).Service_Level1__c;
                        caseObj.Sub_Category__c = skillMasterMap.get(chatNewMap.get(caseObj.Id).Subject__c+caseObj.Origin).Service_Level2__c;
                        caseObj.Product_Category__c = skillMasterMap.get(chatNewMap.get(caseObj.Id).Subject__c+caseObj.Origin).Service_Level3__c;
                        caseObj.Service_Type_Matrix_Code__c = skillMasterMap.get(chatNewMap.get(caseObj.Id).Subject__c+caseObj.Origin).Validate_Code__c;
                        caseObj.Problem_Type__c = skillMasterMap.get(chatNewMap.get(caseObj.Id).Subject__c+caseObj.Origin).Problem_Type__c;
                        caseObj.Journey__c = skillMasterMap.get(chatNewMap.get(caseObj.Id).Subject__c+caseObj.Origin).Journey__c;
                    }
                    caseUpdateList.add(caseObj);                   
                }
            }            
        }
        System.debug('caseUpdateList:'+caseUpdateList);
        update caseUpdateList;
    }
    
}