public class RTL_ReferralAssignment {
    private static String KEY_ISNULL = AppConfig__c.getValues('RTL_Referral_Assignment_ISNULL').Value__c;
    private static String KEY_NOT_NULL = AppConfig__c.getValues('RTL_Referral_Assignment_NOTNULL').Value__c;
    private static List<Group> queueList = [ select Id,Name,DeveloperName from Group where Type = 'Queue' ];
    private static Map<Id,Branch_and_Zone__c> branchAndZoneList = new Map<Id,Branch_and_Zone__c>();
    Map<String,RTL_Referral_Default_Assignment__mdt> mapDefaultAssignmentList = new Map<String,RTL_Referral_Default_Assignment__mdt>();
    private static Map<Id,User> mapUserInActiveList = new Map<Id,User>();
    
    public RTL_ReferralAssignment(List<RTL_Referral__c> newList){
        System.debug('Start RTL_ReferralAssignment');
        List<String> branchAndZone = new List<String>();
        List<Id> recordtypeIdList = new List<Id>();
        List<String> assignUserIdList = new List<String>();
        List<String> recordtypeDevNameList = new List<String>();
        Map<String,RecordType> mapRecordTypeByDevName = new Map<String,RecordType>();        
        Map<Id,Id> mapRTLAssignmentByRecordTypeId = new Map<Id,Id>();
        Map<Id,RTL_Referral_Assignment__c> mapRTLAssignment = new Map<Id,RTL_Referral_Assignment__c>();

        // loop for get condition
        for( RTL_Referral__c each : newList ){
            // get record type
            if( each.RecordTypeId != null ){
                recordtypeIdList.add(each.RecordTypeId);
            }
            if( each.RTL_Preferred_Branch__c != null ){
                branchAndZone.add(each.RTL_Preferred_Branch__c);
            }
        }
        
        // create map branch and zone
        for( Branch_and_Zone__c each : RTL_ReferralAssignUtility.getBranchAndZone(branchAndZone) ){
            branchAndZoneList.put(each.Id,each);
        }

        // get record type developer name
        for( RecordType each : getRTLRecordType(recordtypeIdList).Values() ){
            recordtypeDevNameList.add(each.DeveloperName);
            System.debug('each.DeveloperName : '+each.DeveloperName);
            mapRecordTypeByDevName.put(each.DeveloperName,each);
        }

        // create map Condition RTL Assignment
        for( RTL_Referral_Assignment__c each : getConditionRTLAssignment(recordtypeDevNameList) ){
            Id recordTypeId = mapRecordTypeByDevName.get(each.RTL_Referral_Type__c).Id;
            mapRTLAssignmentByRecordTypeId.put(each.Id,recordTypeId );   
            mapRTLAssignment.put(each.Id,each);
            
            if( RTL_Utility.isNotNull(each.RTL_Assigned_User__c) ){
                assignUserIdList.add( each.RTL_Assigned_User__c );    
            }
            if( RTL_Utility.isNotNull(each.RTL_Default_User__c) ){
                assignUserIdList.add( each.RTL_Default_User__c );                 
            }
            for( RTL_Referral__c rfr : newList ){
                try{
                    if( RTL_Utility.isNotNull(each.RTL_Assigned_User_field__c) ){
                        assignUserIdList.add( String.valueOf(rfr.get(each.RTL_Assigned_User_field__c)) );    
                    }
                    if( RTL_Utility.isNotNull(each.RTL_Branch_and_Zone_Queue_User_field__c) ){
                        if( branchAndZoneList.containsKey( rfr.RTL_Preferred_Branch__c ) ){      
                            assignUserIdList.add( String.valueOf(branchAndZoneList.get( rfr.RTL_Preferred_Branch__c ).get(each.RTL_Branch_and_Zone_Queue_User_field__c)) );   
                            //assignUserIdList.add( String.valueOf(rfr.get(each.RTL_Branch_and_Zone_Queue_User_field__c)) );   
                        } 
                    }                    
                }catch( Exception e ){
                    System.debug('error : '+e.getMessage()+' '+e.getLineNumber()+' '+e.getStackTraceString());
                }  
            }     
        }

        // fiter record
        System.debug('mapRTLAssignmentByRecordTypeId : '+mapRTLAssignmentByRecordTypeId);
        if( mapRTLAssignmentByRecordTypeId.size() > 0 ){            
            mapUserInActiveList = RTL_ReferralAssignUtility.getUserList(assignUserIdList);
            //assign userInActive to RTL_ReferralAssignUtility
            RTL_ReferralAssignUtility.setUserInActiveList(mapUserInActiveList);
            for( User u : mapUserInActiveList.values() ){
                branchAndZone.add( u.RTL_Branch_Code__c );
            }
            
            //create map meta default Assignment
            for( RTL_Referral_Default_Assignment__mdt each : RTL_ReferralAssignUtility.getMetaDefaultAssignment() ){
                mapDefaultAssignmentList.put(each.Referral_record_type__c,each);
            }
            //assign defaultAssignmentList to RTL_ReferralAssignUtility
            RTL_ReferralAssignUtility.setDefaultAssignmentList(mapDefaultAssignmentList);
            
            // create map branch and zone
            for( Branch_and_Zone__c each : RTL_ReferralAssignUtility.getBranchAndZone(branchAndZone) ){
                branchAndZoneList.put(each.Id,each);
            }
            //assigh branchAndZoneList to RTL_ReferralAssignUtility
            RTL_ReferralAssignUtility.setBranchAndZoneList(branchAndZoneList);
            System.debug('newList12 : '+newList);
            for( RTL_Referral__c each : newList ){          

                for( RTL_Referral_Assignment__c eachCond : mapRTLAssignment.values() ){
                    System.debug('eachCond1 : '+eachCond);
                    if( each.RecordTypeId == mapRTLAssignmentByRecordTypeId.get(eachCond.Id) ){
                        System.debug('eachCond : '+eachCond);
                        // if is true Assgin Owner
                        if( checkCriteria(each, eachCond) ){
                            try{
                                System.debug('cond can assign : '+eachCond.Name);                                
                                each.OwnerId = RTL_ReferralAssignUtility.assignOwner(each,eachCond);
                                
                                //CR Call Me Now
    
                                //Capture assignment rule which referral is assigned
                                each.RTL_Referral_Assignment__c = eachCond.Id;
                                //If need to send this referral to Telephony
                                // ปกติตรงนี้เปิด
                                if(eachCond.RTL_Integration_Flag__c == 'Cisco' || eachCond.RTL_Integration_Flag__c == 'Avaya' ){
                                    //stamp integration flag,campaign from referral assignment to referral
                                    each.RTL_Send_To_Call_Me_Now_Flag__c = eachCond.RTL_Integration_Flag__c;
                                    each.RTL_Campaign__c = eachCond.RTL_Campaign__c;
                                    
                                }


                                // meta default assignment
                                if( each.OwnerId == null || mapUserInActiveList.containsKey(each.OwnerId) ){
                                    System.debug('assign default');
									each.OwnerId = RTL_ReferralAssignUtility.assignDefault( each,eachCond );
                                    System.debug(' : '+each.OwnerId);
                                }
                                
                                break;
                            }catch( Exception e ){
                                System.debug('error : '+e.getMessage());
                                each.addError('error default assign : '+e.getMessage() );                                
                            }                        
                        }   
                    }
                }
            }
        }
        
    }
    
    /*public Id assignOwner( RTL_Referral__c data,RTL_Referral_Assignment__c cond ){
        String tempOwner = null;
        // 1.1
        if( isNotNull(cond.RTL_Assigned_User__c) ){        	
            tempOwner = cond.RTL_Assigned_User__c;
            if( !mapUserInActiveList.containsKey(tempOwner) ){
                 return tempOwner;
            }          
        }
        
        // 1.2
        if( isNotNull(cond.RTL_Assigned_User_field__c) ){
            tempOwner = String.ValueOf(data.get(cond.RTL_Assigned_User_field__c));
            if( !mapUserInActiveList.containsKey(tempOwner) && tempOwner != null ){
                return tempOwner; 
            }
        }
        
        // 2.1
        if( isNotNull(cond.RTL_Assigned_Queue_Name__c) ){
            for( Group q : queueList ){
                if( q.DeveloperName == cond.RTL_Assigned_Queue_Name__c ){
                    return q.Id;    
                }
            }        	
        }
        
        // 2.2
        if( isNotNull(cond.RTL_Branch_and_Zone_Queue_User_field__c) ){
            if( branchAndZoneList.containsKey( data.RTL_Preferred_Branch__c ) ){
                tempOwner = String.ValueOf(branchAndZoneList.get( data.RTL_Preferred_Branch__c ).get( cond.RTL_Branch_and_Zone_Queue_User_field__c ));
                if(tempOwner != null){
                    for( Group q : queueList ){
                    	if( q.DeveloperName == tempOwner ){
                        	return q.Id;    
                    	}    
                	}
                    if( !mapUserInActiveList.containsKey( tempOwner ) ){
                        return tempOwner;  
                    }
                	
                }
                              
            }                      	
        }
        
        // 3.1
        if( isNotNull(cond.RTL_Default_Queue_Name__c) ){
            for( Group q : queueList ){
                if( q.DeveloperName == cond.RTL_Default_Queue_Name__c ){
                    return q.Id;    
                }
            }
        }
        
        // 3.2
        if( isNotNull(cond.RTL_Default_User__c) ){
            tempOwner = cond.RTL_Default_User__c;
            if( !mapUserInActiveList.containsKey( tempOwner ) ){
                return tempOwner;    
            }
        }
        System.debug('Map User Inactive '+mapUserInActiveList);
        // 3.3
        if( cond.RTL_Default_For_BM__c && mapUserInActiveList.containsKey(tempOwner) && tempOwner != null ){
            System.debug('detect inactive');
            return assignForBM( tempOwner, cond );    
        }

        //3.4  -- CR RQ-014 to be able to default to queue/user from referral preferred branch
        if( isNotNull(cond.RTL_Default_Branch_Zone_Queue_User_field__c) ){
            if( branchAndZoneList.containsKey( data.RTL_Preferred_Branch__c ) ){
                tempOwner = String.ValueOf(branchAndZoneList.get( data.RTL_Preferred_Branch__c ).get( cond.RTL_Default_Branch_Zone_Queue_User_field__c ));
                if(tempOwner != null){
                    for( Group q : queueList ){
                        if( q.DeveloperName == tempOwner ){
                            return q.Id;    
                        }    
                    }
                    if( !mapUserInActiveList.containsKey( tempOwner ) ){
                        return tempOwner;  
                    }
                    
                }
                              
            }                       
        }
        return null;
    }*/
    
    public Boolean checkCriteria(RTL_Referral__c data,RTL_Referral_Assignment__c cond){
        Boolean criteriaPass = false;
		Boolean criteriaNotNull = false;
        if( RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_1__c) 
           || RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_2__c) 
           || RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_3__c) 
           || RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_4__c) 
           || RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_5__c) ){
               criteriaNotNull = true;
           }
        
        if( criteriaNotNull && 
           checkCondition(cond.RTL_Referral_Field_Criteria_1__c,
                           data,
                           cond.RTL_Referral_Field_Value_1__c) 
           && checkCondition(cond.RTL_Referral_Field_Criteria_2__c,
                           data,
                           cond.RTL_Referral_Field_Value_2__c) 
          && checkCondition(cond.RTL_Referral_Field_Criteria_3__c,
                           data,
                           cond.RTL_Referral_Field_Value_3__c)
          && checkCondition(cond.RTL_Referral_Field_Criteria_4__c,
                           data,
                           cond.RTL_Referral_Field_Value_4__c)
          && checkCondition(cond.RTL_Referral_Field_Criteria_5__c,
                           data,
                           cond.RTL_Referral_Field_Value_5__c)){
        	criteriaPass = true;	       
        }
        System.debug('criteriaNotNull : '+criteriaNotNull);        
        System.debug('criteriaPass : '+criteriaPass);
       return criteriaPass;
    }
    
    public Boolean checkCondition(String cond,SObject data,String condValue){
        if( cond == null || cond == '' ){
            return true;
        }
        System.debug(data.get(cond)+'=='+condValue);
        if( condValue == KEY_NOT_NULL ){
            if( String.valueOf(data.get(cond)) != '' && String.valueOf(data.get(cond)) != null ){
                return true;    
            }    
        }
        if( condValue == KEY_ISNULL ){
            condValue = null;
        }        
        if( String.valueOf(data.get(cond)) != condValue ){
        	return false;    
        }
        return true;
    }
    
    public List<RTL_Referral_Assignment__c> getConditionRTLAssignment(List<String> recordtypeDevNameList){
        return (List<RTL_Referral_Assignment__c>)queryConditionRTLAssignment(recordtypeDevNameList);
    }
    
    public List<SObject> queryConditionRTLAssignment(List<String> recordtypeDevNameList){
        try{            
            String objectName = 'RTL_Referral_Assignment__c';
            String strQuery = 'select ';
            strQuery += RTL_Utility.queryAllField(objectName);
            
            strQuery = strQuery.substring(0,strQuery.length()-1);
            String strWhere = ' where RTL_Active_Flag__c = true and RTL_Reassign_Flag__c = false and RTL_Referral_Type__c IN :recordtypeDevNameList order by RTL_Referral_Type__c,RTL_Priority__c asc ';
            strQuery += ' from '+objectName;
            System.debug('strWhere : '+strWhere);
            strQuery += strWhere;
            System.debug('strQuery : '+strQuery);
            return Database.query(strQuery);
            
        }catch(QueryException e){
          	return new List<SObject>();  
        }
    }

    public Map<Id,RecordType> getRTLRecordType(List<Id> recordtypeIdList){
        return new Map<Id,RecordType>([ select Id,DeveloperName 
                from RecordType 
                where Id IN :recordtypeIdList  ]);
    }

}