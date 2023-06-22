public class CampaignMemberLeadConversionCtrl {

    @AuraEnabled
    public static List<Account> checkDuplicate(String mobileNumber,String idNo,String idType){

        try {         
            List<Account> acctsID = new List<Account>();
            List<Account> acctsMobile = new List<Account>();
            String NID = splitIDtoNID(idNo);

            Map<ID, Account> AccIdMap = new Map<ID, Account>([SELECT Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Segment2__c, Core_Banking_Suggested_Segment__c, Owner.name,Sub_segment__c 
                        FROM account
                        WHERE RTL_NID__c  =: NID]);


            acctsID = AccIdMap.values();

            for(Account acc : acctsID){
                if(acc.ID_Type_PE__c != idType || acc.ID_Number_PE__c != idNo){
                    AccIdMap.remove(acc.Id);
                }
            }


            acctsID = AccIdMap.values();

            List<Account> accounts = new List<Account>(); 
            accounts.addAll(acctsID);

            if(IdType == 'Other ID'){
                List<List<sObject>> searchList = [FIND :mobileNumber IN ALL FIELDS RETURNING Account(Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, Owner.name,Sub_segment__c)];
                acctsMobile = (List<Account>)searchList[0];
                
                for (Account acc : acctsMobile) {
                    if(AccIdMap.get(acc.Id) == null){
                        accounts.add(acc);
                    }
                }
            }
            return accounts;
        }
        catch(Exception e){
            return null;

        }
    }

    @AuraEnabled
    public static List<String> getPickListValues(String objectName,String fieldName){
        return CampaignMemberInfoController.getPickListValues(objectName,fieldName);
        
    }

    private static String splitIDtoNID(String idNumber){
        String nid;
        if (idNumber != null && idNumber.length() > 0) {
            nid = (idNumber.length() <= 5) ?  idNumber: idNumber.substring(0,1)+idNumber.substring(idNumber.length()-4); 
        }
        return nid;
    }
}