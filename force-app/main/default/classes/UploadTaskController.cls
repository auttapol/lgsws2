public class UploadTaskController {
    private static Integer BATCHSIZE = 400;

    public static string fileName = 'FileName';
    public static String errorMassege  {get; set;}
   // @auraEnabled public static boolean isError {get; set;}

    @AuraEnabled
    public static List<String> generateCSVArray(List<String> CSVArray,String BatchType,String fName){
      
        fileName = fName;
        List<Task> taskList = new List<Task>();
        Set<String> LogACallSet = new Set<String>();
        Integer logACallIndex = -1;
        SObjectType TaskType = Schema.getGlobalDescribe().get('Task');
        Map<String,Schema.SObjectField> taskfields = TaskType.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Task.fields.getMap();
        Set<String> employeeId = new Set<String>();

        //Split Header
        List<String> Header = new List<String>();
        boolean isHasExternalID = false;
        if (CSVArray.Size() > 0 && CSVArray.Size() < 5001){
            for (integer i = 0; i < CSVArray.Size(); i++){
                Task taskObj = new Task();
                //Get field header in file from row 0
                if (i == 0){
                    String line = CSVArray.get(i).replace('\n','');                 
                    Header = line.Split(',');                    
                    for (Integer x = 0 ; x < Header.size() ; x++) {
                        String checker = Header.get(x).toLowerCase();
                        
                        if (Header.Size() == x+1 ){
                            String lastIndex = Header.get(x);
                            lastIndex = lastIndex.Substring(0,lastIndex.length() - 1);
                            checker = lastIndex.replace('\n','');
                            Header[x] = checker;
                        } 
                        //Check if Header contain field external ID
                        if (checker.equalsIgnoreCase('LogACall_External_Id_crmdb__c') || checker.equalsIgnoreCase('id') ){
                            isHasExternalID = true;   
                            
                        }
                        
                        if (taskfields.get(checker) == null ){                                                      
                            errorMassege = 'Error File '+fileName + ': header '+ checker +'in column '+ x + ' is not correct'; 
                            sendEmailMessage(errorMassege);
                            return null;  

                        }

                        if (checker == null || checker == ''){                           
                            errorMassege = 'Error File '+fileName + ' have null header in column '+ x; 
                            sendEmailMessage(errorMassege);
                            return null;  

                        }
                        
                    }
                }else if (isHasExternalID){
                        List<String> records = CSVArray.get(i).Split(',');
                       
                        try{

                            for (integer j = 0 ; j < Header.Size();j++){
                             
                                Schema.SObjectField field = M.get(Header.get(j));
                                Schema.DisplayType FldType = field.getDescribe().getType();
                                if(FldType == Schema.DisplayType.Date){
    
                                    Date dt = Date.valueOf(records.get(j));
                                    taskObj.put(Header.get(j) ,dt);
                                }
                                else if(FldType == Schema.DisplayType.DateTime){
    
                                    taskObj.put(Header.get(j) ,DateTime.valueOfGmt(records.get(j)));
     
                                }
                                else if(FldType == Schema.DisplayType.Double){
                                    taskObj.put(Header.get(j) ,decimal.valueof(records.get(j)));
     
                                }
                                else if(FldType == Schema.DisplayType.Integer){
                                    taskObj.put(Header.get(j) ,integer.valueof(records.get(j)));
     
                                }
                                else{
                                    taskObj.put(Header.get(j) ,records.get(j));
                                }                          
     
                            }                        
                              taskList.add(taskObj);

                        }catch(exception e){
                            errorMassege = 'Error file '+fileName+ ' in row '+ i + ' : '+ e.getMessage();                       
                            sendEmailMessage(errorMassege);
                            return null; 
                        }

                    }else{
                        errorMassege = 'Error file '+fileName+' have no external id field logacall_external_id_crmdb__c';                       
                        sendEmailMessage(errorMassege);
                        return null; 
                    }
                }              
               

            if(taskList.size() > 0){            
                if (BatchType == 'Upsert'){
                    BatchUploadTask runBatch = new BatchUploadTask(taskList,Header,fileName);
                    Database.executeBatch(runBatch,BATCHSIZE);
                }else if (BatchType == 'Delete'){
                    BatchDeleteTask runBatch = new BatchDeleteTask(taskList,fileName);
                    Database.executeBatch(runBatch,BATCHSIZE);
                }
            }
        }else{
            errorMassege = 'Error file '+fileName+' size have more than 5000 records';                       
            sendEmailMessage(errorMassege);
            return null; 

        }
        return CSVArray;
    }
/*
    @AuraEnabled
    public static List<String> getErrorMessage (){
        List<String> errors = new List<String>();
        errors.add(status_code__c.getValues('5101').status_message__c);
        errors.add(status_code__c.getValues('5108').status_message__c);
        errors.add(status_code__c.getValues('5001').status_message__c);
        system.debug('**Test ');
        return errors;
    }   
*/
    @AuraEnabled (cacheable=true)
    public static list<Load_Task_Log__c>  getLogFiles()
    {

        List<Load_Task_Log__c> logHeader = [Select name, Id, Total_Record__c,Success_Record__c,Failed_Record__c,OwnerID, CreatedDate, Load_Type__c from Load_Task_Log__c 
                                            Where OwnerID =: UserInfo.getUserId() order by CreatedDate desc limit 100];
        

        return logHeader;

    
    }

    public static void sendEmailMessage(String message){
        TimeZone tz = UserInfo.getTimeZone();       
        String subject = 'Load task Error!';                         
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};      
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});

    }
    /*
    @AuraEnabled
    public static boolean checkLoadResult()
    {
        Datetime minutesBack = Datetime.now().addMinutes(-2);
        boolean result = false;
        List<Load_Task_Log__c> logHeader = [Select name, Id, Total_Record__c,Success_Record__c,Failed_Record__c,OwnerID, CreatedDate, Load_Type__c from Load_Task_Log__c 
                                            Where OwnerID =: UserInfo.getUserId() AND CreatedDate >=: minutesBack limit 1];
        if(logHeader.size() > 0){
            result = true;
        }
        return result;
    }
    */
}