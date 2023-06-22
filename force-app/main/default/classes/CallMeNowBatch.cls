global class CallMeNowBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
	
	String query;
	List<Id> referralIdList;
	List<RTL_Online_Service_Log__c> logList;
	private Map<String, OnlineServiceLog> mapWebUnioslogDetail;
	private Map<String, RTL_Online_Service_Log__c> mapWebUnioslog;
	List<RTL_Referral__c> referralList;
	
	private String name;
	private String referralId;
	private String firstName;
	private String lastName;
	private String interestedProduct;
	private String mobile;
	private String campaign;
	private String subProduct;
	private String channel;
	Boolean isSuccess = false;
	private BusinessHours bh;
	
	//CR Refer from branch to any channel
	private String referralRecordtypeName;
	
	private static User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, Employee_ID__c FROM User WHERE Id = :System.UserInfo.getUserId()];
            }
            return currentUser;
        }
        set;
    }

	global CallMeNowBatch(List<Id> referralIdList) {
		mapWebUnioslog = new Map<String, RTL_Online_Service_Log__c>();
        mapWebUnioslogDetail = new Map<String, OnlineServiceLog>();
		logList = new List<RTL_Online_Service_Log__c>();
		referralList = new List<RTL_Referral__c>();

		bh = [SELECT Id FROM BusinessHours WHERE Name = 'Call Me Now'];
		
		this.referralIdList = referralIdList;
		query = 'SELECT Id,Name,RTL_FirstName__c, Assigned_Pool__c, RTL_LastName__c,RTL_RecordType_Name__c,RTL_Product_Name_Str__c, FNA_Product_Name__c,RTL_Interested_Product__c,RTL_Sub_Product__c,RTL_Mobile1__c,RTL_Channel_Segment__c,RTL_Campaign__c,RTL_Call_Me_Now_Request_Count__c FROM RTL_Referral__c WHERE ID IN : referralIdList';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<CallMeNowDTO> callMeNowList = new List<CallMeNowDTO>();
		Datetime dateTimeNow = Datetime.now();
		
		for(sObject obj : scope){
			RTL_Referral__c referral = (RTL_Referral__c)obj;
			
			if(!BusinessHours.isWithin(bh.Id, dateTimeNow) && referral.RTL_RecordType_Name__c != 'Refer from Digital Channel'){
				referral.RTL_Call_Me_Now_Status__c = 'fail';
				referral.RTL_From_Call_Me_Now__c = true;
			}else{
				CallMeNowDTO callMeNowObj;

				name = referral.Name;
				referralId = referral.Id;
				system.debug('RTL_FirstName__c : ' + referral.RTL_FirstName__c);
				firstName = referral.RTL_FirstName__c == null || referral.RTL_FirstName__c == ''? '-' : referral.RTL_FirstName__c;
				lastName = referral.RTL_LastName__c;
				referralRecordtypeName = referral.RTL_RecordType_Name__c;

				//CR Refer from branch to any channel
				String rtlDateTime = '';
				if (referralRecordtypeName == 'Retail Cross Channel Referral') {
					interestedProduct = referral.RTL_Product_Name_Str__c;
				}else if(referralRecordtypeName == 'Refer from Digital Channel'){
					interestedProduct = referral.FNA_Product_Name__c;
					if(referral.Assigned_Pool__c == 'OUTBOUND'){
						rtlDateTime = fnaUtility.checkBusinessHour('Retail Outbound', Datetime.now());
					}else{
						rtlDateTime = fnaUtility.checkBusinessHour('Call Me Now', Datetime.now());
					}
					
				}else{
					interestedProduct = referral.RTL_Interested_Product__c;
				}

				mobile = referral.RTL_Mobile1__c;
				system.debug('RTL_Campaign__c : ' + referral.RTL_Campaign__c);
				campaign = referral.RTL_Campaign__c;
				subProduct = referral.RTL_Sub_Product__c;
				channel = referral.RTL_Channel_Segment__c;
				
				////// Set default Variable
				Map<String, String> variable = new Map<String, String>();
				variable.put('3','');
				variable.put('4','');
				variable.put('5','');
				variable.put('6','');


				callMeNowObj = RTL_ReferralAssignUtility.doCallService(referralId, name, firstName, lastName, interestedProduct,
																			mobile ,campaign, subProduct, channel, 'true', 
																			referralRecordtypeName, rtlDateTime, variable);
				referral.RTL_Call_Me_Now_Request__c = callMeNowObj.generateJSONContent();
				referral.RTL_Call_Me_Now_Response__c = callMeNowObj.response.rawResponse;
				referral.RTL_Call_Me_Now_Status__c = 'success';
				referral.RTL_From_Call_Me_Now__c = true;
				
				if(callMeNowObj.response.message != 'success'){
					referral.RTL_Call_Me_Now_Status__c = 'fail';
					referral.RTL_Call_Me_Now_Request_Count__c += 1;
					// logList.add(RTL_Utility.InsertErrorTransactionWithServiceName(name,'',UserInfo.getName(),null,callmenowObj.response.message,'','CallMeNow-Lead',false));
				}
				else if(callMeNowObj.response.message == 'success'){
					isSuccess = true;
				}
				OnlineServiceLog oslogDetail = new OnlineServiceLog(isSuccess, callMeNowObj.response.message, callMeNowObj.generateJSONContent(), callMeNowObj.response.rawResponse);
				RTL_Online_Service_Log__c oslog = new RTL_Online_Service_Log__c();
                oslog.RTL_Customer_Name__c = referral.Id;
                oslog.RTL_Name_of_User__c = currentUser.Name;
                oslog.RTL_RM_ID__c = currentUser.Employee_ID__c;
                oslog.RTL_Service_Name__c = 'CallMeNow-Lead';
                oslog.RTL_Is_Success__c = oslogDetail.isSuccess;
				// oslog.RTL_Error_Message__c = oslogDetail.errorMesssage;
                // oslog.RTL_Start_DateTime__c = oslogDetail.startTime;
                // oslog.RTL_End_DateTime__c = oslogDetail.endTime;
                
                if(oslogDetail.isSuccess){
                    osLog.Remark__c = oslogDetail.errorMesssage;
                }else{
                    oslog.RTL_Error_Message__c = oslogDetail.errorMesssage;
                }

                String key = referral.Id + '_' + referral.RTL_Call_Me_Now_Request_Count__c;
				System.debug('key log:'+key);
				System.debug('oslogDetail log:'+oslogDetail);
                mapWebUnioslog.put(key, oslog);
                mapWebUnioslogDetail.put(key, oslogDetail);

			}
			referralList.add(referral);

			System.debug('obj log:'+obj);
           

		}
		System.debug('mapWebUnioslog log:'+mapWebUnioslog.size());
		System.debug('mapWebUnioslogDetail log:'+mapWebUnioslogDetail.size());
		
	}
	
	global void finish(Database.BatchableContext BC) {

		// if(logList.size() > 0){
		// 	insert logList;
		// }
		System.debug('mapWebUnioslog log:'+mapWebUnioslog.size());
		if(mapWebUnioslog.size() > 0){
            RTL_CampaignUtil.insertOnlineServiceLogMultiWithAttach(mapWebUnioslog, mapWebUnioslogDetail);
        }
		if(referralList.size() > 0){
			update referralList;
		}
		
	}
	
}