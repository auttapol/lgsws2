public class RTL_AssignmentCriteriaService {
    
    Map<String, Group> queueMap;
    Map<String, RTL_Messenger_Cover_Area__c> messengerAreaMap;
    Map<String, RTL_Assignment_Criterias__c> ruleMap;
    Map<String, Branch_and_Zone__c> branchCodeMap;
    static final String BRANCH = 'Branch';
    static final String OUTBOUND = 'Outbound';
    static final String TMBADMIN = 'TMB Admin';
    
    public RTL_AssignmentCriteriaService(){
        //Keep the list of the lead queues, where queue Id will be assigned as lead OwnerId
        queueMap = new Map<String, Group>();
        String branchCode = null;
        for(Group queue : [Select Id, DeveloperName from Group where Type = 'Queue']) {
            branchCode = queue.DeveloperName;//e.g. DeveloperName=RTLQ_001, branchcode=001
            if (branchCode.indexOf('_') != -1) {
                branchCode = branchCode.substring(branchCode.indexOf('_')+1, branchCode.length());
            }
            queueMap.put(branchCode, queue);
        } 
        
        //Keep the list of the messenger cover area in map, which will help to determine the lead queue
        messengerAreaMap = new Map<String,RTL_Messenger_Cover_Area__c>();
        for(RTL_Messenger_Cover_Area__c messengerArea : [SELECT RTL_Zip_Code__c,RTL_Area__c FROM RTL_Messenger_Cover_Area__c]){
            messengerAreaMap.put(messengerArea.RTL_Zip_Code__c,messengerArea);
        }
        
        //Keep the list of the lead assignment criteria in map, which will help to determine the lead queue
        ruleMap = new Map<String, RTL_Assignment_Criterias__c>();
        for(RTL_Assignment_Criterias__c rule : [Select Product_Name__r.Name, Destination_BKK__c, Destination_UPC__c from RTL_Assignment_Criterias__c])
            ruleMap.put(rule.Product_Name__r.Name, rule);
                   
        //Keep the branch Name into list for lead owner to lookup
        //CR Web-Drop Lead , query only active branch
        branchCodeMap = new Map<String, Branch_and_Zone__c>();
        for(Branch_and_Zone__c branchzone : [Select Name, Branch_Name__c, Branch_Code__c, RTL_Region_Code__c, RTL_Zone_Code__c from Branch_and_Zone__c WHERE isActive__c = true]) {
            branchCodeMap.put(branchzone.Branch_Code__c, branchzone);
        }


    }
    
    public String assignmentCriteria(String campaignRef,String zipCode,String productName,Boolean isMultipleProducts,String branchCode){
        RTL_Assignment_Criterias__c assignRule = null;
        RTL_Messenger_Cover_Area__c messengerArea = null;
        System.debug('Product Name :: '+ productName);
        System.debug('ZipCode :: '+ zipCode);
        System.debug('isMultipleProducts :: '+ isMultipleProducts);
        System.debug('branchCode :: '+ branchCode);
        System.debug('campaignRef :: '+ campaignRef);

        assignRule = ruleMap.get(productName);
        String Destination = null;
        //If is call me now assign to outbound
        //Disable from redesign droplead retail 2020-05-29
        // if(campaignRef != null && campaignRef == 'Call Me Now'){
        //     return OUTBOUND;
        // }
        //if is multiple product
        if(isMultipleProducts == true){
            if(isBranchCodeValid(branchCode) == true){
               return branchCode; 
            }
            return TMBADMIN;
            
        }
        else if(ruleMap.containsKey(productName)){
            assignRule = ruleMap.get(productName);
            //if product name found in assignment criteria and zipcode found
            if(ZipCode != null && messengerAreaMap.containsKey(ZipCode)){
                System.debug('Has Messenger Cover Area');
                messengerArea = messengerAreaMap.get(ZipCode);
                if(messengerArea.RTL_Area__c == 'Cover'){
                    Destination = assignRule.Destination_BKK__c;
                    
                }else if(messengerArea.RTL_Area__c == 'Not Cover'){
                    Destination = assignRule.Destination_UPC__c;
                }
                System.debug('Destination  '+Destination);
                if(Destination == 'Branch'){
                    
                    if(isBranchCodeValid(branchCode) == true){
                        return branchCode;
                    }
                    return TMBADMIN;
                }
                return OUTBOUND;
                    
                
            }
            //if product name found on assignment criteria but zip code not found
            else{
                if(isBranchCodeValid(branchCode) == true){
                    return branchCode;
                }
                return TMBADMIN;
            }
        }else{
            System.debug('No Messnger Cover area');
            if(branchCode == null || branchCode == ''){
                return OUTBOUND;
            }
            else if(isBranchCodeValid(branchCode) == true){
                System.debug('assign to branch');
                return branchCode;
            }
            return TMBADMIN;
        }
        
        return TMBADMIN;
    }

    private Boolean isBranchCodeValid(String branchCode){
        if(branchCode != null && branchCodeMap.containsKey(branchCode) && queueMap.containsKey(branchCode)){
            return true;
        }
        return false;
    }
}