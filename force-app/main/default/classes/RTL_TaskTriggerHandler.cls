public with sharing class RTL_TaskTriggerHandler extends TriggerHandler {
/*------------------------------------------------------------------------
Author:        Serena Li
Company:       Salesforce
Description:   A class created to manage trigger actions from the Task object 
History
<Date>            <Authors Name>    <Brief Description of Change> 
--------------------------------------------------------------------------*/
    
    // thanakorn CXM 6/6/2017 start
    private static String KEY_OBJECT = 'Task';
    // thanakorn CXM 6/6/2017 end
      
    public RTL_TaskTriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(10);
        }
        else{
            this.setMaxLoopCount(1000);
        }
     
        System.Debug( 'TMB: -> RTL_TaskTriggerHandler Invoked' );
    }
    
    public static RecordType outboundTaskRecordType = [select Id from RecordType where developername='RTL_Retail_Outbound_Phone_Call' and SobjectType = 'Task' and IsActive = true limit 1];

    protected override void beforeUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {
        System.Debug('TMB: -> RTL_TaskTriggerHandler start of beforeUpdate');   
		CXMHandler.checkCXMSendDuplicate(newMap,oldMap);
        System.Debug('TMB: -> RTL_TaskTriggerHandler end of beforeUpdate');  
    }
    
    protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {        
        System.Debug('TMB: -> RTL_TaskTriggerHandler start of afterUpdate');  
        // thanakorn CXM 6/6/2017 start        
        Map<Id,SObject> filterList = CXMHandler.filterToCXM(KEY_OBJECT,newMap,oldMap);
        if( filterList.size() > 0 ){
            List<CalloutRequest__c> cr = CXMCalloutHandler.CreateCXMCalloutRequest( QueueableHandler.CALLOUT_TOKEN , KEY_OBJECT , filterList.values() );
            if( cr.size() > 0 && CXMHandler.getQueueAvailable() ){     
                System.debug('CXM AfterUpdate');
                QueueableHandler.startCalloutJob(QueueableHandler.CALLOUT_TOKEN, cr );
            }
        }
        // thanakorn CXM 6/6/2017 end
		System.Debug('TMB: -> RTL_TaskTriggerHandler end of afterUpdate'); 
    }
    
    protected override void beforeInsert(List<SObject> tasks) {        
        System.Debug('TMB: -> RTL_TaskTriggerHandler start of beforeInsert');
        List<Task> taskList =  new List<Task>();
        for(sObject obj : tasks){
            Task t = (Task)obj;
            if(t.recordTypeId == outboundTaskRecordType.id){
                taskList.add(t);
            }
        }
        
        if(taskList.size() > 0){
            preProcessTask(taskList);
        }
        
        // thanakorn CXM 6/6/2017 start
        CXMHandler cxm = new CXMHandler();
        cxm.stampTaskForCXM(tasks);
        // thanakorn CXM 6/6/2017 end
              
        System.Debug('TMB: -> RTL_TaskTriggerHandler end of beforeInsert'); 
    }
    
    protected override void afterInsert(map<id,SObject> newMap) {       
        System.Debug('TMB: -> RTL_TaskTriggerHandler start of afterInsert');
        Map<Id,Task> taskMap =  new Map<Id,Task>();
        for(sObject obj : newMap.values()){
            Task t = (Task)obj;
            if(t.recordTypeId == outboundTaskRecordType.id){
                taskMap.put(t.id,t);
            }
        }
        
        if(taskMap.size() > 0){
            postProcessTask(taskMap);
        }
        
        // thanakorn CXM 6/6/2017 start
        Map<Id,SObject> filterList = CXMHandler.filterToCXM(KEY_OBJECT,newMap,null);
        if( filterList.size() > 0 ){
            List<CalloutRequest__c> cr = CXMCalloutHandler.CreateCXMCalloutRequest( QueueableHandler.CALLOUT_TOKEN , KEY_OBJECT, filterList.values() );
            if( cr.size() > 0 && CXMHandler.getQueueAvailable() ){     
                System.debug('CXM AfterInsert');
                QueueableHandler.startCalloutJob(QueueableHandler.CALLOUT_TOKEN, cr );
            }
        } 
        // thanakorn CXM 6/6/2017 end   
		System.Debug('TMB: -> RTL_TaskTriggerHandler end of afterInsert');
    }      

    /*end trigger handler overrides*/
    //====================================================================
    
    /* private methods */
    /**
     * This is the method to map task external ID to WhatId and AccountId
     **/
    private static void preProcessTask(List<Task> tasks) { 
        Set<String> taskCustomerIDList = new Set<String>();
        Set<String> taskWhoIdList = new Set<String>();
        Set<String> taskWebIdList = new Set<String>();
		for (Task taskObj: tasks){
			if (taskObj.RTL_TMB_Customer_ID_PE__c != null) taskCustomerIDList.add(taskObj.RTL_TMB_Customer_ID_PE__c);
			if (taskObj.WhoId != null) taskWhoIdList.add(taskObj.WhoId);
			if (taskObj.RTL_Web_ID__c != null) taskWebIdList.add(taskObj.RTL_Web_ID__c);
		}
		
		// Map of SFDC Account ID and Backend Account ID
		Map<String, Id> acctIdMap = new Map<String, Id>();
		for(Account acct: [Select Id, TMB_Customer_ID_PE__c from Account where TMB_Customer_ID_PE__c in :taskCustomerIDList and RTL_RecordType_DevName__c like 'Retail%'])
			acctIdMap.put(acct.TMB_Customer_ID_PE__c, acct.Id);
			
		// Map of SFDC Lead ID and Lead object
		Map<Id, Lead> leadIdMap = new Map<Id, Lead>();
		for(Lead lead: [Select convertedAccountId from Lead where Id in :taskWhoIdList and recordtype.developername like 'Retail%'])
			leadIdMap.put(lead.Id, lead);
			
		// Map of SFDC Lead ID and Lead object
		Map<String, Lead> leadWebIdMap = new Map<String, Lead>();
		for(Lead lead: [Select convertedAccountId, RTL_Web_Unique_ID_c__c from Lead where RTL_Web_Unique_ID_c__c in :taskWebIdList and recordtype.developername like 'Retail%'])
			leadWebIdMap.put(lead.RTL_Web_Unique_ID_c__c, lead);			
		
		// List of task external NBO Product ID
		Set<String> nboExternalIdList = new Set<String>();
		for (Task taskObj:tasks) {
			//nboProductExternalIdList.add(taskObj.RTL_NBO_Product_External_ID__c);
            if(taskObj.RTL_NBO_External_ID__c != NULL){
				nboExternalIdList.add(taskObj.RTL_NBO_External_ID__c);
            }
		}

		// Get the list of NBO History Id related with NBO History Product by exteranl NBO ID
        Map<String, RTL_NBO_History__c> nboHistoryList = new Map<String, RTL_NBO_History__c>();//the key is NBO external Id
        for(RTL_NBO_History__c nboHis : [Select Id, RTL_NBO_ID__c, RTL_Product_Branch_Latest_Modified_Date__c from RTL_NBO_History__c where RTL_NBO_ID__c in : nboExternalIdList]) {
            nboHistoryList.put(nboHis.RTL_NBO_ID__c, nboHis);
		}
					
		// Get the custom metadata type of Customer Interaction Outcome
		Map<String, String> outcomeMap = getCustomerInteractionOutcome();
		// Get the custom metadata type of Customer Interaction Reason
		Map<String, String> reasonMap = getCustomerInteractionReason();
		
		// Get the list of NBO History to update the result business
		List<RTL_NBO_History__c> nboToUpdateList = new List<RTL_NBO_History__c>();
        
        Lead leadObj = null;
		RTL_NBO_History__c nboHistory = null;     
        for (Task taskObj:tasks) {
        	if (taskObj.RTL_Channel__c == 'Contact Center') {
        		taskObj.Subject = '';
				Datetime contactCenterDate = taskObj.RTL_Contact_Center_Modified_Date__c;
				if (contactCenterDate != null)
					taskObj.ActivityDate = date.newinstance(contactCenterDate.year(), contactCenterDate.month(), contactCenterDate.day());	        		
        		//taskObj.RTL_Task_Subject__c = taskObj.Subject;//auto set subject to RTL_Task_Subject__c for SF!
        		taskObj.RecordTypeId = outboundTaskRecordType.Id;//set record type to RTL_Retail_Outbound_Phone_Call
	        	// if the task is account related, set SFDC Account.Id to SFDC Task.WhatId
	            if (taskObj.RTL_TMB_Customer_ID_PE__c != null && taskObj.WhatId == null) {
	            	taskObj.WhatId = acctIdMap.get(taskObj.RTL_TMB_Customer_ID_PE__c);
	            }
	            /*
				* if the task is lead related, need to check if lead is converted
				* if lead is not converted, set SFDC Lead.Id to SFDC Task.WhoId
				* if lead is converted to prospect, set SFDC Lead.ConvertedAccountID to SFDC Task.WhatId
				*/
				if (taskObj.RTL_TMB_Customer_ID_PE__c == null && taskObj.WhoId != null && leadIdMap.get(taskObj.WhoId) != null) {//lead Id exists (WhoId)
					leadObj = leadIdMap.get(taskObj.WhoId);
					if (leadObj.convertedAccountId != null) {//the lead is converted to prospect
						taskObj.WhatId = leadObj.convertedAccountId;
						taskObj.WhoId = null; //must set WhoId to null
					}
				} else if (taskObj.RTL_TMB_Customer_ID_PE__c == null && taskObj.WhoId == null && leadWebIdMap.get(taskObj.RTL_Web_ID__c) != null) {//get lead Id from web Id
					leadObj = leadWebIdMap.get(taskObj.RTL_Web_ID__c);
					if (leadObj.convertedAccountId != null) {//the lead is converted to prospect
						taskObj.WhatId = leadObj.convertedAccountId;
						taskObj.WhoId = null; //must set WhoId to null
					} else {//the lead is not converted to prospect
						taskObj.WhoId = leadObj.Id;
					}
				}				
				
				// Based on the RTL_Result_Business__c from backend, retrieve custom metadata of Customer Interaction Outcome.
				if (taskObj.RTL_Result_Business__c != null) {
					if (outcomeMap.get(taskObj.RTL_Result_Business__c.trim()) != null) {
	        			taskObj.RTL_Outcome__c = outcomeMap.get(taskObj.RTL_Result_Business__c.trim());			
					}
				}
				
				// Based on the RTL_Result_Detail__c + RTL_Result_Business__c from backend, retrieve custom metadata of Customer Interaction Reason.
				if (taskObj.RTL_Result_Detail__c != null && taskObj.RTL_Result_Business__c != null) {
					if (reasonMap.get(taskObj.RTL_Result_Detail__c.trim() + taskObj.RTL_Result_Business__c.trim()) != null) {
	        			taskObj.RTL_Sub_Reason__c = reasonMap.get(taskObj.RTL_Result_Detail__c.trim() + taskObj.RTL_Result_Business__c.trim());
					} else {
						taskObj.RTL_Sub_Reason__c = System.Label.RTL_NBO_RejectReason;//if no matching in metadata type, use custom label to display the reject reason
					}
				}					
								
				// Map External NBO ID to SFDC ID
				if (taskObj.RTL_NBO_External_ID__c != null) {
					nboHistory = nboHistoryList.get(taskObj.RTL_NBO_External_ID__c);
					if (nboHistory != null) {
						taskObj.RTL_NBO_History__c = nboHistory.Id;
						if (taskObj.RTL_Result_Business__c != null) {
							if (nboHistory.RTL_Product_Branch_Latest_Modified_Date__c == null || taskObj.RTL_Contact_Center_Modified_Date__c > nboHistory.RTL_Product_Branch_Latest_Modified_Date__c) {
								nboHistory.RTL_Result_Business__c = taskObj.RTL_Result_Business__c.trim();//set this value to NBO History
								nboToUpdateList.add(nboHistory);
							}
						}
					} else {
						//if RTL_NBO_External_ID__c is not valid, leave RTL_NBO_History__c to null
						taskObj.RTL_NBO_History__c = null;
					}				
				}				
	        }
        }	
        
		//Update the list of NBO History
	    if(nboToUpdateList.size() > 0){
	        Database.SaveResult[] lsr = Database.update(nboToUpdateList, false);
	        // Iterate through each returned result
	        for (Database.SaveResult sr : lsr) {
	            if (sr.isSuccess()) {
	                // Operation was successful, so get the ID of the record that was processed
	                System.debug('Successfully updated NBO History with ID: ' + sr.getId());
	            }
	            else {
	                // Operation failed, so get all errors                
	                for(Database.Error err : sr.getErrors()) {
	                    System.debug(logginglevel.ERROR, 'There is error updating NBO History. Error Message is: ' + err.getMessage());
	                }
	            }
	        }            
	    }                    	
    }
    
    private static void postProcessTask(map<id,sObject> newMap) {
		// List of task external NBO Product ID
		Set<String> nboExternalIdList = new Set<String>();
		Set<String> agentIdList = new Set<String>();
		Task taskObj = null;
		for (Id lId:newMap.keySet()){
			taskObj = (Task)newMap.get(lId);
            if(taskObj.RTL_NBO_External_ID__c != NULL){
            	nboExternalIdList.add(taskObj.RTL_NBO_External_ID__c);
            }
			agentIdList.add(taskObj.RTL_Agent__c);
		}
		
		// Get the list of NBO History Product by exteranl NBO Product ID
        Map<String, Set<RTL_NBO_History_Product__c>> nboMap = new Map<String, Set<RTL_NBO_History_Product__c>>();//the key is NBO external Id
        Set<RTL_NBO_History_Product__c> nboProductList = null;
        for(RTL_NBO_History_Product__c nboProduct : [Select RTL_NBO_ID__c from RTL_NBO_History_Product__c where RTL_NBO_ID__c in : nboExternalIdList AND CreatedDate = LAST_N_DAYS:15]) {
            if (nboMap.get(nboProduct.RTL_NBO_ID__c) == null) {
            	nboProductList = new Set<RTL_NBO_History_Product__c>();
            	nboProductList.add(nboProduct);
            	nboMap.put(nboProduct.RTL_NBO_ID__c, nboProductList);
            } else {
            	nboProductList = nboMap.get(nboProduct.RTL_NBO_ID__c);
            	nboProductList.add(nboProduct);
            }
		}
		
		// Get the list of NBO History Id related with NBO History Product by exteranl NBO ID
        Map<String, RTL_NBO_History__c> nboHistoryList = new Map<String, RTL_NBO_History__c>();//the key is NBO external Id
        for(RTL_NBO_History__c nboHis : [Select Id, RTL_NBO_ID__c, RTL_Product_Branch_Latest_Modified_Date__c from RTL_NBO_History__c where RTL_NBO_ID__c in : nboExternalIdList AND CreatedDate = LAST_N_DAYS:15]) {
            nboHistoryList.put(nboHis.RTL_NBO_ID__c, nboHis);
		}	
		
		// Get the list of User with employee Id as key
        Map<String, User> userList = new Map<String, User>();//the key is Agent Id
        for(User user : [SELECT Region_Code__c,Zone_Code__c,RTL_Branch_Code__c, RTL_Channel__c, Employee_ID__c FROM User where Employee_ID__c in : agentIdList]) {
            userList.put(user.Employee_ID__c, user);
		}
		
		// Get the list of NBO History Product to update with status
		List<RTL_NBO_History_Product__c> nboProductToUpdateList = new List<RTL_NBO_History_Product__c>();
		User agentUser = null;			
		for (Id lId: newMap.keySet()) {
			taskObj = (Task)newMap.get(lId);
			if (taskObj.RTL_Channel__c == 'Contact Center') {			
		        nboProductList = nboMap.get(taskObj.RTL_NBO_External_ID__c);
		        if (nboProductList != null && nboProductList.size() > 0) {
		        	//only update if contact center modified date is later than SFDC last modified date
					if (nboHistoryList.get(taskObj.RTL_NBO_External_ID__c).RTL_Product_Branch_Latest_Modified_Date__c == null || taskObj.RTL_Contact_Center_Modified_Date__c > nboHistoryList.get(taskObj.RTL_NBO_External_ID__c).RTL_Product_Branch_Latest_Modified_Date__c) {
			        	for (RTL_NBO_History_Product__c nboProd: nboProductList) {
    						//update task outcome to nbo product status
							if (taskObj.RTL_Outcome__c == 'Accepted All')
    							nboProd.RTL_Status__c = 'Accepted';//all Accepted
    						else if (taskObj.RTL_Outcome__c == 'Rejected All')
    							nboProd.RTL_Status__c = 'Rejected';//all Rejected
    						else if (taskObj.RTL_Outcome__c == 'Pending')
    							nboProd.RTL_Status__c = 'Pending';//all Pending
    						else
    						  	nboProd.RTL_Status__c = '';//blank out the product status if it's "Accepted Some" or "Rejected Some"
    						//update task sub reason to nbo product reject reason if outcome is "Rejected All" or "Rejected Some"
	        				if (taskObj.RTL_Outcome__c == 'Rejected All' || taskObj.RTL_Outcome__c == 'Rejected Some') {
	        					nboProd.RTL_Reject_Reason__c = taskObj.RTL_Sub_Reason__c;
	        				} else {
	        					nboProd.RTL_Reject_Reason__c = null;
	        				}
	        				//update contact center user info to nbo product region/zone/branch/channel
							agentUser = userList.get(taskObj.RTL_Agent__c);
							if (agentUser != null) {
    							nboProd.RTL_Offering_Channel__c = agentUser.RTL_Channel__c;
				        		nboProd.RTL_User_Branch__c = agentUser.RTL_Branch_Code__c;
				        		nboProd.RTL_User_Region__c = agentUser.Region_Code__c;
				        		nboProd.RTL_User_Zone__c = agentUser.Zone_Code__c;
							} else {
								nboProd.RTL_Offering_Channel__c = taskObj.RTL_Channel__c;
							}
	        				nboProductToUpdateList.add(nboProd);					
	    				} 
			        } 
		        }					
			}
		}
		
	            
		//Update the list of NBO History Product
	    if(nboProductToUpdateList.size() > 0){
	        Database.SaveResult[] lsr = Database.update(nboProductToUpdateList, false);
	        // Iterate through each returned result
	        for (Database.SaveResult sr : lsr) {
	            if (sr.isSuccess()) {
	                // Operation was successful, so get the ID of the record that was processed
	                System.debug('Successfully updated NBO History Product with ID: ' + sr.getId());
	            }
	            else {
	                // Operation failed, so get all errors                
	                for(Database.Error err : sr.getErrors()) {
	                    System.debug(logginglevel.ERROR, 'There is error updating NBO History Product. Error Message is: ' + err.getMessage());
	                }
	            }
	        }            
	    }		
    }    
    
    private static Map<String, String> getCustomerInteractionOutcome() {
        Map<String, String> outcomeMap = new Map<String, String>();
        for (RTL_Customer_Interaction_Outcome__mdt outcome : [SELECT RTL_Outcome__c, RTL_Result_Business__c FROM RTL_Customer_Interaction_Outcome__mdt]){
            outcomeMap.put(outcome.RTL_Result_Business__c.trim(), outcome.RTL_Outcome__c.trim());
        }
        
        return outcomeMap;
    }
    
    private static Map<String, String> getCustomerInteractionReason() {
        Map<String, String> reasonMap = new Map<String, String>();
        for (RTL_Customer_Interaction_Reason__mdt reason : [SELECT RTL_Result_Detail__c, RTL_Result_Business__c, RTL_Sub_Reason__c FROM RTL_Customer_Interaction_Reason__mdt]){
            reasonMap.put(reason.RTL_Result_Detail__c.trim()+reason.RTL_Result_Business__c.trim(), reason.RTL_Sub_Reason__c.trim());
        }
        
        return reasonMap;
    }    
      /* end private methods */
    //====================================================================
}