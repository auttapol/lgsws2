public class CustomerBRCController {
    @AuraEnabled
    public static User getCurrentUser()
    {
        try
        {     
            User user = [SELECT Id, UserRoleName__c, UserRoleId, RTL_Branch__c, UserRole.DeveloperName, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
            return user;
        }
        catch(Exception e)
        {
            return null;
        }
    }

    @AuraEnabled
    public static String getReportId(String reportName)
    {
        try
        {     
            Report report = [SELECT Id, Name FROM Report WHERE DeveloperName =: reportName];
            return report.Id;
        }
        catch(Exception e)
        {
            return null;
        }
    }

    @AuraEnabled
    public static Group getGroupId(String groupName){
        try
        {
            Group publicGroup = [SELECT Id, Name, Type, OwnerId FROM Group WHERE DeveloperName =:groupName];
            return publicGroup;

        }
        catch(Exception e)
        {
            return null;
        }
    }

    @AuraEnabled
    public static Boolean getGroupMemberIdList(String groupId, User userObj, String userRoleId){
        try
        {
            List<String> groupIdList = new List<String>();
            List<String> groupMemberIdList = new List<String>();
            List<String> groupRoleAndSubIdList = new List<String>();
            Set<Id> roleIds = new Set<Id>();
            List<GroupMember> groupMember = [SELECT UserOrGroupId FROM GroupMember where GroupId =: groupId ];
            Boolean hasPermissionInGroup = false;

            if(groupMember.size() > 0)
            {
                for(GroupMember gm : groupMember)
                {
                    System.debug('[๊UserLv] Current user ID: '+userObj.Id+' | Each group member Id: '+gm.UserOrGroupId);
                    if(String.valueOf(gm.UserOrGroupId).startsWith('005'))
                    {
                        if(userObj.Id == gm.UserOrGroupId)
                        {
                            return true;
                        }
                    }
                    else {
                        groupIdList.add(gm.UserOrGroupId);
                    }

                }
            }

            List<Group> groupList = [SELECT Id, DeveloperName, RelatedId, Type FROM Group WHERE Id IN: groupIdList ];
            if(groupList.size() > 0)
            {
                for(Group g : groupList)
                {
                    System.debug('[GROUPLv] DeveloperName: '+g.DeveloperName+' | Type : '+g.Type +' | RelatedId : '+g.RelatedId);

                    switch on g.Type {
                        when 'Role' {		
                            System.debug('[RoleLv] groupMember.UserOrGroupId : '+g.RelatedId +' | UserRoleId : '+userRoleId);

                            if(g.RelatedId == UserRoleId)
                            {
                                return true;
                            }
                        }
                        when 'RoleAndSubordinates' {		  
                            //find all children
                            if(g.RelatedId == UserRoleId)
                            {
                                return true;
                            }
                            else
                            {
                                roleIds.add(g.RelatedId);
                            }
                        }
                        when 'Regular' {	
                            //recursive fn
                            hasPermissionInGroup = getGroupMemberIdList(g.Id, userObj, userRoleId);
                        }	
                    }
                }
            }
            
            if(roleIds.size() > 0 && !hasPermissionInGroup)
            {
                return checkAllSubRoleIds(roleIds, userObj, userRoleId);
            }
            
            return hasPermissionInGroup;
        }
        catch(Exception e)
        {
            //return null;
            return false;
        }
    }

    public static Boolean checkAllSubRoleIds(Set<ID> roleIds, User userObj, String userRoleId) {
        Set<ID> currentRoleIds = new Set<ID>();

        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
        {
            if(userRole.Id == UserRoleId) {
                return true;
            }
            else {
                currentRoleIds.add(userRole.Id);
            }
                
        }
        
        if(currentRoleIds.size() > 0)
        {
            //recursive fn
            return checkAllSubRoleIds(currentRoleIds, userObj, userRoleId);
        }  

        return false;
    }

}