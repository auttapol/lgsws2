global class FXOrderAutoExpireOrderBatch implements Database.Batchable<sObject> {
	
	//String query;
	Private Datetime expirationPeriodTime;
	Private Set<String> fxoStatusToExpired;
	
	global FXOrderAutoExpireOrderBatch() {

		// Get now + 5 minutes to compare with expiration date
		// In case schedule run earlier than expected
		expirationPeriodTime = System.now().addSeconds(300);

		fxoStatusToExpired = new Set<String>();
		fxoStatusToExpired.add('New');
		fxoStatusToExpired.add('Submitted');
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator([
            SELECT id,FXO_Expiration_Date__c,FXO_OrderStatus__c
            FROM FX_Order__c
            WHERE FXO_Expiration_Date__c < :expirationPeriodTime
            AND FXO_OrderStatus__c IN :fxoStatusToExpired
        ]);
	}

   	global void execute(Database.BatchableContext BC, List<FX_Order__c> scope) {
		for(FX_Order__c fxo : scope){

			// Temp remark
			fxo.FXO_Remark__c = 'Expired by Schedule: ' + System.Now().format() ;
			fxo.FXO_OrderStatus__c = 'Expired';
		}

		 Database.SaveResult[] result = Database.update(scope,false);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}