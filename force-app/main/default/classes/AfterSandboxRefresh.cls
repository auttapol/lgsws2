global class AfterSandboxRefresh implements SandboxPostCopy{
	 private String FOR_SANDBOX = 'FOR_SANDBOX';

     global void runApexClass(SandboxContext context) {
     	//clear custom setting
     	clearCustomSetting();
		//createuserAdmin();
     }

     public AfterSandboxRefresh(){}

     public void runExecute() {
     	/**
     		AfterSandboxRefresh refresh = new AfterSandboxRefresh();
			refresh.runExecute();
		**/
     	clearCustomSetting();
		//createuserAdmin();
     }

     private void clearCustomSetting() {
     	String splitFieldName = '0__o';

     	List<For_After_Refresh_Sandbox__c> afterSBList 
     								= [SELECT Id
										     	,Field_Name__c
										     	,Name__c
										     	,Value__c 
										FROM For_After_Refresh_Sandbox__c
									   ];
		List<SObject> sObjListUpdate = New List<SObject>();
		if (afterSBList != null && afterSBList.size() > 0) {
			MAP<String,List<String>> mapResetCS = new MAP<String,List<String>>();
			Map<String,List<SObject>> sObjMap   = new Map<String,List<SObject>>();

			for (For_After_Refresh_Sandbox__c afterSB: afterSBList) {
				String name  = afterSB.Name__c;
				String fieldName  = afterSB.Field_Name__c;

				List<String> valList = afterSB.Value__c.split(',');

				if (mapResetCS.containsKey(name+splitFieldName+fieldName)) {
					List<String> existValList = mapResetCS.get(name+splitFieldName+fieldName);
					existValList.addAll(valList);
				}else {
					mapResetCS.put(name+splitFieldName+fieldName,valList);
				}
			}

			for (String sobjNameField : mapResetCS.KeySet()) {
				List<String> valList = mapResetCS.get(sobjNameField);
				List<String> sobjNameList = sobjNameField.split(splitFieldName);
				String sobjName  = sobjNameList[0];
				String fieldName = sobjNameList[1];

				String joinList = String.join( valList, '\' , \'' );

				String creteriaIn = '(\''+joinList+'\')';
				
				String sql = 'SELECT '+fieldName+' FROM '+sobjName+' WHERE NAME IN '+creteriaIn;
				System.debug(sql);
				List<SObject> sobjList = Database.query(sql);

				for (SObject sobj : sobjList) {
		     		sobj.put(fieldName, FOR_SANDBOX);
		     	}


				sObjMap.put(sobjName,sobjList);
			}

			for (String key : sObjMap.KeySet()) {
				List<SObject> sObjList = sObjMap.get(key);
                sObjListUpdate.addAll(sObjList);
				//update sObjList;
			}
		}
         update sObjListUpdate;
     }

	 /*
	 private void updateNamedCredentails(){
		list<NamedCredential> namedCreListForUpdate = New list<NamedCredential>();
		list<NamedCredential> namedCreList = [SELECT DeveloperName,Endpoint,Id,MasterLabel,PrincipalType FROM NamedCredential];
		if(namedCreList.size() > 0){
			for(NamedCredential nameCre : namedCreList){
				nameCre.Endpoint = 'https://apis-uat';
				namedCreListForUpdate.add(nameCre);
			}
		}

		if(namedCreListForUpdate.size() > 0){
			update namedCreListForUpdate;
		}


	 }
	 */

	 /*
	 private void createuserAdmin(){
		try{
			List<Create_Admin_User_Sandbox__mdt> userAdmin = [Select id, User_ID__c from Create_Admin_User_Sandbox__mdt];
			Set<String> setUserID = New Set<string>();
			if(userAdmin.size() > 0){
				for(Create_Admin_User_Sandbox__mdt uAdmin: userAdmin){
					setUserID.add(uAdmin.User_ID__c);
				}
			}

			List<user> adduserList = New List<user>();

			Id addMinprofileID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
			list<User> userAdminList = [Select ID, Employee_ID__c, Email, Profileid from User where Employee_ID__c in: setUserID];
			if(userAdminList.size() > 0){
				for(integer i = 0; i < userAdminList.size(); i++){
					userAdminList[i].Email = userAdminList[i].Email.replace('.invalid', '');
					userAdminList[i].ProfileID = addMinprofileID;
					System.setPassword(userAdminList[i].Id, 'P@ssw0rd');
					adduserList.add(userAdminList[i]);
				}

				update adduserList;
			}

		}catch(exception e){
			//Do nothing
		}
	}  */
}