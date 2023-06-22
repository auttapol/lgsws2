public class TaskEmailNotifyHandler {
       
    public static void sendEmail(List<Task> tasks) {
        Map<ID,Schema.RecordTypeInfo> rt_Map = Task.sObjectType.getDescribe().getRecordTypeInfosById();
        //if batch delete task more than 10 records, not send email to user
        if(tasks.size() <= 10){
            for(Task ta : tasks){
                if(!rt_map.get(ta.recordTypeID).getName().containsIgnoreCase('Retail') && 
                !rt_map.get(ta.recordTypeID).getName().containsIgnoreCase('Call Log Record Type')){          
                
                    Messaging.reserveSingleEmailCapacity(2);
                    List<User> users = [Select Name, email, Employee_ID__c , Profile.Name from User where ID =: ta.OwnerId or ID =: ta.CreatedById];
                    User dUser = [Select ID,Name, Email, Employee_ID__C from user where ID =: UserInfo.getUserId() limit 1];
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // Strings to hold the email addresses to which you are sending the email.
                    String[] toAddresses = new String[]{}; 
                    if(users.size() > 0){
                        for(user u : users){
                            if(u.email != null && (!u.Profile.Name.equalsIgnoreCase('System Administrator') 
                                                || !u.Profile.Name.equalsIgnoreCase('Retail Integration API Only'))){
                            toAddresses.add(u.email); 
                            }  
                        }
                    }
                    // Assign the addresses for the To and CC lists to the mail object.
                    mail.setToAddresses(toAddresses);
        
                    // Specify the name used as the display name.
                    mail.setSenderDisplayName('CRM Support');
                    
                    // Specify the subject line for your email address.
                    mail.setSubject('Task have been Deleted');
                    
                    // Set to True if you want to BCC yourself on the email.
                    mail.setBccSender(false);
                    
                    // The email address of the user executing the Apex Code will be used.
                    mail.setUseSignature(false);
                    
                    // Specify the text content of the email.
                    mail.setPlainTextBody('Your task assignment has been deleted.');
                    //Email template body
                    mail.setHtmlBody('Dear all,</br></br>'+
                                    'Your task have been <b>Deleted</b> by '+ dUser.Name + '.</br></br>'+ 
                                    
                                    '<b>Customer: </b>' + ta.Customer_Name__c +' </br>'+
                                    '<b>Subject: </b>'+ ta.Subject+ '</br>'+                                 
                                    '<b>Main Task: </b>' + ta.Main_Task__c + '</br>'+
                                    '<b>Sub Task: </b>'+ ta.Sub_Task__c + '</br>'+
                                    '<b>Previous Status: </b>'+ta.Status+ '</br>'+
                                    '<b>Comments: </b>'+ta.Description
                        );
                    // Send the email you have created.
                    try{
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }catch(exception e){
                        //Do nothing
                    }
                    

                }
            }
        }
    }
}