public class mainBankInfoController {
	@AuraEnabled 
    public static Account getAccount(String accId){ 
        Account acc = [Select 
                Main_Bank_Group_1_Name__c 
                ,Main_Bank_Group1_Value__c
                ,Main_Bank_Group2_Name__c
                ,Main_Bank_Group2_Value__c
                ,Main_Bank_Group3_Name__c
                ,Main_Bank_Group3_Value__c
                ,Main_Bank_Group4_Name__c
                ,Main_Bank_Group4_Value__c
                ,Main_Bank_Group5_Name__c
                ,Main_Bank_Group5_Value__c
                ,RTL_Primary_Banking_All_Free_Benefit__c
                ,RTL_Main_Bank_Desc__c
                ,Mainbank_Campaign_Period__c
                
                ,RTL_Entitled_Privilege2__c, RTL_Privilege2__c//, cyc_promo_cond__c
                
 		From Account WHERE Id =: accId];
        
        Boolean chkPermission = checkPermission(accId);
        if(chkPermission == false){
           	acc.id = null;
        }
        return acc; 
    } 
    
    public static Boolean checkPermission(String accId){
		Id userId = UserInfo.getUserId();
        User u = [Select Id, Name, ProfileId, Profile.Name, userRoleId FROM User WHERE Id =: userId];
        Set<ID> roleSet = getAllRole(u.userRoleId);
        List<AccountTeamMember> am = [SELECT Id, AccountId, UserId, User.UserRoleId From AccountTeamMember WHERE AccountId =: accId  AND UserId =:userId];
        
        Set<ID> roleSet_Team = new Set<ID>(); //
        Set<ID> roleSet_Rm = new Set<ID>();
        Set<ID> roleSet_Owner = new Set<ID>();
        

        
        Account acc = [SELECT Id, name, Rtl_wealth_rm__c, Rtl_wealth_rm__r.UserRoleId, ownerId, owner.UserRoleId FROM Account WHERE Id =: accId];
        List<Data_Security_Matrix__c> secs = [SELECT Id, Access_Type__c, Profile_Name__c, Data_Matrix_Key__c, Section_Name__c FROM Data_Security_Matrix__c WHERE Section_Name__c = 'RtlCust:MI Benefits'];
        Data_Security_Matrix__c sec_temp = new Data_Security_Matrix__c();
        
        if(am.size() > 0){
            Set<Id> tempSet = getAllRole(am[0].User.UserRoleId);
            List<Id> tempList = new List<String>();
            tempList.addAll(tempSet);
            for(Integer i = 0; i< tempList.size(); i++){
                if(tempList[i] != am[0].User.UserRoleId){
                    roleSet_Team.add(tempList[i]);
                }
            }
        }
        
        if(acc.Rtl_wealth_rm__c != null){
            Set<Id> tempSet = getAllRole(acc.Rtl_wealth_rm__r.UserRoleId);
            List<Id> tempList = new List<String>();
            tempList.addAll(tempSet);
            for(Integer i = 0; i< tempList.size(); i++){
                if(tempList[i] != acc.Rtl_wealth_rm__r.UserRoleId){
                    roleSet_Rm.add(tempList[i]);
                }
            }
        }
        
        if(acc.ownerId != null){
            Set<Id> tempSet = getAllRole(acc.owner.UserRoleId);
            List<Id> tempList = new List<String>();
            tempList.addAll(tempSet);
            for(Integer i = 0; i< tempList.size(); i++){
                if(tempList[i] != acc.owner.UserRoleId){
                    roleSet_Owner.add(tempList[i]);
                }
            }
        }
        
        System.debug('secs:::' + secs);
        for(Data_Security_Matrix__c each : secs){
            if(each.Profile_Name__c == u.Profile.Name){
                sec_temp = each;
            }
        }
        System.debug('sec_temp.Id:::' + sec_temp.Id);
        if(sec_temp.Id == null){
            System.debug('in if1');
            return false;
        }
        
        if(u.Profile.Name == sec_temp.Profile_Name__c && sec_temp.Access_Type__c == 'No Access'){
            return false;
        }
        if(sec_temp.Access_Type__c == 'Authorize Only'){
            if(acc.Rtl_wealth_rm__c == u.Id || acc.ownerId == u.Id || roleSet_Team.contains(u.UserRoleId) || roleSet_Rm.contains(u.UserRoleId) || roleSet_Owner.contains(u.UserRoleId) || (am.size() > 0)){
                return true;
            }else{
                return false;
            }
        }else if(sec_temp.Access_Type__c == 'All'){
            return true;
        }
        return FALSE;
    }
    
    public static Set<ID> getAllRole(Id roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        list<UserRole> LisiAllUserRole = [select id,ParentRoleId,Name from UserRole];
        map<Id,Id> MapRoleIdWithParent = new map<Id,Id>();
        for(UserRole role : LisiAllUserRole){
            MapRoleIdWithParent.put(role.Id,role.ParentRoleId);
        }
        currentRoleIds.add(roleIds);
        System.debug('currentRoleIds :'+currentRoleIds);
        
        Id firstStartParentRoleId = null;
        if(MapRoleIdWithParent.containsKey(roleIds)){
            firstStartParentRoleId = MapRoleIdWithParent.get(roleIds);
        }
        if(firstStartParentRoleId != null){
            
            Id UserRoleIdstart = firstStartParentRoleId;
            Id UserRoleIdParent = null;
            
            if(UserRoleIdstart != null){
                Boolean resultflag = true;
                while (resultflag) {
                    UserRoleIdParent = null;
                    currentRoleIds.add(UserRoleIdstart);
                    if(MapRoleIdWithParent.containsKey(UserRoleIdstart)){
                        UserRoleIdParent = MapRoleIdWithParent.get(UserRoleIdstart);
                    }
                    if(UserRoleIdParent != null){
                        UserRoleIdstart = UserRoleIdParent;
                        resultflag=true;
                    }
                    else{
                        resultflag=false;
                        break;
                    }
                }
            }
        }
        return currentRoleIds;
    }

    @AuraEnabled
    public static Object getDescribeFieldResultAndValue(String recordId, List<String> fields, List<String> fields_translate){
        return RetailCSVLightningUtil.getDescribeFieldResultAndValue(recordId, fields, fields_translate);      
    }


    @AuraEnabled
    public static Object verifyFieldSecurity(String section, String userProfile, String accountId)
    {    
        return RTL_AccountUtility.verifyFieldSecurity(section, userProfile, accountId);
    }

    @AuraEnabled
    public static Object CallCYCCampaignMappingInqAPI(String NameCredentail,Object headerParam, Object bodyParam,Object OnlineServiceLog){
        return RetailCSVLightningUtil.CallCYCCampaignMappingInqAPI(NameCredentail, headerParam, bodyParam, OnlineServiceLog);
    }
}