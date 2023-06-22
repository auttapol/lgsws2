global class RTL_GenerateTaskBatch implements Database.Batchable<sObject>, Database.stateful {
  Datetime batchDate = datetime.now();
  Datetime batchStartTime = datetime.now();
  Datetime batchEndTime = null;
  Integer  recordsSuccessful = 0;
  Integer  recordsFailed = 0;

  final String SEMICO = ',';
  final String jobDailyName = 'Generate Wealth Tasks';
  final String sObjectName = 'Task';

  String query;

  List<Id> accIdErrorList = new List<Id>();

  private String SUCCESSLOG_HEAEDER  = 'RecordId,WhatId,WhoId,Description\n';
  private String CSV_LOG_SUCCESS     = '';

  Map<Id, Task>    tskErrorMap =  new Map<Id, Task>();
  Map<Id, String>  tskErrorMsgMap = new Map<Id, String>();
  Map<Id, String>  accErrorMsgMap = new Map<Id, String>();
  Map<Id, Account> accErrorMap = new Map<Id, Account>();

  @TestVisible
  Map<String, Operating_Model__c> OPModelMap{
    get{
      if(OPModelMap != null) {
        return OPModelMap;
      }
      OPModelMap = new Map<String, Operating_Model__c>();
      
      Map<ID, Operating_Model__c> m = new Map<ID, Operating_Model__c>([SELECT Operating_Model_Name__c, Duration__c, Days_Month__c, Day_of_the_month__c, Day_of_due_date__c FROM Operating_Model__c]);
      
      for(Operating_Model__c OPModel : m.values()){
        OPModelMap.put(OPModel.Operating_Model_Name__c, OPModel);
      }
      return OPModelMap;
    }
    set;
  }
  
  global RTL_GenerateTaskBatch(String q) {
    query = q;
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
    //System.debug(':::::::::::::::execute:::::::::::::::');
    date d = System.today();
    date NextGenDate;
    date DueDate;

    List<Task> tskList = new List<Task>();
    Map<Id, Account> AccMap = new Map<Id, Account>();

    //String key = '';
    //Operating_Model__c opm = new Operating_Model__c();
    for (Account acc : scope) {
      if(acc.Operating_Model__c != null){
        //key = acc.Operating_Model__c;
        Operating_Model__c opm = OPModelMap.get(acc.Operating_Model__c);
        
        if(opm != null){
          //System.debug('UPDATE ACCOUNT : ' + acc);
          acc.Last_Generate_task_date__c = acc.Next_Generate_task_date__c;
          NextGenDate = date.newInstance(d.year(), d.month(), d.day());

          //UPDATE ACCOUNT NEXT GEN DATE 
          if(opm.Days_Month__c == 'Month'){
            //ADD MONTH
            NextGenDate = date.newInstance(d.year(), d.month(), 1);
            NextGenDate = NextGenDate.addMonths(Integer.valueOf(opm.Duration__c));

            //CHANGE DAY
            Integer genDay = d.day();
            
            if(opm.Day_of_the_month__c != null){
              genDay = Integer.valueOf(opm.Day_of_the_month__c);
            }

            if(genDay > Date.daysInMonth(NextGenDate.year(), NextGenDate.month())){
              NextGenDate = date.newInstance(NextGenDate.year(), NextGenDate.month(), Date.daysInMonth(NextGenDate.year(), NextGenDate.month()));
            }else{
              NextGenDate = date.newInstance(NextGenDate.year(), NextGenDate.month(), genDay);
            }

          }else if(opm.Days_Month__c == 'Days'){
            //CHANGE DAY
            NextGenDate = NextGenDate.addDays(Integer.valueOf(opm.Duration__c));
          }

          acc.Next_Generate_task_date__c = NextGenDate;
          AccMap.put(acc.id, acc);

          Task tsk = new Task();
          Id TaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Retail Task').getRecordTypeId();

          if(opm.Day_of_due_date__c != null){
            DueDate = date.newInstance(d.year(), d.month(), d.day()).addDays(Integer.valueOf(opm.Day_of_due_date__c));
            tsk.ActivityDate = DueDate;
          }


          tsk.RTL_Task_Subject__c = 'Portfolio Review';
          tsk.RTL_Channel__c  = 'Wealth Management';
          tsk.Type = 'Visit';
          tsk.WhatId = acc.Id;
          tsk.OwnerId = acc.RTL_Wealth_RM__c;
          tsk.Priority = 'High';
          tsk.Description  = '[Operating Model:' + opm.Operating_Model_Name__c + ']';
          tsk.RecordTypeId = TaskRecordTypeId;
          tsk.ReminderDateTime = datetime.now();
          tskList.add(tsk);
        }
      }
    }
    

    if(tskList != null && tskList.size()>0){
      List<Database.SaveResult> srList = Database.insert(tskList, false);

      for (Integer i = 0 ; i < srList.size() ; i++){
          Database.SaveResult sr = srList.get(i);

          if (!sr.isSuccess()) {
            recordsFailed++;
            accIdErrorList.add(tskList.get(i).WhatId);
            tskErrorMap.put(tskList.get(i).WhatId, tskList.get(i));
            String errormsg = '';

            for(Database.Error err : sr.getErrors()) {
              errormsg += err.getStatusCode() + ':' + err.getMessage();
            }

            tskErrorMsgMap.put(tskList.get(i).WhatId, errormsg);
          }else {
            recordsSuccessful++;
            CSV_LOG_SUCCESS = CSV_LOG_SUCCESS 
                              + sr.getId()
                              + SEMICO 
                              + tskList.get(i).WhatId
                              + SEMICO
                              + tskList.get(i).OwnerId
                              + SEMICO
                              + 'Created_Wealth_Task_Success'
                              + '\n';
          }
      }
    }

    for(Id id : accIdErrorList){
      if(AccMap.get(Id) != null){
        accErrorMap.put(id, AccMap.get(Id));
        AccMap.remove(Id);
      }
    }

    if(AccMap != null && !AccMap.isEmpty()){
      Database.SaveResult[] srList = Database.update(AccMap.values(), false);

      for (Integer i = 0 ; i < srList.size() ; i++){
          Database.SaveResult sr = srList.get(i);
          if (!sr.isSuccess()) {
            recordsFailed++;
            String errormsg = '';

            for(Database.Error err : sr.getErrors()) {
              errormsg += err.getStatusCode() + ':' + err.getMessage();
            }

            accErrorMsgMap.put(AccMap.values().get(i).Id,errormsg);

          }
      }
    }
  }
  
  global void finish(Database.BatchableContext BC) {
    batchEndTime = datetime.now();

    String csvHeaderStr = 'AccountId, TMB Customer ID, TaskOwnerId, Wealth RM Name, Description, DueDate, ErrorMessage, StatusCode, UpdateOnAccount\n';
    String CSV_BODY  = '';

    Map<Id,String> accountNextGenTaskMap = new Map<Id,String>();

    for(Id ID : tskErrorMsgMap.keySet()){
      String[] errorMsg = tskErrorMsgMap.get(ID).split(':', 2);

      Task tsk = tskErrorMap.get(ID);
      Account acc = accErrorMap.get(ID);

      String errorDetail = tsk.WhatId + SEMICO +
                acc.TMB_Customer_ID_PE__c + SEMICO +
                tsk.OwnerId + SEMICO + 
                acc.RTL_Wealth_RM__r.Name + SEMICO +
                tsk.Description + SEMICO +
                tsk.ActivityDate + SEMICO +
                errorMsg[1] + SEMICO +
                errorMsg[0] + SEMICO;

      accountNextGenTaskMap.put(acc.Id,errorDetail);
    }
    
    List<Account> accNextGenTomorrowList = [SELECT Id,Next_Generate_task_date__c 
                          From Account 
                        Where Id 
                        in : accountNextGenTaskMap.KeySet() 
                        AND Next_Generate_task_date__c = TODAY];

    for (Account acc : accNextGenTomorrowList) {
      acc.Next_Generate_task_date__c = Date.today().addDays(1);
    }


    Database.SaveResult[] srList = Database.update(accNextGenTomorrowList, false);

    for (Database.SaveResult sr : srList) {
      String errorDesc = accountNextGenTaskMap.get(sr.getId());
      if (sr.isSuccess()) {
        CSV_BODY = CSV_BODY + errorDesc + 'Update_Next_Generate_task_date__c_Tomorow\n';
      }else {
        String errormsgUpdateAcc = ''; 
        for(Database.Error err : sr.getErrors()) {
          errormsgUpdateAcc += err.getStatusCode() + ':' + err.getMessage();
        }
        CSV_BODY = CSV_BODY + errorDesc + errormsgUpdateAcc + '\n';
      }
    }
    
    for(Id ID : accErrorMsgMap.keySet()){
      String[] errorMsg = accErrorMsgMap.get(ID).split(':', 2);
      CSV_BODY = CSV_BODY 
                   + ID 
                   + SEMICO +
                '' + SEMICO +
                '' + SEMICO + 
                '' + SEMICO +
                '' + SEMICO +
                '' + SEMICO +
                errorMsg[1] + SEMICO +
                errorMsg[0] + SEMICO + '\n';
    }

    List<String> sendToEmail = new List<String>();
    sendToEmail.add('CRM Admin 2');

    //SEND MAIL
    String filename = jobDailyName +'_'+ String.Valueof(Datetime.now());
     /*
    RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , batchEndTime
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        , csvHeaderStr
                                                        , filename
                                                        , sObjectName
                                                        , sendToEmail
                                                        , CSV_BODY);*/

   
    RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , batchEndTime
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        , filename
                                                        , sobjectName
                                                        , sendToEmail
                                                        , CSV_BODY
                                                        , ''
                                                        , CSV_LOG_SUCCESS
                                                        , csvHeaderStr
                                                        , ''
                                                        , SUCCESSLOG_HEAEDER
                                                        , ''
                                                        );
    
  }
  
}