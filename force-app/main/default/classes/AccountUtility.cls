/*
 * Block comments with details of changes
 */
public class AccountUtility
{
    public AccountUtility()
    {
        
    }
    
    //public static String getCommercial_RM(String OwnerId){ 
    //    String result = '';
    //    String Commercial_RM_ID = '';
    //    try{
    //        if( OwnerId != null ){
    //          User tempUL = [SELECT Id,name,Employee_ID__c, isActive ,ProfileId FROM User WHERE Id =: OwnerId ];
    //Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id =: tempUL.ProfileId LIMIT 1];

    //            if(userProfile.name.contains('TMB') && !userProfile.name.contains('Retail')){
    //                result = tempUL.name;
    //                Commercial_RM_ID = tempUL.Id;
    //            }
    //        }
    //    }catch(Exception e){
    //        System.debug('getCommercial_RM error = ' + e.getMessage());
    //    }
    //    return Commercial_RM_ID;
    //}

    public static String getCommercial_RM(String OwnerId ){ 
        String commercialRmId = null;
        try{
            if( OwnerId != null ){
                // Fix Apex CPU time limit exceeded - By Tay, Max I&I
                User tempUL = userMap.get(OwnerId);
                String userProfileName = tempUL.Profile.Name;


                if(userProfileName.contains('TMB') && !userProfileName.contains('Retail')){
                    //result = tempUL.name;
                    commercialRmId = tempUL.Id;
                }
            }

        }catch(Exception e){
            System.debug('getCommercial_RM error = ' + e.getMessage());
        }

        return commercialRmId;
    }

    public class OSC07wraper
    {
        public CVSAnalyticsDataDTO responseData {get;set;}
        public Boolean isInitialised {get;set;}
    }

    public static OSC07wraper processOSC07Data( RTL_CvsAnalyticsDataService.CVSAnalyticsData soapCVSAnalyticsData ,
        String rmid , Id wealthRmId ,Id commercialRmId )
    {
        OSC07wraper result = new OSC07wraper();

        result.responseData = ((CVSAnalyticsDataDTO) TypeMapper.MappingSoapToDTO(soapCVSAnalyticsData,rmid));

        result.isInitialised = AccountUtility.updateAccount(result.responseData,rmid,wealthRmId,commercialRmId);

        return result;
    }

    public static Branch_and_Zone__c getBranch(String branchCode){

        Branch_and_Zone__c branch;
        try{
            branch = [Select Name, Branch_Name__c, RTL_Region_Code__c, RTL_Zone_Code__c from Branch_and_Zone__c WHERE Branch_Code__c =: branchCode LIMIT 1];
        }catch(exception e) {
            // No branch return;
        }

        return branch;
    }
    
    /* this is action method called by visualforce page action={!updateAccount} */
    public static boolean updateAccount(CVSAnalyticsDataDTO soapCVSAnalyticsData,
        String rmid,Id wealthRmId ,Id commercialRmId ) {

        //if (!initialised) {
		try {            
        	Account acc = [select id,TMB_Customer_ID_PE__c, RTL_OTC_ATM_ADM_IB_MIB__c, RTL_MIB_Status__c, RTL_Suitability__c, 
                           RTL_Wealth_RM__c, RTL_Commercial_RM__c, Sub_segment__c, RTL_Privilege1_Expired_Date__c, RTL_Average_AUM__c 
                           From Account Where TMB_Customer_ID_PE__c = :rmid Limit 1];

                acc.RTL_OTC_ATM_ADM_IB_MIB__c = soapCVSAnalyticsData.UsagePercentage;
                acc.RTL_MIB_Status__c = soapCVSAnalyticsData.MIBStatus;
                acc.RTL_Suitability__c = soapCVSAnalyticsData.Suitability;
                acc.RTL_Wealth_RM__c = wealthRmId;
                acc.RTL_Commercial_RM__c = commercialRmId;
                acc.Sub_segment__c = soapCVSAnalyticsData.csProfSubsegment;
                acc.RTL_Privilege1_Expired_Date__c = date.parse(soapCVSAnalyticsData.csProfWealthExpDt); //String to Date by TK
                acc.RTL_Average_AUM__c = soapCVSAnalyticsData.csProfAvgaum12m;
                acc.RTL_Most_Visited_Branch__c =  ( getBranch(soapCVSAnalyticsData.csProfFreqBr) !=null ? getBranch(soapCVSAnalyticsData.csProfFreqBr).id : null );
                

                //system.debug('updateAccount  '+acc);
                update acc;
                //system.debug('End updateAccount');
                return true;
            }
            catch (Exception e) {
                System.debug('Update account OSC07 error: ' + e.getMessage() + e.getLineNumber() );
                 return false;
            }
            
        //}
        
    }

    private static List<User> activeuser {
        get
        {
            if(activeuser == null){ 

                    activeuser = [select Id,name,Employee_ID__c, RTL_Branch_Code__c ,isActive,Profile.Name,title,
                                      ManagerId, Manager.isActive, Manager.name, Zone_Code__c   
                             from user where IsActive = true OR (IsActive = false AND LastLoginDate = LAST_N_DAYS:120)];

            }
            return activeuser;

            
            
        }set;
    }

    private static String branchManagerTitle{
        get{
            if(branchManagerTitle == null){ 
                branchManagerTitle  = RTL_Branch_Manager_Title__c.getValues('Branch Manager').RTL_Value__c;
            }
            return branchManagerTitle;
        }
        set;
    }   

    public static Map< String, List<User> > branchCodeUserMap
    {
        //************************************************************************
        //Issue: Fix the Wealth RM logic when Branch Manager is inactive, 
        //       and the Branch Code has more than one Branch Manager
        //Edited by: Siwapongsakorn Dechapisood
        //Edited Date: 14-Nov-2018
        //************************************************************************
        get{
            if( branchCodeUserMap == null )
            {
                branchCodeUserMap = new Map<String, List<User>>();
                for (User u : activeuser) 
                {
                    List<User> mBranchManagerList = branchCodeUserMap.get(u.RTL_Branch_Code__c);
                	//if Branch Code is not null and is branch manager
                    if(u.RTL_Branch_Code__c != null && u.title == branchManagerTitle)
                    {
                        if(mBranchManagerList == NULL)
                        {
                            branchCodeUserMap.put(u.RTL_Branch_Code__c, new List<User>{u});
                        }
                        else
                        {
                            mBranchManagerList.add(u);
                        }
                    }
                }
            }
            return branchCodeUserMap;
        }
        set;
    }

    public static  Map<String,User> empCodeUserMap{
        get{
            if( empCodeUserMap == null )
            {
                 empCodeUserMap = new Map<String,User>();
  
                for (User u : activeuser) {

                    //if Employee Id is not null
                    if(u.Employee_ID__c != null){
                        empCodeUserMap.put(u.Employee_ID__c,u);
                    }
                }
            }
            return empCodeUserMap;
        }
        set;
    }
    
     // CR-Wealth RM Additional - Customer Metadata to keep subsegment mapping
    public static Map<String,Sub_Segment_Code_Mapping__mdt> subSegmentMap {
    get{
        Map<String,Sub_Segment_Code_Mapping__mdt> subSegmentMap = new Map<String,Sub_Segment_Code_Mapping__mdt>();        
        	for(Sub_Segment_Code_Mapping__mdt subSegment : [select id,DeveloperName,Sub_Segment_Code__c,Segment_Code__c,Description__c from Sub_Segment_Code_Mapping__mdt ] ){
            	subSegmentMap.put(subSegment.Sub_Segment_Code__c,subSegment);
        	}        
        return new Map<String,Sub_Segment_Code_Mapping__mdt>(subSegmentMap);
    }set;}

    //Change Reture type from Map<String, User> to Map<String, List<User>>
    //Edited by: Siwapongsakorn Dechapisood
    //Edited Date: 14-Nov-2018
    public static Map<String, List<User>> getBranchCodeUserMap()
    {
        return branchCodeUserMap;

    }

    public static Map<String,User> getEmpCodeUserMap()
    {
        return empCodeUserMap;

    }


    public static Map<Id, User> userMap {
        get
        {
            if(userMap == null){
                userMap = new Map<Id, User>(activeuser);
            }
            return userMap;
        }
        set;
    }

    // public static Map<Id,User> getOwnerUserMap(Id OwnerId)
    // {
    //     Map<Id,User> ownerUserMap = new Map<Id,User>();
    //     for (User u : activeuser) {
    //         //get account owner user
    //         if(OwnerId == u.id){
    //             ownerUserMap.put(u.id,u);
    //         }
    //     }
    //     return ownerUserMap;
    // }

    // CR-Wealth RM Additional - Customer Metadata to keep subsegment mapping
    public static String getSubSegment(String subSegmentCode){
    	if(subSegmentMap.containsKey(subSegmentCode)){
        	return subSegmentMap.get(subSegmentCode).Description__c;
        }
        return subSegmentCode;
    }

    // CR Smart BDM Phase II
    public static List<Smart_BDM_Action__mdt> RecommandActionLst {
		get {
			if(RecommandActionLst == null){
				RecommandActionLst = [SELECT Id, Deposit_Account__c, S1B__c, BIZ_Touch__c, Six_Months_Avg__c, Action__c FROM Smart_BDM_Action__mdt];
			}
			return RecommandActionLst;
		}
		set;
	}
    public static String CalculateRecommendedAction(Boolean HasDepositAcct, Boolean HasS1B, Boolean HasBIZTouch, String SixMTHTXN)
	{
		for(Smart_BDM_Action__mdt ra : RecommandActionLst){
			if(ra.Deposit_Account__c == HasDepositAcct && ra.S1B__c == HasS1B && ra.BIZ_Touch__c == HasBIZTouch && ra.Six_Months_Avg__c == SixMTHTXN){
				return ra.Action__c;
			}
		}
		return '';
	}
}