public class CS_EClientSuitabilityTriggerHandler extends TriggerHandler {

    public CS_EClientSuitabilityTriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(10);
        }
        else{
            this.setMaxLoopCount(1000);
        }
    }
    
    protected override void beforeUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) 
    {
        for(sObject ecTmp : newMap.values() )
        {
            E_Client_Suitability__c ec = (E_Client_Suitability__c)ecTmp;

            if( ec.CS_Stamped_Customer_Segment__c != ec.CS_Customer_Segment__c )
            {
                ec.CS_Stamped_Customer_Segment__c = ec.CS_Customer_Segment__c;
            }
        }
    }

    protected override void beforeInsert(List<sObject> newList) {

        List<Id> accIdList = new List<Id>();
        for(sObject ecTmp : newList )
        {
            E_Client_Suitability__c ec = (E_Client_Suitability__c)ecTmp;
            ec.CS_Stamped_Customer_Segment__c = ec.CS_Customer_Segment__c;

            accIdList.add(ec.CS_Customer__c);
        }

        Map<String,Account> idAccountMap = new Map<String,Account>();
        Map<String,Account> tmbIdAccountMap = new Map<String,Account>();

        for(Account acc : [SELECT Id, TMB_Customer_ID_PE__c, CS_Murex_ID__c ,Murex_Counter_Label__c,
                    OwnerId,Core_Banking_Suggested_Segment__c,Customer_Segment_Team__c
                    FROM Account WHERE Id IN:accIdList])
        {
            idAccountMap.put(acc.Id, acc);
            tmbIdAccountMap.put(acc.TMB_Customer_ID_PE__c, acc);
        }


        // List<AccountTeamMember> accTeam = [SELECT Id, AccountId,TeamMemberRole, 
        //                      UserId,  Account.TMB_Customer_ID_PE__c 
        //                   FROM AccountTeamMember
        //                   WHERE AccountId in :accIdList
        //                   AND TeamMemberRole = 'FX Sales' AND User.IsActive = true
        //                   ];

        
        // Map<String,List<AccountTeamMember>> idAccountTeamMap = new Map<String,List<AccountTeamMember>>();
        // for( AccountTeamMember atm : accTeam )
        // {
        //     List<AccountTeamMember> actList;
        //     if( idAccountTeamMap.containsKey( atm.Account.TMB_Customer_ID_PE__c ) )
        //     {
        //         actList = idAccountTeamMap.get( atm.Account.TMB_Customer_ID_PE__c );
        //     }
        //     else 
        //     {
        //         actList = new List<AccountTeamMember>();
        //     }
        //     actList.add(atm);

        //     idAccountTeamMap.put( atm.Account.TMB_Customer_ID_PE__c  , actList );
        // }


        Map<String,Group> queueNameIdMap = new Map<String,Group>();
        Map<String,Group>  segmentQueueMap = new Map<String,Group> ();
        
        List<Group> groupList  = [SELECT Id, Name, DeveloperName,Type, OwnerId FROM Group Where Type = 'Queue'  ];

        for(Group g : groupList)        
        {
            queueNameIdMap.put(g.DeveloperName ,g );
        }
        for( CS_Segment_To_Queue_Mapping__mdt x : CS_EClientSuitabilityUtil.queue )
        {
            segmentQueueMap.put( x.Fx_Sales_Segment__c , queueNameIdMap.get(x.Queue__c) );
        }


        for(sObject ecTmp : newList )
        {
        
            E_Client_Suitability__c ec = (E_Client_Suitability__c)ecTmp;
            if(idAccountMap.containsKey(ec.CS_Customer__c))
            {
                String expiryDateText = '';
                DateTime expiryDateTime;
                if( ec.CS_Expiry_Date_Next__c != null )
                {
                    Integer d = ec.CS_Expiry_Date_Next__c.day();
                    Integer mo = ec.CS_Expiry_Date_Next__c.month();
                    Integer yr = ec.CS_Expiry_Date_Next__c.year();
                    expiryDateTime = DateTime.newInstance(yr, mo, d);  
                    expiryDateText = expiryDateTime.format('YYYYMMdd');
                }
                else
                {
                    Integer d = datetime.now().day();
                    Integer mo = datetime.now().month();
                    Integer yr = datetime.now().year();
                    expiryDateTime = DateTime.newInstance(yr, mo, d);  
                    expiryDateText = expiryDateTime.format('YYYYMMdd');
                    //Integer hr = datetime.now().hour();
                    //Integer mt = datetime.now().minute();
                    //Integer mili = datetime.now().millisecond();
                    //expiryDateTime = DateTime.newInstance(yr, mo, d, hr, mt, mili);  
                    //expiryDateText = expiryDateTime.format('YYYYMMddHHmmss');
                }
           
                String tmbCustId = idAccountMap.get(ec.CS_Customer__c).TMB_Customer_ID_PE__c;

                if( tmbCustId != '' && tmbCustId != null )
                {

                    String csKey = tmbCustId + expiryDateText;

                    if( ec.CS_Key__c == null )
                    {
                        ec.CS_Key__c = csKey;
                    }

                    // system.debug('gade: ' + idAccountMap.get(ec.CS_Customer__c));

                    if(idAccountMap.get(ec.CS_Customer__c).Murex_Counter_Label__c != null)
                    {
                        ec.CS_Murex_ID__c = idAccountMap.get(ec.CS_Customer__c).CS_Murex_ID__c;
                        ec.Murex_Counter_Label__c = idAccountMap.get(ec.CS_Customer__c).Murex_Counter_Label__c;

                        String accountCustomerSegmentTeam = idAccountMap.get(ec.CS_Customer__c).Customer_Segment_Team__c;
                        String accountCoreBankingSuggestedSegment = idAccountMap.get(ec.CS_Customer__c).Core_Banking_Suggested_Segment__c;

                        String segment = '';

                        if( accountCustomerSegmentTeam == 'MB : MB-FI' )
                        {
                            segment = 'FI';
                        }
                        else
                        {
                            segment = accountCoreBankingSuggestedSegment;
                        }

                        ec.CS_Stamped_Customer_Segment__c = segment;

                        // ec.CS_RM__c  = CS_EClientSuitabilityUtil.getRM( tmbCustId, tmbIdAccountMap );
                        // ec.CS_Sales_Owner__c = CS_EClientSuitabilityUtil.getSaleOwner( tmbCustId, tmbIdAccountMap , idAccountTeamMap );
                        // ec.OwnerId = CS_EClientSuitabilityUtil.getEClientOwner( tmbCustId, tmbIdAccountMap , idAccountTeamMap,segmentQueueMap );

                        //ec.CS_RM__c = idAccountMap.get(ec.CS_Customer__c).OwnerId;
                        //ec.CS_Sales_Owner__c = UserInfo.getUserId();
                    }
                    else
                    {
                        ec.addError(System.Label.E_Client_CS_EClientSuitabilityTriggerHandler_BeforeInsert_Error_Msg);
                    }
                }
                else 
                {
                    ec.addError(System.Label.E_Client_CS_EClientSuitabilityTriggerHandler_BeforeInsert_Error_Msg);
                }
                
            }

        }
        
        
    }

    protected override void afterInsert(map<id,sObject> newMap) 
    {
        List<Id> surveySheetIdStatusToBlank = new List<Id>();
        List<Id> surveySheetIdStatusCanceled = new List<Id>();  

        for( Id eClientId : newMap.keySet() )
        {
            E_Client_Suitability__c newEclient = (E_Client_Suitability__c)newMap.get(eClientId);

            if(newEclient.CS_Status__c == 'Suspended')
            {
                surveySheetIdStatusCanceled.add( newEclient.CS_Customer_Survey_A__c );
                surveySheetIdStatusCanceled.add( newEclient.CS_Customer_Survey_B__c );
            }
            else if( newEclient.CS_Status__c == 'Pending Review' )
            {
                surveySheetIdStatusToBlank.add( newEclient.CS_Customer_Survey_A__c );
                surveySheetIdStatusToBlank.add( newEclient.CS_Customer_Survey_B__c );
            }
        }

        List<Survey_Sheet__c> shStatusToBlank = [SELECT Id,Status__c FROM Survey_Sheet__c WHERE Id in :surveySheetIdStatusToBlank ];

        for( Survey_Sheet__c sc : shStatusToBlank )
        {
            sc.Status__c = null;
        }

        List<Survey_Sheet__c> shStatusToCanceled = [SELECT Id,Status__c FROM Survey_Sheet__c WHERE Id in :surveySheetIdStatusCanceled ];

        for( Survey_Sheet__c sc : shStatusToCanceled )
        {
            sc.Status__c = 'Cancelled'; 
        }

        List<Survey_Sheet__c> updatedSurveySheetList = new List<Survey_Sheet__c>();
        updatedSurveySheetList.addAll(shStatusToBlank );
        updatedSurveySheetList.addAll(shStatusToCanceled );

        update updatedSurveySheetList;
    }

    protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) 
    {
        List<Id> surveySheetIdStatusToBlank = new List<Id>();
        List<Id> surveySheetIdStatusCanceled = new List<Id>();
        List<Id> surveySheetIdStatusNew= new List<Id>();  

        for( Id eClientId : oldMap.keySet() )
        {
            E_Client_Suitability__c newEclient = (E_Client_Suitability__c)newMap.get(eClientId);
            E_Client_Suitability__c oldEclient = (E_Client_Suitability__c)oldMap.get(eClientId);

           

            if( newEclient.CS_Status__c != oldEclient.CS_Status__c )
            {
               
               if(newEclient.CS_Status__c == 'Suspended')
                {
                    surveySheetIdStatusCanceled.add( newEclient.CS_Customer_Survey_A__c );
                    surveySheetIdStatusCanceled.add( newEclient.CS_Customer_Survey_B__c );
                }
                else if( newEclient.CS_Status__c == 'Pending Review')
                {
                    if(oldEclient.CS_Status__c == 'Suspended')
                    {           
                        surveySheetIdStatusNew.add(newEclient.CS_Customer_Survey_A__c);
                        surveySheetIdStatusNew.add(newEclient.CS_Customer_Survey_B__c);
                    }
                    else
                    {
                        surveySheetIdStatusToBlank.add( newEclient.CS_Customer_Survey_A__c );
                        surveySheetIdStatusToBlank.add( newEclient.CS_Customer_Survey_B__c );
                    }
                   
                }

            }          

        }

        List<Survey_Sheet__c> shStatusToBlank = [SELECT Id,Status__c FROM Survey_Sheet__c WHERE Id in :surveySheetIdStatusToBlank ];

        for( Survey_Sheet__c sc : shStatusToBlank )
        {
            sc.Status__c = null;
        }

        List<Survey_Sheet__c> shStatusToCanceled = [SELECT Id,Status__c FROM Survey_Sheet__c WHERE Id in :surveySheetIdStatusCanceled ];

        for( Survey_Sheet__c sc : shStatusToCanceled )
        {
            sc.Status__c = 'Cancelled'; 
        }

        List<Survey_Sheet__c> shStatusToNew = [SELECT Id,Status__c FROM Survey_Sheet__c WHERE Id in :surveySheetIdStatusNew ];

        for( Survey_Sheet__c sc : shStatusToNew )
        {
            sc.Status__c = 'New';

        }

        List<Survey_Sheet__c> updatedSurveySheetList = new List<Survey_Sheet__c>();
        updatedSurveySheetList.addAll(shStatusToBlank );
        updatedSurveySheetList.addAll(shStatusToCanceled );
        updatedSurveySheetList.addAll(shStatusToNew );

        update updatedSurveySheetList;

    }

}