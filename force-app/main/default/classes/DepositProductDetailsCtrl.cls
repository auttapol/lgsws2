public class DepositProductDetailsCtrl extends OscControllerBase {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Controller of DepositProductDetailsView.page
	  Inputs:        
	  1. Account Number
	  2. Deposit Product Code => It is used to derive the Product Name from ProductHierarchy.
	  Base Class:    -
	  Test Class:    TestDepositProductDetailsCtrl.cls
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  2016-04-25   Keattisak.C        First Draft
	  ----------------------------------------------------------------------------------*/

	private String rmid; /* crmid  */
	public String acctno; /* account no   */
	public String dpprotype; /* product Type */	
    private String projectcode; /*Project Code*/
    private String datasource; /*Data Source*/
    private String fiident; /*Fiident*/
    public Boolean isEmployee {get;set;}/*is Employee*/
	public ViewState ViewState { get; set; }
	AsyncRTL_DepositProductDetailsService.getProductDetailsResponse_elementFuture asyncRet;
	public Account acct { get; set; }
	Datetime startReq;
	public DepositProductDetailsCtrl() {
		params = ApexPages.currentPage().getParameters();
		string p = params.get('p');
		System.debug('TMB: -> p is :' + p);
		p = p.replace(' ', '+');
		string dc = UrlHelper.decryptParams(p);
		System.debug('TMB: -> dc is :' + dc);
        
        projectcode = '';
        datasource = '';

		List<String> arrParams = dc.split('&');

		if (null != arrParams && arrParams.size() >= 3)
		{
			acctno = arrParams[0];
			dpprotype = arrParams[1];
			/*isEmployee = Boolean.ValueOf(arrParams[2]);
            if(arrParams.size() > 3)
            	projectcode = arrParams[3];
            if(arrParams.size() > 4)
            	datasource = arrParams[4];*/
            //2nd drop	
            rmid = arrParams[2];
            isEmployee = Boolean.ValueOf(arrParams[3]);
            fiident = arrParams[4];
            /*if(arrParams.size() > 4)
            	projectcode = arrParams[4];
            if(arrParams.size() > 5)
            	datasource = arrParams[5];*/
            
            if(arrParams.size() > 5)
            	projectcode = arrParams[5];
            if(arrParams.size() > 6)
            	datasource = arrParams[6];
		}


		System.debug('TMB: -> acctno is :' + acctno);
		System.debug('TMB: -> dpcode is :' + dpprotype);
		ViewState = new ViewState();
		// Get Retail Product Master
		//ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
   		ViewState.isEmployee = isEmployee;
		acct = getAcct(rmid);
	}

	public Account getAcct(String TMB_CUST_ID){
		try{
			return [SELECT Id FROM Account WHERE TMB_Customer_ID_PE__c =: TMB_CUST_ID LIMIT 1];
		}
		catch(Exception e){
			System.debug('System Error : ' + e.getMessage());
		}
		return null;
	}

	public string getRMID() {
		return rmid;
	}	
	
	public override void CallSOAP(Continuation cont) {
		startReq = Datetime.now();
		cont.continuationMethod = 'processResponseSOAP';
		AsyncRTL_DepositProductDetailsService.AsyncDepositProductDetailsSOAP asynSvr = new AsyncRTL_DepositProductDetailsService.AsyncDepositProductDetailsSOAP();
		//asyncRet = asynSvr.beginGetProductDetails(cont, /*accountNumber'2471779484'*/ acctno, /*productType'com.fnf.xes.IM'*/ dpprotype);
		asyncRet = asynSvr.beginGetProductDetails(cont, /*accountNumber'2471779484'*/ acctno, /*productType'com.fnf.xes.IM'*/ dpprotype,rmid,fiident);
        System.debug('request :: '+asynSvr);
        System.debug('request :: '+asyncRet);
	}

	public Object processResponseSOAP() {
		
		try
		{
			RTL_DepositProductDetailsService.getProductDetails_element requestDepositDetail = new RTL_DepositProductDetailsService.getProductDetails_element();
			requestDepositDetail.accountNumber = acctno;
			requestDepositDetail.productType = dpprotype;
			requestDepositDetail.CustomerRMID = rmid;
			requestDepositDetail.FIIdent = fiident;

			RTL_DepositProductDetailsService.DepositProductDetails soapDepositProductDetails = asyncRet.getValue();
			DepositeProductDetailDTO item = ((DepositeProductDetailDTO) TypeMapper.MappingSoapToDTO(soapDepositProductDetails));
            System.debug('return value :: '+soapDepositProductDetails);
            if(item.SoapStatus == 'ERROR'){
            	pageMessage = item.SoapMessage;
                // CR203 Product holding - 20181214
				RTL_CampaignUtil.insertOnlineLogWithResponse(   '',
																ViewState.ErrorMessages, 
																rmid, 
																'Deposit Detail', 
																acct.Id, 
																JSON.serialize(requestDepositDetail),
																JSON.serialize(soapDepositProductDetails),																
																startReq,
																Datetime.now() 
																);
				// return null;
            }
			else
			{
				// CR203 Product holding - 20181214
				RTL_CampaignUtil.insertOnlineLogWithResponse(   '',
																ViewState.ErrorMessages, 
																rmid, 
																'Deposit Detail', 
																acct.Id, 
																JSON.serialize(requestDepositDetail), 
																JSON.serialize(soapDepositProductDetails), 																
																startReq,
																Datetime.now() 
																);
			}
            ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
            ViewState.DepositeProductDetail = item;
			ViewState.TransformDataDeposit(acctno,projectcode,datasource);
			return null;
		}
		catch(Exception e)
		{
			PageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
		}
		return null;
	}


	public class ViewState {
		public DepositeProductDetailDTO DepositeProductDetail { get; set; }
		public Map<string /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode { get; set; }
        private Boolean isEmployee;
		public String ErrorMessages { get; set; }
		public ViewState() {
			DepositeProductDetail = new DepositeProductDetailDTO();
			ErrorMessages = '';
		}
		/* Private Method */
		public void TransformDataDeposit(String acctno,String projectcode,String datasource) {

            //initiate product code to productcode+projectcode+datasource
            string productcode = DepositeProductDetail.DepositProductCode+projectcode+datasource;
            
            //use account number from service1 instead
            DepositeProductDetail.DepositAccountNumber = acctno;
			DepositeProductDetail.isEmployee = isEmployee;

			// Transform Deposit
            if(DepositeProductDetail.SoapStatus == 'ERROR'){
                // isDepositError = true;
                ErrorMessages +='DEPOSIT PRODUCT DETAILS\n';
                ErrorMessages +='Status : '+DepositeProductDetail.SoapStatus+'\n';
                ErrorMessages +='Message : '+DepositeProductDetail.SoapMessage+'\n\n';
            }
			else if (OnlyProductWithProductCode.containsKey(productcode))
			{
				// Found Product code in RTL Product Master
				DepositeProductDetail.ProductName = OnlyProductWithProductCode.get(productcode).Name;
				DepositeProductDetail.SubProductGroup = OnlyProductWithProductCode.get(productcode).Product_Sub_group;
			}
			else {
				DepositeProductDetail.DepositProductCode = 'error';
				DepositeProductDetail.ProductName = '#N/A';
				DepositeProductDetail.SubProductGroup = '#N/A';
			}
		}
	}
    
    
}