global class CustomHelpTextService {
    // Lazy
    public static Map<string/*screen name */,Map<String/*Sobjec-Field*/,CustomHelpText__c>> mapTextHelpers;
    global static string  getHelpText(string sobjectname ,string field ,string screen){
        
        if(mapTextHelpers == null){
            mapTextHelpers = new Map<string/*screen name */,Map<String/*Sobjec-Field*/,CustomHelpText__c>>();
        }
        if(!mapTextHelpers.containsKey(screen/*screen name*/)){
            //fix query
            mapTextHelpers.put(screen,new Map<String/*Sobjec-Field*/,CustomHelpText__c>());
            for(CustomHelpText__c item : [SELECT Id ,FieldName__c,SObject__c,Screen__c,HelpText__c FROM CustomHelpText__c WHERE Screen__c =: screen limit 500]){
                mapTextHelpers.get(screen).put(item.SObject__c+'-'+ item.FieldName__c /*Sobjec-Field*/, item);
            }
        }
        return   mapTextHelpers.get(screen).get(sobjectname + '-'+ field).HelpText__c;
    }
     
 }