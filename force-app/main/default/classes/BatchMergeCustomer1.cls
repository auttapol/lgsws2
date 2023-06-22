//Create class by Danudath
//Objective: batch daily for merge duplicate customer, move all related object under old Customer to new Customer
//Date deploy: 07-10- 2021
//First batch, after run finish call second batch BatchMergeCustomer2
global class BatchMergeCustomer1 implements Schedulable
                                                        , Database.Batchable<SObject>
                                                        , Database.Stateful
                                                        , Database.AllowsCallouts {

    private Integer BATCHSIZE = 50;
    private String query; 


	List<Merge_Customer_Detail__c> mergeDetailList;


    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
    }

	global void execute(SchedulableContext sc){
       
        this.query = 'SELECT ID, Customer_New__c, Customer_Old__c, RM_ID_New__c,RM_ID_Old__c FROM Merge_Customer__c WHERE Customer_Old__c != null';   
        Id BatchProcessIdForInt = Database.ExecuteBatch(this,this.BATCHSIZE); 
    }

    global void execute(Database.BatchableContext bc, List<Merge_Customer__c> scope){

		Map<Id,Id> mapCust = New Map<Id,Id>();
		Set<Id> custIdSet = new Set<Id>();
		Map<Id,Id> mapMergeCust = New Map<Id,Id>();
        Id userid = UserInfo.getUserId();

		for(Merge_Customer__c mergecust : scope){
			mapCust.put(mergecust.Customer_Old__c,mergecust.Customer_New__c);
			custIdSet.add(mergecust.Customer_Old__c);
			mapMergeCust.put(mergecust.Customer_Old__c,mergecust.id);
		}

		mergeDetailList = New List<Merge_Customer_Detail__c>();

			
		//1. Move lead
		List<lead> leadList = [Select id, Account__c from Lead where Account__c in: custIdSet AND isconverted = false];
		if(leadList.size() > 0){
			List<lead> leadUpdate = New List<lead>();
			for(lead le: leadList){
				mapping(mapMergeCust.get(le.Account__c),le.Id, 'Lead',le.Account__c, mapCust.get(le.Account__c));        
				le.Account__c = mapCust.get(le.Account__c);
				leadUpdate.add(le);
				
			}
			if(leadUpdate.size() > 0){
				Database.update(leadUpdate,false);
                
			}
		}

		//2. Move Opportunity
		List<Opportunity> oppList = [Select id, AccountId, Is_Owner_active__c from Opportunity where AccountId in: custIdSet];
		if(oppList.size() > 0){
			List<Opportunity> oppUpdate = New List<Opportunity>();
			for(Opportunity opp : oppList){
				mapping(mapMergeCust.get(opp.AccountId),opp.Id, 'Opportunity',opp.AccountId, mapCust.get(opp.AccountId)); 
				if(opp.Is_Owner_active__c == false){
					opp.ownerid = userid;
				}				
				opp.AccountId = mapCust.get(opp.AccountId);
				oppUpdate.add(opp);
			}
			if(oppUpdate.size() > 0){
				Database.update(oppUpdate,false);

			}
		}


		//3. Move visit plan report
		List<Call_Report__c> visitList = [Select id, Customer_name__c from Call_Report__c where Customer_name__c in: custIdSet];
		if(visitList.size() > 0){
			List<Call_Report__c> visitUpdate = New List<Call_Report__c>();
			for(Call_Report__c visit : visitList){		
				mapping(mapMergeCust.get(visit.Customer_name__c),visit.Id, 'Call_Report__c',visit.Customer_name__c, mapCust.get(visit.Customer_name__c)); 
				visit.Customer_name__c = mapCust.get(visit.Customer_name__c);
				visitUpdate.add(visit);
			}
			
			if(visitUpdate.size() > 0){
				Database.update(visitUpdate,false);
			}
		}

		//4. Move Director
		List<Director__c> DirectorList = [Select id, Account__c from Director__c where Account__c in: custIdSet];
		if(DirectorList.size() > 0){
			List<Director__c> directorUpdate = new List<Director__c>();
			for(Director__c dir : DirectorList){		
				mapping(mapMergeCust.get(dir.Account__c),dir.Id, 'Director__c',dir.Account__c, mapCust.get(dir.Account__c)); 
				dir.Account__c = mapCust.get(dir.Account__c);
				directorUpdate.add(dir);
			}
			
			if(directorUpdate.size() > 0){
				Database.update(directorUpdate,false);
			}
		}

		//5. Move Share Holder
		List<Share_Holder__c> shareHList = [Select id, Account__c from Share_Holder__c where Account__c in: custIdSet];
		if(shareHList.size() > 0){
			List<Share_Holder__c> shareHolUpdate = New List<Share_Holder__c>();
			for(Share_Holder__c shareH : shareHList){
				mapping(mapMergeCust.get(shareH.Account__c),shareH.Id, 'Share_Holder__c',shareH.Account__c, mapCust.get(shareH.Account__c)); 
				shareH.Account__c = mapCust.get(shareH.Account__c);
				shareHolUpdate.add(shareH);
			}
			
			if(shareHolUpdate.size() > 0){
				Database.update(shareHolUpdate,false);
			}
		}

		//6. Move FX order
		List<FX_Order__c> fxOrderList = [Select id, FXO_Customer__c from FX_Order__c where FXO_Customer__c in: custIdSet];
		if(fxOrderList.size() > 0){
			List<FX_Order__c> fxOrderUpdate = New List<FX_Order__c>();
			for(FX_Order__c fxorder : fxOrderList){
				mapping(mapMergeCust.get(fxorder.FXO_Customer__c),fxorder.Id, 'FX_Order__c',fxorder.FXO_Customer__c, mapCust.get(fxorder.FXO_Customer__c));
				fxorder.FXO_Customer__c = mapCust.get(fxorder.FXO_Customer__c);
				fxOrderUpdate.add(fxorder);
			}
			
			if(fxOrderUpdate.size() > 0){
				Database.update(fxOrderUpdate,false);
			}
		}

		//7. Move Do Not Contact
		List<RTL_Do_not_Contact_Info__c> doNotConList = [Select id, Customer__c from RTL_Do_not_Contact_Info__c where Customer__c in: custIdSet];
		if(doNotConList.size() > 0){
			List<RTL_Do_not_Contact_Info__c> doNotConUpdate = New List<RTL_Do_not_Contact_Info__c>();
			for(RTL_Do_not_Contact_Info__c doNot : doNotConList){		
				mapping(mapMergeCust.get(doNot.Customer__c),doNot.Id, 'RTL_Do_not_Contact_Info__c',doNot.Customer__c, mapCust.get(doNot.Customer__c));
				doNot.Customer__c = mapCust.get(doNot.Customer__c);
				doNotConUpdate.add(doNot);
			}
			
			if(doNotConUpdate.size() > 0){
				Database.update(doNotConUpdate,false);
			}
		}

		//8. Move referral
		List<RTL_Referral__c> referralList = [Select id, RTL_Account_Name__c from RTL_Referral__c where RTL_Account_Name__c in: custIdSet];
		if(referralList.size() > 0){
			List<RTL_Referral__c> referUpdate = New List<RTL_Referral__c>();
			for(RTL_Referral__c refer : referralList){		
				mapping(mapMergeCust.get(refer.RTL_Account_Name__c),refer.Id, 'RTL_Referral__c',refer.RTL_Account_Name__c, mapCust.get(refer.RTL_Account_Name__c));
				refer.RTL_Account_Name__c = mapCust.get(refer.RTL_Account_Name__c);
				referUpdate.add(refer);
			}
			
			if(referUpdate.size() > 0){				
				Database.update(referUpdate,false);
			}
		}

		//9. Move E Client Suitability
		List<E_Client_Suitability__c> eSuitList = [Select id, CS_Customer__c from E_Client_Suitability__c where CS_Customer__c in: custIdSet];
		if(eSuitList.size() > 0){
			List<E_Client_Suitability__c> eSuitUpdate = New List<E_Client_Suitability__c>();
			for(E_Client_Suitability__c esuit : eSuitList){
				mapping(mapMergeCust.get(esuit.CS_Customer__c),esuit.Id, 'E_Client_Suitability__c',esuit.CS_Customer__c, mapCust.get(esuit.CS_Customer__c));
				esuit.CS_Customer__c = mapCust.get(esuit.CS_Customer__c);
				eSuitUpdate.add(esuit);
			}
			
			if(eSuitUpdate.size() > 0){				
				Database.update(eSuitUpdate,false);
			}
		}

		//10. Move survey
		List<Survey__c> surveyList = [Select id, Customer__c from Survey__c where Customer__c in: custIdSet];
		if(surveyList.size() > 0){
			List<Survey__c> surveyUpdate = New List<Survey__c>();
			for(Survey__c survey : surveyList){
				mapping(mapMergeCust.get(survey.Customer__c),survey.Id, 'Survey__c',survey.Customer__c, mapCust.get(survey.Customer__c));
				survey.Customer__c = mapCust.get(survey.Customer__c);
				surveyUpdate.add(survey);
			}
			
			if(surveyUpdate.size() > 0){				
				Database.update(surveyUpdate,false);
			}
		}

		//11. Move executive summary
		List<Executive_Summary__c> executiveList = [Select id, Customer_Name__c from Executive_Summary__c where Customer_Name__c in: custIdSet];
		if(executiveList.size() > 0){
			List<Executive_Summary__c> exSumUpdate = New List<Executive_Summary__c>();
			for(Executive_Summary__c exSum : executiveList){
				mapping(mapMergeCust.get(exSum.Customer_Name__c),exSum.Id, 'Executive_Summary__c',exSum.Customer_Name__c, mapCust.get(exSum.Customer_Name__c));
				exSum.Customer_Name__c = mapCust.get(exSum.Customer_Name__c);
				exSumUpdate.add(exSum);
			}
			
			if(exSumUpdate.size() > 0){				
				Database.update(exSumUpdate,false);
			}
		}
	
		//12. Move Customer Migration Note
		List<RTL_Customer_Migration_Info__c> CustMigList = [Select id, RTL_Customer__c from RTL_Customer_Migration_Info__c where RTL_Customer__c in: custIdSet];
		if(CustMigList.size() > 0){
			List<RTL_Customer_Migration_Info__c> custMigUpdate = New List<RTL_Customer_Migration_Info__c>();
			for(RTL_Customer_Migration_Info__c custMig : CustMigList){		
				mapping(mapMergeCust.get(custMig.RTL_Customer__c),custMig.Id, 'RTL_Customer_Migration_Info__c',custMig.RTL_Customer__c, mapCust.get(custMig.RTL_Customer__c));
				custMig.RTL_Customer__c = mapCust.get(custMig.RTL_Customer__c);
				custMigUpdate.add(custMig);
			}
			
			if(custMigUpdate.size() > 0){
				Database.update(custMigUpdate,false);
			}
		}

		//13. Move Customer Note Info
		List<Customer_Note_Info__c> custNotList = [Select id, Customer__c from Customer_Note_Info__c where Customer__c in: custIdSet];
		if(custNotList.size() > 0){
			List<Customer_Note_Info__c> custNoteUpdate = New List<Customer_Note_Info__c>();
			for(Customer_Note_Info__c custNote : custNotList){
				mapping(mapMergeCust.get(custNote.Customer__c),custNote.Id, 'Customer_Note_Info__c',custNote.Customer__c, mapCust.get(custNote.Customer__c));
				custNote.Customer__c = mapCust.get(custNote.Customer__c);
				custNoteUpdate.add(custNote);
			}
			
			if(custNoteUpdate.size() > 0){
				Database.update(custNoteUpdate,false);
			}
		}

		//14. Move Account Plan company profile
		List<AcctPlanCompanyProfile__c> accPlanList = [Select id, Account__c from AcctPlanCompanyProfile__c where Account__c in: custIdSet];
		if(accPlanList.size() > 0){
			List<AcctPlanCompanyProfile__c> accProfileUpdate = New List<AcctPlanCompanyProfile__c>();
			for(AcctPlanCompanyProfile__c accprofile : accPlanList){		
				mapping(mapMergeCust.get(accprofile.Account__c),accprofile.Id, 'AcctPlanCompanyProfile__c',accprofile.Account__c, mapCust.get(accprofile.Account__c));
				accprofile.Account__c = mapCust.get(accprofile.Account__c);
				accProfileUpdate.add(accprofile);
			}
			
			if(accProfileUpdate.size() > 0){
				Database.update(accProfileUpdate,false);
			}
		}

		//15. Move Account Plan company port
		List<AcctPlanCompanyPort__c> accPortList = [Select id, Account__c from AcctPlanCompanyPort__c where Account__c in: custIdSet];
		if(accPortList.size() > 0){
			List<AcctPlanCompanyPort__c> accPortUpdate = New List<AcctPlanCompanyPort__c>();
			for(AcctPlanCompanyPort__c accPort : accPortList){
				mapping(mapMergeCust.get(accPort.Account__c),accPort.Id, 'AcctPlanCompanyPort__c',accPort.Account__c, mapCust.get(accPort.Account__c));
				accPort.Account__c = mapCust.get(accPort.Account__c);
				accPortUpdate.add(accPort);
			}
			
			if(accPortUpdate.size() > 0){
				Database.update(accPortUpdate,false);
			}
		}


		/*
		//*** salesforce limit Field is not writeable, so cannot move attachedment to new customer
		//16. Move Attachment
		List<Attachment> attList = [Select id, ParentId from Attachment where ParentId in: custIdSet];
		if(attList.size() > 0){
			List<Attachment> attUpdate = New List<Attachment>();
			for(Attachment attach : attList){
				mapping(mapMergeCust.get(attach.ParentId),attach.Id, 'Attachment',attach.ParentId, mapCust.get(attach.ParentId));
				attach.ParentId = mapCust.get(attach.ParentId);
				attUpdate.add(attach);
			}
			
			if(attUpdate.size() > 0){
				Database.update(attUpdate,false);
			}
		}

		//17. Move ContentDocumentLink
		List<ContentDocumentLink> conAttList = [Select id, LinkedEntityId from ContentDocumentLink where LinkedEntityId in: custIdSet];
		if(conAttList.size() > 0){
			List<ContentDocumentLink> conAttUpdate = New List<ContentDocumentLink>();
			for(ContentDocumentLink conLink : conAttList){
				mapping(mapMergeCust.get(conLink.LinkedEntityId),conLink.Id, 'ContentDocumentLink',conLink.LinkedEntityId, mapCust.get(conLink.LinkedEntityId));
				conLink.LinkedEntityId = mapCust.get(conLink.LinkedEntityId);
				conAttUpdate.add(conLink);
			}
			
			if(conAttUpdate.size() > 0){
				Database.update(conAttUpdate,false);
			}
		}
		*/

		//30. Move forecast input
		//*** cannot move forecast, because there are many process batch backend to limit DML 10001
		/*try{
		integer loopMove = 0;
		boolean loopCheck = true;
		while(loopCheck){
			loopMove ++;
			if(loopMove == 10){
				loopCheck = false;
			}
			List<Monthly_Forecast_Input__c> foreCastList = [Select id, Customer__c from Monthly_Forecast_Input__c where Customer__c in: custIdSet and createddate >= LAST_N_MONTHS:12 limit 1000];
			if(foreCastList.size() > 0){
				List<Monthly_Forecast_Input__c> forecastUpdate = New List<Monthly_Forecast_Input__c>();
				for(Monthly_Forecast_Input__c foreCast : foreCastList){		
					mapping(mapMergeCust.get(foreCast.Customer__c),foreCast.Id, 'Monthly_Forecast_Input__c',foreCast.Customer__c, mapCust.get(foreCast.Customer__c));
					foreCast.Customer__c = mapCust.get(foreCast.Customer__c);
					forecastUpdate.add(foreCast);
				}
				
				if(forecastUpdate.size() > 0){
					Database.update(forecastUpdate,false);
				}
			}else{
				loopCheck = false;
			}  
		}
		}catch(Exception e){            
			//do nothing
			system.debug('**Error move monthly forecast input: '+ e.getMessage());
		}
		
		//31. Deal_Forecast_Income__c
		List<Deal_Forecast_Income__c> dealincomeList = [Select id, Customer__c from Deal_Forecast_Income__c where Customer__c in: custIdSet];
		if(dealincomeList.size() > 0){
			List<Deal_Forecast_Income__c> dealincomeUpdate = New List<Deal_Forecast_Income__c>();
			for(Deal_Forecast_Income__c dealIncome : dealincomeList){
				mapping(mapMergeCust.get(dealIncome.Customer__c),dealIncome.Id, 'Deal_Forecast_Income__c',dealIncome.Customer__c, mapCust.get(dealIncome.Customer__c));
				dealIncome.Customer__c = mapCust.get(dealIncome.Customer__c);
				dealincomeUpdate.add(dealIncome);
			}
			
			if(dealincomeUpdate.size() > 0){
				Database.update(dealincomeUpdate,false);
			}
		}
		
		//32. Forecast_Cube_1__c
		List<Forecast_Cube_1__c> cube1List = [Select id, Customer__c from Forecast_Cube_1__c where Customer__c in: custIdSet];
		if(cube1List.size() > 0){
			List<Forecast_Cube_1__c> cube1Update = New List<Forecast_Cube_1__c>();
			for(Forecast_Cube_1__c cube1 : cube1List){
				mapping(mapMergeCust.get(cube1.Customer__c),cube1.Id, 'Forecast_Cube_1__c',cube1.Customer__c, mapCust.get(cube1.Customer__c));
				cube1.Customer__c = mapCust.get(cube1.Customer__c);
				cube1Update.add(cube1);
			}
			
			if(cube1Update.size() > 0){
				Database.update(cube1Update,false);
			}
		}
		
		//33. Forecast_Cube_2__c
		List<Forecast_Cube_2__c> cube2List = [Select id, Customer__c from Forecast_Cube_2__c where Customer__c in: custIdSet];
		if(cube2List.size() > 0){
			List<Forecast_Cube_2__c> cube2Update = New List<Forecast_Cube_2__c>();
			for(Forecast_Cube_2__c cube2 : cube2List){
				mapping(mapMergeCust.get(cube2.Customer__c),cube2.Id, 'Forecast_Cube_2__c',cube2.Customer__c, mapCust.get(cube2.Customer__c));
				cube2.Customer__c = mapCust.get(cube2.Customer__c);
				cube2Update.add(cube2);
			}
			
			if(cube2Update.size() > 0){
				Database.update(cube2Update,false);
			}
		}
	    */
		if(mergeDetailList.size() > 0){
			insert mergeDetailList;
		}

	}

    global void finish(Database.BatchableContext bc){

    	BatchMergeCustomer2 callNewBatch = new BatchMergeCustomer2();
		Database.executeBatch(callNewBatch, BATCHSIZE);
    }

	global void mapping(id referId, String recId, String objectName, String fromID, String toId ){
		Merge_Customer_Detail__c mergeDetail = New Merge_Customer_Detail__c();
			mergeDetail.Merge_Customer__c = referId;
			mergeDetail.Record_ID__c = recId;
			mergeDetail.Sobject__c = objectName;
			mergeDetail.FromCustomerID__c = fromID;
			mergeDetail.ToCustomerID__c = toId;
			mergeDetailList.add(mergeDetail);
	}

}