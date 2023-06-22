global class GoogleExternalAPI implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
	global final String query;
    global Integer recordsSuccessful = 0;
    global Integer recordsFailed = 0;
    global Datetime batchDate = datetime.now();
    global Datetime batchStartTime = datetime.now();
    global Datetime batchEndTime = null;

    private String sobjectName;
    private String jobDailyName;
    private String CSV_BODY = '';
	private String EMAIL_TO  = 'CRM Admin 2';

    private Integer indexAPIKey = 0;

    global GoogleExternalAPI(){}

	global GoogleExternalAPI(String q){
        query = q;
        this.sobjectName = 'Call_Report__c';
        this.jobDailyName = 'Update_Geolocation_Google_Map_SalesVisitReport';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Call_Report__c> scope){
    	System.Debug('TMB: -> GoogleExternalAPI start of execute');
		if (scope.size() > 0) {
			updateLocationForCallReport(scope,0);
		}
        System.Debug('TMB: -> GoogleExternalAPI end of execute');
    }    

    global void finish(Database.BatchableContext bc){  	
    	batchEndTime = datetime.now();
    	List<String> emailOpsList = new List<String>();
        emailOpsList.add(this.EMAIL_TO);
        RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , batchEndTime
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        , jobDailyName
                                                        , sobjectName
                                                        , emailOpsList
                                                        , this.CSV_BODY);
    }

	private static List<API_Credential__mdt> cridentialList;
	static {
        try{
            cridentialList = [SELECT Credential__c 
            			FROM API_Credential__mdt 
            			WHERE MasterLabel LIKE 'GoogleMapSFKey%' Order by Id ASC];
          }catch( Exception e ){
          	System.debug(e.getMessage());
          	cridentialList = new List<API_Credential__mdt>();
        }
	}

	public void updateLocationForCallReport(List<Call_Report__c> callReportList) {
		updateLocationForCallReport(callReportList,0);
	}

	private void updateLocationForCallReport(List<Call_Report__c> callReportList,Integer indexAPI) {
		if (cridentialList == null || cridentialList.size() == 0) return;

		this.indexAPIKey = indexAPI;

		for (Call_Report__c callreport : callReportList) {
			try {
				GoogleMapJSONUtil.GoogleMapJSON gjson = retrieveAPI(callreport.Check_in_Location__c);
				if (gjson != null) {
						List<GoogleMapJSONUtil.Results> results = gjson.results;
						String status         = gjson.status;
						String error_message  = gjson.error_message;

						if (status == 'OK') {
							GoogleMapJSONUtil.Results result = results[0];
							callreport.Formatted_Address__c = result.formatted_address;
							Map<String,String> infoMap = new Map<String,String>();
							for (GoogleMapJSONUtil.Address_components addr_comp : result.address_components) {
								Integer index_key = 0;

								while (addr_comp.types.size() > index_key) {
								   	if (!infoMap.containsKey(addr_comp.types[index_key])) {
								   		infoMap.put(addr_comp.types[index_key],addr_comp.long_name);
								   		break;
								   	}
								   	index_key++;
								}
							}

							if (infoMap.containsKey('street_number')) {
								callreport.Address_No__c = infoMap.get('street_number');
							}else {
								callreport.Address_No__c = '';
							}

							if (infoMap.containsKey('premise')) {
								callreport.Address_No__c = callreport.Address_No__c + infoMap.get('premise');
							}

							if (infoMap.containsKey('route')) {
								callreport.Road__c = infoMap.get('route');
							}else {
								callreport.Road__c = '';
							}

							if (infoMap.containsKey('political')) {
								callreport.Sub_District__c = infoMap.get('political');
							}else if (infoMap.containsKey('locality')) {
								callreport.Sub_District__c = infoMap.get('locality');
							}else{
								callreport.Sub_District__c = '';
							}
							
							if (infoMap.containsKey('sublocality')) {
								callreport.District__c = infoMap.get('sublocality');
							}else if (infoMap.containsKey('administrative_area_level_2')) {
								callreport.District__c = infoMap.get('administrative_area_level_2');
							}else {
								callreport.District__c = '';
							}
 							
							if (infoMap.containsKey('administrative_area_level_1')) {
								callreport.Province__c = infoMap.get('administrative_area_level_1');
							}else {
								callreport.Province__c = '';
							}


							if (infoMap.containsKey('postal_code')) {
								callreport.Zip_Code__c = infoMap.get('postal_code');
							}else {
								callreport.Zip_Code__c = '';
							}


							if (infoMap.containsKey('country')) {
								callreport.Country__c = infoMap.get('country');
							}else {
								callreport.Country__c = '';
							}

							callreport.Is_Last_Checkin_Location__c  = true;
							callreport.Google_API_Error__c     = '';
						}else if (status == 'ZERO_RESULTS') {
							callreport.Address_No__c = '';
							callreport.Road__c = '';
							callreport.Sub_District__c = '';
							callreport.Zip_Code__c = '';
							callreport.District__c = '';
							callreport.Province__c = '';
							callreport.Country__c = '';
							callreport.Formatted_Address__c = '';
							callreport.Is_Last_Checkin_Location__c  = true;
							callreport.Google_API_Error__c     = status + ' '+error_message;
						}else {
							callreport.Google_API_Error__c = status + ' '+error_message;
							if (callreport.Retry_Google_Map__c != null && callreport.Retry_Google_Map__c > 0)
								callreport.Retry_Google_Map__c = callreport.Retry_Google_Map__c+1;
							else 
								callreport.Retry_Google_Map__c = 1;
						}

						callreport.Last_Update_Location__c     = Datetime.now();
				}else {
					callreport.Google_API_Error__c = 'No Location Checkin';
					if (callreport.Retry_Google_Map__c != null && callreport.Retry_Google_Map__c > 0)
						callreport.Retry_Google_Map__c = callreport.Retry_Google_Map__c+1;
					else 
						callreport.Retry_Google_Map__c = 1;
				}
			}catch (Exception e) {
				if (callreport.Retry_Google_Map__c != null && callreport.Retry_Google_Map__c > 0)
					callreport.Retry_Google_Map__c = callreport.Retry_Google_Map__c+1;
				else 
					callreport.Retry_Google_Map__c = 1;

				callreport.Google_API_Error__c = e.getMessage();
			}
		}

		if (callReportList != null && callReportList.size() > 0) {
			Database.SaveResult[]  lsr = Database.update(callReportList, false);
			Integer runningIndex = 0;
	        // Iterate through each returned result
	        for (Database.SaveResult sr : lsr) {
	                if (sr.isSuccess()) {
	                    // Operation was successful, so get the ID of the record that was processed
	                    System.debug('Successfully Update '+this.jobDailyName+' with ID: ' + sr.getId());
	                    recordsSuccessful++;
	                }
	                else {
	                    // Operation failed, so get all errors    
	                    Id recordId = callReportList[runningIndex].Id;
	                    for(Database.Error err : sr.getErrors()) {
	                    	this.CSV_BODY = this.CSV_BODY +recordId + ','
	                    					    +err.getMessage() + ','
	                    					    +String.join(err.getFields(),',') + ','
	                    					    +err.getStatusCode()+'\n';

	                        System.debug(logginglevel.ERROR, 'There is error on'+this.jobDailyName
	                        				+'. Error Message is: ' + err.getMessage());
	                    }
	                    recordsFailed++;
	                }
	            runningIndex++;
	        } 
		}
	}

	private GoogleMapJSONUtil.GoogleMapJSON retrieveAPI(Location checkinLoc) {

		if (checkinLoc != null && cridentialList.size() > this.indexAPIKey) {
			HttpRequest req = new HttpRequest();
			Http http = new Http();
				
			String lat = String.valueOf(checkinLoc.latitude);
			String lon = String.valueOf(checkinLoc.longitude);
			req.setMethod('GET');
			String apiToken = cridentialList.get(this.indexAPIKey).Credential__c;
			
			String url = 'https://maps.googleapis.com/maps/api/geocode/json'
							+'?latlng='+lat+','+lon+'&key='+apiToken
							+'&language=th&region=TH';
			
			req.setEndPoint(url);
			HTTPResponse resp = http.send(req);
			String jsonResults = resp.getBody().replace('\n', '');

			GoogleMapJSONUtil.GoogleMapJSON gjson = GoogleMapJSONUtil.parse(jsonResults);
			
			if (gjson != null && gjson.status != null 
					&& (cridentialList.size() - 1)  != this.indexAPIKey //if the key is last then return the lastest resut
					&& (gjson.status == 'REQUEST_DENIED' || gjson.status == 'OVER_QUERY_LIMIT')) {
				this.indexAPIKey = this.indexAPIKey + 1;
				return retrieveAPI(checkinLoc);
			}
			

			return gjson;
		}
		return null;
	}
}