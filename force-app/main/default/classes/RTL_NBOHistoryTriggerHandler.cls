public with sharing class RTL_NBOHistoryTriggerHandler extends TriggerHandler {
      public RTL_NBOHistoryTriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(100);
        }
        else{
            this.setMaxLoopCount(1000);
        }
     
        System.Debug( 'TMB: -> RTL_NBOHistoryTriggerHandler Invoked' );
    }
    
    protected override void beforeInsert(List<SObject> nboHistoryList) {   
    	System.Debug('TMB: -> RTL_NBOHistoryTriggerHandler start of beforeInsert');
    	 
		preprocessNBO(nboHistoryList);
        findCampaignToNBO(nboHistoryList);
		
		System.Debug('TMB: -> RTL_NBOHistoryTriggerHandler end of beforeInsert');
    }  
    
    protected override void beforeUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {
        System.Debug('TMB: -> LeadTriggerHaRTL_NBOHistoryTriggerHandlerndler start of beforeUpdate');    
        
        List<RTL_NBO_History__c> nboHistoryList = new List<RTL_NBO_History__c>();
        for (Id lId:newMap.keySet()){
        	nboHistoryList.add(((RTL_NBO_History__c)newMap.get(lId)));
        }
        preprocessNBO(nboHistoryList);
        //findCampaignToNBO(nboHistoryList);
        
        
        System.Debug('TMB: -> LeadTriggerHaRTL_NBOHistoryTriggerHandlerndler end of beforeInsert');
    }                
      
	private static void preprocessNBO(List<RTL_NBO_History__c> nboHistoryList) {
		String campaignName = null;
        for (RTL_NBO_History__c nbo: nboHistoryList) {
        	campaignName = nbo.RTL_Campaign_Name__c;
        	if (campaignName != null) {
        		nbo.Name = campaignName;
        		if (campaignName.length() > 80)
					nbo.Name = campaignName.substring(0, 80);//standard Name is Text(80)
        	}
        }
	}

    private static void findCampaignToNBO(List<RTL_NBO_History__c> nboHistoryList){

        String campaigncode = null;
        Id campaignid = null;

        Map<string,Campaign> campaignMap = new Map<string,Campaign>();

        for (Campaign c:[Select Id, RTL_Campaign_Code_10_digits__c from Campaign where RTL_Campaign_Code_10_digits__c != null]){//IsActive = true and
            campaignMap.put(c.RTL_Campaign_Code_10_digits__c,c);
        }

        system.debug('All active campaign : '+campaignMap);

        for (RTL_NBO_History__c nbo: nboHistoryList) {
            campaigncode = nbo.RTL_Campaign_Code__c;

            if(campaignMap.get(campaignCode) !=null){

                campaigncode = campaignMap.get(campaignCode).RTL_Campaign_Code_10_digits__c;
                if(campaigncode != null && campaigncode.equalsIgnoreCase(campaigncode)){
                    nbo.RTL_Campaign__c = campaignMap.get(campaignCode).id; 
                    system.debug('NBO History : campaign match nbo - '+nbo.RTL_Campaign_Code__c);
                }

            }else{
                system.debug('NBO History : Can\'t found campaign match nbo.');
            }
        }


    }
}