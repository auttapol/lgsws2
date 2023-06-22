public class AccountOwnerAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
	Datetime batchDate = datetime.now();
	Datetime batchStartTime = datetime.now();
	Datetime batchEndTime = null;

    final String SEMICO = ',';
    final String jobDailyName = 'Assign Account Owner';
	final String sObjectName = 'Account';
    
    private String query;
    private List<Owner_Assignment_Rule__c> ownerAssignmentRules;
    private Map<String, List<sObject>> mapObj;
    private Map<String, List<sObject>> mapObjfieldVal;
     Map<Id, Owner_Assignment_Rule__c> acctruleMap;

    private Map<Id, String> mapAccountAssignOwnerResult;
    private Integer assignTotal;
    private Integer assignSuccess;
    private Integer assignFail;

    private String sfadmSystemAccount{
        get{
            if(sfadmSystemAccount == null){
                AppConfig__c ac = AppConfig__c.getValues('sfadm Account Name');
                if(ac != null){
                    sfadmSystemAccount = ac.Value__c;
                }else{
                    sfadmSystemAccount = 'sfadm System Account';
                }
            }
            return sfadmSystemAccount;
        }
        set;
    }

    public AccountOwnerAssignmentBatch(){
        System.debug(':::::::::::::::AccountOwnerAssignmentBatch:::::::::::::::');
        assignTotal = 0;
        assignSuccess = 0;
        assignFail = 0;

        mapAccountAssignOwnerResult = new Map<Id, String>();

        String ScopeObj = 'Account';
        String Scopefield = 'Id, OwnerId, Name, Account_Type__c, Core_Banking_Suggested_Segment__c, RTL_Created_Branch__c';
        String Scopecriteria = 'Account_Type__c = \'Existing Customer\' AND Owner.Name = :sfadmSystemAccount';
        // AND Core_Banking_Suggested_Segment__c = \'SE\' AND Owner.Name = \'sfadm System Account\' 

        Map<String, String> queryObjectResource = new Map<String, String>();
        Map<String, List<String>> mapResourceOwnerCriteriaField = new Map<String, List<String>>();
        mapObj = new Map<String, List<sObject>>();
        mapObjfieldVal = new Map<String, List<sObject>>();
        acctruleMap = new Map<Id, Owner_Assignment_Rule__c>();

        ownerAssignmentRules = new List<Owner_Assignment_Rule__c>();

        ownerAssignmentRules = [SELECT Priority__c, Result_field__c, Entry_Criteria_Field_2__c, Entry_Criteria_Field_3__c, Entry_Criteria_Field_4__c, Entry_Criteria_Field_5__c, Criteria_Field_Value_3__c, Criteria_Field_Value_4__c, Criteria_Field_Value_5__c, Assigned_Object__c, Active_Flag__c, Criteria_Field_Value_1__c, Criteria_Field_Value_2__c, Record_Type__c, User_mapping_profile__c, Default__c, Destination_Field__c, User_mapping_condition__c, Entry_Criteria_Field_1__c, Mapped_to_field__c, Object_field_to_Map__c, Mapped_to_table__c, Id, Name FROM Owner_Assignment_Rule__c WHERE Assigned_Object__c = :ScopeObj ORDER BY Priority__c];

        for(Owner_Assignment_Rule__c assignRule : ownerAssignmentRules){
            if(assignRule.Object_field_to_Map__c != null && !Scopefield.contains(assignRule.Object_field_to_Map__c)){
                Scopefield += ', ' + assignRule.Object_field_to_Map__c;
            }

            if(assignRule.Entry_Criteria_Field_1__c != null && !Scopefield.contains(assignRule.Entry_Criteria_Field_1__c)){
                Scopefield += ', ' + assignRule.Entry_Criteria_Field_1__c;
            }
            if(assignRule.Entry_Criteria_Field_2__c != null && !Scopefield.contains(assignRule.Entry_Criteria_Field_2__c)){
                Scopefield += ', ' + assignRule.Entry_Criteria_Field_2__c;
            }
            if(assignRule.Entry_Criteria_Field_3__c != null && !Scopefield.contains(assignRule.Entry_Criteria_Field_3__c)){
                Scopefield += ', ' + assignRule.Entry_Criteria_Field_3__c;
            }
            if(assignRule.Entry_Criteria_Field_4__c != null && !Scopefield.contains(assignRule.Entry_Criteria_Field_4__c)){
                Scopefield += ', ' + assignRule.Entry_Criteria_Field_4__c;
            }
            if(assignRule.Entry_Criteria_Field_5__c != null && !Scopefield.contains(assignRule.Entry_Criteria_Field_5__c)){
                Scopefield += ', ' + assignRule.Entry_Criteria_Field_5__c;
            }

            if(assignRule.Mapped_to_table__c != null && assignRule.Mapped_to_field__c != null && assignRule.Result_field__c != null){
                Map<String, String> mapObjField = new Map<String, String>();
                String queryField = '';

                List<String> strlstTemp = new List<String>();

                if(mapResourceOwnerCriteriaField.containsKey(assignRule.Mapped_to_table__c)){
                    strlstTemp = mapResourceOwnerCriteriaField.get(assignRule.Mapped_to_table__c);
                }

                if(!strlstTemp.contains(assignRule.Mapped_to_field__c)){
                    strlstTemp.add(assignRule.Mapped_to_field__c);
                }

                mapResourceOwnerCriteriaField.put(assignRule.Mapped_to_table__c, strlstTemp);

                if(queryObjectResource.containsKey(assignRule.Mapped_to_table__c)){
                    queryField = queryObjectResource.get(assignRule.Mapped_to_table__c);
                }

                if(!queryField.contains(assignRule.Mapped_to_field__c)){
                    queryField = queryField == '' ? queryField : queryField + ', ';
                    queryField += assignRule.Mapped_to_field__c;
                }
                
                if(!queryField.contains(assignRule.Result_field__c)){
                    queryField = queryField == '' ? queryField : queryField + ', ';
                    queryField += assignRule.Result_field__c;
                }

                queryObjectResource.put(assignRule.Mapped_to_table__c, queryField);
            }
        }

        // System.debug('queryObjectRes ource : ' + queryObjectResource);

        for (String objName : queryObjectResource.keySet()) {
            String obj = objName;
            String field = queryObjectResource.get(objName);

            List<sObject> tempObj; 

            String queryStr = 'SELECT ' + field + ' FROM ' + obj;
            // System.debug('queryStr : ' + queryStr);

            tempObj = Database.query(queryStr);

            // System.debug('tempObj : ' + tempObj);
            mapObj.put(objName, tempObj);
        }

        // System.debug('ownerAssignmentRules : ' + ownerAssignmentRules);
        // System.debug(ownerAssignmentRules.size());

        // System.debug('mapObj : ' + mapObj);

        for (String key : mapObj.keySet()) {
            // System.debug('key : ' + key);
            List<sObject> objlst = mapObj.get(key);
            // System.debug('objlst : ' + objlst);
            // System.debug('objlst.size() : ' + objlst.size());
            for(sObject obj : objlst){
                for(String fieldName : mapResourceOwnerCriteriaField.get(key)){
                    String mapObjfieldKey = key + fieldName + String.valueOf(obj.get(fieldName));
                    List<sObject> tmp;
                    tmp = mapObjfieldVal.containsKey(mapObjfieldKey) ? mapObjfieldVal.get(mapObjfieldKey) : new List<sObject>();
                    tmp.add(obj);
                    mapObjfieldVal.put(mapObjfieldKey, tmp);
                }
            }
        }

        // System.debug('mapObjfieldVal : ' + mapObjfieldVal);
        

        query = 'SELECT ' + Scopefield + ' FROM ' + ScopeObj + ' WHERE ' + Scopecriteria;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug(':::::::::::::::start:::::::::::::::');
		System.debug('query');
		System.debug(query);
        
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug(':::::::::::::::execute:::::::::::::::');

        // System.debug('scope.size() : ');
        // System.debug(scope.size());

        // System.debug('ownerAssignmentRules : ' + ownerAssignmentRules);
        // System.debug(ownerAssignmentRules.size());
        List<Account> updateAcctLst = new List<Account>();

        Map<String, Set<String>> OwnerCriteria = new Map<String, Set<String>>();

        Map<Id, Map<String, String>> mapAcctOwnerCriteria = new Map<Id, Map<String, String>>();

        Map<Id, Account> mapAcctId = new Map<Id, Account>(scope);

        Map<String, List<User>> mapUserCriteria = new Map<String, List<User>>();

        for (Account acct : scope) {
            assignTotal += 1;
            for (Owner_Assignment_Rule__c rule : ownerAssignmentRules) {
                // System.debug('rule : ' + rule);
                // System.debug('rule.Priority__c : ' + rule.Priority__c);

                if(AccountOwnerAssignmentBatchUtil.checkCriteria(acct, rule)){
                    // System.debug('acct : ' + acct);
                    // System.debug('rule : ' + rule);

                    acctruleMap.put(acct.Id, rule);

                    String tableMap = rule.Mapped_to_table__c;
                    String valueToMap = String.valueOf(acct.get(rule.Object_field_to_Map__c));
                    String fieldMapTo = rule.Mapped_to_field__c;
                    String fieldMapResult = rule.Result_field__c;

                    String resourceMapKey = tableMap + fieldMapTo + valueToMap;
                    System.debug('tableMap : ' + tableMap);
                    System.debug('valueToMap : ' + valueToMap);
                    System.debug('fieldMapTo : ' + fieldMapTo);
                    System.debug('fieldMapResult : ' + fieldMapResult);
                    System.debug('resourceMapKey : ' + resourceMapKey);
                    System.debug('mapObjfieldVal.containsKey(resourceMapKey) : ' + mapObjfieldVal.containsKey(resourceMapKey));

                    if(mapObjfieldVal.containsKey(resourceMapKey)){
                        Map<String, String> mapOwnerCriteria = new Map<String, String> ();
                        Set<String> mapCriteriaVal = new Set<String> ();
                        String resultVal = String.valueOf(mapObjfieldVal.get(resourceMapKey).get(0).get(fieldMapResult));

                        if(resultVal != null){
                            mapCriteriaVal = OwnerCriteria.containsKey(rule.User_mapping_condition__c) ? OwnerCriteria.get(rule.User_mapping_condition__c) : new Set<String>();
                            mapCriteriaVal.add('\'' + resultVal + '\'');
                            OwnerCriteria.put(rule.User_mapping_condition__c, mapCriteriaVal);
                        }
                        
                        mapCriteriaVal = OwnerCriteria.containsKey('Profile.Name') ? OwnerCriteria.get('Profile.Name') : new Set<String>();
                        mapCriteriaVal.add('\'' + rule.User_mapping_profile__c + '\'');
                        OwnerCriteria.put('Profile.Name', mapCriteriaVal);

                        // System.debug('OwnerCriteria : ' + OwnerCriteria);

                        mapOwnerCriteria.put(rule.User_mapping_condition__c, resultVal);
                        mapOwnerCriteria.put('Profile.Name', rule.User_mapping_profile__c);

                        mapAcctOwnerCriteria.put(acct.Id, mapOwnerCriteria);
                    }
                    
                    break;
                }
            }
        }

        String userQField = 'Id, Name, ProfileId';
        String userQCriteria = '';

        // System.debug('OwnerCriteria : ' + OwnerCriteria);
        
        String userQCriteria0 = ' Profile.Name IN (' + String.join((Iterable<String>)OwnerCriteria.get('Profile.Name'), ', ') + ') ';

        for(String field : OwnerCriteria.keySet()){
            String tmp = String.join((Iterable<String>)OwnerCriteria.get(field), ', ');

            // System.debug('tmp : ' + tmp);

            userQField = userQField == '' ? userQField + field : (userQField.contains(field) ? userQField : userQField + ', ' + field);
            if(field != 'Profile.Name'){
                userQCriteria = userQCriteria == '' ? userQCriteria + ' ' + field + ' IN (' + tmp + ') ' : userQCriteria + ' OR ' + field + ' IN (' + tmp + ') ' ;
            }
        }
        userQCriteria0 = userQCriteria == '' ? userQCriteria0 : userQCriteria0 + 'AND (' + userQCriteria + ') ';

        // System.debug(userQField);
        // System.debug(userQCriteria0);

        userQCriteria0 = userQCriteria0 == '' ? userQCriteria0 : ' WHERE ' + userQCriteria0 + 'AND Isactive = true ';

        // System.debug('mapAcctOwnerCriteria : ' + mapAcctOwnerCriteria);
        String queryStr = 'SELECT ' + userQField + ' FROM User ' + userQCriteria0;
        
        for (Integer i = 0; i < queryStr.length(); i += 200) {
            // System.debug(queryStr.substring(i, i + 200 <= queryStr.length() ? i + 200 : queryStr.length()));
        }
         System.debug('queryStr : ' + queryStr);

        List<User> userlst = Database.query(queryStr);

        // System.debug('userlst : ' + userlst);
        // System.debug('userlst.size : ' + userlst.size());

        for (User u : userlst) {
            for(String field : OwnerCriteria.keySet()){
                // System.debug('field : ' + field);
                if(field != 'Profile.Name' && u.get(field) != null){
                    String key = u.Profile.Name + field + u.get(field);
                    List<User> tmp;
                    tmp = mapUserCriteria.containsKey(key) ? mapUserCriteria.get(key) : new List<User> ();
                    tmp.add(u);
                    mapUserCriteria.put(key, tmp);
                    // System.debug('key + tmp : ' + key + '  ' + tmp);
                }
            }
        }

        // System.debug('mapUserCriteria : ' + mapUserCriteria);
        
        for (Account acct : scope) {
            System.debug('---------------------------------');
            String assignResult = '';
            if(mapAcctOwnerCriteria.containsKey(acct.Id)){
                System.debug('ASSIGN acct : ' + acct);
                Map<String, String> mapOwnerCriteria = mapAcctOwnerCriteria.get(acct.Id);
                String key = mapOwnerCriteria.containsKey('Profile.Name') ? mapOwnerCriteria.get('Profile.Name') : '';
                for(String criteria : mapOwnerCriteria.keySet()){
                    if(criteria != 'Profile.Name'){
                        key += criteria;
                        key += mapOwnerCriteria.get(criteria);
                    }
                }
                System.debug('key : ' + key);
                System.debug(mapUserCriteria.containsKey(key));

                if(mapUserCriteria.containsKey(key) && mapUserCriteria.get(key).size() == 1){
                    System.debug(mapUserCriteria.get(key));
                    acct.Owner_Assignment_Rule__c = acctruleMap.get(acct.Id).Id;
                    acct.OwnerId = mapUserCriteria.get(key).get(0).Id;
                    
                    // update acct;
                    updateAcctLst.add(acct);
                    
                    assignSuccess += 1;
                    assignResult = 'SUCCESS';
                }else{
                    assignFail += 1;
                    assignResult = 'FAIL : ' + System.label.AssingOwnerMessage1;
                    System.debug(assignResult);
                }
                
            }else{
                assignFail += 1;
                assignResult = 'FAIL : ' + System.label.AssingOwnerMessage2;
                System.debug(assignResult);
                System.debug(acct);
            }
            System.debug('---------------------------------');
            mapAccountAssignOwnerResult.put(acct.Id, assignResult);
        }
        
        // update updateAcctLst;

        if(updateAcctLst != null && updateAcctLst.size() > 0){
			List<Database.SaveResult> srList = Database.update(updateAcctLst, false);

			for (Integer i = 0 ; i < srList.size() ; i++){
				Database.SaveResult sr = srList.get(i);
				
				if (!sr.isSuccess()) {
					assignFail += 1;
					String errormsg = '';

					for(Database.Error err : sr.getErrors()) {
						errormsg += err.getStatusCode() + ':' + err.getMessage();
					}

					mapAccountAssignOwnerResult.put(updateAcctLst.get(i).Id, errormsg);
				}
			}
		}
	}
	
    public void finish(Database.BatchableContext BC){
        System.debug(':::::::::::::::finish:::::::::::::::');
        System.debug('mapAccountAssignOwnerResult : ' + mapAccountAssignOwnerResult);
        System.debug('assignTotal : ' + assignTotal);
        System.debug('assignSuccess : ' + assignSuccess);
        System.debug('assignFail : ' + assignFail);

        batchEndTime = datetime.now();

        Integer recordsSuccessful = assignSuccess;
		Integer recordsFailed = assignFail;

        String csvHeaderStr = 'AccountId, Result';
		String CSV_BODY  = '';
        String resultMessage;

        for(Id Id : mapAccountAssignOwnerResult.keySet()){
            resultMessage = mapAccountAssignOwnerResult.get(ID);
			System.debug(Id + ' : ' + resultMessage);

            if(resultMessage != 'SUCCESS'){
                CSV_BODY = CSV_BODY + 
                        Id + SEMICO +
                        resultMessage + '\n';
            }
		}

        List<String> sendToEmail = new List<String>();
		sendToEmail.add('CRM Admin 2');

        System.debug(csvHeaderStr);
		System.debug(CSV_BODY);

        if(assignTotal > 0){
			//SEND MAIL
			RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , batchEndTime
                                                        , recordsSuccessful
                                                        , recordsFailed
														, csvHeaderStr
                                                        , jobDailyName
                                                        , sObjectName
                                                        , sendToEmail
                                                        , CSV_BODY);
		}
    }
}