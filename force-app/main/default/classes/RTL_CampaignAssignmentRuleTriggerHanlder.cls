public with sharing class RTL_CampaignAssignmentRuleTriggerHanlder {
	public RTL_CampaignAssignmentRuleTriggerHanlder() {
		
	}

	public static void afterInsert(List<RTL_Campaign_Assignment_Rule__c> newList, Map<Id, RTL_Campaign_Assignment_Rule__c> oldMap){
		system.debug('RTL_CampaignAssignmentRuleTriggerHanlder - Start After Insert ');
		assignCampaignMemberToCampaign(newList,oldMap);
		system.debug('RTL_CampaignAssignmentRuleTriggerHanlder - End After Insert ');
	}

	public static void afterUpdate(List<RTL_Campaign_Assignment_Rule__c> newList, Map<Id, RTL_Campaign_Assignment_Rule__c> oldMap){
		system.debug('RTL_CampaignAssignmentRuleTriggerHanlder - Start After Update ');
		assignCampaignMemberToCampaign(newList,oldMap);
		system.debug('RTL_CampaignAssignmentRuleTriggerHanlder - End After Update ');
	}

	public static void assignCampaignMemberToCampaign (List<RTL_Campaign_Assignment_Rule__c> newList, Map<Id, RTL_Campaign_Assignment_Rule__c> oldMap){

		List<RTL_Campaign_Assignment_Rule__c> campaignassignList = new List<RTL_Campaign_Assignment_Rule__c>();
		List<CampaignMember> dummyCampaignMemberList = new List<CampaignMember>();
		List<Campaignmember> tempCMList = new List<CampaignMember>();
		List<Campaignmember> newCMList = new List<CampaignMember>();
		List<Campaignmember> delCMList = new List<CampaignMember>();
		List<String> camId = new List<String>();
		Set<String> sourceSet = new Set<String>();
		Set<Date> startdateSet = new Set<Date>();
		Set<Date> enddateSet = new Set<Date>();
		Map<id,id> memberMapCampaignId = new Map<id,id> ();


		for(RTL_Campaign_Assignment_Rule__c car : newList){
			if(car.RTL_Campaign_Lead_Source__c != null 
				&& car.RTL_Start_Date__c != null 
				&& car.RTL_End_Date__c != null
				&& car.RTL_Active__c == true){
				campaignassignList.add(car);
				sourceSet.add(car.RTL_Campaign_Lead_Source__c);
				startdateSet.add(car.RTL_Start_Date__c);
				enddateSet.add(car.RTL_End_Date__c);
			}
		}
		if(campaignassignList.size() > 0 ){

			Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;

			dummyCampaignMemberList = [Select id,Name,CampaignId,CreatedDate,RTL_TMB_Campaign_Source__c from Campaignmember 
					WHERE CreatedDate >: startdateSet and CreatedDate <: enddateSet
					AND RTL_TMB_Campaign_Source__c in: sourceSet
					AND Campaign.Recordtypeid =: recordTypeId];

			if(dummyCampaignMemberList.size() > 0){
				
				for(Campaignmember cm : dummyCampaignMemberList){
					for(RTL_Campaign_Assignment_Rule__c cmpAssign : campaignassignList){
						if(cm.CampaignId != cmpAssign.RTL_Campaign__c){
							if(cm.RTL_TMB_Campaign_Source__c == cmpAssign.RTL_Campaign_Lead_Source__c &&
								(cm.CreatedDate >= cmpAssign.RTL_Start_Date__c && cm.CreatedDate <= cmpAssign.RTL_End_Date__c)){
									memberMapCampaignId.put(cm.Id,cmpAssign.RTL_Campaign__c);
							}
						}else{
							//campaign of campaign member is same campaign dummy.
						}
					}
				}

				//Add Campaign member to temp list
				if(memberMapCampaignId.size() > 0){
					for(Id cid : memberMapCampaignId.keySet()){
						camId.add('\''+String.valueOf(cid)+'\'');
					}

					DescribeSObjectResult describeResult = Campaignmember.getSObjectType().getDescribe();		
					List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );	

					//Get unused field campaign member before insert campaign member
					List<RTL_Web_Drop_Lead_Unused_Field__mdt> listUnusedField = [SELECT RTL_API_Name__c FROM RTL_Web_Drop_Lead_Unused_Field__mdt];

					for(integer i=0;i<fieldNames.size();i++){
						for(RTL_Web_Drop_Lead_Unused_Field__mdt f : listUnusedField){
							if(fieldNames.get(i) == f.RTL_API_Name__c){
								fieldNames.remove(i);
							}
						}
					}

					//String query =	' SELECT ' + String.join( fieldNames, ',' ) +' FROM ' +	describeResult.getName() + ' Where id in ' + camId;		
					String query =	' SELECT ' + String.join( fieldNames, ',' ) +' FROM ' +	describeResult.getName() + ' Where id in (' +  String.join( camId, ',' )+')';
					system.debug(query);
					tempCMList = Database.query( query );	

					system.debug('tempCMList'+tempCMList);

					if(tempCMList.size() >0){
						for(CampaignMember m : tempCMList){
				            CampaignMember campMemb = m.clone(false, true);
				            campMemb.Campaignid = memberMapCampaignId.get(m.id);
				            newCMList.add(campMemb);
			        	}
					}

				}

				//insert campaign member to campaign assignmemt rule
				try{
					system.debug('CAR Trigger : Campaign member dummy - '+dummyCampaignMemberList);
					system.debug('CAR Trigger : Campaign member insert to new campaign - '+newCMList);
					
					List<Id> idList = new List<Id>();

					if(newCMList.size() >0){
						Database.SaveResult[] lsr = Database.insert(newCMList, false);
			            // Iterate through each returned result
			            for (Database.SaveResult sr : lsr) {
			                if (sr.isSuccess()) {
			                    // Operation was successful, so get the ID of the record that was processed
			                    idList.add(sr.getId());
			                    System.debug('Successfully move dummy campaign member.');
			                    
			                }
			                else {
			                    // Operation failed, so get all errors               
			                    for(Database.Error err : sr.getErrors()) {
			                        System.debug(logginglevel.ERROR, 'There is error move dummy campaign member. Error Message is: ' + err.getMessage());
			                    }

			                }
			            } 
					}


					if(idList.size() > 0){
						system.debug('Success record : ' + idList);
						List<Id> contactidList = new List<Id>();
						List<Id> leadidList = new List<Id>();

						List<Campaignmember> succeesList = [Select leadid,contactid from Campaignmember where Id = :idList];
						if(succeesList.size() > 0){
							for(Campaignmember c : succeesList){
								if(c.leadid != null){
									leadidList.add(c.leadid);
								}else if(c.contactid != null){
									contactidList.add(c.contactid);
								}else{
									system.debug('Campaign member not found.');
								}

							}

						}

						//delete campaign member 
						delCMList = [ select Id ,Name from Campaignmember 
										where (leadid in:leadidList or contactid in:contactidList) 
										AND Campaign.Recordtypeid =: recordTypeId ];
						system.debug('CAR Trigger : Delete Campaign member dummy - '+delCMList);

						try{
							delete delCMList;
						}catch(Exception e){
			             	system.debug(e);
			            }
					}

				}catch(Exception e){
	             	system.debug(e);
	            }


			}

		}

		/*if(campaignassignList.size() > 0 ){
			source = campaignassignList.get(0).RTL_Campaign_Lead_Source__c;
			startdate = campaignassignList.get(0).RTL_Start_Date__c;
			enddate = campaignassignList.get(0).RTL_End_Date__c;

			RTL_Campaign_Assignment_Rule__c newCar = campaignassignList.get(0);

			Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and Name=: 'Dummy Campaign' and IsActive=true ].Id;

			dummyCMList = [Select id,Name,CampaignId,CreatedDate from Campaignmember 
					WHERE CreatedDate >: startdate and CreatedDate <: enddate
					AND RTL_TMB_Campaign_Source__c =: source
					AND Campaign.Recordtypeid =: recordTypeId];

			
			if(dummyCMList.size() > 0){
				for(Campaignmember c : dummyCMList){
					if(c.CampaignId != newCar.RTL_Campaign__c){
						camId.add('\''+String.valueOf(c.id)+'\'');
					}	
				}
			}

			if(camId.size() > 0){
				DescribeSObjectResult describeResult = Campaignmember.getSObjectType().getDescribe();		
				List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );	

				//Get unused field campaign member before insert campaign member
				List<RTL_Web_Drop_Lead_Unused_Field__mdt> listUnusedField = [SELECT RTL_API_Name__c FROM RTL_Web_Drop_Lead_Unused_Field__mdt];

				for(integer i=0;i<fieldNames.size();i++){
					for(RTL_Web_Drop_Lead_Unused_Field__mdt f : listUnusedField){
						if(fieldNames.get(i) == f.RTL_API_Name__c){
							fieldNames.remove(i);
						}
					}
				}

				String query =	' SELECT ' + String.join( fieldNames, ',' ) +' FROM ' +	describeResult.getName() + ' Where id in ' + camId;		
				system.debug(query);
				tempCMList = Database.query( query );		
			}

			if(tempCMList.size() >0){
				for(CampaignMember m : tempCMList){
		            CampaignMember campMemb = m.clone(false, true);
		            campMemb.Campaignid = newCar.RTL_Campaign__c;
		            newCMList.add(campMemb);
	        	}
			}

			try{
				system.debug('CAR Trigger : Campaign member dummy - '+dummyCMList);
				system.debug('CAR Trigger : Campaign member insert to new campaign - '+newCMList);
				
				List<Id> idList = new List<Id>();

				if(newCMList.size() >0){
					Database.SaveResult[] lsr = Database.insert(newCMList, false);
		            // Iterate through each returned result
		            for (Database.SaveResult sr : lsr) {
		                if (sr.isSuccess()) {
		                    // Operation was successful, so get the ID of the record that was processed
		                    idList.add(sr.getId());
		                    System.debug('Successfully move dummy campaign member.');
		                    
		                }
		                else {
		                    // Operation failed, so get all errors               
		                    for(Database.Error err : sr.getErrors()) {
		                        System.debug(logginglevel.ERROR, 'There is error move dummy campaign member. Error Message is: ' + err.getMessage());
		                    }

		                }
		            } 
				}

				if(idList.size() > 0){
					system.debug('Success record : ' + idList);
					List<Id> contactidList = new List<Id>();
					List<Id> leadidList = new List<Id>();

					List<Campaignmember> succeesList = [Select leadid,contactid from Campaignmember where Id = :idList];
					if(succeesList.size() > 0){
						for(Campaignmember c : succeesList){
							if(c.leadid != null){
								leadidList.add(c.leadid);
							}else if(c.contactid != null){
								contactidList.add(c.contactid);
							}else{
								system.debug('Campaign member not found.');
							}

						}

					}

					delCMList = [ select Id ,Name from Campaignmember 
									where (leadid in:leadidList or contactid in:contactidList) 
									AND Campaign.Recordtypeid =: recordTypeId ];
					system.debug('CAR Trigger : Delete Campaign member dummy - '+delCMList);

					try{
						delete delCMList;
					}catch(Exception e){
		             	system.debug(e);
		            }
				}

			}catch(Exception e){
             	system.debug(e);
            }

			
		}*/



	}



}