public with sharing class lookUpController {
	@AuraEnabled
 	public static List < User > fetchAccount(String searchKeyWord) 
	{
  		String searchKey = '%' + searchKeyWord + '%';
		try
		{
			List < User > returnList = new List < User > ();
			List < User > lstOfAccount = [SELECT Id,Name,ProfileId From User where Name LIKE: searchKey AND isActive=true
			order by createdDate DESC limit 5];

			for (User acc: lstOfAccount) {
				returnList.add(acc);
				}
			return returnList;
		}
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			return null;
				
		}
	}
	@AuraEnabled
 	public static List < User > getOwnerName(String searchKeyWord) 
	{
  		String searchKey = searchKeyWord;
		try
		{
			List < User > returnList = new List < User > ();
			List < User > getName = [SELECT Id,Name From User where Id =: searchKey AND isActive=true];

			for (User acc: getName) {
				returnList.add(acc);
				}
			return returnList;
		}
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			return null;
				
		}
	}

	@AuraEnabled 
    public static User fetchUser(){
     // query current user information  
      User oUser = [Select Id,Name,Username,Country,Email,FirstName,LastName,IsActive 
                 FROM User Where Id =: userInfo.getUserId() AND isActive=true];
        return oUser;
    }

	@AuraEnabled 
    public static User fetchAccountOwner(String accountId){
     // query current user information  
		Account acc  = [SELECT Id, OwnerId FROM Account Where Id =: accountId];
		User user = [SELECT Id,Name From User where Id =: acc.OwnerId AND isActive=true];

        return user;
    }
}