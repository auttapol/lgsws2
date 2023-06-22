@RestResource(urlMapping='/inbound/transferred-popup/*')
global with sharing class InboundTransfer {

    @HttpGet
    global static void helloWorld(){
        InboundUtility.restRespond(
            InboundUtility.HTTP_OK,
            '',
            'Use POST Instead!'
        );
    }

    @HttpPost
    global static void handleTransfer(InboundUtility.task_wrapper task, InboundUtility.verification_history_wrapper verification_history){

        String errorMessage = '';
        String customerName = '';
        String msLogId = '-';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = task.tmb_cust_id;
        String serviceName = '/inbound/transferred';
        String requestBody = JSON.serialize(task);
        String responseBody = '';

        DateTime startTime = DateTime.Now();
        DateTime endTime;

        Account accForLog = new Account();

        Boolean isSuccess = true;
        try{
            if(task.call_number == '' || task.call_number == null){
                responseBody = InboundUtility.restRespond(
                    InboundUtility.HTTP_BAD_REQUEST,
                    'Call Number is required.',
                    ''
                );
                isSuccess = false;
            }

            else if(task.employee_id == '' || task.employee_id == null){
                responseBody = InboundUtility.restRespond(
                    InboundUtility.HTTP_BAD_REQUEST,
                    'Employee ID is required.',
                    ''
                );
                isSuccess = false;

            }

            else if(task.call_id == '' || task.call_id == null){
                responseBody = InboundUtility.restRespond(
                    InboundUtility.HTTP_BAD_REQUEST,
                    'Call ID is required.',
                    ''
                );
                isSuccess = false;

            }

            
            else if(task.task_id == '' || task.task_id == null){
                responseBody = InboundUtility.restRespond(
                    InboundUtility.HTTP_BAD_REQUEST,
                    'Task ID is required.',
                    ''
                );
                isSuccess = false;

            }
            else{
                //Check for timedout request
                List<Task> searchTask = [SELECT Id FROM Task WHERE Call_Log_ID__c = :task.call_id AND Call_Agent_Id__c = :task.employee_id AND Call_Start_Datetime__c =: task.call_start_datetime];
                if(searchTask.isEmpty()){

                    //Start Query Task
                    errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryTask, message='+task.call_id+' , agentid='+task.employee_id;

                    //Verify that task exists
                    List<Task> verifyTask = [SELECT Id, Call_Log_ID__c, Call_Agent_Id__c, WhatId  FROM Task WHERE Id = :task.task_id];
                    if(verifyTask.isEmpty()){
                        //Stop Query Task : Task not found

                        responseBody = InboundUtility.restRespond(
                            InboundUtility.HTTP_NOT_FOUND,
                            'Task ID is invalid.',
                            ''
                        );
                        isSuccess = false;
                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryTask, message=Task not found';
                        //
                    }

                    else{
                        String verf_hist_id = '';
                        //Stop Query Task : task_id

                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryTask, message='+task.task_id;


                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryAccount, message='+task.task_id;
                        List<Account> searchCust = [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE Id = :verifyTask.get(0).WhatId];
                        if(searchCust.isEmpty()){
                            isSuccess = false;
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryAccount, message=Account not found';
                        }
                        else{
                            accForLog = searchCust.get(0);
                            customerName = searchCust.get(0).Name;
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryAccount, message='+searchCust.get(0).Id;
                        }
                                
                        //Start Query Verification History
                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryVerificationHistory, message='+task.call_id+', agentid='+task.employee_id;

                        //Find verification history from task
                        List<Verification_History__c> verf_hist = [SELECT Id
                                                                    FROM Verification_History__c
                                                                    WHERE Call_ID__c = :verifyTask.get(0).Call_Log_ID__c
                                                                    AND Employee_ID__c = :verifyTask.get(0).Call_Agent_Id__c];


                        //Stop Query Verification History : Error message = Verification History Not Found
                        if(verf_hist.isEmpty()){

                            isSuccess = false;
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryVerificationHistory, message=Verification History not found';
                        }
                        //Stop Query Verification History : Success message = id
                        else{
                            verf_hist_id = verf_hist.get(0).Id;
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryVerificationHistory, message='+verf_hist_id;
                        

                            System.debug(verf_hist_id);
                            
                        }

                        //Check if agent exist
                        List<User> agent = [SELECT Id FROM User WHERE Employee_ID__c = :task.employee_id LIMIT 1];
                        if(agent.isEmpty()){
                            responseBody = InboundUtility.restRespond(
                                InboundUtility.HTTP_NOT_FOUND,
                                'Agent ID is invalid.',
                                ''
                            );
                            isSuccess = false;
                        }

                        else{
                            System.debug(task);
                            //Start create log a call
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start CreateLogACall, message='+task.call_id+', agentid='+task.employee_id+', callnumber='+task.call_number;
                            String newTaskId = InboundUtility.insertTask(
                                task,
                                agent.get(0).Id
                            );

                            if(newTaskId.contains('Error')){
                                responseBody = InboundUtility.restRespond(
                                    InboundUtility.HTTP_BAD_REQUEST,
                                    'Cannot Create Task',
                                    newTaskId
                                );
                                isSuccess = false;
                                errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop CreateLogACall, message='+newTaskId;

                                //
                                

                            }
                            else{

                                errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop CreateLogACall, message='+newTaskId;
                                responseBody = InboundUtility.restRespond(
                                    InboundUtility.HTTP_CREATED,
                                    '',
                                    newTaskId
                                );
                                
                                
                                System.debug(verf_hist_id);
                                errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start TriggerPlatformEvents, message='+task.call_id+', agentid='+task.employee_id+', callnumber='+task.call_number;
                                String returnMsg = InboundUtility.publishCustomerTransfer(
                                    newTaskId,
                                    task,
                                    // task.task_id,
                                    // task.employee_id,
                                    verf_hist_id
                                    // task.call_number
                                );

                                if(returnMsg.contains('Error')){
                                    isSuccess = false;
                                }
                                errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop TriggerPlatformEvents, message='+returnMsg;

                            }
                        }
                    }
                }
                else{

                    String verf_hist_id = '';
                    errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryTask, message='+task.call_id+' , agentid='+task.employee_id;
                    List<Task> verifyTask = [SELECT Id, Call_Log_ID__c, Call_Agent_Id__c, WhatId  FROM Task WHERE Id = :task.task_id];

                    if(verifyTask.size() > 0){
                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryTask, message='+task.task_id;
                        List<Account> searchCust = [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE Id = :verifyTask.get(0).WhatId];
                        
                        if(!searchCust.isEmpty()){
                            accForLog = searchCust.get(0);
                            customerName = searchCust.get(0).Name;
                        }

                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryVerificationHistory, message='+task.call_id+', agentid='+task.employee_id;

                        //Find verification history from task
                        List<Verification_History__c> verf_hist = [SELECT Id
                                                                    FROM Verification_History__c
                                                                    WHERE Call_ID__c = :verifyTask.get(0).Call_Log_ID__c
                                                                    AND Employee_ID__c = :verifyTask.get(0).Call_Agent_Id__c];

                                                                    
                        if(verf_hist.isEmpty()){

                            isSuccess = false;
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryVerificationHistory, message=Verification History not found';
                        }
                        
                        else{
                            verf_hist_id = verf_hist.get(0).Id;
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryVerificationHistory, message='+verf_hist_id;

                            System.debug(verf_hist_id);

                        }
                        String newTaskId = searchTask.get(0).Id;
                        responseBody = InboundUtility.restRespond(
                            InboundUtility.HTTP_OK,
                            '',
                            newTaskId
                        );

                        System.debug(verf_hist_id);
                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start TriggerPlatformEvents, message='+task.call_id+', agentid='+task.employee_id+', callnumber='+task.call_number;
                        String returnMsg = InboundUtility.publishCustomerTransfer(
                            newTaskId,
                            task,
                            // task.task_id,
                            // task.employee_id,
                            verf_hist_id
                            // task.call_number
                        );

                        if(returnMsg.contains('Error')){
                            isSuccess = false;
                        }
                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop TriggerPlatformEvents, message='+returnMsg;

                    }
                    else{
                        responseBody = InboundUtility.restRespond(
                            InboundUtility.HTTP_NOT_FOUND,
                            'Task ID is invalid.',
                            ''
                        );
                        isSuccess = false;
                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryTask, message=Task not found';
                    }
                }
            }
            
            endTime = DateTime.now();
            
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                    rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                    startTime ,  endTime,  null );
            
        }

        catch(Exception e){
            List<Account> searchCust = [SELECT Id, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :task.tmb_cust_id];
            if(!searchCust.isEmpty()){
                accForLog = searchCust.get(0);
            }
            
            responseBody = InboundUtility.restRespond(
                InboundUtility.HTTP_BAD_REQUEST,
                'Uncaught Exception',
                e.getMessage() + ' : ' + e.getStackTraceString()
            );
            endTime = DateTime.now();
            isSuccess = false;
            
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );

        }
    }
}