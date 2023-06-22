trigger PendingServiceRoutingTrigger on PendingServiceRouting (before insert, before update, after update) {
    System.debug('PendingServiceRoutingTriggerStart...');
    if (Trigger.isAfter) {
        List<PendingServiceRouting> psrList = new List<PendingServiceRouting>();
        Set<Id> chatSessionId = new Set<Id>();
        Set<Id> postId = new Set<Id>();
        for (PendingServiceRouting psr : Trigger.new) {
            Schema.SObjectType workItemType = psr.WorkItemId.getSObjectType();
            if (psr.CustomRequestedDateTime != null && (psr.LastDeclinedAgentSession != null || psr.LastModifiedById != psr.preferredUserId) && psr.CreatedById != psr.LastModifiedById && Schema.iigproduct_2__ChatSession__c.getSObjectType() == workItemType) {
                psrList.add(psr);
                chatSessionId.add(psr.WorkItemId);
            // } else if (psr.CustomRequestedDateTime != null && (psr.LastDeclinedAgentSession != null || psr.LastModifiedById != psr.preferredUserId) && psr.CreatedById != psr.LastModifiedById && Schema.Social_Post__c.getSObjectType() == workItemType) {
            //     psrList.add(psr);
            //     postId.add(psr.WorkItemId);
            }
        }
        System.debug('psrList: ' + psrList);
        if (psrList.size() > 0) {
            System.debug('PendingServiceRoutingTriggerHandler: afterUpdate');
            if (!chatSessionId.isEmpty()) {
                PendingServiceRoutingTriggerHandler.afterUpdate(psrList, chatSessionId);
            }
            // if (!postId.isEmpty()) {
            //     PendingServiceRoutingTriggerHandler.afterUpdateForSocialPost(psrList, postId);
            // }
        }
    }
    System.debug('PendingServiceRoutingTriggerEnd...');
}