public class RTL_DataAge {
    public string status {get;set;}
    public string pageMsg {get;set;}
    
    private Map<String,RTL_Data_Age__mdt> dataAgeMdtMap;
    
    public void validateDataAge(Account cust){
        dataAgeMdtMap = getDataAgeMdt();
        if(cust.RTL_RM_Last_Update__c != null && cust.Segment_crm__c != null && dataAgeMdtMap.containsKey(cust.Segment_crm__c)){
            Decimal dataAgeLimit = dataAgeMdtMap.get(cust.Segment_crm__c).RTL_Data_Age_Limit__c;            
            if(cust.RTL_RM_Last_Update__c.monthsBetween(System.today()) > dataAgeLimit ){
                status = 'Fail';
                if(dataAgeMdtMap.get(cust.Segment_crm__c).DeveloperName == 'Affluent'){
                    pageMsg = System.Label.RTL_ERR008;
                }
                else if(dataAgeMdtMap.get(cust.Segment_crm__c).DeveloperName == 'Mid'){
                    pageMsg = System.Label.RTL_ERR009;
                }
                else if(dataAgeMdtMap.get(cust.Segment_crm__c).DeveloperName == 'Mass'){
                    pageMsg = System.Label.RTL_ERR010;
                }
                else if(dataAgeMdtMap.get(cust.Segment_crm__c).DeveloperName == 'Dummy' || dataAgeMdtMap.get(cust.Segment_crm__c).DeveloperName == 'Other'){
                    pageMsg = 'N.A.';   
                }
            }else{
                status = 'Pass';
                pageMsg = '';
            }
        }
        
        
       else if(cust.RTL_RM_Last_Update__c == null )
       {
           status = 'Fail';
           pageMsg = System.Label.RTL_ERR012;
       }else if(cust.Segment_crm__c == null){
           status = 'Fail';
           pageMsg = System.Label.RTL_ERR013;
       }else{
          status = 'N.A.';
          pageMsg = '';
       }
        
    }
    public Map<String,RTL_Data_Age__mdt> getDataAgeMdt(){
    	Map<String,RTL_Data_Age__mdt> returnDataAgeMap = new  Map<String,RTL_Data_Age__mdt>();
    	for(RTL_Data_Age__mdt dataAge : [SELECT DeveloperName,RTL_Customer_Segment__c,RTL_Data_Age_Limit__c 
                                          FROM RTL_Data_Age__mdt]){
         	returnDataAgeMap.put(dataAge.RTL_Customer_Segment__c,dataAge);                         
    	}
        return returnDataAgeMap;
    }
}