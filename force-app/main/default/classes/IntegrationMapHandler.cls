public class IntegrationMapHandler {
	private Integer MAX_CONDITION_VALUE = 3;
	private Integer MAX_VARIABLE_VALUE = 1;
	private Integration_Mapping__c  intfInfo = null;

	private String NULLVAL = 'null';

	private String EQUALS = 'equals';
	private String NOTEQUALS = 'notequals';
	private String STARTSWITH = 'startswith';

	private String INTEGRATION_NAME;

	public IntegrationMapHandler(String integrationName) {
		this.INTEGRATION_NAME = integrationName;
		List<Integration_Mapping__c> intfInfoList = [SELECT Id
							,Field_Condition_1__c
							,Field_Condition_2__c
							,Field_Condition_3__c
							,Field_Value_1__c
							,Field_Value_2__c
							,Field_Value_3__c
							,Condition_1__c
							,Condition_2__c
							,Condition_3__c
							,Variable_Field_1__c
							,Batch_SQL__c 
							,IsActive__c
							,Is_Log_Only_Bulk_Success__c
							,TOKEN_ENDPOINT_NAME__c
					FROM Integration_Mapping__c 
							WHERE Name =: integrationName
							LIMIT 1];

		intfInfo = intfInfoList.get(0);
	}

	public Boolean isActive() {
		return intfInfo.IsActive__c;
	}

	public String getTokenEndpoint() {
		return intfInfo.TOKEN_ENDPOINT_NAME__c;
	}

	public String getSQL() {
		return intfInfo.Batch_SQL__c;
	}

	public Boolean isLogOnlyBulkSuccess() {
		return intfInfo.Is_Log_Only_Bulk_Success__c;
	}


	private Boolean check_condition(SObject sobj) {
		Map<String, Object> fieldToValue = sobj.getPopulatedFieldsAsMap();
		Set<String> fieldList = fieldToValue.keySet();

		for (Integer i=1;i<=MAX_CONDITION_VALUE;i++) {
			String fieldConditionName = 'Field_Condition_'+i+'__c';
			String fieldValueName 	  = 'Field_Value_'+i+'__c';
			String conditionName      = 'Condition_'+i+'__c';

			String fieldCondition = (String)intfInfo.get(fieldConditionName);
			String fieldValue     = (String)intfInfo.get(fieldValueName);
			String conditionValue     = (String)intfInfo.get(conditionName);
			if (!String.isBlank(fieldCondition) && !String.isBlank(fieldValue)) {

				if (!String.isBlank(fieldValue) && !fieldValue.equalsIgnoreCase(NULLVAL)) {
					if (sobj.get(fieldCondition) == null) return false;

					List<String> fieldValList = fieldValue.split(',');

					String sobjVal = (String)sobj.get(fieldCondition);
					
					if (conditionValue.equalsIgnoreCase(EQUALS)) {
						if (!fieldValList.contains(sobjVal)) {
							return false;
						}
					}else if(conditionValue.equalsIgnoreCase(NOTEQUALS)) {
						if (fieldValList.contains(sobjVal)) {
							return false;
						}
					}else if(conditionValue.equalsIgnoreCase(STARTSWITH)) {
						for (String val : fieldValList) {
							if (!sobjVal.startsWith(val)) return false;
						}
					}
				}else {
					//check equals to null so if not equals to null then return false
					if (conditionValue.equalsIgnoreCase(EQUALS) && sobj.get(fieldCondition) != null) 
						return false; 

					if (conditionValue.equalsIgnoreCase(NOTEQUALS) && sobj.get(fieldCondition) == null) 
						return false; 
				}
			}
			
		}
		return true;
	}

	public String integrate(Sobject sobj) {
		if (intfInfo != null && check_condition(sobj)) {
			String batchSQL = intfInfo.Batch_SQL__c;

			for (Integer i=1;i<=MAX_VARIABLE_VALUE;i++) {
				if (batchSQL.contains('{'+i+'}')) {
					String variableField = (String)intfInfo.get('Variable_Field_'+i+'__c');
					batchSQL = batchSQL.replace('{'+i+'}', '\''+(String)sobj.get(variableField)+'\'');
				}
			}
				
			return batchSQL;
		}
		return null;
	}
}