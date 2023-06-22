public class LoanProductDetailsCtrl  extends OscControllerBase {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Controller of CreditCardDetailsView.page
	  Inputs:        
	  1. Card Number
	  2. Credit Card Type
	  Base Class:    -
	  Test Class:    TestCreditCardDetailsCtrl.cls
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  2016-04-18   Keattisak.C        First Draft
	  ----------------------------------------------------------------------------------*/
	private String loanacctno; /*  Card Number  */
	private String prdtype; /* Product Type  */
    private String fiident; /*Fiident from OSC01*/
    private String status; /*Loan Status from OSC01*/
    private String projectcode; /*Project Code*/
    private String datasource; /*Data Source*/
	public ViewState ViewState { get; set; }	
	private AsyncRTL_LoanProductDetailsService.getLoanProductDetailsResponse_elementFuture asyncRet;

	public LoanProductDetailsCtrl()
	{
		// Input
		params = ApexPages.currentPage().getParameters();

		string p = params.get('p');
		System.debug('TMB: -> p is :' + p);
		p = p.replace(' ', '+');
		string dc = UrlHelper.decryptParams(p);
		System.debug('TMB: -> dc is :' + dc);

		List<String> arrParams = dc.split('&');
        
        projectcode = '';
        datasource = '';
        System.debug('Params '+arrParams);


		if (null != arrParams && arrParams.size() >= 3)
		{
			loanacctno = arrParams[0];
			prdtype = arrParams[1];
            fiident = arrParams[2];
            status = arrParams[3];
            
            if(arrParams.size() > 4)
            	projectcode = arrParams[4];
            if(arrParams.size() > 5)
            	datasource = arrParams[5];
            
            /*if(arrParams.size() > 2)
            	projectcode = arrParams[2];
            if(arrParams.size() > 3)
            	datasource = arrParams[3];*/
		}		
		System.debug('TMB: -> loanacctno is :' + loanacctno);
		System.debug('TMB: -> prdtype is :' + prdtype);
		ViewState = new ViewState();
		// Get Retail Product Master
		//ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();

	}

	public override void CallSOAP(Continuation cont) {
		cont.continuationMethod = 'processResponseSOAP';
		AsyncRTL_LoanProductDetailsService.AsyncLoanProductDetailsSOAP asynSvr = new AsyncRTL_LoanProductDetailsService.AsyncLoanProductDetailsSOAP();
		asyncRet = asynSvr.beginGetLoanProductDetails(cont, /* accountNumber'00016080681007' */ loanacctno, /*'com.fnf.xes.AM' productType */ prdtype,fiident); // fix,String 
	}
	public Object processResponseSOAP() {
		try
		{
			RTL_LoanProductDetailsService.LoanProductDetails soapLoanProductDetails = asyncRet.getValue();
			LoanProductDetailDTO item = ((LoanProductDetailDTO) TypeMapper.MappingSoapToDTO(soapLoanProductDetails));
			if (item != null)
			{
                if(item.SoapStatus == 'ERROR'){
            		pageMessage = item.SoapMessage;
                	return null;
            	}
                ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
				ViewState.LoanProductDetail = item;
                ViewState.LoanProductDetail.AccountStatus = status;
				ViewState.TransformDataDeposit(loanacctno,projectcode,datasource);

			}

		}
		catch(Exception e)
		{

			PageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
		}
		return null;
	}

	public class ViewState {
		public LoanProductDetailDTO LoanProductDetail { get; set; }
		public Map<string /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode { get; set; }

		public ViewState() {
			LoanProductDetail = new LoanProductDetailDTO();
		}
		/* Private Method */
		public void TransformDataDeposit(String loanacctno,String projectcode,String datasource) {
            // initiate 
            string productcode = LoanProductDetail.LoanProductCode+projectcode+datasource;
            // use loan account number from service1 instead
            LoanProductDetail.LoanAccountNumber = loanacctno;
            
            System.debug('loanproductcode :'+productcode);
			// Transform Deposit
			if (OnlyProductWithProductCode.containsKey(productcode))
			{
				// Found Product code in RTL Product Master
				LoanProductDetail.ProductName = OnlyProductWithProductCode.get(productcode).Name;
				LoanProductDetail.SubProductGroup = OnlyProductWithProductCode.get(productcode).Product_Sub_group;
			}
			else {
				LoanProductDetail.LoanProductCode = 'error';
				LoanProductDetail.ProductName = '#N/A';
				LoanProductDetail.SubProductGroup = '#N/A';
			}
		}

	}
}