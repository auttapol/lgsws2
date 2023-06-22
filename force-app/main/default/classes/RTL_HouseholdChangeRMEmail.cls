public class RTL_HouseholdChangeRMEmail {
	public static List<RTL_Household> householdInEmail {get;set;}
    public static Map<String,List<RTL_Household>> householdRMMap {get;set;}  
    public static String rmId{get;set;}
    
    public static void SendEmail(Id inRMId,Id approverId,List<RTL_Household__c> inHouseholdList,Map<Id,RTL_Household__c> householdMap){
        if(householdRMMap == null) householdRMMap = new Map<String,List<RTL_Household>>();

        List<RTL_Household__c> householdInEmailDB = inHouseholdList;
        householdInEmail = new List<RTL_Household>();
        System.debug('Household In EmailDB '+householdInEmailDB);
        for (RTL_Household__c household: householdInEmailDB) {
        	householdInEmail.add(transformHousehold(householdMap.get(household.id)));
        }
        
        System.debug('EMAIL SENT');
        householdRMMap.put(inRMId,householdInEmail);

    }
    
    public static List<RTL_Household> getHH(){
    	if (householdRMMap != null)
        	return householdRMMap.get(rmId);
        else
        	return null;
    }
   
    public static RTL_Household transformHousehold(RTL_Household__c householdObj) {
    	RTL_Household household = new RTL_Household();
    	household.RTL_HouseholdName = householdObj.Name;
    	household.RTL_HouseholdId = householdObj.Id;
    	household.RTL_RequestDate = householdObj.Household_History_And_Approvals__r[0].RTL_Date_Requested__c.format();
        household.RTL_Requestor = householdObj.Household_History_And_Approvals__r[0].RTL_User_Requesting__r.Name;//householdObj.RTL_A.format();
    	return household;
    }
    
    //Wrapper class
    public class RTL_Household{
        public string RTL_HouseholdName {get;set;}
        public string RTL_HouseholdId {get;set;}
        public string RTL_RequestDate {get;set;}
        public string RTL_Requestor {get;set;}
    } 
}