public without sharing class S2OUtil {
	
	public static Map<String,S2O_Code_Mapping__c> getAllS2OCodeMap() {
		Map<String,S2O_Code_Mapping__c> s20Map = new Map<String,S2O_Code_Mapping__c>();

		List<S2O_Code_Mapping__c> s2oCodeList = [SELECT Id
													   ,CRM_Task_Key__c
													   ,EWM_Service_Type_Code__c
														,EWM_Service_EN_Type_Desc__c
														,EWM_Service_TH_Type_Desc__c
												FROM S2O_Code_Mapping__c 
												WHERE isActive__c = true
												];

		for (S2O_Code_Mapping__c codeMapping : s2oCodeList) {
			s20Map.put(codeMapping.CRM_Task_Key__c.toLowerCase().replace(' ',''),codeMapping);
		}

		return s20Map;
	}
}