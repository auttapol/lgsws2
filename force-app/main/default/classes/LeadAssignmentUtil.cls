public class LeadAssignmentUtil {
    public static Map<Id, RTL_Lead_Assignment_Rule__c>  leadAssignmentRule {
        get{
            if(leadAssignmentRule == null){
                leadAssignmentRule = new Map<Id, RTL_Lead_Assignment_Rule__c>([SELECT Id, Name, RTL_Active_Flag__c, RTL_Priority__c, RTL_Lead_Record_Type__c, RTL_Integration_Type__c, RTL_Lead_Field_Criteria_1__c, RTL_Lead_Field_Criteria_2__c, RTL_Lead_Field_Criteria_3__c, RTL_Lead_Field_Criteria_4__c, RTL_Lead_Field_Criteria_5__c, RTL_Lead_Field_Value_1__c, RTL_Lead_Field_Value_2__c, RTL_Lead_Field_Value_3__c, RTL_Lead_Field_Value_4__c, RTL_Lead_Field_Value_5__c, RTL_Assigned_User__c, RTL_Assigned_User_field__c, RTL_Assigned_Queue_Name__c, RTL_Branch_and_Zone_Queue_User_field__c, RTL_Default_Queue_Name__c, RTL_Default_User__c, RTL_IsAssign_Campaign__c, RTL_Assigned_Apex__c, RTL_IsInsertProduct__c FROM RTL_Lead_Assignment_Rule__c WHERE RTL_Active_Flag__c = true ORDER BY RTL_Priority__c]);
            }
            return leadAssignmentRule;
        }
        set{}
    }

    public static User tmbAdmin {
        get{
            if(tmbAdmin == null){
                tmbAdmin = [SELECT Id, Name FROM User WHERE Name = 'TMB Administrator'];
            }
            return tmbAdmin;
        }
        set;
    }

    public static Map<Id, Group> mapIdQueue{
        get{
            if(mapIdQueue == null){
                mapIdQueue = new Map<id, Group>([SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']);
            }
            return mapIdQueue;
        }set;
    }

    public static Map<String, Group> queueMapFullName {
        get{
            if(queueMapFullName == null){
                queueMapFullName = new Map<String, Group>();
                for(Group queue : mapIdQueue.values()) {
                    queueMapFullName.put(queue.DeveloperName, queue);
                }
            }
            return queueMapFullName;
        }set;
    }

    public static Map<String, Group> mapBranchCodeQueueName {
        get{
            if(mapBranchCodeQueueName == null){
                mapBranchCodeQueueName = new Map<String, Group>();
                for(String qName : queueMapFullName.keySet()){
                    String branchCode = qName; //e.g. DeveloperName=RTLQ_001, branchcode=001
                    if(qName.indexOf('_') != -1) {
                        branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
                    }
                    mapBranchCodeQueueName.put(branchCode, queueMapFullName.get(qName));
                }
            }
            return mapBranchCodeQueueName;
        }set;
    }

    public static Map<String, Branch_and_Zone__c> mapBranchCode{
        get{
            if(mapBranchCode == null){
                mapBranchCode = new Map<String, Branch_and_Zone__c>();
                String queryBranchField = RTL_Utility.queryAllField('Branch_and_Zone__c');
                queryBranchField = queryBranchField.substring(0, queryBranchField.length()-1);
                String queryStr = 'SELECT ' + queryBranchField + ' FROM Branch_and_Zone__c WHERE isActive__c = true';
                // System.debug('queryStr: ' + queryStr);
                List<Branch_and_Zone__c> tempObj = Database.query(queryStr);
    
                for(Branch_and_Zone__c branchzone : tempObj){
                    mapBranchCode.put(branchzone.Branch_Code__c, branchzone);
                }
            }
            return mapBranchCode;
        }set;
        
    }
    
    public static Map<String, User> mapIdUser{
        get{
            if(mapIdUser == null){
                mapIdUser = new Map<String, User> ([
                    SELECT 
                        Id, Name, RTL_Branch__c, RTL_Branch_Code__c, Employee_ID__c,
                        Region_Code__c, Zone_Code__c, RTL_Channel__c, IsActive 
                    FROM User 
                    WHERE IsActive = true]);
                // Add Employee Id to be Key
                for (User u : mapIdUser.values()) {
                    if(RTL_Utility.isNotNull(u.Employee_ID__c)) mapIdUser.put(u.Employee_ID__c, u);
                }
            }
            return mapIdUser;
        }set;
    }

    public static RTL_AssignmentCriteriaService assignmentService{
        get{
            if(assignmentService == null){
                assignmentService = new RTL_AssignmentCriteriaService();
            }
            return assignmentService;
        }set;
    }

    public static Map<String, Schema.RecordTypeInfo> mapIdReordtypeLead{
        get{
            if(mapIdReordtypeLead == null){
                mapIdReordtypeLead = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName();
            }
            return mapIdReordtypeLead;
        }set;
    }

    public static Map<String, RTL_Product_Outbound_Mapping__mdt> mapProductOutboundDetail {
        get{
            if(mapProductOutboundDetail == null){
                mapProductOutboundDetail = new Map<String, RTL_Product_Outbound_Mapping__mdt>();
                for(RTL_Product_Outbound_Mapping__mdt productOutbound : [SELECT RTL_Product_Name__c, RTL_Contact_Method__c, RTL_Lead_Campaign_Outbound__c, RTL_Lead_Channel_Outbound__c FROM RTL_Product_Outbound_Mapping__mdt] ){
                    mapProductOutboundDetail.put(productOutbound.RTL_Product_Name__c + productOutbound.RTL_Contact_Method__c, productOutbound);
                }
            }
            return mapProductOutboundDetail;
        }
        set;
    }

    public static void assignLeadOwnerByLeadAssignmentrule(List<Lead> listNewLead){
        for(Lead leadObj : listNewLead){
            RTL_Lead_Assignment_Rule__c matchRule = getAssignMatchedRule(leadObj);
            leadObj.RTL_Lead_Assigned_By_Rule__c = !(RTL_Lead_Assignment__c.getValues('Auto Assign') != null && RTL_Lead_Assignment__c.getValues('Auto Assign').Enable__c) ? null : matchRule != null ? matchRule.Id : null;

            if(leadObj.RTL_Lead_Assigned_By_Rule__c != null){
                RTL_Lead_Assignment_Rule__c LeadMatchAssignmentRule = leadAssignmentRule.get(leadObj.RTL_Lead_Assigned_By_Rule__c);
                if(LeadMatchAssignmentRule.RTL_Assigned_Apex__c != null){
                    //ASSIGN APEX FUNCTION HERE
                    if(LeadMatchAssignmentRule.RTL_Assigned_Apex__c == 'RTL_AssignmentCriteriaService'){
                        Boolean isMultipleProducts = leadObj.RTL_Multiple_Interested_Product_s__c == null ? false : leadObj.RTL_Multiple_Interested_Product_s__c;
                        String queueName = assignmentService.assignmentCriteria(leadObj.RTL_TMB_Campaign_Source__c, leadObj.RTL_BranchW2L_Area__c, leadObj.RTL_Product_Name__c, isMultipleProducts, leadObj.RTL_Branch_Name__c);
                        leadObj.ownerId = mapBranchCodeQueueName.containsKey(queueName) ? mapBranchCodeQueueName.get(queueName).Id : tmbAdmin.id;
                    }
                    //****** ADD APEX FUNCTION HERE (as else if) ****** 
                }else{

                    if(LeadMatchAssignmentRule.RTL_Integration_Type__c != null){
                        leadObj.RTL_Lead_Campaign_Outbound__c = mapProductOutboundDetail.containsKey(leadObj.RTL_Product_Name__c + leadObj.RTL_Contact_Method__c) ? mapProductOutboundDetail.get(leadObj.RTL_Product_Name__c + leadObj.RTL_Contact_Method__c).RTL_Lead_Campaign_Outbound__c : null;
                        leadObj.RTL_Lead_Channel_Outbound__c = mapProductOutboundDetail.containsKey(leadObj.RTL_Product_Name__c + leadObj.RTL_Contact_Method__c) ? mapProductOutboundDetail.get(leadObj.RTL_Product_Name__c + leadObj.RTL_Contact_Method__c).RTL_Lead_Channel_Outbound__c : null;
                    }

                    assignLeadOwnerByRule(leadObj, LeadMatchAssignmentRule);
                }
            }
        }
    }

    private static RTL_Lead_Assignment_Rule__c getAssignMatchedRule(lead leadObj){
        RTL_Lead_Assignment_Rule__c result;
        for(RTL_Lead_Assignment_Rule__c rule : leadAssignmentRule.values()){
            if(mapIdReordtypeLead.containsKey(rule.RTL_Lead_Record_Type__c) == null || mapIdReordtypeLead.get(rule.RTL_Lead_Record_Type__c).getRecordTypeId() != leadObj.RecordtypeId) continue;
            if(checkCriteria(leadObj, rule)){
                result = rule;
                break;
            }
        }
        return result;
    }

    private static Boolean checkCriteria(Lead leadObj, RTL_Lead_Assignment_Rule__c rule){
        Boolean result = false;

        Boolean cond1 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_1__c);
        Boolean cond2 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_2__c);
        Boolean cond3 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_3__c);
        Boolean cond4 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_4__c);
        Boolean cond5 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_5__c);

        cond1 = checkCondition(rule.RTL_Lead_Field_Criteria_1__c, leadObj, rule.RTL_Lead_Field_Value_1__c);
        cond2 = checkCondition(rule.RTL_Lead_Field_Criteria_2__c, leadObj, rule.RTL_Lead_Field_Value_2__c);
        cond3 = checkCondition(rule.RTL_Lead_Field_Criteria_3__c, leadObj, rule.RTL_Lead_Field_Value_3__c);
        cond4 = checkCondition(rule.RTL_Lead_Field_Criteria_4__c, leadObj, rule.RTL_Lead_Field_Value_4__c);
        cond5 = checkCondition(rule.RTL_Lead_Field_Criteria_5__c, leadObj, rule.RTL_Lead_Field_Value_5__c);

        if(cond1 && cond2 && cond3 && cond4 && cond5){
            result = true;           
        }

        return result;
    }

    private static Boolean checkCondition(String cond, SObject data, String condValue){
        if(cond == null || cond == ''){
            return true;
        }

        if(String.valueOf(data.get(cond)) == condValue){
        	return true;    
        }
        return false;
    }

    private static void assignLeadOwnerByRule(Lead leadObj, RTL_Lead_Assignment_Rule__c LeadMatchAssignmentRule){
        // 2.1 Assigned User
        if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Assigned_User__c)){
            if(mapIdUser.containsKey(LeadMatchAssignmentRule.RTL_Assigned_User__c)){
                leadObj.ownerId = LeadMatchAssignmentRule.RTL_Assigned_User__c;
                return ;
            }
        }
        // 2.2 Assigned User field
        if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Assigned_User_field__c)){
            if(mapIdUser.containsKey(String.valueOf(leadObj.get(LeadMatchAssignmentRule.RTL_Assigned_User_field__c)))){
                leadObj.ownerId = mapIdUser.get(String.valueOf(leadObj.get(LeadMatchAssignmentRule.RTL_Assigned_User_field__c))).Id;
                return ;
            }
        }
        
        // 3.1 Assigned Queue Name	
        if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Assigned_Queue_Name__c)){
            if(queueMapFullName.containsKey(LeadMatchAssignmentRule.RTL_Assigned_Queue_Name__c)){
                leadObj.ownerId = queueMapFullName.get(LeadMatchAssignmentRule.RTL_Assigned_Queue_Name__c).Id;
                return ;
            }
        }
        
        // 3.2 Branch and Zone Queue/User field
        if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)){
            if(mapBranchCode.ContainsKey(leadObj.RTL_Branch_Name__c) && queueMapFullName.containsKey(String.valueOf(mapBranchCode.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)))){
                leadObj.ownerId = queueMapFullName.get(String.valueOf(mapBranchCode.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c))).Id;
                return ;
            }
            
            try{
                if(mapIdUser.containsKey(String.valueOf(mapBranchCode.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)))){
                    User u = mapIdUser.get(String.valueOf(mapBranchCode.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)));
                    if(u != null){
                        System.debug(u);
                        leadObj.ownerId = u.Id;
                        return ;
                    }
                }
            }catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        
        // 4.1 Default Queue Name
        if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Default_Queue_Name__c)){
            if(queueMapFullName.containsKey(LeadMatchAssignmentRule.RTL_Default_Queue_Name__c)){
                leadObj.ownerId = queueMapFullName.get(LeadMatchAssignmentRule.RTL_Default_Queue_Name__c).Id;
                return ;
            }
        }
        
        // 4.2 Default User
        if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Default_User__c)){
            if(mapIdUser.containsKey(LeadMatchAssignmentRule.RTL_Default_User__c)){
                leadObj.ownerId = LeadMatchAssignmentRule.RTL_Default_User__c;
                return ;
            }
        }
    }
}