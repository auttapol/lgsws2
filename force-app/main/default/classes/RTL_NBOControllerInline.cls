public with sharing class RTL_NBOControllerInline extends OscControllerBase {
    
    public Account acct {get;set;}
    public Id acctId;
    public User user {get;set;}
    public Boolean isSF1{get; set;}
    public List<NBOHistory> nbohistoryList  {get;set;}
    public List<NBOHistoryTable> nbohistoryTableList {get;set;} 
    public List<RTL_NBO_History__c> nbohistoryTempList {get;set;} 
    public String[] excludeNBO {get;set;} 
    public Set<String> excludeNBOSet {get;set;}
    public String sortDirection = 'DESC';
    public String sortExp = 'RTL_Valid_To__c';
    public Map<String,RTL_NBO_History_Pagination__c> pageSize {get;set;}
    public List<String> nboSeq {get;set;}
    public Integer pageMaxSize {
    	get {
    		pageMaxSize = Integer.valueOf(pageSize.get('Record Per Page').Page_Max_Size__c);
    		return pageMaxSize;
        }set;}
    public Integer counter{get;set;}
    public Integer totalNBOhis {
        get
        {
            if(totalNBOhis == null){
                totalNBOhis = 0;
            }
        return totalNBOhis;
        }set;}
    
    // NBO service call and response
    private String rmid;
    private String queryString;
    private String queryCondition;
    private String excludeNBOString;
    private AsyncRTL_NextBestOffer.getNextBestOfferResponse_elementFuture asyncRet;
    public Map<RTL_NBOService.NBOHistory, List<RTL_NBOService.NBOHistoryProduct>> mapNBO {get;set;}
    
    public RTL_NBOControllerInline(ApexPages.StandardController stdController){
        
        // acctId = ApexPages.currentPage().getParameters().get('acctId');
        Account acc = (Account)stdController.getRecord();
        acctId = acc.Id;
        system.debug('##acctId : ' +acctId);
        user = [select Id,Name,RTL_Branch_Code__c,Region_Code__c,Zone_Code__c from User where Id =:UserInfo.getUserId()];
        
        //pagination
        counter = 0;
        pageSize = getNBOHistoryPageSize();
        getAccountRMID(acctId);
    }
    
    
    private void getAccountRMID(string acctId) {

        acct = RetailAccountService.GetAccountById(acctId);
        if (null != acct)
        {
            rmid = acct.TMB_Customer_ID_PE__c;
        }
    }
    
    
    public override void CallSOAP(Continuation cont) {  
        isSF1 = Boolean.valueOf(Apexpages.currentPage().getParameters().get('isSf1'));
        cont.continuationMethod = 'processResponseSOAP';
        //async call to webservice SOAP API
        
        AsyncRTL_NextBestOffer.AsyncNextBestOfferSOAP asyncSoap = new AsyncRTL_NextBestOffer.AsyncNextBestOfferSOAP();
        asyncRet = asyncSoap.beginGetNextBestOffer(cont, rmid);
    }
    public Object processResponseSOAP() {
        try {
            //process SOAP API response
            RTL_NextBestOffer.NextBestOffer soapNBO = asyncRet.getValue();
            //keep the NBO sequence from MuleSoft
            nboSeq = getNBOSeq(soapNBO);
            //convert SOAP API response to map
            RTL_NBOService.NBO item = TypeMapper.MappingSoapToNBO(soapNBO);
            if (item != null) {
                if(item.SoapStatus == 'ERROR'){
                    pageMessage = item.SoapMessage;
                    RTL_Utility.InsertErrorTransaction(acct.Name,rmid,UserInfo.getName(),null,pageMessage,acct.Core_Banking_Suggested_Segment__c);
                    return null;
                }
                mapNBO = item.nboMap;
                String insertionErrMsg =  RTL_NBOService.validateNBO(acctId, user, mapNBO);
                //Get the list of inbound external NBO ID first
                Set<String> nboExtIdList = new Set<String>();
                for (RTL_NBOService.NBOHistory nbo : mapNBO.keySet()){
                    nboExtIdList.add(nbo.RTL_NBO_ID);
                }    
                List<RTL_NBO_History__c> nboAndProductTmp = [select RTL_NBO_ID__c, RTL_Campaign_Name__c, RTL_Campaign_Code__c, RTL_NBO_Group__c,
                                                    RTL_NBO_SubGroup__c, RTL_Valid_From__c, RTL_Valid_To__c, 
                                                    RTL_Smart_Info__c, RTL_Contact_Date__c, 
                                                    RTL_Channel__c, 
                                                    RTL_Status__c, 
                                                    RTL_Number_of_Products__c, RTL_Number_of_Invalid_NBO__c
                                                    from RTL_NBO_History__c 
                                                    where RTL_NBO_ID__c in : nboExtIdList and (RTL_valid_to__c = null or RTL_valid_to__c >= TODAY) and RTL_Status__c != : RTL_Utility.NBO_STATUS_INVALID and RTL_Status__c != : RTL_Utility.NBO_STATUS_ACCEPTEDALL and RTL_Customer_Name__c = :acctId];                         	
               if (nboAndProductTmp.size() == 0) {//all NBO are invalid
                    if (insertionErrMsg != '') pageMessage += System.Label.RTL_NBO_ERR007 + '<br/>' + insertionErrMsg;
                    else pageMessage = System.Label.RTL_NBO_ERR007;//Sorry, there is no valid NBO.
                    //return null;
                } else if (insertionErrMsg != '') {
                    pageMessage = insertionErrMsg;
                    //return null;
                }

                //Sort NBO by sequence
                List<RTL_NBO_History__c> nboAndProduct = new List<RTL_NBO_History__c>();
                for (String nboId: nboSeq) {
                	for (RTL_NBO_History__c nbo: nboAndProductTmp){
                		if (nbo.RTL_NBO_ID__c == nboId) nboAndProduct.add(nbo);
                	}
                }
                callRetrieveNBOAndProduct(nboAndProduct);           
                //nbohistoryTempList = null;
            }
        } catch(Exception e) {
            System.debug('There is error during processing fetched NBO: ' + e.getStackTraceString());
            PageMessage = System.Label.ERR002;
            System.debug('Show Error Message '+PageMessage);
            RTL_Utility.InsertErrorTransaction(acct.Name,rmid,UserInfo.getName(),null,e.getTypeName()+' '+e.getMessage()+' '+e.getStackTraceString(),acct.Core_Banking_Suggested_Segment__c);
        }
        System.debug('Show Page Message '+PageMessage);
        return null;
    } 

    public void callRetrieveNBOAndProduct(List<RTL_NBO_History__c> nboAndProduct) {
    	excludeNBO = new List<String>();
        excludeNBOSet = new Set<String>();
    	if (nboAndProduct != null) {
    		for (RTL_NBO_History__c nbo: nboAndProduct) {//do no show fresh NBO in NBO history table
    			excludeNBO.add('\'' + nbo.RTL_NBO_ID__c + '\'');
                excludeNBOSet.add(nbo.RTL_NBO_ID__c);
    		}
			nbohistoryList = getNBOHistory(nboAndProduct);
    	}
        
        //pagination
        counter = 0;
        pageSize = getNBOHistoryPageSize();
        queryNBOHistory();
        nbohistoryTableList = getNBOHistoryTable(); 
    }
    
    public Map<String,RTL_NBO_History_Pagination__c> getNBOHistoryPageSize(){
        Map<String,RTL_NBO_History_Pagination__c> mapPageSize = RTL_NBO_History_Pagination__c.getAll();
        return mapPageSize;
    }
    
    // get NBO from mock data
    public List<NBOHistory> getNBOHistory(List<RTL_NBO_History__c> nboAndProduct){
        List<NBOHistory> nboHistoryAddList = new List<NBOHistory>();
        
        for(RTL_NBO_History__c nboHistory : nboAndProduct){
                        
            NBOHistory nbo = new NBOHistory();
            //into wrapper class
            nbo.nboId = nboHistory.RTL_NBO_ID__c;
            nbo.nboName = nboHistory.RTL_Campaign_Name__c;
            nbo.campaign = nboHistory.RTL_Campaign_Code__c;
            if (nboHistory.RTL_Valid_From__c != null)
            	nbo.validFrom = nboHistory.RTL_Valid_From__c.format();
            else 
            	nbo.validFrom = null;
            if (nboHistory.RTL_Valid_To__c != null)
            	nbo.validTo = nboHistory.RTL_Valid_To__c.format();
            else 
            	nbo.validTo = null;
            nbo.status = nboHistory.RTL_Status__c;
            
            nboHistoryAddList.add(nbo);
        }
        return nboHistoryAddList;
   }
    
    public List<NBOHistoryTable> getNBOHistoryTable(){
        //get NBO History page size 
        List<NBOHistoryTable> nbohistorytableList = new List<NBOHistoryTable>();
        if (nbohistoryTempList != null) { 
	        for(RTL_NBO_History__c  nbohistoryTableItem : nbohistoryTempList){
	            //into wrapper class
	            NBOHistoryTable nbohistoryTable = new NBOHistoryTable();
	            nbohistoryTable.nboId = nbohistoryTableItem.RTL_NBO_ID__c;
	            nbohistoryTable.nboName = nbohistoryTableItem.RTL_Campaign_Name__c;
	            nbohistoryTable.campaign = nbohistoryTableItem.RTL_Campaign_Code__c;
	            if (nbohistoryTableItem.RTL_Valid_From__c != null)
	            	nbohistoryTable.validFrom = nbohistoryTableItem.RTL_Valid_From__c.format();
	            else 
	            	nbohistoryTable.validFrom = null;
	            if (nbohistoryTableItem.RTL_Valid_To__c != null)
	           		nbohistoryTable.validTo = nbohistoryTableItem.RTL_Valid_To__c.format();
	           	else 
	           		nbohistoryTable.validTo = null;
	            nbohistoryTable.status = nbohistoryTableItem.RTL_Status__c;
	            nbohistoryTable.expired = nbohistoryTableItem.RTL_Expired__c;
	            nbohistorytableList.add(nbohistoryTable);
	        }
        }
        
        return  nbohistorytableList;
    }

    //Wrapper class
    public class NBOHistory{
        public string nboId {get;set;}
        public string nboName {get;set;}
        public string campaign {get;set;}
        public string validFrom {get;set;}
        public string validTo {get;set;}
        public string status {get;set;} 
    }
    
    //SF
    public class NBOHistoryTable{
        public string nboId {get;set;}
        public string nboName {get;set;}
        public string campaign {get;set;}
        public string validFrom {get;set;}
        public string validTo {get;set;}
        public string status {get;set;} 
        public boolean expired {get;set;}
    }
    
    public PageReference Previous() { //user clicked previous button
      counter -= pageMaxSize;
      queryNBOHistory();
 	  nbohistoryTableList = getNBOHistoryTable();
      return null;
   }
    
    public PageReference  Next() { //user clicked next button
    	counter += pageMaxSize;
    	queryNBOHistory();
        
        nbohistoryTableList = getNBOHistoryTable(); 
      	return null;
   }
    
    public PageReference First(){
        counter = 0;
        queryNBOHistory();
        
        nbohistoryTableList = getNBOHistoryTable(); 
        return null;
    }
    
    public PageReference Last(){
        Decimal page = ((Decimal)totalNBOhis/(Decimal)pageMaxSize);
        Integer LastPage = Integer.ValueOf(page.round(System.RoundingMode.CEILING));
        counter = (LastPage-1) * pageMaxSize;
        queryNBOHistory();
        
        nbohistoryTableList = getNBOHistoryTable(); 
        return null;
    }
    
    
    
    public boolean  getDisableNext() { //user clicked next button
      
        if((counter + pageMaxSize) >= totalNBOhis) {
            return true;
        }else{
            return false;
        }
   }
    
    public boolean  getDisablePrevious() { //user clicked next button
      
        if(counter == 0) {
            return true;
        }else{
            return false;
        }
   }
    
    //sorting table
    public String sortExpression
    {
        get 
        {
            return sortExp;
        } 
        set
        {
            if (value == sortExp){
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            }
            
            else{
                sortDirection = 'ASC';
            }
            
            sortExp = value;
        }
    }

    public String getSortDirection()
    {
        if (sortExpression == null || sortExpression == ''){
            return 'ASC';
        }
        
        else{
            return sortDirection;
        }
        
    }
             
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
     
    public PageReference  ViewData() {
       	queryNBOHistory();   	
		nbohistoryTableList = getNBOHistoryTable(); 
	 	return null;
      
   }
   
	public List<String> getNBOSeq(RTL_NextBestOffer.NextBestOffer item)
	{
		List<String> nboSeq = new List<String>();
		
		if(item.NextBestOfferDetails != null && item.NextBestOfferDetails.NextBestOfferDetail != null) {
			for (RTL_NextBestOffer.NextBestOfferDetail dN : item.NextBestOfferDetails.NextBestOfferDetail) {
				nboSeq.add(dN.NboId);
			}
		}
		return nboSeq;
	}
    
    public void queryNBOHistory(){
       queryString = 'SELECT Id,RTL_NBO_ID__c,RTL_Campaign_Name__c,RTL_Campaign_Code__c,RTL_Valid_From__c,RTL_Valid_To__c,'+ 
            				'RTL_Status__c,RTL_Channel__c,RTL_Expired__c FROM RTL_NBO_History__c WHERE RTL_Status__c != \'' + 
            				RTL_Utility.NBO_STATUS_INVALID + '\' '+
            				' AND RTL_Customer_Name__c =\''+acctId+'\' ';
        excludeNBOString = ' AND RTL_NBO_ID__c NOT IN ' + excludeNBO;
        queryCondition = ' ORDER BY '+sortExpression+ ' '+sortDirection+
            			 ' LIMIT '+pageMaxSize+' OFFSET '+counter;
       if (excludeNBO != null && excludeNBO.size() > 0){
           System.debug('Query String :::: '+queryString+excludeNBOString+queryCondition);
           nbohistoryTempList = Database.query(queryString+excludeNBOString+queryCondition);
           System.debug('Temp List ::::: '+nbohistoryTempList);
           totalNBOhis = [SELECT count() FROM RTL_NBO_History__c WHERE RTL_Status__c != :RTL_Utility.NBO_STATUS_INVALID and RTL_Customer_Name__c =:acctId and RTL_NBO_ID__c not in :excludeNBOSet]; 
       }
       else{
           System.debug('Query String :::: '+queryString+queryCondition);
           nbohistoryTempList = Database.query(queryString+queryCondition);
           System.debug('Temp List ::::: '+nbohistoryTempList);
           totalNBOhis = [SELECT count() FROM RTL_NBO_History__c WHERE RTL_Status__c != :RTL_Utility.NBO_STATUS_INVALID and RTL_Customer_Name__c =:acctId]; 
       }
       System.debug('TOTAL NBO HISTORY ::: '+totalNBOHis);
       
        
    }
	
	public void refreshNBOFromDB() {	
		try {
			List<RTL_NBO_History__c> nboAndProductTmp = new List<RTL_NBO_History__c>();
			List<RTL_NBO_History__c> nboAndProduct = new List<RTL_NBO_History__c>();
			if (excludeNBO != null && excludeNBO.size() > 0)
	       		nboAndProductTmp = Database.query('select RTL_NBO_ID__c, RTL_Campaign_Name__c, RTL_Campaign_Code__c, RTL_Valid_From__c, RTL_Valid_To__c, RTL_Status__c from RTL_NBO_History__c WHERE (RTL_valid_to__c = null or RTL_valid_to__c >= TODAY) and RTL_Status__c != \'' + RTL_Utility.NBO_STATUS_INVALID + '\' and RTL_Status__c != \'' + RTL_Utility.NBO_STATUS_ACCEPTEDALL + '\' and RTL_NBO_ID__c in ' + excludeNBO + ' and RTL_Customer_Name__c =\''+acctId + '\'');
	       	if (nboAndProductTmp.size() == 0) {//all NBO are invalid
	            pageMessage = System.Label.RTL_NBO_ERR007;//Sorry, there is no valid NBO.
	        } else {
		        //Sort NBO by sequence
		        if (nboSeq != null) {
			        for (String nboId: nboSeq) {
			        	for (RTL_NBO_History__c nbo: nboAndProductTmp){
			        		if (nbo.RTL_NBO_ID__c == nboId) nboAndProduct.add(nbo);
			        	}
			        }
		        }
	       	}
	       	callRetrieveNBOAndProduct(nboAndProduct);    
        } catch(Exception e) {
            System.debug('There is error during refreshing NBO from DB: ' + e.getStackTraceString());
            PageMessage = System.Label.ERR002;
            RTL_Utility.InsertErrorTransaction(acct.Name,rmid,UserInfo.getName(),null,e.getTypeName()+' '+e.getMessage()+' '+e.getStackTraceString(),acct.Core_Banking_Suggested_Segment__c);
        }	                                                     		
	} 
	
	public PageReference doNothing() {
		//this method is just used for UI alignment
		return null;
	}
}