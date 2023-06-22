public class RTL_HouseholdRelationshipManager {
    private RTL_Branch_Manager_Title__c branchTitle;
    private Map<String,User> branchCodeUserMap = new Map<String,User>();
    private Map<String,User> empCodeUserMap = new Map<String,User>();
    private Map<User,List<RTL_Household__c>> rmWithHousehold = new Map<User,List<RTL_Household__c>>();
    static Id templateId;
    public RTL_HouseholdRelationshipManager(){
        //get branch title from custom setting
        branchTitle = RTL_Branch_Manager_Title__c.getValues('Branch Manager');
        //Loop Through all user which employee id is not null or branch code is not null and is a branch manager
        //2022-Feb: INC0191538, Remove field Name,Manager.Name
        for(User user : [SELECT ID,ManagerId,RTL_Branch_Code__c,Employee_Id__c,title FROM User 
                         WHERE (
                                (RTL_Branch_Code__c != null AND title =:branchTitle.RTL_Value__c) 
                                 OR Employee_ID__c != null
                               ) AND IsActive = true])
        {
            //if Branch Code is not null and is branch manager
            if(user.RTL_Branch_Code__c != null && user.title == branchTitle.RTL_Value__c){
                branchCodeUserMap.put(user.RTL_Branch_Code__c,user);
            }
            //if Employee Id is not null
            if(user.Employee_ID__c != null){
                empCodeUserMap.put(user.Employee_ID__c,user);
            }
        }
    }
    public void updateHouseholdRM(Map<Id,Account> newMap){ 
        Map<Id,Account> accountWithPrimaryMemberMap;
        List<RTL_Household__c> householdToUpdate = new List<RTL_Household__c>();
        
        //query account with household he is a primary member
        accountWithPrimaryMemberMap = getAccountwithPrimaryMember(newMap.keySet());
		//loop through account with his primary member
        for(Account acct : accountWithPrimaryMemberMap.values()){
            Account newAcct = newMap.get(acct.id);
            //loop through primary member
            for(RTL_Household_Member__c memb : acct.Household_Members__r){
                //get new RM
                User rmUser = getRMUser(newAcct.RTL_RM_Name__c);
                RTL_Household__c household = new RTL_Household__c();
                household.id = memb.RTL_Household__c;
                household.RTL_RM__c = null;
                //If rm not found , leave household RM Blank
                
                //If rm found , assign rm to household and add the household to the map
                if(rmUser != null){
                	household.RTL_RM__c = rmUser.id;  
 
                	if(rmWithHousehold.containsKey(rmUser)){
                		rmWithHousehold.get(rmUser).add(household);
                	}else{
                    	rmWithHousehold.put(rmUser,new List<RTL_Household__c>{household});
                	}    
                }
                householdToUpdate.add(household);
                
            }
        } 
              
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        if(householdToUpdate.size() > 0){ 
            if(templateId == null) templateId = [select id, name from EmailTemplate where developername = 'RTL_Household_Change_RM'].id;
            Map<Id,RTL_Household__c> householdWithPendingApproval = queryPendingHousehold(householdToUpdate);
            Messaging.SingleEmailMessage email;
            //Loop through all rm
            for(User rmUser :rmWithHousehold.keySet()){

                List<RTL_Household__c> rmHouseholdList = rmWithHousehold.get(rmUser);
                List<RTL_Household__c> pendingHouseholdList = new List<RTL_Household__c>();
                //Loop through all household of this new rm
                for(RTL_Household__c household : rmHouseholdList){
                    //if the household have pending history add to the list
                    if(householdWithPendingApproval.get(household.id).Household_History_And_Approvals__r.size() > 0){
                        pendingHouseholdList.add(household);
                    }
                }
                //If this rm has household with pending request, send notify email 
                if(pendingHouseholdList.size() > 0 && rmuser.ManagerId != null){
                	RTL_HouseholdChangeRMEmail.sendEmail(rmUser.id,rmuser.ManagerId,pendingHouseholdList,householdWithPendingApproval);
                	email = new Messaging.SingleEmailMessage();
        			email.setSaveAsActivity(false);
        			email.setTargetObjectId(rmUser.ManagerId);//Set Approver Id as a targetObjectId
        			email.setWhatId(rmUser.id);
        			email.setTemplateId(templateId); 
                	emails.add(email);
                }

            }
            update householdToUpdate;
            Messaging.sendEmail(emails);
            
        }
 
    }
    
    public Map<Id,Account>getAccountwithPrimaryMember(Set<Id> accountId){
        Map<Id,Account> accoutWithPrimaryMap;
        /*accoutWithPrimaryMap =  new Map<Id,Account>([SELECT ID,Name,
                                                     (SELECT Id,Name,RTL_Household__c 
                                                      FROM Household_Members__r 
                                                      WHERE RTL_Primary__c = true) 
                                                     FROM Account  WHERE Id IN:accountId 
                                                     				AND Id IN (SELECT RTL_Household_Member_Name__c  
                                                                               FROM RTL_Household_Member__c 
                                                                               WHERE RTL_Primary__c = true 
                                                                                 AND RTL_Household_Member_Name__c  IN : accountId)]);*/
        //2022-Feb: INC0191538, Remove field Name
        accoutWithPrimaryMap =  new Map<Id,Account>([SELECT ID,
                                                     (SELECT Id,RTL_Household__c 
                                                      FROM Household_Members__r 
                                                      WHERE RTL_Primary__c = true) 
                                                     FROM Account  WHERE Id IN:accountId 
                                                     				AND Id IN (SELECT RTL_Household_Member_Name__c  
                                                                               FROM RTL_Household_Member__c 
                                                                               WHERE RTL_Primary__c = true 
                                                                                 AND RTL_Household_Member_Name__c  IN : accountId)]);
        return accoutWithPrimaryMap;
    }
    
    public User getRMUser(String empBrCode){
        //If EMP/BR Code starts with 00 , find User with this branch code and is a branch manager
        if(empBrCode != null && empBrCode.startsWith('00')){
            empBrCode = empBrCode.substring(2);
            if(branchCodeUserMap.containsKey(empBrCode)){
                return branchCodeUserMap.get(empBrCode);
            }
        //else find a User with EMP/BR = Employee_Id   
        }else{
            if(empCodeUserMap.containsKey(empBrCode)){
                return empCodeUserMap.get(empBrCode);
            }
            
        }
        return null;
    }
    
    public static Map<Id,RTL_Household__c> queryPendingHousehold(List<RTL_Household__c> householdList){
        /*Map<Id,RTL_Household__c> householdMap = new Map<Id,RTL_Household__c>([SELECT ID,Name,(SELECT ID,Name,RTL_User_Requesting__r.Name
                        ,RTL_Outcome__c,RTL_Date_Requested__c 
                    FROM Household_History_and_Approvals__r WHERE RTL_Outcome__c = 'Pending')  
                    FROM RTL_Household__c WHERE Id IN: householdList]);*/

        //2022-Feb: INC0191538, Remove field Name, RTL_Outcome__c
        Map<Id,RTL_Household__c> householdMap = new Map<Id,RTL_Household__c>([SELECT ID,Name,(SELECT ID,RTL_User_Requesting__r.Name
                        ,RTL_Outcome__c,RTL_Date_Requested__c 
                    FROM Household_History_and_Approvals__r WHERE RTL_Outcome__c = 'Pending')  
                    FROM RTL_Household__c WHERE Id IN: householdList]);
        return householdMap;
    }
}