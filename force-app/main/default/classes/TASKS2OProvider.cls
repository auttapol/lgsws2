public class TASKS2OProvider {
	class TaskValueMap extends RestfulServiceUtil.ValueMapBase {

		private Map<String,S2O_Code_Mapping__c> s2oMap = S2OUtil.getAllS2OCodeMap();

		public override 
 			Boolean isErrorNotCallout(Map<String,String> valueMap){
 				if (valueMap.get('EWM_Service_Type_Code__c') == 'S20 Code Mapping Not Found') {
 					return true;
 				}
 				return false;
 		}

		public override 
 			Map<String,String> prepareValueMap(SObject sobj,EIMManager manager){ 
 				//System.debug('WhatId :'+(String)sobj.get('WhatId'));
 				List<Account> accList = [SELECT Id,TMB_Customer_ID_PE__c,First_name_PE__c
							            ,Last_name_PE__c,ID_Type_PE__c,First_Name_ENG_PE__c,Last_Name_PE_Eng__c
							            ,ID_Number_PE__c,Customer_Type__c,RTL_RM_Name__c
							            ,RTL_Segment__c 
							            ,RecordType.DeveloperName
							            ,Core_Banking_Suggested_Segment__c
							            ,Owner.Segment__c
							            ,Customer_Name_PE_Eng__c
							            ,RTL_Customer_Name_TH__c
							            FROM Account 
							            Where Id =: (String)sobj.get('WhatId')];

				Account acc = accList.get(0);

				String mainTask = (String)sobj.get('Main_Task__c');
				String subTask  = (String)sobj.get('Sub_Task__c');
				String taskKey  = mainTask+subTask;
				//List<S2O_Code_Mapping__c> s2oCodeMapList = S2OUtil.getS2OCodeList(mainTask, subTask);

				Map<String,String> mapData = new Map<String,String>();

				List<EIM_Map__c> eimMapList = manager.getEIMMapReqList();

				String taskObjName = ''+sobj.getSobjectType();
				String accObjName  = ''+acc.getSobjectType();

				for(EIM_Map__c eimMap : eimMapList) {
					String obj = eimMap.Object__c;
					string sffield = eimMap.SF_Field__c;

					if (obj == 'S2O_Code_Mapping__c') {
						S2O_Code_Mapping__c s2oCode = this.s2oMap.get(taskKey.toLowerCase().replace(' ',''));
						if (s2oCode != null ) {
					        mapData.put(sffield,(String)s2oCode.get(sffield));		        
						}else {
							mapData.put(sffield,'S20 Code Mapping Not Found');	
						}
					}else if (obj == taskObjName) {
						mapData.put(sffield,(String)sobj.get(sffield));
					}else if (obj == accObjName) {
						//for (Customer Segment is retrieved from task's customer's Core Bank Segment. 
						//In case of Prospect, User's Segment will be used instead. 
						//And in case, existing customer has no segment, 
						//S2O will return error as they cannot assign the task to appropriate team.) 
						if (sffield == 'Core_Banking_Suggested_Segment__c'
							&& acc.RecordType.DeveloperName != 'Existing_Customer' 
							&& acc.RecordType.DeveloperName != 'Retail_Customer') {
							mapData.put(sffield,acc.Owner.Segment__c);
							continue;
						}
						mapData.put(sffield,(String)acc.get(sffield));
					}else {
						mapData.put(sffield,null);
					}
				}

			return mapData;	
        }
	}

	public static void integrate(List<Sobject> scope,String integrationName) {
		AppConfig__c cf = AppConfig__c.getValues('Is_EWMServiceEnable');
        String isEWMServiceLog = (cf == null ? 'false' : cf.Value__c);

        Boolean isEnable = isEWMServiceLog.equalsIgnoreCase('true'); 

        if (isEnable) {
			IntegrationMapHandler integrateHandler = new IntegrationMapHandler(integrationName);
			
			for (Sobject sobj:scope) {
				String batchSQL = integrateHandler.integrate(sobj);

				if (!String.isBlank(batchSQL)) {
					RestfulServiceUtil restService 
										= new RestfulServiceUtil(batchSQL,integrationName,'WhatId','What.Name');
						
					restService.setValueMapImpl(new TaskValueMap());
					restService.runBatch();
				}
			}
        }		
	}
}