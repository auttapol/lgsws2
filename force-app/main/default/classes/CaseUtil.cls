public class CaseUtil {

	static Map<Id, List<UserRole>> hierarchy
	{
		get
		{
			if (hierarchy == null)
			{
				hierarchy = new Map<Id, List<UserRole>>();
				for (UserRole role : [SELECT ParentRoleId FROM UserRole])
				{
					if (!hierarchy.containsKey(role.ParentRoleId))
						hierarchy.put(role.ParentRoleId, new List<UserRole>());
					hierarchy.get(role.ParentRoleId).add(role);
				}
			}
			return hierarchy;
		}
		private set;
	}

	public static Boolean isInGroupOrRole(Group queue, User user ,
					 Map<Id,Group> gMap , Map<String,List<GroupMember>> queueNameGroupMemberMap ){
		try{
			

			List<GroupMember> gmList = queueNameGroupMemberMap.get(queue.Name);

			Set<Group> groupAndSubIdSet = new Set<Group>();

			Set<Id> userAndGroupIdSet = new Set<Id>();
			Set<Id> roleIdSet = new Set<Id>();
			Set<Id> roleWithSubIdSet = new Set<Id>();


			for( GroupMember gm : gmList )
			{
				userAndGroupIdSet.add( gm.userorgroupid );

				// Add group and subOrdinate to Set
				if( gMap.containsKey(gm.userorgroupid) )
				{
					Group g = gMap.get(gm.userorgroupid);
					if( g.Type == 'RoleAndSubordinates' )
					{
						groupAndSubIdSet.add(g);
					}
					else if( g.Type =='Role' )
					{
						roleIdSet.add( g.RelatedId );
					}
				}
			}



			Id userRoleId = user.userroleId;

			//Check User is In Queue
			if( userAndGroupIdSet.contains(user.Id) )
			{
				return true;
			}

			//Check User's Role is In Queue
			if( roleIdSet.contains(user.userroleid) )
			{
				return true;
			}

			Set<Id> parentAndChildRole_list = new Set<Id>();

			for(Group g : groupAndSubIdSet){

				Set<Id> tmpRoleAndChildIdSet = getSubHierarchyInclusive(g.RelatedId);
				parentAndChildRole_list.addAll(tmpRoleAndChildIdSet);
			}

			if( parentAndChildRole_list.contains( user.userroleid ) )
			{
				return true;
			}

			
		}catch(Exception e){
			system.debug( e.getMessage() + '(' + e.getLineNumber() + ')' );
			return false;
		}
		return false;
	}

	public static List<UserRole> getChildren(Id userRoleId)
	{
		return hierarchy.containsKey(userRoleId) ?
			hierarchy.get(userRoleId) : new List<UserRole>();
	}

	public static Set<Id> getSubHierarchyInclusive(Id userRoleId)
	{
	    Set<Id> roleIds = new Set<Id> { userRoleId };
	    for (UserRole childRole : getChildren(userRoleId))
	        roleIds.addAll( getSubHierarchyInclusive(childRole.Id) );
	    return roleIds;
	}

	public static Set<Id> getSubHierarchyExclusive(Id userRoleId)
	{
	    Set<Id> roleIds = new Set<Id>();
	    for (UserRole childRole : getChildren(userRoleId))
	    {
	        roleIds.add(childRole.Id);
	        roleIds.addAll(getSubHierarchyExclusive(childRole.Id) );
	    }
	    return roleIds;
	}

	public static Set<Id> getAllChildrenRoleId(Id userRoleId)
	{
	    Set<Id> roleIds = new Set<Id> {};
	    for (UserRole childRole : getChildren(userRoleId))
	        roleIds.addAll( getSubHierarchyInclusive(childRole.Id) );
	    return roleIds;
	}


}