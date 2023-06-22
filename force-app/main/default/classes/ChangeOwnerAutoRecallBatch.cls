public class ChangeOwnerAutoRecallBatch implements Database.Batchable<sObject>, Database.Stateful {
    final String SEMICO = ',';
    final String jobDailyName = 'Change Owner - Auto Recall Approval And Approver Escalation';
	final String sObjectName = 'Change Owner Approval History';

    private Datetime batchDate = datetime.now();
	private Datetime batchStartTime = datetime.now();
	private Datetime batchEndTime = null;
    private Map<Id, String> mapEscalationResult;

    private Integer RecallDaysChange_Owner_Existing_Customer;
    private Integer RecallDaysChange_Owner_Qualified_Prospect;
    private Integer RecallDaysAdd_Account_Team;
    private Integer RecallDaysChange_Segment;
    private Integer exceedEscalateDays;
    private Integer escalateTotal;

    Datetime dateTimeNow;
    private BusinessHours bh;
    private Set<Id> changeOwnerIdSetRecall;
    private Map<Id, String> mapEscalateResult;

    private Map<String, Recordtype> mapRecordtypeName;

    public ChangeOwnerAutoRecallBatch() {
        System.debug(':::::::::::::::ChangeOwnerAutoRecallBatch:::::::::::::::');
        RecallDaysChange_Owner_Existing_Customer = Integer.valueOf(AppConfig__c.getValues('Auto Recall Change Owner Approval flow').Value__c);
        RecallDaysChange_Owner_Qualified_Prospect = Integer.valueOf(AppConfig__c.getValues('Auto Recall: Change Owner Prospect').Value__c);
        RecallDaysAdd_Account_Team = Integer.valueOf(AppConfig__c.getValues('Auto Recall: Request Account Team').Value__c);
        exceedEscalateDays = Integer.valueOf(AppConfig__c.getValues('Auto Reassign Current Approver').Value__c);
        RecallDaysChange_Segment = Integer.valueOf(AppConfig__c.getValues('Auto Recall: Change Segment').Value__c);


        dateTimeNow = Datetime.now();
        // Get the default business hours
        bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];

        mapEscalationResult = new Map<Id, String> ();

        escalateTotal = 0;

        changeOwnerIdSetRecall = new Set<Id>();
        mapEscalateResult = new Map<Id, String>();

        mapRecordtypeName = new Map<String, Recordtype> ();
        for(Recordtype rt : [SELECT id, DeveloperName FROM recordType WHERE SobjectType = 'Change_Owner_Approval_History__c']) {
            mapRecordtypeName.put(rt.DeveloperName, rt);
        }
    }

    public ChangeOwnerAutoRecallBatch(Integer month, Integer day) {
        System.debug(':::::::::::::::ChangeOwnerAutoRecallBatch:::::::::::::::');
        System.debug('month : ' + month);
        System.debug('day : ' + day);
        RecallDaysChange_Owner_Existing_Customer = Integer.valueOf(AppConfig__c.getValues('Auto Recall Change Owner Approval flow').Value__c);
        RecallDaysChange_Owner_Qualified_Prospect = Integer.valueOf(AppConfig__c.getValues('Auto Recall: Change Owner Prospect').Value__c);
        RecallDaysAdd_Account_Team = Integer.valueOf(AppConfig__c.getValues('Auto Recall: Request Account Team').Value__c);
        exceedEscalateDays = Integer.valueOf(AppConfig__c.getValues('Auto Reassign Current Approver').Value__c);
        RecallDaysChange_Segment = Integer.valueOf(AppConfig__c.getValues('Auto Recall: Change Segment').Value__c);

        dateTimeNow = Datetime.newInstance(Datetime.now().year(), month, day, Datetime.now().hour(), Datetime.now().minute(), Datetime.now().second());
        // Get the default business hours
        bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];

        mapEscalationResult = new Map<Id, String> ();

        escalateTotal = 0;

        changeOwnerIdSetRecall = new Set<Id>();
        mapEscalateResult = new Map<Id, String>();

        mapRecordtypeName = new Map<String, Recordtype> ();
        for(Recordtype rt : [SELECT id, DeveloperName FROM recordType WHERE SobjectType = 'Change_Owner_Approval_History__c']) {
            mapRecordtypeName.put(rt.DeveloperName, rt);
        }
    }


    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::::::::::::::start:::::::::::::::');
        batchStartTime = datetime.now();
        return Database.getQueryLocator([
            SELECT Id, Approval_Start_Wait_Time__c, Approval_Step_Start_Wait_Time__c, Change_Owner_Approval_Status__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c, RecordTypeId
            FROM Change_Owner_Approval_History__c
            WHERE Change_Owner_Approval_Status__c NOT IN ('Final Approved', 'Rejected', 'Recalled') 
            AND Approval_Step_Start_Wait_Time__c <> NULL
            AND Approval_Start_Wait_Time__c <> NULL
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Change_Owner_Approval_History__c> scope) {
        System.debug(':::::::::::::::execute:::::::::::::::');
       
        Map<Id, Change_Owner_Approval_History__c> mapScope = new Map<Id, Change_Owner_Approval_History__c> (scope);
        
        Set<Id> userIdset = new Set<Id> ();
        Map<Id, Change_Owner_Approval_History__c> mapChangeOwnerEscalate = new Map<Id, Change_Owner_Approval_History__c>  ();
        
        List<ProcessInstanceWorkitem> updatePiwlst = new List<ProcessInstanceWorkitem>();
        List<Change_Owner_Approval_History__c> updateChangeOwnHis = new List<Change_Owner_Approval_History__c>();

        System.debug('BusinessHours.isWithin(bh.Id, dateTimeNow)  : ' + BusinessHours.isWithin(bh.Id, dateTimeNow) );
        System.debug('!Test.isRunningTest() : ' + Test.isRunningTest());
         
        if(BusinessHours.isWithin(bh.Id, dateTimeNow) || Test.isRunningTest() ){
            List<User> userlst = new List<User>();

            for(Change_Owner_Approval_History__c changeownerHistory : scope){
                System.debug('changeownerHistory : ' + changeownerHistory);

                if(changeownerHistory.Approver1__c != null)
                    userIdset.add(changeownerHistory.Approver1__c);
                if(changeownerHistory.Approver2__c != null)
                    userIdset.add(changeownerHistory.Approver2__c);
                if(changeownerHistory.Approver3__c != null)
                    userIdset.add(changeownerHistory.Approver3__c);
                if(changeownerHistory.Approver4__c != null)
                    userIdset.add(changeownerHistory.Approver4__c);

                if(changeownerHistory.RecordTypeId == mapRecordtypeName.get('Change_Owner_Existing_Customer').id){
                    if (BusinessHours.diff(bh.Id, changeownerHistory.Approval_Start_Wait_Time__c, dateTimeNow) >= (RecallDaysChange_Owner_Existing_Customer * 24 * 60 * 60 * 1000)) {
                        System.debug(':::: RECALL ::::');
                        changeOwnerIdSetRecall.add(changeownerHistory.Id);
                    }else if(BusinessHours.diff(bh.Id, changeownerHistory.Approval_Step_Start_Wait_Time__c, dateTimeNow) >= (exceedEscalateDays * 24 * 60 * 60 * 1000)){
                        System.debug(':::: ESCALATE ::::');
                        escalateTotal += 1;
                        mapChangeOwnerEscalate.put(changeownerHistory.id, changeownerHistory);
                    }
                }else if(changeownerHistory.RecordTypeId == mapRecordtypeName.get('Change_Owner_Qualified_Prospect').id){
                    if (BusinessHours.diff(bh.Id, changeownerHistory.Approval_Start_Wait_Time__c, dateTimeNow) >= (RecallDaysChange_Owner_Qualified_Prospect * 24 * 60 * 60 * 1000)) {
                        System.debug(':::: RECALL ::::');
                        changeOwnerIdSetRecall.add(changeownerHistory.Id);
                    }
                }else if(changeownerHistory.RecordTypeId == mapRecordtypeName.get('Add_Account_Team').id){
                    if (BusinessHours.diff(bh.Id, changeownerHistory.Approval_Start_Wait_Time__c, dateTimeNow) >= (RecallDaysAdd_Account_Team * 24 * 60 * 60 * 1000)) {
                        System.debug(':::: RECALL ::::');
                        changeOwnerIdSetRecall.add(changeownerHistory.Id);
                    }
                }else if(changeownerHistory.RecordTypeId == mapRecordtypeName.get('Change_Segment').id){
                    if (BusinessHours.diff(bh.Id, changeownerHistory.Approval_Start_Wait_Time__c, dateTimeNow) >= (RecallDaysChange_Segment * 24 * 60 * 60 * 1000)) {
                        System.debug(':::: RECALL ::::');
                        changeOwnerIdSetRecall.add(changeownerHistory.Id);
                    }
                }
            }

            //Recall if anyway if any approver is inactive
            if(userIdset.size() > 0){
                Map<Id, User> mapRecallUserCheck = new Map<Id, User> ([SELECT Id, IsActive FROM User WHERE Id IN :userIdset]);

                for(Change_Owner_Approval_History__c changeownerHistory : scope){
                    Boolean criteria1 = (changeownerHistory.Approver1__c != null && !mapRecallUserCheck.get(changeownerHistory.Approver1__c).IsActive);
                    Boolean criteria2 = (changeownerHistory.Approver2__c != null && !mapRecallUserCheck.get(changeownerHistory.Approver2__c).IsActive);
                    Boolean criteria3 = (changeownerHistory.Approver3__c != null && !mapRecallUserCheck.get(changeownerHistory.Approver3__c).IsActive);
                    Boolean criteria4 = (changeownerHistory.Approver4__c != null && !mapRecallUserCheck.get(changeownerHistory.Approver4__c).IsActive);
                    
                    Boolean MatchCriteriaRecall = criteria1 || criteria2 || criteria3 || criteria4;

                    if(MatchCriteriaRecall){
                        changeOwnerIdSetRecall.add(changeownerHistory.Id);
                    }
                }
            }

            //ESCALATE PROCESS --- (RECALL PROCESS IN FINISH)
            if(mapChangeOwnerEscalate.size() > 0){
                Map<Id, String> result = ChangeOwnerAutoRecallBatchUtil.reassignApprover(mapChangeOwnerEscalate);
                //Custbase P2 Change flow not longer reassign to salesmanagement.
                // for (Id recid : result.keySet()) {
                //     if(result.get(recid) == 'SalesManagement inactive'){
                //         changeOwnerIdSetRecall.add(recid);
                //         result.remove(recid);
                //     }
                // }
                mapEscalateResult.putAll(result);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug(':::::::::::::::finish:::::::::::::::');
        System.debug('batchDate : ' + batchDate);
        System.debug('batchStartTime : ' + batchStartTime);
        try{
            List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :changeOwnerIdSetRecall];
            
            List<Approval.ProcessWorkitemRequest> reqList = new List<Approval.ProcessWorkitemRequest>();
            
            for (ProcessInstanceWorkitem p : piwi) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Auto recall performed by system');
                req.setAction('Removed');
                req.setWorkitemId(p.Id);
                reqList.add(req);
            }

            List<Approval.ProcessResult> resultProcess = Approval.process(reqList);
        }
        catch (Exception e){
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
        }

        batchEndTime = datetime.now();

        Integer recordsSuccessful = escalateTotal - mapEscalateResult.size();
		Integer recordsFailed = mapEscalateResult.size();

        String csvHeaderStr = 'ChangeOwnerApprovalHistoryId, Result';
		String CSV_BODY  = '';
        String resultMessage;

        for(Id id : mapEscalateResult.keySet()){
            resultMessage = mapEscalateResult.get(id);
			System.debug(id + ' : ' + resultMessage);

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

        if(escalateTotal > 0){
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