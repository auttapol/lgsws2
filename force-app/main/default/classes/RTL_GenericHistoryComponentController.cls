public class RTL_GenericHistoryComponentController {

    // External variables
    public SObject myObject {get; set;}
    public Integer recordLimit {get; set;}
    public static String objectLabel {get;}

    // Internal Variables
    public objectHistoryLine[] objectHistory; 

    public static final Map<String, Schema.SObjectType> mySObjectTypeMap = Schema.getGlobalDescribe();
    public static Map<String, Schema.SObjectField> myObjectFieldMap;
    public static List<Schema.PicklistEntry> historyFieldPicklistValues;

    public List<objectHistoryLine> getObjectHistory(){
    	Map<String, String> fieldTransMap = RTL_Utility.getNBOProductFieldTranslationMapping();//key is NBO product field translation mapping  

        Id myObjectId = String.valueOf(myObject.get('Id'));
        Schema.DescribeSObjectResult objectDescription = myObject.getSObjectType().getDescribe();

        myObjectFieldMap = objectDescription.fields.getMap();
        objectLabel = String.valueOf(objectDescription.getLabel());

        //Get the name of thew history table
        String objectHistoryTableName = objectDescription.getName();
        //if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name
        if (objectDescription.isCustom()){
            objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
        }
        objectHistoryTableName = objectHistoryTableName + 'History';

        Schema.DescribeFieldResult objectHistoryFieldField = mySObjectTypeMap.get(objectHistoryTableName).getDescribe().fields.getMap().get('Field').getDescribe();
        historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();

        list<objectHistoryLine> objectHistory = new list<objectHistoryLine>();

        String prevDate = '';

        if (recordLimit== null){
            recordLimit = 100;
        }

        list<sObject> historyList = Database.query( 'SELECT CreatedDate,'+
                                                    'CreatedById,'+
                                                    'Field,'+
                                                    'NewValue,'+
                                                    'OldValue ' +
                                                    'FROM ' + objectHistoryTableName + ' ' +
                                                    'WHERE ParentId =\'' + myObjectId + '\' ' +
                                                    'ORDER BY CreatedDate DESC '+
                                                    'LIMIT ' + String.valueOf(recordLimit));

        for(Integer i = 0; i < historyList.size(); i++){
            sObject historyLine = historyList.get(i);
            if ((historyLine.get('newValue') == null && historyLine.get('oldValue') == null) 
                    || (historyLine.get('newValue') != null && !(string.valueOf(historyLine.get('newValue')).startsWith('005') || string.valueOf(historyLine.get('newValue')).startsWith('00G')))
                    || (historyLine.get('oldValue') != null && !(string.valueOf(historyLine.get('oldValue')).startsWith('005') || string.valueOf(historyLine.get('oldValue')).startsWith('00G')))){
                objectHistoryLine tempHistory = new objectHistoryLine();
                // Set the Date and who performed the action
                if (String.valueOf(historyLine.get('CreatedDate')) != prevDate){
                    tempHistory.theDate = String.valueOf(((Datetime)historyLine.get('CreatedDate')).format());
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                    tempHistory.who = String.valueOf(historyLine.get('CreatedById'));
                }
                else{
                    tempHistory.theDate = '';
                    tempHistory.who = '';
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                }
                prevDate = String.valueOf(historyLine.get('CreatedDate'));

                // Get the field label
                String fieldLabel = RTL_GenericHistoryComponentController.returnFieldLabel(String.valueOf(historyLine.get('Field')));

                // Set the Action value
                if (String.valueOf(historyLine.get('Field')) == 'created') {    // on Creation
                   tempHistory.action = System.Label.RTL_Created;
                }
                else if (historyLine.get('oldValue') != null && historyLine.get('newValue') == null){ // when deleting a value from a field
                  // Format the Date and if there's an error, catch it and re
                  try {
                     tempHistory.action = System.Label.RTL_Deleted+' ' + translateValue(Date.valueOf(historyLine.get('oldValue')).format(), fieldTransMap) + ' '+System.Label.RTL_In+' <b>' + fieldLabel + '</b>.';
                } catch (Exception e){
                     tempHistory.action = System.Label.RTL_Deleted+' ' + translateValue(String.valueOf(historyLine.get('oldValue')), fieldTransMap) + ' '+System.Label.RTL_In+' <b>' + fieldLabel + '</b>.';
                }
              }
              else{  // all other scenarios
                  String fromText = '';
                if (historyLine.get('oldValue') != null || Test.isRunningTest()) {
                     try {
                          fromText = ' '+System.Label.RTL_From+' '+ translateValue(Date.valueOf(historyLine.get('oldValue')).format(), fieldTransMap);
                     } catch (Exception e) {
                          fromText = ' '+System.Label.RTL_From+' '+ translateValue(String.valueOf(historyLine.get('oldValue')), fieldTransMap);
                     }
                }

                String toText = '';
                if (historyLine.get('newValue') != null || Test.isRunningTest()) {
                    try {
                         toText = translateValue(Date.valueOf(historyLine.get('newValue')).format(), fieldTransMap);
                    } catch (Exception e) {
                         toText = translateValue(String.valueOf(historyLine.get('newValue')), fieldTransMap);
                    }
                }
                if (toText != ''){
                	if (fromText != null || Test.isRunningTest())
                    	tempHistory.action = System.Label.RTL_Changed+' <b>' + fieldLabel + '</b>' + fromText +' '+System.Label.RTL_To +' <b>' + toText + '</b>.';
                    else
                    	tempHistory.action = System.Label.RTL_Changed+' <b>' + fieldLabel + '</b>' +System.Label.RTL_To +' <b>' + toText + '</b>.';
                }
               }

               // Add to the list
               objectHistory.add(tempHistory);
        }
     }

     List<Id> userIdList = new List<Id>();
     for (objectHistoryLine myHistory : objectHistory){
         userIdList.add(myHistory.userId);
     }
     Map<Id, User> userIdMap = new Map<ID, User>([SELECT Name FROM User WHERE Id IN : userIdList]);

     for (objectHistoryLine myHistory : objectHistory){
         if (userIdMap.containsKey(myHistory.userId) & (myHistory.who != '') ){
             myHistory.who = userIdMap.get(myHistory.who).Name;
         }
     }

     return objectHistory;
}    

    // Function to return Field Label of a object field given a Field API name
    public Static String returnFieldLabel(String fieldName){

        if (RTL_GenericHistoryComponentController.myObjectFieldMap.containsKey(fieldName)){
            return RTL_GenericHistoryComponentController.myObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : historyFieldPicklistValues){
                if (pickList.getValue() == fieldName){
                    if (pickList.getLabel() != null){
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
            }
        }
        return '';
    }
    
    public Static String translateValue(String input, Map<String, String> fieldTransMap) {
    	if (input != null) {
    		if (fieldTransMap.get(input) != null) return getLabelString(fieldTransMap.get(input));
    		else return input;
    	}
    	return null;
    }
    
     public Static String getLabelString(String labelName ){
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value = '{!$Label.' + labelName + '}';
        
        return String.valueOf(output.value);
    }    

    // Inner Class to store the detail of the object history lines    
    public class objectHistoryLine {

        public String theDate {get; set;}
        public String who {get; set;}
        public Id userId {get; set;} 
        public String action {get; set;}
    }	    
}