public class RTL_CampaignCodeGenerator {
    public static String yearvalue {get;set;}
    public static String monthvalue {get;set;}
    public static String dayvalue {get;set;}
    public static string datevalue {get;set;}
    //test
    public static ID MasterLocalExclusiveCampaignrecordTypeID {get{
        if(MasterLocalExclusiveCampaignrecordTypeID == null){
            MasterLocalExclusiveCampaignrecordTypeID = [SELECT ID from RecordType 
                                          WHERE sObjectType = 'Campaign'
                                          AND DeveloperName = 'Master_Campaign' LIMIT 1].get(0).id;
        }
        return MasterLocalExclusiveCampaignrecordTypeID;
    }set;}
    
    // public static ID ChildLocalExclusiveCampaignRecordTypeID {get{
    //     if(ChildLocalExclusiveCampaignRecordTypeID == null){
    //         ChildLocalExclusiveCampaignRecordTypeID = [SELECT ID from RecordType 
    //                                       WHERE sObjectType = 'Campaign'
    //                                       AND DeveloperName = 'Local_Exclusive_Campaign' LIMIT 1].get(0).id;
    //     }
    //     return ChildLocalExclusiveCampaignRecordTypeID;
    // }set;}

    // public static ID ChildLocalExclusiveCampaignActiveRecordTypeID {get{
    //     if(ChildLocalExclusiveCampaignActiveRecordTypeID == null){
    //         ChildLocalExclusiveCampaignActiveRecordTypeID = [SELECT ID from RecordType 
    //                                       WHERE sObjectType = 'Campaign'
    //                                       AND DeveloperName = 'Local_Exclusive_Campaign_Active' LIMIT 1].get(0).id;
    //     }
    //     return ChildLocalExclusiveCampaignActiveRecordTypeID;
    // }set;}

    // public static ID ChildLocalExclusiveCampaignExpiredRecordTypeID {get{
    //     if(ChildLocalExclusiveCampaignExpiredRecordTypeID == null){
    //         ChildLocalExclusiveCampaignExpiredRecordTypeID = [SELECT ID from RecordType 
    //                                       WHERE sObjectType = 'Campaign'
    //                                       AND DeveloperName = 'Local_Exclusive_Campaign_Expired' LIMIT 1].get(0).id;
    //     }
    //     return ChildLocalExclusiveCampaignExpiredRecordTypeID;
    // }set;}

    public static List<ID> ChildLocalExclusiveCampaignRecordTypeIDList {get{
        if(ChildLocalExclusiveCampaignRecordTypeIDList == null){
            ChildLocalExclusiveCampaignRecordTypeIDList = new List<Id>();
            List<RecordType> rts = [SELECT ID from RecordType 
                                          WHERE sObjectType = 'Campaign'
                                          AND( DeveloperName = 'Local_Exclusive_Campaign'
                                                OR DeveloperName = 'Local_Exclusive_Campaign_Active'
                                                OR DeveloperName = 'Local_Exclusive_Campaign_Expired' )];
            for(RecordType rt : rts){
                System.debug('rt' + rt);
                ChildLocalExclusiveCampaignRecordTypeIDList.add(rt.Id);
                System.debug('RT: ' + ChildLocalExclusiveCampaignRecordTypeIDList);
            }
        }
        return ChildLocalExclusiveCampaignRecordTypeIDList;
    }set;}

    public static final string LOCALEXCLUESIVEPREFIX = 'L';
    public static final string ALPHABETS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    public static void GenerateCampaignCode(List<Campaign> triggerNewList){
        List <Campaign> localMasterCampaignList = new List<Campaign>();
        List <Campaign> localChildCampaignList = new List<Campaign>();
        
        for(Campaign campaignRecord : triggerNewList){
            System.debug(campaignRecord);
            System.debug('MasterLocalExclusiveCampaignrecordTypeID :' + MasterLocalExclusiveCampaignrecordTypeID);
            System.debug('ChildLocalExclusiveCampaignRecordTypeIDList :' + ChildLocalExclusiveCampaignRecordTypeIDList);
            if(campaignRecord.RecordTypeId == MasterLocalExclusiveCampaignrecordTypeID){
                if(campaignRecord.RTL_Campaign_Type__c =='Local Exclusive'){
                    localMasterCampaignList.add(campaignRecord);
                }   
            }
            
            // System.debug('ChildLocalExclusiveCampaignRecordTypeID :' + ChildLocalExclusiveCampaignRecordTypeID);
            // if(campaignRecord.RecordTypeId == ChildLocalExclusiveCampaignRecordTypeID && campaignRecord.ParentId !=null){
            //     localChildCampaignList.add(campaignRecord);
            // }

            if(ChildLocalExclusiveCampaignRecordTypeIDList.contains(campaignRecord.RecordTypeId) && campaignRecord.ParentId !=null){
                localChildCampaignList.add(campaignRecord);
            }
            
        }
        
        Date todaydate = System.today();
        String todayDatestr = DateTime.newInstance(todaydate.year(),todaydate.month(),todaydate.day()).format('dd-MM-YY');
        dayvalue = todaydatestr.split('-').get(0);
        monthvalue = todaydatestr.split('-').get(1);
        yearvalue = todaydatestr.split('-').get(2);
        datevalue = yearvalue+monthvalue+dayvalue;
        
        if(localMasterCampaignList.size()>0){
            generateCampaignCode9Digit(localMasterCampaignList);
        }
        
        if(localChildCampaignList.size()>0){
            generateCampaignCode10Digit(localChildCampaignList);
        }
        
    }
    
    
    public static void generateCampaignCode9Digit(List<Campaign> localMasterCampaignList){
        RTL_Campaign_Running_No__c runningNo = [SELECT Name,DateValue__c,Day__c,Month__c,Year__c,Running_No__c 
         from RTL_Campaign_Running_No__c 
         WHERE Name =:'Local Exclusive Campaign Running No.' LIMIT 1 FOR UPDATE ];
         
        String intervalStr = '01';
        if(runningNo.DateValue__c == datevalue){
            intervalStr = runningNo.Running_No__c;
        }
        
        integer intervalInt = Integer.valueOf(intervalStr);
        for(Campaign campaignRecord : localMasterCampaignList){
            String campaignCode = LOCALEXCLUESIVEPREFIX+yearvalue+monthvalue+dayvalue+intervalStr;
            System.debug(campaignCode);
            campaignRecord.RTL_Campaign_Code_9_digits__c = campaignCode;
            
            intervalInt++;
            
            if(intervalInt<10){
                intervalStr = String.valueof('0'+intervalInt);
            }else{
                intervalStr = String.valueof(intervalInt);
            }
            
             System.debug(campaignRecord.RTL_Campaign_Code_9_digits__c);
        }
        
       
        runningNo.DateValue__c = datevalue;
        runningNo.Day__c = dayvalue;
        runningNo.Month__c = monthvalue;
        runningNo.Year__c = yearvalue;
        runningNo.Running_No__c = intervalStr;
        
        update runningNo;
        
        
        
        
    }
    
    public static void generateCampaignCode10Digit(List<Campaign> localChildCampaignList){
        Set<ID> parentCampaignIDset = new Set<ID>();
        
        for(Campaign childCampaign : localChildCampaignList){
            parentCampaignIDset.add(childCampaign.parentID);
        }
        
        Map<ID,Campaign> parentCampaignMap = new Map<ID,Campaign>();
        
        for(Campaign parentcampaign : [SELECT ID,RTL_Campaign_Code_9_digits__c ,RTL_Child_Campaign_Index__c  from Campaign
                                      WHERE ID IN: parentCampaignIDset FOR UPDATE]){
            parentCampaignMap.put(parentcampaign.id,parentcampaign);
        }
        
        for(Campaign childCampaign : localChildCampaignList){
            Campaign parentcampaign = parentCampaignMap.get(childCampaign.ParentId);
            String indexFromParent = parentcampaign.RTL_Child_Campaign_Index__c;
            String nextIndex;
            System.debug(indexFromParent);
            if(indexFromParent!=null && indexFromParent !='' ){
                System.debug('getNext');
                nextIndex = getNextChar(indexFromParent);
                
            }else{
                System.debug('initiate');
                nextIndex = 'A';
            }
            System.debug(nextIndex);
            childCampaign.RTL_Campaign_Code_10_digits__c = parentcampaign.RTL_Campaign_Code_9_digits__c+nextIndex;
            parentcampaign.RTL_Child_Campaign_Index__c = nextIndex;
            parentCampaignMap.put(parentcampaign.id,parentcampaign);
        }
        
        update parentCampaignMap.values();
        
    }
    
    
    public static String getNextChar(String oldChar) {
        
        Integer index = ALPHABETS.indexOfChar(oldChar.charAt(0));
        return index == -1? null: ALPHABETS.substring(index+1, index+2);
    }
    
    
}