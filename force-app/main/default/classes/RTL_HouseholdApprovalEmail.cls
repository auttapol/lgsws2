public class RTL_HouseholdApprovalEmail {

    public static List<RTL_Household_History_and_Approval> historyInEmail {get;set;}
    public static Map<String,RTL_Household_History_Type__mdt> historyTypeMap{get;set;}
    
    private static String householdId;
    private static Map<Id,List<RTL_Household_History_and_Approval__c>> historyMap;
    private static String templateId;
    private static List<Messaging.SingleEmailMessage> emails;
    
    public static Map <String,RTL_Household_History_Type__mdt > getHistoryTypeMdt(){
        Map <String,RTL_Household_History_Type__mdt > historyTypeMapTmp = new Map <String,RTL_Household_History_Type__mdt >();
        
        for(RTL_Household_History_Type__mdt historyType : [SELECT Id,MasterLabel ,DeveloperName ,RTL_English_Value__c , RTL_Thai_Value__c FROM RTL_Household_History_Type__mdt ]){
            historyTypeMapTmp.put(historyType.RTL_English_Value__c,historyType);
            historyTypeMapTmp.put(historyType.RTL_Thai_Value__c,historyType);
        }
        return historyTypeMapTmp;
    }
    
    public static void SendEmail(Id inHouseholdId){
        templateId = [select id, name from EmailTemplate where developername = 'RTL_Household_Approval_Mail_Template'].id;
        emails = new List<Messaging.SingleEmailMessage>();
        householdId = inHouseholdId;
        List<RTL_Household_History_and_Approval__c> historyInEmailDB = querySenttoApproverHistoryList(householdId);
        historyInEmail = new List<RTL_Household_History_and_Approval>();
        historyTypeMap = getHistoryTypeMdt();
        for (RTL_Household_History_and_Approval__c history: historyInEmailDB) {
            historyInEmail.add(newHouseholdApprovalHistory(history));
            history.RTL_Sent_to_Approval__c = true;
        }
        Id approverId = getApproverId(householdId);
        System.debug('HISTORY IN EMAIL ------------ '+historyInEmail);
        generateEmail(householdId,approverId,emails);
        Messaging.sendEmail(emails);

        update historyInEmailDB;
    }
    
    public static List<RTL_Household_History_and_Approval__c> querySenttoApproverHistoryList(String hhid){
        List<RTL_Household_History_and_Approval__c> historyList = [SELECT ID,Name,RTL_Field_Changed__c,RTL_Field_Label__c,RTL_User_Requesting__r.Name ,RTL_Prev_Value__c ,
                       RTL_New_Value__c ,RTL_Outcome__c,RTL_Date_Requested__c ,RTL_Date_Approved__c,RTL_Household_Member__c,
                        RTL_Household__c,RTL_Household__r.Name,RTL_Household_Member__r.Name,RTL_Sent_To_Approval__c,
                        RTL_Section__c,RTL_Sent_to_Requestor__c,RTL_Approver_Link__r.Name
                   FROM RTL_Household_History_and_Approval__c  
                   WHERE RTL_Household__c =: hhid and (RTL_Outcome__c = 'New' or RTL_Outcome__c = 'Pending')];
        return historyList;
    }
    
    public static Id getApproverId(String hhid){
        RTL_Household__c household = [select RTL_RM__r.ManagerId from RTL_Household__c where id = :householdId];
        User approver = [select ManagerId from user where id = :household.RTL_RM__c];
        return approver.ManagerId;
    }
    
    public static void generateEmail(Id whatID,Id targetId,List<Messaging.SingleEmailMessage> emailList){
        emailList.clear();
        Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(targetId);//Set Requestor Id as a targetObjectId
        mail.setWhatId(whatId);
        mail.setTemplateId(templateId);     
        emailList.add(mail);
    }
    
    public static RTL_Household_History_and_Approval newHouseholdApprovalHistory(RTL_Household_History_and_Approval__c history) {
        RTL_Household_History_and_Approval approvalHistory = new RTL_Household_History_and_Approval();
        approvalHistory.RTL_Section = history.RTL_Section__c;
        approvalHistory.RTL_Field_Label = history.RTL_Field_Label__c;
        approvalHistory.RTL_Field_Changed = history.RTL_Field_Changed__c;
        if (history.RTL_Household_Member__r != null)
            approvalHistory.RTL_Household_Member = history.RTL_Household_Member__r.Name;
        else if (history.RTL_Household__r != null)
            approvalHistory.RTL_Household_Member = history.RTL_Household__r.Name;
        approvalHistory.RTL_Prev_Value = history.RTL_Prev_Value__c;
        approvalHistory.RTL_New_Value = history.RTL_New_Value__c;
        approvalHistory.RTL_Date_Requested = history.RTL_Date_Requested__c.format();
        approvalHistory.RTL_User_Requesting = history.RTL_User_Requesting__r.Name;
        return approvalHistory;
    }
    
    //Wrapper class
    public class RTL_Household_History_and_Approval{
        public string RTL_Section {get;set;}
        public string RTL_Field_Label {get;set;}
        public string RTL_Field_Changed {get;set;}
        public string RTL_Household_Member {get;set;}
        public string RTL_Prev_Value {get;set;}
        public string RTL_New_Value {get;set;}
        public String RTL_Date_Requested {get;set;}
        public string RTL_User_Requesting {get;set;} 
    }    
}