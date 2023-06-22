public without sharing class QCA_LogCallLogVisitController {
    public QCA_LogCallLogVisitController() {

    }

    public static Map<Id, Call_Report__c> getVisitPlanReportList(Id leadObjId, String flowType, Id visitPlanId)
    {   
        if(flowType == 'QCAOpptyType') {
            return new Map<Id, Call_Report__c>([
                SELECT Id, Lead__c, RecordTypeId, RecordType.Name, Outcome__c, Status__c, Actual_Visit_Date__c, Date_of_Visit__c, Customer_name__c, Meeting_Place__c, Loss_Incomplete_reason__c, Business_talk_and_opportunity__c
                FROM Call_Report__c
                WHERE Id =: visitPlanId 
                ORDER BY LastModifiedDate DESC
            ]);
        } else if(flowType == 'QCALeadType') {
            return new Map<Id, Call_Report__c>([
                SELECT Id, Lead__c, RecordTypeId, RecordType.Name, Outcome__c, Status__c, Actual_Visit_Date__c, Date_of_Visit__c, Customer_name__c, Meeting_Place__c, Loss_Incomplete_reason__c, Business_talk_and_opportunity__c
                FROM Call_Report__c
                WHERE Lead__c =: leadObjId
                ORDER BY LastModifiedDate DESC
            ]);
        }   
        return null;
    }

    public static Map<Id, Visit_Report_Opportunity__c> getVisitReportOpptyList(Id opptyId){
        return new Map<id,Visit_Report_Opportunity__c>([
            SELECT Id, Customer__c, Opportunity__c 
            FROM Visit_Report_Opportunity__c
            WHERE Opportunity__c=:opptyId
            ORDER BY LastModifiedDate DESC
        ]);
    }

    public static Map<Id, Task> getTaskList(Id leadObjId)
    {
        return new Map<Id, Task>([
            SELECT Id, RecordTypeId, OwnerId, WhoId, Subject, ActivityDate, Description, RTL_Call_Date_Time__c, Main_Task__c, Sub_Task__c, Reference_Job_Id__c, Status, Priority
            FROM Task
            WHERE WhoId =: leadObjId
            ORDER BY LastModifiedDate DESC
        ]);
    }

    @AuraEnabled
    public static Task getMyTaskLastedInforamtion(Id leadObjId){
        Map<Id, Task> tmpMapTask = getTaskList(leadObjId);
        return !tmpMapTask.isEmpty() ? (Task)tmpMapTask.values().get(0) : null;
    }
    
    @AuraEnabled
    public static Call_Report__c getMyVisitPlanReportLastedInforamtion(Id leadObjId, String flowType,Id opptyId){
        Map<Id, Call_Report__c> tmpMapCallReport = new  Map<Id, Call_Report__c>();
        if(flowType == 'QCAOpptyType'){
            List<Visit_Report_Opportunity__c> tmpVistOppty = getMyVisitReportOpportunityLasted(opptyId);
            if( tmpVistOppty.size() > 0){
                 tmpMapCallReport = getVisitPlanReportList(leadObjId, flowType, tmpVistOppty[0].Customer__c);
            }
            return !tmpMapCallReport.isEmpty()  ? (Call_Report__c)tmpMapCallReport.values().get(0) : null;
        }
        else if(flowType == 'QCALeadType') {
            tmpMapCallReport = getVisitPlanReportList(leadObjId, flowType, null);
            return !tmpMapCallReport.isEmpty() ? (Call_Report__c)tmpMapCallReport.values().get(0) : null;
        }
        return null;
    }

    @AuraEnabled
    public static List<Visit_Report_Opportunity__c> getMyVisitReportOpportunityLasted(Id opptyId){
        Map<Id, Visit_Report_Opportunity__c> tmpMapVisitReportOppty = getVisitReportOpptyList(opptyId);
        return !tmpMapVisitReportOppty.isEmpty() ? (List<Visit_Report_Opportunity__c>)tmpMapVisitReportOppty.values() : new List<Visit_Report_Opportunity__c>();
    }

    @AuraEnabled
    public static Call_Report__c UpdateVisitPlanReport(Call_Report__c callReportObj){
        try {
            Call_Report__c tmpCallReport = (Call_Report__c)callReportObj;
            // tmpCallReport.Id = callReportObjId;
            // tmpCallReport.RecordTypeId = QCA_LeadSimplifiedController.VisitPlanforLeadRecordTypeId;
            upsert tmpCallReport;

            return tmpCallReport;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Call_Report__c UpdateVisitPlanReportOppty(Call_Report__c callReportObj, Id opptyId){
        try {
            Call_Report__c tmpCallReport = (Call_Report__c)callReportObj;
            // tmpCallReport.Id = callReportObjId;
            // tmpCallReport.RecordTypeId = QCA_LeadSimplifiedController.VisitPlanforLeadRecordTypeId;
            upsert tmpCallReport;

            List<Visit_Report_Opportunity__c> tmpVisitOpptyList = getMyVisitReportOpportunityLasted(opptyId);
            if(tmpVisitOpptyList.size() > 0){
                if(tmpVisitOpptyList[0].Customer__c == null){
                    tmpVisitOpptyList[0].Customer__c = tmpCallReport.id;
                    tmpVisitOpptyList[0].Opportunity__c = opptyId;
                }
            }else{
                Visit_Report_Opportunity__c tmpVisitOppty = new Visit_Report_Opportunity__c();
                tmpVisitOppty.Customer__c = tmpCallReport.id;
                tmpVisitOppty.Opportunity__c = opptyId;
                tmpVisitOpptyList.add(tmpVisitOppty);
            }
            upsert tmpVisitOpptyList;
            return tmpCallReport;
        }catch(DmlException e){
            String msg = '';
            //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
            //we can get from DmlException
                
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
                // System.debug('msg : '+msg);
            }
            //throw DML exception message
            throw new AuraHandledException(msg);
             
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Task UpdateTaskRecord(Task taskObj){
        try {
            Task tmpTaskObj = (Task)taskObj;
            upsert tmpTaskObj;

            return tmpTaskObj;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class TaskValuesWrapper {
        @AuraEnabled
        public Set<String> mainTaskValues {get; set;}
        @AuraEnabled
        public Map<String, List<SmartBDM_PicklistOption>> subjectTaskValues {get; set;}
        @AuraEnabled
        public List<SmartBDM_PicklistOption> statusValues {get; set;}
        @AuraEnabled
        public List<SmartBDM_PicklistOption> priorityValues {get; set;}
    }

    @AuraEnabled
    public static TaskValuesWrapper getTaskValues()
    {
        TaskValuesWrapper taskValuesWrapper = new TaskValuesWrapper();
        Map<String, List<SmartBDM_PicklistOption>> MainTaskAndSubTaskMap = getTaskDependencyFieldValues('Main_Task__c', 'Sub_Task__c');
        taskValuesWrapper.mainTaskValues = MainTaskAndSubTaskMap.keySet();
        taskValuesWrapper.subjectTaskValues = MainTaskAndSubTaskMap;
        taskValuesWrapper.statusValues = getTaskFieldValues('Status');
        taskValuesWrapper.priorityValues = getTaskFieldValues('Priority');
        return taskValuesWrapper;
    }

    public static List<SmartBDM_PicklistOption> getTaskFieldValues(String FieldAPIName)
    {
        return SmartBDM_PicklistDescriber.describe('Task', QCA_LeadSimplifiedController.TaskRecordTypeId, FieldAPIName);
    }

    public static Map<String, List<SmartBDM_PicklistOption>> getTaskDependencyFieldValues(String FieldAPIName1st, String FieldAPIName2nd)
    {
        // List<SmartBDM_PicklistOption> options = new List<SmartBDM_PicklistOption>();
        Schema.sObjectType sobjectType = Task.getSObjectType();
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();

        Schema.SObjectField ctrlField = fieldMap.get(FieldAPIName1st);
        Schema.SObjectField targetField = fieldMap.get(FieldAPIName2nd);

        Map<String, List<SmartBDM_PicklistOption>> dependencyField = HL_FieldDescribeUtil.getDependentOptionsImpl(targetField, ctrlField);
        return dependencyField;
    }

    @AuraEnabled
    public static Map<String, List<SmartBDM_PicklistOption>> getVisitPlanReportDependencyFieldValues(String FieldAPIName1st, String FieldAPIName2nd)
    {
        // List<SmartBDM_PicklistOption> options = new List<SmartBDM_PicklistOption>();
        Schema.sObjectType sobjectType = Call_Report__c.getSObjectType();
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();

        Schema.SObjectField ctrlField = fieldMap.get(FieldAPIName1st);
        Schema.SObjectField targetField = fieldMap.get(FieldAPIName2nd);

        Map<String, List<SmartBDM_PicklistOption>> dependencyField = HL_FieldDescribeUtil.getDependentOptionsImpl(targetField, ctrlField);
        return dependencyField;
    }
}