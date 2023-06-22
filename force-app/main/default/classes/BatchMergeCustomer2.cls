//Create class by Danudath
//Objective: batch daily for merge duplicate customer, move all related object under old Customer to new Customer
//Date deploy: 07-10- 2021
//Second batch
global  class BatchMergeCustomer2 implements Database.Batchable<sObject>,
                                                    Database.Stateful, 
                                                    Database.AllowsCallouts {
//private Integer BATCHSIZE = 100;
private String query; 

private TimeZone tz = UserInfo.getTimeZone();
private Datetime batchDate = datetime.now();
private Datetime batchStartTime = datetime.now();

private integer totalRecord = 0;
private integer totalSuccess = 0;
private integer totalError = 0;

List<Merge_Customer_Detail__c> mergeDetailList;

String generatedExcelFile ='Id,Result\n';
String errorMessage = '';
Boolean checkIsError = false;

global Database.QueryLocator start(Database.BatchableContext BC){
    this.query = 'SELECT ID, Customer_New__c, Customer_Old__c, RM_ID_New__c,RM_ID_Old__c FROM Merge_Customer__c WHERE Customer_Old__c != null'; 
    return Database.getQueryLocator(this.query);
}

global void execute(Database.BatchableContext bc, List<Merge_Customer__c> scope){

    Map<Id,Id> mapCust = New Map<Id,Id>();
    Set<Id> custIdSet = new Set<Id>();
    Map<Id,Id> mapMergeCust = New Map<Id,Id>();
	Id userid = UserInfo.getUserId();
    totalRecord = totalRecord + scope.size();

    for(Merge_Customer__c mergecust : scope){
        mapCust.put(mergecust.Customer_Old__c,mergecust.Customer_New__c);
        custIdSet.add(mergecust.Customer_Old__c);
        mapMergeCust.put(mergecust.Customer_Old__c,mergecust.id);
    }

    List<Account> accDeleteList = [Select id, TMB_Customer_ID_PE__c from Account where id in: custIdSet];
    mergeDetailList = New List<Merge_Customer_Detail__c>();

    //16. Move contact
    List<Contact> contactList = [Select id, recordtypeid, AccountId from Contact where AccountId in: custIdSet ];
    List<Contact> deleteContact = New List<Contact>();
    if(contactList.size() > 0){
        List<Contact> contactUpdate = New List<Contact>();
        for(Contact con : contactList){
            //Add retail contact for delete
            if(con.recordtypeid == '01290000000iZYIAA2'){
                deleteContact.add(con);
            }else{
                mapping(mapMergeCust.get(con.AccountId),con.Id, 'Contact',con.AccountId, mapCust.get(con.AccountId)); 
                con.AccountId = mapCust.get(con.AccountId);
                contactUpdate.add(con);
            }
        }
        if(contactUpdate.size() > 0){
            Database.update(contactUpdate,false);
        }
    }	

    //17. Move Case
    try{
        integer loopMove = 0;
		boolean loopCheck = true;
		while(loopCheck){
			loopMove ++;
			if(loopMove == 10){
				loopCheck = false;
			}
            List<Case> caseList = [Select id, AccountId, Is_Owner_active__c from Case where AccountId in: custIdSet limit 50];
            if(caseList.size() > 0){
                List<Case> caseUpdate = New List<Case>();
                for(Case caseU : caseList){
                    mapping(mapMergeCust.get(caseU.AccountId),caseU.Id, 'Case',caseU.AccountId, mapCust.get(caseU.AccountId));
                    caseU.AccountId = mapCust.get(caseU.AccountId);
                    caseU.ContactId = null;
                    if(caseU.Is_Owner_active__c == false){
                        caseU.ownerid = userid;
                    }
    
                    caseUpdate.add(caseU);
                }
                
                if(caseUpdate.size() > 0){				
                    Database.update(caseUpdate,false);
                }
            }else{
				loopCheck = false;
			} 
        }
    }catch(Exception e){
        checkIsError = true;
        errorMessage = errorMessage + 'Case,' + e.getMessage() + '\n';
    }

    //delete retail contact
    if(deleteContact.size() > 0){
        Database.delete(deleteContact,false);
    }

    //18. Move Collateral
    List<Collateral__c> collatList = [Select id, Account__c from Collateral__c where Account__c in: custIdSet];
    if(collatList.size() > 0){
        List<Collateral__c> collatUpdate = New List<Collateral__c>();
        for(Collateral__c collat : collatList){
            mapping(mapMergeCust.get(collat.Account__c),collat.Id, 'Collateral__c',collat.Account__c, mapCust.get(collat.Account__c));
            collat.Account__c = mapCust.get(collat.Account__c);
            collatUpdate.add(collat);
        }
        
        if(collatUpdate.size() > 0){
            Database.update(collatUpdate,false);
        }
    }

    //19. Move Account Annual Performance
    List<AcctAnnualPerformance__c> annualList = [Select id, Account__c from AcctAnnualPerformance__c where Account__c in: custIdSet];
    if(annualList.size() > 0){
        List<AcctAnnualPerformance__c> annualUpdate = New List<AcctAnnualPerformance__c>();
        for(AcctAnnualPerformance__c annual : annualList){
            mapping(mapMergeCust.get(annual.Account__c),annual.Id, 'AcctAnnualPerformance__c',annual.Account__c, mapCust.get(annual.Account__c));
            annual.Account__c = mapCust.get(annual.Account__c);
            annualUpdate.add(annual);
        }
        
        if(annualUpdate.size() > 0){
            Database.update(annualUpdate,false);
        }
    }

    //20. Move Hourshold Member
    List<RTL_Household_Member__c> hoursHoList = [Select id, RTL_Household_Member_Name__c from RTL_Household_Member__c where RTL_Household_Member_Name__c in: custIdSet];
    if(hoursHoList.size() > 0){
        List<RTL_Household_Member__c> hoursHUpdate = New List<RTL_Household_Member__c>();
        for(RTL_Household_Member__c hoursH : hoursHoList){		
            mapping(mapMergeCust.get(hoursH.RTL_Household_Member_Name__c),hoursH.Id, 'RTL_Household_Member__c',hoursH.RTL_Household_Member_Name__c, mapCust.get(hoursH.RTL_Household_Member_Name__c));
            hoursH.RTL_Household_Member_Name__c = mapCust.get(hoursH.RTL_Household_Member_Name__c);
            hoursHUpdate.add(hoursH);
        }
        
        if(hoursHUpdate.size() > 0){
            Database.update(hoursHUpdate,false);
        }
    }
 
    //21. Move task
    List<Task> taskList = [Select id, whatId from Task where whatid in: custIdSet and IsRecurrence = false];
    if(taskList.size() > 0){
        List<Task> taskUpdate = New List<Task>();
        for(Task tas : taskList){
            mapping(mapMergeCust.get(tas.whatId),tas.Id, 'Task',tas.whatId, mapCust.get(tas.whatId));
            tas.whatId = mapCust.get(tas.whatId);
            taskUpdate.add(tas);
        }
        
        if(taskUpdate.size() > 0){
            Database.update(taskUpdate,false);
        }
    }    

    //22. Move Product fee
    List<Product_Fee__c> productFeeList = [Select id, Customer__c from Product_Fee__c where Customer__c in: custIdSet];
    if(productFeeList.size() > 0){
        List<Product_Fee__c> productfeeUpdate = New List<Product_Fee__c>();
        for(Product_Fee__c proFee : productFeeList){
            mapping(mapMergeCust.get(proFee.Customer__c),proFee.Id, 'Product_Fee__c',proFee.Customer__c, mapCust.get(proFee.Customer__c));
            proFee.Customer__c = mapCust.get(proFee.Customer__c);
            productfeeUpdate.add(proFee);
        }
        
        if(productfeeUpdate.size() > 0){
            Database.update(productfeeUpdate,false);
        }
    }

    //23. Move Product NIM
    List<Product_NIM__c> productNimList = [Select id, Customer__c from Product_NIM__c where Customer__c in: custIdSet];
    if(productNimList.size() > 0){
        List<Product_NIM__c> productNimUpdate = New List<Product_NIM__c>();
        for(Product_NIM__c proNim : productNimList){
            mapping(mapMergeCust.get(proNim.Customer__c),proNim.Id, 'Product_NIM__c',proNim.Customer__c, mapCust.get(proNim.Customer__c));
            proNim.Customer__c = mapCust.get(proNim.Customer__c);
            productNimUpdate.add(proNim);
        }
        
        if(productNimUpdate.size() > 0){
            Database.update(productNimUpdate,false);
        }
    }


    //24. Move product performance
    List<Product_Performance__c> productPerList = [Select id, Account__c from Product_Performance__c where Account__c in: custIdSet];
    if(productPerList.size() > 0){
        List<Product_Performance__c> productPerUpdate = New List<Product_Performance__c>();
        for(Product_Performance__c proPer : productPerList){
            mapping(mapMergeCust.get(proPer.Account__c),proPer.Id, 'Product_Performance__c',proPer.Account__c, mapCust.get(proPer.Account__c));
            proPer.Account__c = mapCust.get(proPer.Account__c);
            productPerUpdate.add(proPer);
        }
        
        if(productPerUpdate.size() > 0){
            Database.update(productPerUpdate,false);
        }
    }

    //25. Move product Transection Risk
    List<Product_Trans_Risk__c> productRiskList = [Select id, Account__c from Product_Trans_Risk__c where Account__c in: custIdSet];
    if(productRiskList.size() > 0){
        List<Product_Trans_Risk__c> productTranUpdate = New List<Product_Trans_Risk__c>();
        for(Product_Trans_Risk__c proTran : productRiskList){
            mapping(mapMergeCust.get(proTran.Account__c),proTran.Id, 'Product_Trans_Risk__c',proTran.Account__c, mapCust.get(proTran.Account__c));
            proTran.Account__c = mapCust.get(proTran.Account__c);
            productTranUpdate.add(proTran);
        }
        
        if(productTranUpdate.size() > 0){
            Database.update(productTranUpdate,false);
        }
    }
 

    //26. Move product on hand
    List<Product_Information_On_Hand__c> productInfoOnHandList = [Select id, Account__c from Product_Information_On_Hand__c where Account__c in: custIdSet];
    if(productInfoOnHandList.size() > 0){
        List<Product_Information_On_Hand__c> productOnHandUpdate = New List<Product_Information_On_Hand__c>();
        for(Product_Information_On_Hand__c proOn : productInfoOnHandList){
            mapping(mapMergeCust.get(proOn.Account__c),proOn.Id, 'Product_Information_On_Hand__c',proOn.Account__c, mapCust.get(proOn.Account__c));
            proOn.Account__c = mapCust.get(proOn.Account__c);
            productOnHandUpdate.add(proOn);
        }
        
        if(productOnHandUpdate.size() > 0){
            Database.update(productOnHandUpdate,false);
        }
    }

    //27. Move Tbank Case
    List<TBank_Case_History__c> tbankCaseList = [Select id, Customer__c from TBank_Case_History__c where Customer__c  in: custIdSet];
    if(tbankCaseList.size() > 0){
        List<TBank_Case_History__c> tbankCaseUpdate = New List<TBank_Case_History__c>();
        for(TBank_Case_History__c tbankCase : tbankCaseList){
            mapping(mapMergeCust.get(tbankCase.Customer__c),tbankCase.Id, 'TBank_Case_History__c',tbankCase.Customer__c, mapCust.get(tbankCase.Customer__c));
            tbankCase.Customer__c = mapCust.get(tbankCase.Customer__c);
            tbankCaseUpdate.add(tbankCase);
        }
        
        if(tbankCaseUpdate.size() > 0){
            Database.update(tbankCaseUpdate,false);
        }
    }

    //28. Move Tbank complaint
    List<TBank_Complaint_History__c> tbankComplaintList = [Select id, Customer__c from TBank_Complaint_History__c where Customer__c in: custIdSet];
    if(tbankComplaintList.size() > 0){
        List<TBank_Complaint_History__c> tbankComPlainUpdate = New List<TBank_Complaint_History__c>();
        for(TBank_Complaint_History__c tbankComplaint : tbankComplaintList){
            mapping(mapMergeCust.get(tbankComplaint.Customer__c),tbankComplaint.Id, 'TBank_Complaint_History__c',tbankComplaint.Customer__c, mapCust.get(tbankComplaint.Customer__c));
            tbankComplaint.Customer__c = mapCust.get(tbankComplaint.Customer__c);
            tbankComPlainUpdate.add(tbankComplaint);
        }
        
        if(tbankComPlainUpdate.size() > 0){
            Database.update(tbankComPlainUpdate,false);
        }
    }

     //29. Income_Estimation__c
    List<Income_Estimation__c> incomeList = [Select id, Account__c from Income_Estimation__c where Account__c in: custIdSet];
    if(incomeList.size() > 0){
        List<Income_Estimation__c> incomeUpdate = New List<Income_Estimation__c>();
        for(Income_Estimation__c income : incomeList){
            mapping(mapMergeCust.get(income.Account__c),income.Id, 'Income_Estimation__c',income.Account__c, mapCust.get(income.Account__c));
            income.Account__c = mapCust.get(income.Account__c);
            incomeUpdate.add(income);
        }
        
        if(incomeUpdate.size() > 0){
            Database.update(incomeUpdate,false);
        }
    }

    
    //30. RTL_Fulfillment__c
    List<RTL_Fulfillment__c> FulfillmentList = [Select id, RTL_Customer__c from RTL_Fulfillment__c where RTL_Customer__c in: custIdSet];
    if(FulfillmentList.size() > 0){
        List<RTL_Fulfillment__c> FulfillmentUpdate = New List<RTL_Fulfillment__c>();
        for(RTL_Fulfillment__c Fulfillment : FulfillmentList){
            mapping(mapMergeCust.get(Fulfillment.RTL_Customer__c),Fulfillment.Id, 'RTL_Fulfillment__c',Fulfillment.RTL_Customer__c, mapCust.get(Fulfillment.RTL_Customer__c));
            Fulfillment.RTL_Customer__c = mapCust.get(Fulfillment.RTL_Customer__c);
            FulfillmentUpdate.add(Fulfillment);
        }
        
        if(FulfillmentUpdate.size() > 0){
            Database.update(FulfillmentUpdate,false);
        }
    }

   
    //Main_Bank_List_View__c  
    //Not move main bank list view, because it relate to external id 'Customer_ID__c'
    
    List<RTL_Customer_Data_Validation__c> validateList = [Select Id, RTL_Account__c from RTL_Customer_Data_Validation__c where RTL_Account__c in: custIdSet];

    if(validateList.size() > 0){
        Delete validateList;
    }

    if(mergeDetailList.size() > 0){
        insert mergeDetailList;
    }

    //Delete accDeleteList;
    if(accDeleteList.size() > 0){
        Database.DeleteResult[] resultDelete = Database.delete(accDeleteList,false);
        integer i = 0;
        for (Database.DeleteResult sr : resultDelete) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                totalSuccess = totalSuccess + 1;
                generatedExcelFile = generatedExcelFile +sr.getId() + ',Success\n';
            }
            else {
                totalError = totalError + 1;
                String errorMesage = '';
                for(Database.Error err : sr.getErrors()) {                   
                    errorMesage = err.getFields() + ': ' + err.getStatusCode() + ': ' + err.getMessage();

                }
                generatedExcelFile = generatedExcelFile + accDeleteList[i].id + ','+ errorMesage +'\n';
            }
            i++;
        }

    }

    if(checkIsError){
        generatedExcelFile = generatedExcelFile + errorMessage;
    }

}

global void finish(Database.BatchableContext bc){

    String subject = null;
    String description = null;
    String status = null;
    
    if(totalSuccess == 0){
        totalError = totalRecord;
    }
    if (totalError > 0 ) {//there are failed records
        subject = 'Batch : Merge Customer in salesforce' + ' Failed';
        description = 'Some record have failed for merge record, please see result in attached file';
        status = 'Failed';
    } else {//there are no failed records
        subject = 'Batch : Merge Customer in salesforce run' + ' successfully';
        description = 'All record have merge completely';
        status = 'Success';
    }   	
 
    string htmlMsg = description + ' <br/><br/>'
                + 'Batch as of : ' + batchDate.format('dd/MM/yyyy', tz.toString()) + '<br/><br/>'
                + 'Batch : Merge Customer in Saleforce' + ' : ' + status + '<br/><br/>'
                + '<table style="width:100%" border=1>'
                + '<tr>'
                + '	<th>' + System.Label.RTL_Purge_Email_006 + '</th>'					
                + '	<th>' + System.Label.RTL_Purge_Email_007 + '</th>'
                + '	<th>' + System.Label.RTL_Purge_Email_008 + '</th>'
                + '	<th>' + System.Label.RTL_Purge_Email_009 + '</th>'
                + '</tr>'
                + '<tr>'

                + '	<td>' + 'Account' + '</td>'					
                + '	<td>' + totalRecord + '</td>'
                + '	<td>' + totalSuccess + '</td>'
                + '	<td>' + totalError + '</td>'
                + '</tr>'
                    
                + '</table>'
                + '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
                + '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';


    String emailOpsTeamA = AppConfig__c.getValues('CRM Admin').Value__c;
    String[] toAddresses = emailOpsTeamA.split(';');
    //Send email after finish
    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
    Blob csvBlob = Blob.valueOf(generatedExcelFile);
    csvAttc.setFileName('Merge_Customer_Result.csv');
    csvAttc.setBody(csvBlob);
    Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
    email.setSubject(subject);
    email.setToAddresses( toAddresses );
    email.setHtmlBody(htmlMsg);
    //email.setPlainTextBody(htmlMsg);
    email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
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