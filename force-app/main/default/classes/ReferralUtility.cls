public without sharing class ReferralUtility {
    
    private static final String RTL_DIGITAL_CHANNEL_RECORD_TYPE = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer from Digital Channel').getRecordTypeId();
    private static final Id LEAD_RETAIL_BANKING_RECORDTYPE = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
    private static final String OUTBOUND = 'OUTBOUND';
    private static final String BRANCH = 'BRANCH';
    private static final String RMC = 'RMC';
    private static final String LOAN = 'LOAN';

    private final static List<App_Config__mdt> DEFAULT_COMMENT = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'FNA Referral Comment' LIMIT 1];

    public static void createReferral(String FnaActivityId, String sessionData){
        system.debug('create Referral START');    

        List<Id> splitSessionData = sessionData.split('\\|');
        system.debug('splitSessionData : '+ splitSessionData);

        List<FNA_Product_Offering__c> prodOfferInterestedList = new List<FNA_Product_Offering__c>();
        List<FNA_Product_Offering__c> prodOfferList = [SELECT Id, FNA_Product_Name__r.Product__r.FNA_Product_Name_TH__c, 
                                                                    FNA_Product_Name__r.Product__c,FNA_Product_Name__r.Product__r.Name, FNA_Product_Name__r.Product__r.RTL_Product_Group_Upper__c,
                                                                    FNA_Product_Name__r.Product__r.FNA_Assigned_Pool__c, Flag_Highlight__c, 
                                                                    Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c 
                                                                    FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: FnaActivityId];
                                                                    // AND FNA_Product_Name__r.Product__r.Id IN: splitSessionData
        system.debug('prodOfferList : '+ prodOfferList);
        
        //Update interested flag
        for(FNA_Product_Offering__c prodOffer : prodOfferList){
            if(splitSessionData.contains(prodOffer.FNA_Product_Name__r.Product__c)){
                prodOffer.Flag_Interested_Product__c = true;
                prodOfferInterestedList.add(prodOffer);
            }
        }
        update prodOfferInterestedList;
        system.debug('prodOfferInterestedList : '+ prodOfferInterestedList);
        
        /*for(FNA_Product_Offering__c prodOfferInterestObj : prodOfferInterestedList){
            system.debug('prodOfferInterestedObj : '+ prodOfferInterestObj);
            prodOfferInterestObj.Flag_Interested_Product__c = true;
        }
        update prodOfferInterestedList;*/

        List<FNA_Product_Offering__c> prodInterestedBranchList = new List<FNA_Product_Offering__c>();
        List<FNA_Product_Offering__c> prodInterestedOutboundList = new List<FNA_Product_Offering__c>();
        List<FNA_Product_Offering__c> prodInterestedRmcList = new List<FNA_Product_Offering__c>();

        List<FNA_Activity__c> fnaActivityRecordList = new List<FNA_Activity__c>();
        List<Branch_and_Zone__c> branchList = new List<Branch_and_Zone__c>();
        List<RTL_Referral__c> newReferralList = new List<RTL_Referral__c>(); // for create new referral
        String fnaActivityBranchCodeStr;

        for(FNA_Product_Offering__c prodOfferInterestedObj : prodOfferInterestedList){
            system.debug('Product__c : ' + prodOfferInterestedObj.FNA_Product_Name__r.Product__c);
            system.debug('FNA_Assigned_Pool__c : ' + prodOfferInterestedObj.FNA_Product_Name__r.Product__r.FNA_Assigned_Pool__c);
            system.debug('==========');

            if(prodOfferInterestedObj.FNA_Product_Name__r.Product__r.FNA_Assigned_Pool__c == OUTBOUND){
                prodInterestedOutboundList.add(prodOfferInterestedObj);
                system.debug('OUTBOUND');
                system.debug('Product__c : ' + prodOfferInterestedObj);
                system.debug('==========');
            }
            else if(prodOfferInterestedObj.FNA_Product_Name__r.Product__r.FNA_Assigned_Pool__c == RMC){
                prodInterestedRmcList.add(prodOfferInterestedObj);
                system.debug('RMC');
                system.debug('Product__c : ' + prodOfferInterestedObj);
                system.debug('==========');
            }
            else{
                // system.debug('FNA_Assigned_Pool Not Found');
                prodInterestedBranchList.add(prodOfferInterestedObj);
                system.debug('BRANCH');
                system.debug('Product__c : ' + prodOfferInterestedObj);
                system.debug('==========');
            }
        }

        system.debug('prodInterestedBranchList : ' +  prodInterestedBranchList.size());
        system.debug('prodInterestedOutboundList : ' +  prodInterestedOutboundList.size());
        system.debug('prodInterestedRmcList : ' +  prodInterestedRmcList.size());

        fnaActivityRecordList = [SELECT Id, Person_Name__c, Phone__c, Customer__c, Branch__c, Avatar_Master__r.Avatar_Segment__c, 
                                    Avatar_Master__r.Segment__c, Avatar_Name__c, Avatar_Downloaded__c, CreatedDate, Product_Holding__c,
                                    (SELECT id, name, FNA_Activity__c, RTL_Referral__c FROM Leads__r WHERE RTL_Referral__c = null), 
                                    (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13')
                                    FROM FNA_Activity__c WHERE id =: FnaActivityId];
        fnaActivityBranchCodeStr = fnaActivityRecordList[0].Branch__c;
        branchList = [SELECT Id, Branch_Code__c, isActive__c FROM Branch_and_Zone__c WHERE Branch_Code__c =: fnaActivityBranchCodeStr AND isActive__c = true];

        // existReferralList = [SELECT RTL_Account_Name__c, RTL_Channel_Segment__c, RTL_Mobile1__c, FNA_Activity__c, FNA_Product_Name__c, Assigned_Pool__c, Id FROM RTL_Referral__c WHERE FNA_Activity__c =: FnaActivityId];

        // system.debug('existReferralList size : ' + existReferralList.size());
        // if(existReferralList.isEmpty()){
            //referral is empty

        if(!prodInterestedBranchList.isEmpty()){
            //create referral 'branch'
            newReferralList.add(setReferral(prodInterestedBranchList, fnaActivityRecordList, branchList, BRANCH));
        }
        if(!prodInterestedOutboundList.isEmpty()){
            //create referral 'outbound'
            newReferralList.add(setReferral(prodInterestedOutboundList, fnaActivityRecordList, branchList, OUTBOUND));
        }
        if(!prodInterestedRmcList.isEmpty()){
            //create referral 'rmc'
            newReferralList.add(setReferral(prodInterestedRmcList, fnaActivityRecordList, branchList, RMC));
        }

        insert newReferralList;

        if(newReferralList.size() > 1){
            system.debug('newReferralList Related If');
            newReferralList[0].Related_to_Referral__c = newReferralList[1].Id;
            newReferralList[1].Related_to_Referral__c = newReferralList[0].Id;
            update newReferralList;
        }
        // }
        // FNA_Activity__c fnaObj, Id recordTypeLead, RTL_Referral__c ref, List<FNA_Product_Offering__c> prodOfferList
        /// branch

        Map<String, String> productOfferingMap = new Map<String, String>();
        
        if(prodOfferList.size() > 0){
            system.debug('Activity  : ');
            productOfferingMap = fnaUtility.splitProductOffering(prodOfferList);
            system.debug('Interestd Offering : ' + productOfferingMap.get('Interestd'));
            system.debug('HighlightHolding Offering : ' + productOfferingMap.get('HighlightHolding'));
            fnaActivityRecordList[0].Have_Referral__c = true;
            fnaActivityRecordList[0].Product_Interested__c = productOfferingMap.get('Interestd');
            if( productOfferingMap.get('HighlightHolding') != null && productOfferingMap.get('HighlightHolding') != ''){
                fnaActivityRecordList[0].Product_Holding__c = productOfferingMap.get('HighlightHolding');
            }
            
            update fnaActivityRecordList[0];
        }

        system.debug('customer__c : ' + fnaActivityRecordList[0].customer__c);
        system.debug('productOfferingMap.size(): ' + productOfferingMap.size());
        system.debug('Assigned_Pool__c : ' + newReferralList[0].Assigned_Pool__c);
        if(fnaActivityRecordList[0].customer__c != null && productOfferingMap.size() > 0){
            Account acc = new Account();
            acc.id = fnaActivityRecordList[0].customer__c;
            acc.Fna_Product_Interested__c = productOfferingMap.get('Interestd');
            if(productOfferingMap.get('HighlightHolding') != null && productOfferingMap.get('HighlightHolding') != ''){
                acc.Fna_Product_Holding__c = productOfferingMap.get('HighlightHolding');
            }
            
            acc.Fna_Have_Referral__c = true;
            update acc;

        }else if(newReferralList[0].Assigned_Pool__c == BRANCH){
            system.debug('Leads__r.size : ' + fnaActivityRecordList[0].Leads__r.size());
            if(fnaActivityRecordList[0].Leads__r.size() > 0){
                 system.debug('FNA Have Lead : ');
                Lead leadObj = new Lead();
                leadObj.id = fnaActivityRecordList[0].Leads__r[0].id;
                leadObj.RTL_Referral__c = newReferralList[0].id;
                leadObj.RTL_isAllowedToUpdate__c = true;
                if(productOfferingMap.size() > 0){
                   leadObj.Fna_Product_Interested__c = productOfferingMap.get('Interestd');
                   if(productOfferingMap.get('HighlightHolding') != null && productOfferingMap.get('HighlightHolding') != ''){
                       leadObj.Fna_Product_Holding__c = productOfferingMap.get('HighlightHolding');
                   }
                }
                update leadObj;

            }else{
                system.debug('Create Lead : ');
                List<RTL_Referral__c> refList = [Select id, name, OwnerId FROM RTL_Referral__c WHERE id =:newReferralList[0].id];
                fnaUtility.createLead(fnaActivityRecordList[0], LEAD_RETAIL_BANKING_RECORDTYPE, refList[0], prodOfferList);
            }
        }

        fnaUtility.updateProductofLead(fnaActivityRecordList[0].id);
        
        

        system.debug('create Referral End');
    }

    public static RTL_Referral__c setReferral(List<FNA_Product_Offering__c> prodInterested, List<FNA_Activity__c> fnaActivityRecordList, List<Branch_and_Zone__c> branchList, String type){
        RTL_Referral__c newReferralObj = new RTL_Referral__c();
        Boolean isWithIn = fnaUtility.checkBusinessHourTF('Retail Outbound', Datetime.now());

        //String recordTypeId = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer from Digital Channel').getRecordTypeId();
          
        newReferralObj.RTL_FirstName__c = fnaActivityRecordList[0].Person_Name__c;
        newReferralObj.RTL_LastName__c = '(ไม่ระบุ)';
        newReferralObj.RTL_Mobile1__c = fnaActivityRecordList[0].Phone__c;
        newReferralObj.RTL_Account_Name__c = fnaActivityRecordList[0].Customer__c;
        newReferralObj.FNA_Activity__c = fnaActivityRecordList[0].Id;
        newReferralObj.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
        newReferralObj.RTL_Preferred_Branch__c = branchList[0].Id;
        newReferralObj.RTL_Stage__c = 'New';

        newReferralObj.Assigned_Pool__c = type; // BRANCH OUTBOUND RMC

        newReferralObj.FNA_Product_Name__c = '';
        for(FNA_Product_Offering__c prodInterestBranch : prodInterested){
            if(newReferralObj.FNA_Product_Name__c == ''){
                newReferralObj.FNA_Product_Name__c = prodInterestBranch.FNA_Product_Name__r.Product__r.Name;
            }
            else{
                newReferralObj.FNA_Product_Name__c += ';' + prodInterestBranch.FNA_Product_Name__r.Product__r.Name;
            }

            if(prodInterestBranch.FNA_Product_Name__r.Product__r.RTL_Product_Group_Upper__c == LOAN){
                newReferralObj.FNA_Have_Loan_Product__c = true;
            }
        }
        system.debug('prodInterestBranch of FNA_Product_Name__c : ' + newReferralObj.FNA_Product_Name__c);

        newReferralObj.RTL_Comment__c = DEFAULT_COMMENT[0].Value__c;
        newReferralObj.RecordTypeId = RTL_DIGITAL_CHANNEL_RECORD_TYPE;
        if(type != OUTBOUND){
            newReferralObj.RTL_Channel_Segment__c = 'FNA';
        }else{
            if(isWithIn == true){ // in work time
                newReferralObj.RTL_Channel_Segment__c = 'CMN_FNA';
            }
            else{ // out work time
                newReferralObj.RTL_Channel_Segment__c = 'CML_FNA';
            }
        }        
        System.debug('Check BusinessHour : ' + isWithIn);

        return newReferralObj;
    }
}