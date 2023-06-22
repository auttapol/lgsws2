trigger CaseTrigger on Case (before insert, after insert,before update, after update, after delete, after undelete) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true'; 
    Id kycRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('KYC System').getRecordTypeId();
    Id closedKycRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Closed KYC System').getRecordTypeId();
    List<Case> kycCases = new List<Case>();
    List<Case> newCases = new List<Case>();

    if(Trigger.New != null) {
        for(Case nCase : Trigger.New) {
            if(nCase.RecordTypeId == kycRecordTypeId || nCase.RecordTypeId == closedKycRecordTypeId) {
                kycCases.add(nCase);
            } else {
                newCases.add(nCase);
            }
        }
    }
    
     // Before insert record to database
    System.debug('Trigger Start Before insert ' + RESTOpportunityUtil.getTHDatetimeNOW());
     if(Trigger.isBefore && Trigger.isInsert) 
     {           
        if(RunTrigger || Test.isRunningTest()){
            //Check validation rule
            CaseValidationRule.checkValidate(Trigger.New);
            if(newCases.size() > 0) {
                CaseTriggerHandler.handleBeforeInsert(Trigger.New);    
            }
            if(kycCases.size() > 0) {
                // handle kyc cases
                CaseTriggerHandler.autoAssignKYCCaseOwner(kycCases);
            }
        }
    }
    System.debug('Trigger End Before insert ' + RESTOpportunityUtil.getTHDatetimeNOW());
    
    //  After insert record to database
    System.debug('Trigger Start After insert ' + RESTOpportunityUtil.getTHDatetimeNOW());
     if(Trigger.isAfter && Trigger.isInsert) 
     {              
        if(RunTrigger || Test.isRunningTest()){
            CaseTriggerHandler.handleAfterInsert(Trigger.New);

            // Check send SMS
            caseSMSButtonCtl callSendSMS = new caseSMSButtonCtl();
            callSendSMS.checkSendSMSAfterInsert(Trigger.New);

            //CXMServiceProvider
            CXMServiceProvider cxmProvider = new CXMServiceProvider();
            cxmProvider.integrateToCXM(null,Trigger.NewMap);
        }
    }
    System.debug('Trigger End After insert ' + RESTOpportunityUtil.getTHDatetimeNOW());
    
    //Before update record to database
    if(Trigger.isBefore && Trigger.isUpdate){
        if(RunTrigger || Test.isRunningTest()){
            //Check validation rule
            CaseValidationRule.checkValidate(Trigger.New);
            if(newCases.size() > 0) {
                CaseTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.NewMap);
            }
            if(kycCases.size() > 0) {
                // handle kyc cases
                CaseTriggerHandler.autoAssignKYCApprover(Trigger.oldMap, kycCases);
            }
        }
    }
    
    //After update record to database
    if(Trigger.isAfter && Trigger.isUpdate){
         if(RunTrigger || Test.isRunningTest()){ 

            CaseTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.NewMap);

            //Check send SMS
            caseSMSButtonCtl callSendSMS = new caseSMSButtonCtl();
            callSendSMS.checkSendSMS(Trigger.oldMap, Trigger.NewMap);

            //CXMServiceProvider
            CXMServiceProvider cxmProvider = new CXMServiceProvider();
            cxmProvider.integrateToCXM(Trigger.oldMap,Trigger.NewMap, true);

            //Send closed case date update to ECM
            // UpdateToECMController callUpdateECM = new UpdateToECMController();
            // callUpdateECM.caseClosedFromTrigger(Trigger.oldMap,Trigger.NewMap);
         }
    } 
}