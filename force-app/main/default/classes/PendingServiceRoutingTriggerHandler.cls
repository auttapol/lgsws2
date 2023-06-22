public without sharing class PendingServiceRoutingTriggerHandler {
    public static void afterUpdate(List<PendingServiceRouting> psrList, Set<Id> chatSessionId) {
        List<PendingServiceRouting> oldpsrList = new List<PendingServiceRouting>();
        
        ServiceChannel chatServiceChannel = [SELECT Id, relatedEntity FROM ServiceChannel WHERE relatedEntity = :'iigproduct_2__ChatSession__c'];

        List<iigproduct_2__ChatMessage__c> chatMessageList = new List<iigproduct_2__ChatMessage__c>();
        
        List<iigproduct_2__ChatSession__c> chatSessionList = new List<iigproduct_2__ChatSession__c>();
        Map<Id, iigproduct_2__ChatSession__c> chatSessionMap = new Map<Id, iigproduct_2__ChatSession__c>([SELECT Id, OwnerId, iigproduct_2__Status__c, iigproduct_2__IsExpired__c FROM iigproduct_2__ChatSession__c WHERE Id IN :chatSessionId]);
        
        for (PendingServiceRouting psr : [
            SELECT Id, OwnerId, preferredUserId, WorkItemId, IsPreferredUserRequired, PushTimeout, CreatedById, CreatedBy.Name, CustomRequestedDateTime
            FROM PendingServiceRouting
            WHERE Id IN :psrList AND WorkItemId IN :chatSessionId
        ]) {
            Schema.SObjectType workItemType = psr.WorkItemId.getSObjectType();
            Id createdId = psr.CreatedById;
            String createdName = psr.CreatedBy.Name;
            Id recordId = psr.WorkItemId;
            if (Schema.iigproduct_2__ChatSession__c.getSObjectType() == workItemType) {
                oldpsrList.add(psr);
            }

            if (chatSessionMap.containsKey(recordId)){
                iigproduct_2__ChatSession__c chatSession = chatSessionMap.get(recordId);
                chatSession.ownerId = createdId;
                if (!chatSession.iigproduct_2__IsExpired__c) {
                    chatSession.iigproduct_2__Status__c = 'Inprogress';
                }
                chatSessionList.add(chatSession);
            }

            // log
            System.debug('Creating Transfer Message...');
            iigproduct_2__ChatMessage__c chatMessage = new iigproduct_2__ChatMessage__c();
            // chatMessage.Body_Message__c = 'ปฎิเสธคำขอโอนการสนทนาแล้ว';
            chatMessage.iigproduct_2__Body_Message__c = 'Rejected transfer request';
            chatMessage.iigproduct_2__Sender__c = createdName;
            chatMessage.iigproduct_2__Time_Stamp__c = System.now();
            chatMessage.iigproduct_2__Message_Type__c = 'transfer';
            chatMessage.iigproduct_2__ChatSession__c = recordId;
            chatMessage.iigproduct_2__Is_System_Message__c = true;
            chatMessage.iigproduct_2__IsOutbound__c = false;
            chatMessage.iigproduct_2__chatSessionOwner__c = createdId;
            chatMessageList.add(chatMessage);
            System.debug('Chat Message: ' + chatMessage);
        }
        System.debug('oldpsrList: ' + oldpsrList);
        delete oldpsrList;
        System.debug('newpsrList: ' + chatMessageList);
        insert chatMessageList;
        System.debug('chatSessionMap: ' + chatSessionMap);
        update chatSessionList;
    }

    /*
    public static void afterUpdateForSocialPost(List<PendingServiceRouting> psrList, Set<Id> postId) {
        List<PendingServiceRouting> oldpsrList = new List<PendingServiceRouting>();
        
        ServiceChannel chatServiceChannel = [SELECT Id, relatedEntity FROM ServiceChannel WHERE relatedEntity = :'Social_Post__c'];
        
        List<Social_Post__c> postList = new List<Social_Post__c>();
        Map<Id, Social_Post__c> postMap = new Map<Id, Social_Post__c>([SELECT Id, OwnerId, Status__c, LastTransferUser__c FROM Social_Post__c WHERE Id IN :postId]);
        
        for (PendingServiceRouting psr : [
            SELECT Id, OwnerId, preferredUserId, WorkItemId, IsPreferredUserRequired, PushTimeout, CreatedById, CreatedBy.Name, CustomRequestedDateTime
            FROM PendingServiceRouting
            WHERE Id IN :psrList AND WorkItemId IN :postId
        ]) {
            Schema.SObjectType workItemType = psr.WorkItemId.getSObjectType();
            Id createdId = psr.CreatedById;
            String createdName = psr.CreatedBy.Name;
            Id recordId = psr.WorkItemId;
            if (Schema.Social_Post__c.getSObjectType() == workItemType) {
                oldpsrList.add(psr);
            }

            if (postMap.containsKey(recordId)){
                Social_Post__c thisPost = postMap.get(recordId);
                thisPost.ownerId = createdId;
                thisPost.LastTransferUser__c = createdId;
                // thisPost.LastTransferUser__c = null;
                thisPost.Status__c = 'New';
                postList.add(thisPost);
            }
        }
        System.debug('oldpsrList: ' + oldpsrList);
        delete oldpsrList;
        System.debug('postMap: ' + postMap);
        update postList;
    }
    */
}