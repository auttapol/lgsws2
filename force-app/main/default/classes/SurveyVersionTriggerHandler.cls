public class SurveyVersionTriggerHandler extends TriggerHandler {

    public SurveyVersionTriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(10);
        }
        else{
            this.setMaxLoopCount(1000);
        }
    }

    public static boolean ignoreSurveyVersionTrigger = false;

    protected override void afterUpdate(MAP<id,sObject> oldMap, MAP<id,sObject> newMap) 
    {

        if( ignoreSurveyVersionTrigger == true )
        {
            //ignore run trigger in current session session 
        }
        else
        {

        	MAP<Id,Survey_Version__c> surveyManagerActiveSurveyVersion = new MAP<Id,Survey_Version__c>();

            List<Survey_Manager__c> surveyManagerSetSurveyVersionNull = new List<Survey_Manager__c>();

        	for( Id surveyVerionId : newMap.keySet() )
            {
                
            	Survey_Version__c surveyVersionNew = (Survey_Version__c)newMap.get(surveyVerionId);
            	Survey_Version__c surveyVersionOld = (Survey_Version__c)oldMap.get(surveyVerionId);
                
                if( surveyVersionNew.Active_Status__c != surveyVersionOld.Active_Status__c )
            	{
                    // If atlease one of survey version change active flag , add survey manager to set survey version null list
                    Survey_Manager__c sm = new Survey_Manager__c( Id = surveyVersionNew.Survey_Manager__c );
                    sm.Survey_Version__c = null;
                    surveyManagerSetSurveyVersionNull.add(sm);

                    // Mark survey version on Survey manager and set active flag for all others version belong to each Survey Manager
                    if( surveyVersionNew.Active_Status__c == true  )
                    {
                		if( !surveyManagerActiveSurveyVersion.containsKey(surveyVersionNew.Survey_Manager__c) )
                		{
                			surveyManagerActiveSurveyVersion.put( surveyVersionNew.Survey_Manager__c , new Survey_Version__c() );
                		}

                		surveyManagerActiveSurveyVersion.put( surveyVersionNew.Survey_Manager__c  ,surveyVersionNew);

                    }

            	}
            }

            // Always set Survey Version on survey manager to null before reassign new value
            if( surveyManagerSetSurveyVersionNull.size() > 0 )
            {           
                update surveyManagerSetSurveyVersionNull;
             }
 
            if( surveyManagerActiveSurveyVersion.size() > 0 )
            {
                setActiveSurveyVersion(surveyManagerActiveSurveyVersion);
            }
        }
     


    }

    protected override void afterInsert(MAP<id,sObject> newMap) 
    {
        MAP<Id,Survey_Version__c> surveyManagerActiveSurveyVersion = new MAP<Id,Survey_Version__c>();

    	for( Id surveyVerionId : newMap.keySet() )
        {
            
        	Survey_Version__c surveyVersionNew = (Survey_Version__c)newMap.get(surveyVerionId);

        	 if( surveyVersionNew.Active_Status__c == true )
        	 {
        		if( !surveyManagerActiveSurveyVersion.containsKey(surveyVersionNew.Survey_Manager__c) )
        		{
        			surveyManagerActiveSurveyVersion.put( surveyVersionNew.Survey_Manager__c , new Survey_Version__c() );
        		}

        		surveyManagerActiveSurveyVersion.put( surveyVersionNew.Survey_Manager__c  ,surveyVersionNew);
        	 }
        }


        setActiveSurveyVersion(surveyManagerActiveSurveyVersion);
     
    }

    public static void setActiveSurveyVersion( MAP<id,Survey_Version__c> surveyManagerActiveSurveyVersion )
    {
        List<Id> newActiveSurveyVersionId = new List<Id>();

        for( Survey_Version__c sv : surveyManagerActiveSurveyVersion.values() )
        {
            newActiveSurveyVersionId.add(sv.Id);
        }

        //ignore this update to execute trigger
        ignoreSurveyVersionTrigger = true;

        // get all other survey version on surveyManagerActiveSurveyVersion.keyset(); set to in active
        List<Survey_Version__c> setToInactive = [SELECT Id, Name, Active_Status__c, Survey_Manager__c, CS_Survey_Version_Key__c 
                FROM Survey_Version__c 
                WHERE Id not in: newActiveSurveyVersionId
                AND Survey_Manager__c in :  surveyManagerActiveSurveyVersion.keySet() 
            ];
        for( Survey_Version__c sv : setToInactive )
        {
            sv.Active_Status__c = false;
        }
        update setToInactive;

        //resume trigger
        ignoreSurveyVersionTrigger = false;


        List<Id> svIdListToSetActive = new List<Id>();
        List<Survey_Manager__c> smList = new List<Survey_Manager__c>();
        // 1. set survey Manger's survey question filed to value in surveyManagerActiveSurveyVersion
        for( Id surveyManagerId : surveyManagerActiveSurveyVersion.keySet() )
        {
            Survey_Version__c sv = (Survey_Version__c)surveyManagerActiveSurveyVersion.get(surveyManagerId);

            Survey_Manager__c sm = new Survey_Manager__c( Id = surveyManagerId );
            sm.Survey_Version__c = sv.Id;
        
            smList.add(sm) ;
        }
        update smList;
    }
    
}