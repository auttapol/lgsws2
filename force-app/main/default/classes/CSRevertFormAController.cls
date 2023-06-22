public without sharing class CSRevertFormAController {
    @AuraEnabled
	public static E_Client_Suitability__c getEclient(String recordId) {

		try 
        {
			E_Client_Suitability__c ec =  [SELECT Id, OwnerId, Name, CS_RM__r.Name, CS_Sales_Owner__r.Name,
			CS_Customer__r.Name, CS_Status__c, LastModifiedBy.Name, CreatedDate, LastModifiedDate,
			CS_Customer_Survey_A__c, CS_Customer_Survey_B__c
			FROM E_Client_Suitability__c
			WHERE Id =:recordId
			];
			return ec;
		}
		catch (Exception e)
		{
			System.debug(e.getMessage() );
    		throw new AuraHandledException(System.Label.E_Client_CSCancelEClientController_GetEclient_Error_Msg);
		}	
	}

    @AuraEnabled
    public static Boolean revertFormA(String ecId,String comment){
        try 
        {
            Id pendingRecordTypeId = Schema.Sobjecttype.E_Client_Suitability__c.getRecordTypeInfosByName().get('Reviewing').getRecordTypeId();
            
            E_Client_Suitability__c ec =  [SELECT Id, OwnerId, Name, CS_RM__r.Name, CS_Sales_Owner__r.Name,
			CS_Customer__r.Name, CS_Status__c, LastModifiedBy.Name, CreatedDate, LastModifiedDate,
			CS_Customer_Survey_A__c, CS_Customer_Survey_B__c,Reverse_Reason__c
			FROM E_Client_Suitability__c
			WHERE Id =:ecId
			];

            ec.CS_Status__c = 'Reviewing';
            ec.RecordTypeId = pendingRecordTypeId;
			ec.Reverse_Reason__c = comment;

			ec.RM_TH_Approve_DT__c = null;
			ec.RM_Submitted_By__c = null;
			ec.RM_Submit_Date_Time__c = null; 
			ec.CS_RM_TH_Approved_Date_Tme__c = null;

			ec.Sales_TH_Approved_DT__c = null;
			ec.Sale_Submitted_By__c = null;
			ec.Sale_Submit_Date_Time__c = null; 
			ec.CS_Sales_TH_Approved_Date_Time__c = null;
			
            upsert ec;

            Survey_Sheet__c sh = new Survey_Sheet__c(Id = ec.CS_Customer_Survey_A__c);
            sh.Status__c = 'In Progress';
            sh.Is_SurveyA_Approve__c = false;

            update sh;
            
            return true;
		}
		catch (Exception e)
		{
			System.debug(e.getMessage() );
    		throw new AuraHandledException(e.getMessage() );
		}	
    }

	
}