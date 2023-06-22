public class RTL_NBOProductCtrl {

    public User loggedInUser {get;set;}
    public string nboId {get;set;}
    public Id accId {get;set;}
    public RTL_NBO_History_Product__c nboProduct {get;set;}
    public Boolean hasError {get;set;}
    public String nboTabId {get;set;}
    
    private string oldStatus;
    private string oldRejectReason;
    private boolean baOpptError;
    private boolean productError;
    
    public RTL_NBOProductCtrl(ApexPages.StandardController std) {
        nboProduct = (RTL_NBO_History_Product__c)std.getRecord();
        nboProduct = [SELECT ID,Name,RTL_Status__c,RTL_Reject_Reason__c,RTL_Offering_Channel__c,RTL_Product_Group__c,
                            RTL_Product_SubGroup__c,RTL_Product__c,RTL_Opportunity__c,
                        RTL_User_Region__c,RTL_User_Zone__c,RTL_User_Branch__c,RTL_Major_Reason__c,RTL_Other_Specific__c,
                        RTL_Sub_Reason__c,RTL_Related_NBO__c, RTL_Related_NBO__r.Name,RTL_NBO_ID__c,RTL_Related_NBO__r.RTL_Customer_Name__c,
                        RTL_Product_Smart_Info__c, RTL_Related_NBO__r.RTL_NBO_ID__c,
                        RTL_Related_NBO__r.RTL_Campaign_Name__c, RTL_Related_NBO__r.RTL_Campaign_Code__c, 
                        RTL_Related_NBO__r.RTL_Valid_From__c, RTL_Related_NBO__r.RTL_Valid_To__c,
                        RTL_Related_NBO__r.RTL_Campaign__c,RTL_Related_NBO__r.RTL_TMB_Customer_ID_PE__c //Campaign id from campaign phase2
                       FROM RTL_NBO_History_Product__c WHERE ID=:nboProduct.id];
        nboId = nboProduct.RTL_NBO_ID__c ;
        accId = nboProduct.RTL_Related_NBO__r.RTL_Customer_Name__c;
        nboTabId = ApexPages.currentPage().getParameters().get('tabId');
        oldStatus = nboProduct.RTL_Status__c;
        oldRejectReason = nboProduct.RTL_Reject_Reason__c;
        loggedInUser = [SELECT Id,Name,Region_Code__c ,Zone_Code__c,RTL_Branch_Code__c, RTL_Channel__c FROM User WHERE id=:UserInfo.getUserId()];
    }

    /*public List<SelectOption> getStatusValue()
    {
        List<SelectOption> statusOptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = RTL_NBO_History_Product__c.RTL_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            if(f.getValue() != 'Invalid')
            {
                statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }  
        return statusOptions;      
    }*/
    
    public Opportunity createOpportunity(RTL_NBO_History_Product__c nboHistoryProductItem){
    	baOpptError = false;
    	productError = false;
         //get Opportunity_Recordtype_Mapping__c from custom setting
        Map<String,Opportunity_Recordtype_Mapping__c> oppRecType = getMapOppRecordType();
        //get Product short name
        Map<String,RTL_Product_Group_Short_Name__mdt> pShortName = getProductShortName();
        
        Map<String,RTL_Product_Master__c> productMasterMap = new Map<String,RTL_Product_Master__c>();
        //opp record type
        Id RTBancassurance = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecType.get('RetailBancassuranceStage').Record_Type__c).getRecordTypeId();
        Id RTCard = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecType.get('RetailCardandRDCStage').Record_Type__c).getRecordTypeId();
        Id RTDeposit = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecType.get('RetailDepositStage').Record_Type__c).getRecordTypeId();
        Id RTInvestment = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecType.get('RetailInvestmentStage').Record_Type__c).getRecordTypeId();
        Id RTLoans = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecType.get('RetailLoansStage').Record_Type__c).getRecordTypeId();
        Id RTOthers = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecType.get('RetailOthersStage').Record_Type__c).getRecordTypeId();
        Id RTRetentions = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecType.get('RetailRetentionsStage').Record_Type__c).getRecordTypeId();
        
        //default opportunity close date
        Date closeDate = [Select EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].EndDate;
        
        for(RTL_product_master__c retailProduct : [Select Name, Product_Group__c, Product_Sub_group__c, RTL_Product_Smart_Info__c from RTL_product_master__c where Active__c = true]) {
            productMasterMap.put(toLowerCase(retailProduct.Name+retailProduct.Product_Group__c+retailProduct.Product_Sub_group__c),retailProduct);
        }
       
        Opportunity opp  = new Opportunity();
        
        
            //if product group = Bancassurance recordtype = RetailBancassuranceStage
            if(nboHistoryProductItem.RTL_Product_Group__c == oppRecType.get('RetailBancassuranceStage').Product_Group__c){
            	/*String lowerNBOProductSubGroup = toLowerCase(nboHistoryProductItem.RTL_Product_SubGroup__c);
            	String lowerBALifeSubGroup = toLowerCase(pShortName.get('BA Life').RTL_Product_SubGroup__c);
            	String lowerBANonLifeSubGroup = toLowerCase(pShortName.get('BA Non Life').RTL_Product_SubGroup__c);
                if(lowerNBOProductSubGroup.contains(lowerBALifeSubGroup) || lowerNBOProductSubGroup.contains(lowerBANonLifeSubGroup)){
                    opp.Name = pShortName.get('BA Life').RTL_Short_Name__c+' (NBO)';
                    if (lowerNBOProductSubGroup.contains(lowerBANonLifeSubGroup))
                    	opp.Name = pShortName.get('BA Non Life').RTL_Short_Name__c+' (NBO)';
                } else {
                	baOpptError = true;
                	//pageMsgFlag = true;
                	return null;
                }*/
                
                opp.RecordTypeId = RTBancassurance;
                opp.StageName = oppRecType.get('RetailBancassuranceStage').Stage__c;
                
            }
            //if product group = Credit Card & RDC recordtype = RetailCardandRDCStage
            else if(nboHistoryProductItem.RTL_Product_Group__c == oppRecType.get('RetailCardandRDCStage').Product_Group__c){
                opp.RecordTypeId = RTCard;
                //opp.Name = pShortName.get('Card').RTL_Short_Name__c+' (NBO)';
                opp.StageName = oppRecType.get('RetailCardandRDCStage').Stage__c;
            }       
            //if product group = Deposit recordtype = RetailDepositStage
            else if(nboHistoryProductItem.RTL_Product_Group__c == oppRecType.get('RetailDepositStage').Product_Group__c){
                opp.RecordTypeId = RTDeposit;
                //opp.Name = pShortName.get('Deposit').RTL_Short_Name__c+' (NBO)';
                opp.StageName = oppRecType.get('RetailDepositStage').Stage__c;
            }
            //if product group = Investment recordtype = RetailInvestmentStage
            else if(nboHistoryProductItem.RTL_Product_Group__c == oppRecType.get('RetailInvestmentStage').Product_Group__c){
                opp.RecordTypeId = RTInvestment;
                //opp.Name = pShortName.get('MF').RTL_Short_Name__c+' (NBO)';
                opp.StageName = oppRecType.get('RetailInvestmentStage').Stage__c;
            }
            //if product group = Loan recordtype = RetailLoansStage
            else if(nboHistoryProductItem.RTL_Product_Group__c == oppRecType.get('RetailLoansStage').Product_Group__c){
                opp.RecordTypeId = RTLoans;
                //opp.Name = pShortName.get('Loan').RTL_Short_Name__c+' (NBO)';
                opp.StageName = oppRecType.get('RetailLoansStage').Stage__c;
            }
            //if product group = Others recordtype = RetailOthersStage
            else if(nboHistoryProductItem.RTL_Product_Group__c == oppRecType.get('RetailOthersStage').Product_Group__c){
                opp.RecordTypeId = RTOthers;
                //opp.Name = 'Others (NBO)';
                opp.StageName = oppRecType.get('RetailOthersStage').Stage__c;
            }
            //if product group = Loan Retention recordtype = RetailRetentionsStage
            else if(nboHistoryProductItem.RTL_Product_Group__c == oppRecType.get('RetailRetentionsStage').Product_Group__c){
                opp.RecordTypeId = RTRetentions;
                //opp.Name = 'Retentions (NBO)';
                opp.StageName = oppRecType.get('RetailRetentionsStage').Stage__c;
            }
            else{
                opp.RecordTypeId = RTOthers;
                //opp.Name = 'Others (NBO)';
                opp.StageName = oppRecType.get('RetailOthersStage').Stage__c;
            }
            
            opp.CloseDate = closeDate;
            opp.RTL_Project_Name__c = nboHistoryProductItem.RTL_Product__c;
            opp.AccountId = accId;
            opp.RTL_Status__c = 'Open';
            opp.RTL_Related_NBO_History__c = nboProduct.RTL_Related_NBO__c;
            opp.RTL_Related_to_NBO_History__c = true;
            opp.RTL_Oppt_Channel__c = nboHistoryProductItem.RTL_Offering_Channel__c;
            opp.RTL_Campaign_Name__c = nboHistoryProductItem.RTL_Related_NBO__r.RTL_Campaign_Name__c;
            opp.RTL_Campaign_Code__c = nboHistoryProductItem.RTL_Related_NBO__r.RTL_Campaign_Code__c;
            opp.RTL_Campaign_Start_Date__c = nboHistoryProductItem.RTL_Related_NBO__r.RTL_Valid_From__c;
            opp.RTL_Campaign_End_Date__c = nboHistoryProductItem.RTL_Related_NBO__r.RTL_Valid_To__c;
        	RTL_OpportunityService.defaultOpportunityName(new List<Opportunity>{opp});
            opp.Name += ' (NBO)';
          
        if(nboHistoryProductItem.RTL_Product__c != null 
           && nboHistoryProductItem.RTL_Product_Group__c != null 
           && nboHistoryProductItem.RTL_Product_SubGroup__c != null){
            String productKey = toLowerCase(nboHistoryProductItem.RTL_Product__c+nboHistoryProductItem.RTL_Product_Group__c+nboHistoryProductItem.RTL_Product_SubGroup__c);
            if(productMasterMap.containsKey(productKey)){
                opp.RTL_Product_Name__c = productMasterMap.get(productKey).id;                               
            }else{
                productError = true;
                //pageMsgFlag = true;
                return null;
            }
            
        }
        if (nboHistoryProductItem.RTL_Product_Group__c != null && nboHistoryProductItem.RTL_Product_SubGroup__c != null) {
            opp.RTL_Product_Group__c = nboHistoryProductItem.RTL_Product_Group__c;
            opp.RTL_Prod_SubGrp__c = nboHistoryProductItem.RTL_Product_SubGroup__c;
        }
        
        insert  opp;
        return opp;
        
    }
    
    // get  value from custom setting Opportunity_Recordtype_Mapping__c
    public Map<String,Opportunity_Recordtype_Mapping__c> getMapOppRecordType(){
        Map<String,Opportunity_Recordtype_Mapping__c> mapOppRecType = Opportunity_Recordtype_Mapping__c.getAll();
        return mapOppRecType;
    }
    
    public Map<String,RTL_Product_Group_Short_Name__mdt> getProductShortName(){
        Map<String,RTL_Product_Group_Short_Name__mdt> mapProductShortName = new Map<String,RTL_Product_Group_Short_Name__mdt>();
        List<RTL_Product_Group_Short_Name__mdt> productShortNameList = new List<RTL_Product_Group_Short_Name__mdt>([SELECT MasterLabel,RTL_Product_Group__c,RTL_Product_SubGroup__c,RTL_Short_Name__c FROM RTL_Product_Group_Short_Name__mdt]);
        for(RTL_Product_Group_Short_Name__mdt productShortName : productShortNameList){
            mapProductShortName.put(productShortName.MasterLabel, productShortName);
        }
        
        return mapProductShortName;
    }

  
  public PageReference cancel() {
        try{
            PageReference nboPage = new PageReference('/apex/RTL_NBODetailView?p='+nboId);
            nboPage.setRedirect(true);
            return nboPage;
        }catch(Exception e){
            return showErrorMessage(e.getMessage());
            //pageMsgFlag = true;
        }
        return null;
  }
 
    public PageReference saveNBOProduct(){
    	hasError = false;
        Boolean campaignIsActive = false;
        Opportunity oppt = null;
        try{      	

            if(nboProduct.RTL_Status__c == 'Accepted' && nboProduct.RTL_Reject_Reason__c != null){
                return showErrorMessage(System.Label.RTL_NBO_ERR008);
            }           

            if(oldStatus != 'Accepted' && nboProduct.RTL_Status__c == 'Accepted'){
                //check campaign isactive or on hold
                if(nboProduct.RTL_Related_NBO__r.RTL_Campaign__c!= null){
                    campaignIsActive = checkCampaignIsActive(nboProduct.RTL_Related_NBO__r.RTL_Campaign__c,nboProduct.RTL_Related_NBO__r.RTL_TMB_Customer_ID_PE__c);
                    if(campaignIsActive){
                        oppt = createOpportunity(nboProduct);
                    }else{
                        hasError = true;
                        return showErrorMessage(System.Label.RTL_NBO_Campaign_ERR001);
                    }
                }else{
                    oppt = createOpportunity(nboProduct);
                }

            	if (oppt != null) {
            		nboProduct.RTL_Opportunity__c = oppt.id;
            	} else {
        			hasError = true;
        			if (productError)
            			return showErrorMessage(System.Label.RTL_NBO_ERR009);
            		else if (baOpptError)
            			return showErrorMessage(System.Label.RTL_NBO_Oppt_Error);     		
            	}
            }
            
            //Update Region,Zone,Branch and Channel only when status/reject reason change
            if(oldStatus != nboProduct.RTL_Status__c || oldRejectReason != nboProduct.RTL_Reject_Reason__c){
                nboProduct.RTL_User_Region__c = loggedInUser.Region_Code__c;
                nboProduct.RTL_User_Zone__c = loggedInUser.Zone_Code__c;
                nboProduct.RTL_User_Branch__c = loggedInUser.RTL_Branch_Code__c;
                nboProduct.RTL_Offering_Channel__c = loggedInUser.RTL_Channel__c;
                update nboProduct;
            }
            
            
            //PageReference nboPage = new PageReference('/apex/RTL_NBODetailView?p='+nboId);
            //nboPage.setRedirect(true);
            //return nboPage;
            return null;   
        }catch(DMLException e){
            return showErrorMessage(e.getDmlMessage(0));
        }catch(Exception e){
            System.debug('Error Message :: '+e.getMessage());
        	System.debug('There is error during saving NBO Product: ' + e.getStackTraceString());
        	return showErrorMessage(e.getMessage());
        }
        return null;
        
    } 
    
    public static String toLowerCase(String input){
        return input != null ? input.toLowerCase() : null;
    }
    
    public PageReference showErrorMessage(String errMsg){
        hasError = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errMsg));
        return null;
    }

    public static Boolean checkCampaignIsActive (Id campaignId,String tmbCus){
        Boolean isActive = false;

        if(campaignId != null){
            Campaign campaign = [Select id,status,Approvedflag__c,RecordType.DeveloperName from campaign where id=: campaignId];

            if(campaign!= null){
                
                List<CampaignMember> memberlist = [Select RTL_Contact_Status__c,RTL_TMB_Cust_ID__c 
                                                from campaignmember 
                                                where campaignid =: campaign.id];

                //Check Active Campaign
                for(CampaignMember c : memberlist){
                    //check campaign member matching nbo by TMB Customer 
                    if(tmbCus.equalsIgnoreCase(c.RTL_TMB_Cust_ID__c)){
                        isActive = RTL_CampaignMemberUtil.checkActiveCampaign(campaign,c);
                        if(!isActive){
                            break;
                        }
                    }else{
                        isActive = true;
                    }
                }

            }
        }

        return isActive;
    }

}