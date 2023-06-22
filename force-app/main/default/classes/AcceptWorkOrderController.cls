public with sharing class AcceptWorkOrderController {
    @AuraEnabled
    public static string acceptWorkOrder(String workOrderId){
        String result;
        try
        {               
            Work_Order__c workOrder = [SELECT Id,OwnerId FROM Work_Order__c WHERE Id =:workOrderId];
            workOrder.OwnerId = System.UserInfo.getUserId();
            result = 'Success';
            update workOrder;
        
            System.debug('result:'+result);
        }catch(DMLException e){
            result = e.getDmlMessage(0);
        }catch(Exception e){
            result = e.getMessage();
        }
        return result;
    }

    @AuraEnabled
    public static List<String> getGroupMember(String groupId){
        try
        {
            List<String> idList = new List<String>();
            List<String> grouptIdList = new List<String>();
            List<GroupMember> groupMember = [SELECT UserOrGroupId FROM GroupMember where GroupId =: groupId ];
            if(groupMember.size() > 0)
            {
                for(GroupMember g : groupMember)
                {
                    idList.add(g.UserOrGroupId);
                }
            }
            System.debug('idList:'+idList);
            List<Group> groupList = [SELECT Id,DeveloperName FROM Group WHERE Id IN: idList ];
            if(groupList.size() > 0)
            {
                for(Group g : groupList)
                {
                    grouptIdList.add(g.DeveloperName);
                }
            }
            System.debug('groupList:'+groupList);
            return grouptIdList;
        }
        catch(Exception e)
        {
            return null;
        }
    }

    @AuraEnabled
    public static List<String> checkBranch(String ownerId){
        try
        {     
            Boolean isBranch = false;
            // User user = [SELECT Id,RTL_Branch_Code__c FROM User WHERE Id =: System.UserInfo.getUserId()];
            // String branchCode = '%'+user.RTL_Branch_Code__c+'%';
            List<String> groupIdList = new List<String>();
            List<Group> groupList = [SELECT Id, DeveloperName, OwnerId FROM Group WHERE Id =: ownerId ];
            if(groupList.size() > 0)
            {
                for(Group g : groupList)
                {
                    groupIdList.add(g.DeveloperName);
                }
            }
            return groupIdList;
        }
        catch(Exception e)
        {
            return null;
        }
    }

    @AuraEnabled
    public static User getCurrentUser()
    {
        try
        {     
            User user = [SELECT Id,RTL_Branch_Code__c,UserRoleName__c,UserRoleId,UserRole.DeveloperName FROM User WHERE Id =: System.UserInfo.getUserId()];
            System.debug('user:'+user);
            return user;
        }
        catch(Exception e)
        {
            return null;
        }
    }



    
}