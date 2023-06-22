public class RTL_WriteHistory {   
    public static void writeUpdateHistory(map<id,sObject> oldMap, map<id,sObject> newMap,List<String> fieldsToTrack,Map<String,String> fieldNameMap,Map<String,RTL_Household_History_and_Approval__c> existingHistoryMap){
        List<RTL_Household_History_and_Approval__c> historyToInsert = new List<RTL_Household_History_and_Approval__c>();
        List<RTL_Household_History_and_Approval__c> historyToUpdate = new List<RTL_Household_History_and_Approval__c>();
        
        for(sObject obj :oldMap.values()){
            Sobject newObj = newMap.get(obj.id);
            String oldStatus = String.ValueOf(Obj.get('RTL_Status__c'));
            String newStatus = String.ValueOf(newObj.get('RTL_Status__c'));
            	for(String field :fieldsToTrack){
                	String oldValue = String.ValueOf(obj.get(field));
                	String newValue = String.valueOf(newObj.get(field));
                	//If Field Value Change
                	if(oldValue != newValue){ 
                    	if(oldStatus == newStatus && newStatus != 'New' && newStatus != 'Pending' && newStatus != 'Deleted'){
                        	RTL_Household_History_and_Approval__c  history;
                        	//existing Hisory Map find history with 'New' status
                        	if(existingHistoryMap.containsKey(obj.Id+Field)){
                            	history = existingHistoryMap.get(obj.Id+Field);
                            
                            	if(history.RTL_New_Value__c != history.RTL_Prev_Value__c){
                            		history.RTL_Date_Requested__c = Date.today();
                    				history.RTL_User_Requesting__c = UserInfo.getUserId();
                            		history.RTL_New_Value__c = newValue;
                            		historyToUpdate.add(history);
                            	}
                            
                        	}else{
                            	history = new RTL_Household_History_and_Approval__c ();
                    			history.RTL_Field_Changed__c = field;
                    			history.RTL_Household__c = obj.id;
                    			history.RTL_New_Value__c = newValue;
                    			history.RTL_Outcome__c = 'New';
                    			history.RTL_Prev_Value__c = oldValue;
                    			history.RTL_Date_Requested__c = Date.today();
                    			history.RTL_User_Requesting__c = UserInfo.getUserId();
                    			history.RTL_Field_Label__c = fieldNameMap.get(field);
                                
                    	
                        		//If incoming object is a Household Member Object
                    			if(obj.getSObjectType() == Schema.RTL_Household_Member__c.getSObjectType()){
                        			history.RTL_Household__c = String.ValueOf(obj.get('RTL_HouseHold__c'));
                        			history.RTL_Household_Member__c = obj.id;
                                    history.RTL_HHM_Benefit__c = Boolean.ValueOf(obj.get('RTL_Benefit__c'));
                                    history.RTL_HHM_Relationship__c = String.ValueOf(obj.get('RTL_Relationship__c'));
                                    history.RTL_HH_RM_BM__c  = String.ValueOf(obj.get('RTL_RM_BM__c'));
                                    history.RTL_Member_Lookup_Account__c = String.ValueOf(obj.get('RTL_Household_Member_Name__c'));
                                }else{
                                	history.RTL_HH_Req_Benefit_Package__c = String.ValueOf(obj.get('RTL_Benefit_Package__c')); 
                                	history.RTL_HH_Req_Remarks__c = String.ValueOf(obj.get('RTL_Remarks__c'));
                                	history.RTL_HH_RM_BM__c  = String.ValueOf(obj.get('RTL_RM__c'));
                                    newObj.put('RTL_Number_of_New_and_Pending_Reque__c',Integer.ValueOf(newObj.get('RTL_Number_of_New_and_Pending_Reque__c'))+1);
                                }
                    			historyToInsert.add(history);
                                
                        	}
                    	
                        	//reset the value 
                        	if(field == 'RTL_Primary__c' || field == 'RTL_Benefit__c' )
                        	{
                            	newObj.put(field, Boolean.ValueOf(oldValue)); 
                        	}	
                        	else if(field == 'RTL_To_Delete__c'){
                            	//Do nothing
                        	}   
                        	else
                        	{
                            	newObj.put(field, oldValue); 
                        	}
                            
                        }              
                   
                	}
            	}
            if(oldStatus == newStatus && newStatus == 'New'){
                System.debug('UPDATE NEW HISTORY '+existingHistoryMap);
            	RTL_Household_History_and_Approval__c  history;
                //existing Hisory Map find history with 'New' status
               	if(existingHistoryMap.containsKey(obj.Id+'New Household')){
                	history = existingHistoryMap.get(obj.Id+'New Household');
                    history.RTL_Date_Requested__c = Date.today();
                    history.RTL_User_Requesting__c = UserInfo.getUserId();
                    //If incoming object is a Household Member Object
                    if(obj.getSObjectType() == Schema.RTL_Household_Member__c.getSObjectType()){
                    	history.RTL_HHM_Benefit__c = Boolean.ValueOf(newObj.get('RTL_Benefit__c'));
                    	history.RTL_HHM_Relationship__c = String.ValueOf(newObj.get('RTL_Relationship__c'));
                    	history.RTL_HH_RM_BM__c  = String.ValueOf(newObj.get('RTL_RM_BM__c'));
                    }else{
                    	history.RTL_HH_Req_Benefit_Package__c = String.ValueOf(newObj.get('RTL_Benefit_Package__c')); 
                    	history.RTL_HH_Req_Remarks__c = String.ValueOf(newObj.get('RTL_Remarks__c'));
                    	history.RTL_HH_RM_BM__c  = String.ValueOf(newObj.get('RTL_RM__c'));  
                    }
                    historyToUpdate.add(history);
                }
            }
            

        }
        
        if(historyToInsert.size() > 0){
            try{
                System.Debug(historyToInsert);
                insert historyToInsert;
            }catch(Exception e){
                
            }
        }
        System.debug('UPDATE '+historyToUpdate);
        if(historyToUpdate.size() > 0){
            try{
                System.Debug(historyToInsert);
                update historyToUpdate;
            }catch(Exception e){
                System.debug('UPDATE HISTORY ERROR '+e.getMessage());
            }
        }
                    
    }
    
    public static void writeInsertHistory(map<id,sObject> newMap,List<String> fieldsToTrack,Map<String,String> fieldNameMap){
        List<RTL_Household_History_and_Approval__c> historyToInsert = new List<RTL_Household_History_and_Approval__c>();      
        RTL_Household_History_and_Approval__c  history;
        
        for(sObject obj :newMap.values()){
            Sobject newObj = newMap.get(obj.id);
            history = new RTL_Household_History_and_Approval__c ();
            history.RTL_Field_Label__c = 'New Household'; 
            history.RTL_Field_Changed__c = 'New Household';
            history.RTL_Household__c = obj.id;
            history.RTL_New_Value__c = String.valueOf(newObj.get('Name'));
            history.RTL_Outcome__c = 'New';
            history.RTL_Date_Requested__c = Date.today();
            history.RTL_User_Requesting__c = UserInfo.getUserId();
            history.RTL_Is_Insert_Action__c = true;
                    
            if(obj.getSObjectType() == Schema.RTL_Household_Member__c.getSObjectType()){
            	history.RTL_Household__c = String.ValueOf(obj.get('RTL_HouseHold__c'));
            	history.RTL_Household_Member__c = obj.id;
                history.RTL_Field_Label__c = 'New Member'; 
                history.RTL_Field_Changed__c = 'New Member';
                history.RTL_New_Value__c = String.valueOf(obj.get('Name'));
                history.RTL_HHM_Benefit__c = Boolean.ValueOf(obj.get('RTL_Benefit__c'));
                history.RTL_HHM_Relationship__c = String.ValueOf(obj.get('RTL_Relationship__c'));
                history.RTL_HH_RM_BM__c  = String.ValueOf(obj.get('RTL_RM_BM__c'));
                history.RTL_Member_Lookup_Account__c = String.ValueOf(obj.get('RTL_Household_Member_Name__c'));
            }else{
            	//history.RTL_HH_Req_Approver__c = userMap.get(String.ValueOf(obj.get('RTL_RM__c'))).Manager.Name; 
                history.RTL_HH_Req_Benefit_Package__c = String.ValueOf(obj.get('RTL_Benefit_Package__c')); 
               	history.RTL_HH_Req_Remarks__c = String.ValueOf(obj.get('RTL_Remarks__c'));
                history.RTL_HH_RM_BM__c  = String.ValueOf(obj.get('RTL_RM__c'));
            }
            historyToInsert.add(history);
  
        }
        
        if(historyToInsert.size() > 0){
            try{
                insert historyToInsert;
            }catch(Exception e){
             	System.debug('ERROR INSERT HISTORY : '+e.getMessage());   
            }
        }
            
        
    }
}