public without sharing class AccountPlanGroupProfileSelector {

     private static string  selectGroupProfileById(){
        return  ' Select Id, Name, Year__c,Group__c,Group__r.Name  From AcctPlanGroupProfile__c Where Id =: groupProfileId ';
     }
    
     public static AcctPlanGroupProfile__c getGroupProfileById(String groupProfileId){
        system.debug('::: groupProfileId >> ' + groupProfileId);
        if(groupProfileId == null || groupProfileId == '' )
            throw new AccountPlanGroupProfileSelectorException('Set of groupProfileId Cannot be null');

        string sql = selectGroupProfileById();
        system.debug('::: sql' + sql);

		List<AcctPlanGroupProfile__c> ret = Database.query(sql); 
		if (ret.size() > 0)
		{
		   return ret[0];
		}
        return null;
    }

    // Exception
    public class AccountPlanGroupProfileSelectorException extends Exception{   
    }
}