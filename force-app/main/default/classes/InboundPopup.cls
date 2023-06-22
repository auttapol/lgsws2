@RestResource(urlMapping='/inbound/popup/*')
global with sharing class InboundPopup {

    @HttpGet
    global static void helloWorld(){
        InboundUtility.restRespond(
            InboundUtility.HTTP_OK,
            '',
            'Hello World!'
        );
    }

    @HttpPost
    global static void handleInbound(InboundUtility.task_wrapper task, InboundUtility.verification_history_wrapper verification_history){

        String errorMessage = '';
        String customerName = '';
        String msLogId = task.call_id + task.call_start_datetime;
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = task.tmb_cust_id;
        String serviceName = '/inbound/popup';
        String requestBody = JSON.serialize(task) + JSON.serialize(verification_history);
        String responseBody = '';

        DateTime startTime = DateTime.Now();
        DateTime endTime;

        //TODO: Query account and insert to onlone log
        Account accForLog = new Account();

        Boolean isSuccess = true;
        // String jsonString = RestContext.request.requestBody.toString();
        System.debug(task);
        System.debug(verification_history);
        try{
            /*
			System.debug('Start inquiry account -->' + RESTOpportunityUtil.getTHDatetimeNOW());
            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryAcct, message='+task.tmb_cust_id;
            List<Account> searchCust = [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :task.tmb_cust_id];
            System.debug('End inquiry account -->' + RESTOpportunityUtil.getTHDatetimeNOW());
            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryAcct,';

			if(!searchCust.isEmpty()){
                accForLog = searchCust.get(0);
                customerName = searchCust.get(0).Name;
            }
			*/
            if (String.isNotEmpty(task.tmb_cust_id)) {
                System.debug('Start inquiry account -->' + RESTOpportunityUtil.getTHDatetimeNOW());
                errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryAcct, message='+task.tmb_cust_id;
                List<Account> searchCust = [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :task.tmb_cust_id];
                System.debug('End inquiry account -->' + RESTOpportunityUtil.getTHDatetimeNOW());
                errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryAcct,';

                if(!searchCust.isEmpty()){
                    accForLog = searchCust.get(0);
                    customerName = searchCust.get(0).Name;
                }
            }

            if(task.call_number == '' || task.call_number == null){
                responseBody = InboundUtility.restRespond(
                    InboundUtility.HTTP_BAD_REQUEST,
                    'Phone is required.',
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

            else{

                //Start Query Task
                errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryTask, message='+task.call_id+' , agentid='+task.employee_id + 'task_id='+task.task_id;
                
                List<Task> searchTask = null;
                if (String.isNotBlank(task.task_id)) {
                    searchTask = [SELECT Id FROM Task WHERE Id = :task.task_id];
                } else {
                    searchTask = [SELECT Id FROM Task WHERE Call_Log_ID__c = :task.call_id AND Call_Agent_Id__c = :task.employee_id AND Call_Start_Datetime__c =: task.call_start_datetime ];
                }

                Map<String, String> result = new Map<String, String>();

                if(searchTask.isEmpty()){
                    //Stop Query Task : Task not found

                    errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryTask, message=Task not found';
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
                        errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start CreateLogACall, message='+task.call_id+',agentid='+task.employee_id+',callnumber='+task.call_number;
                        task.task_id = InboundUtility.insertTask(
                            task,
                            agent[0].Id
                        );
                        if(task.task_id.contains('Error')){
                            responseBody = InboundUtility.restRespond(
                                InboundUtility.HTTP_BAD_REQUEST,
                                'Cannot Create Task',
                                task.task_id
                            );
                            isSuccess = false;
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop CreateLogACall, message='+task.task_id;

                        }
                        else{
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop CreateLogACall, message='+task.task_id;

                            responseBody = InboundUtility.restRespond(
                                InboundUtility.HTTP_CREATED,
                                '',
                                task.task_id
                            );
                            
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start TriggerPlatformEvents, message='+task.call_id+',agentid='+task.employee_id+',callnumber='+task.call_number;
                            String returnMsg = InboundUtility.publishCustomerInbound(
                                task,
                                verification_history
                            );
                            if(returnMsg.contains('Error')){
                                isSuccess = false;
                            }
                            errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop TriggerPlatformEvents, message='+returnMsg;

                        }
                    }

                }
                else{
                    //Stop Query Task : Task found
                    errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryTask, message='+searchTask.get(0).Id;
                    task.task_id = searchTask.get(0).Id;
                    responseBody = InboundUtility.restRespond(
                        InboundUtility.HTTP_CREATED,
                        '',
                        task.task_id
                    );
                    
                    errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start TriggerPlatformEvents, message='+task.call_id+',agentid='+task.employee_id+',callnumber='+task.call_number;
                    String returnMsg = InboundUtility.publishCustomerInbound(
                        task,
                        verification_history
                    );
                    if(returnMsg.contains('Error')){
                        isSuccess = false;
                    }
                    errorMessage += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop TriggerPlatformEvents, message='+returnMsg;

                }
            }
            endTime = DateTime.now();
            System.debug(JSON.serializePretty(errorMessage));
            System.debug(msLogId);
            System.debug(serviceName);
            System.debug(requestBody);
            System.debug(responseBody);
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );
        }
        
        catch(Exception e){
            List<Account> searchCust = [SELECT Id, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :task.tmb_cust_id];
            if(!searchCust.isEmpty()){
                accForLog = searchCust.get(0);
            }
            // Map<String, String> result = new Map<String, String>();
            // result.put('message', npe.getMessage());
            responseBody = InboundUtility.restRespond(
                InboundUtility.HTTP_BAD_REQUEST,
                'Uncaught Exception',
                e.getMessage() + ' : ' + e.getStackTraceString()
            );
            endTime = DateTime.now();
            isSuccess = false;
            System.debug(JSON.serializePretty(errorMessage));
            System.debug(msLogId);
            System.debug(serviceName);
            System.debug(requestBody);
            System.debug(responseBody);
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );

        }

    }

}